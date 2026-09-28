import 'dart:async';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show decodeHex, encodeHex;
import 'package:polkadart_keyring/polkadart_keyring.dart';

import '../generated/era/era.dart' as era_api;
import '../generated/era/types/era_runtime/runtime_call.dart' as runtime_call;
import '../generated/era/types/pallet_ai_predictions/pallet/error.dart'
    as ai_error;
import '../generated/era/types/sp_runtime/dispatch_error.dart'
    as dispatch_error;
import 'transaction_lifecycle.dart';
import 'runtime_compatibility.dart';

const Set<String> phase6bParticipantTransactionCalls = {
  'stake_on_prediction_outcome_side',
  'unstake_from_prediction_outcome_side',
  'claim_prediction_market_payout',
};

const Set<String> phase6bGovernanceTransactionCalls = {
  'approve_model',
  'suspend_model',
  'reject_model',
  'set_model_submitter',
  'admin_finalize_prediction_outcome',
};

void requirePhase6bCallEnabledForBuild(TransactionIntent intent) {
  if (intent.pallet != 'AiPredictions') return;
  if (!enablePhase6bTestingTools &&
      !phase6bParticipantTransactionCalls.contains(intent.call)) {
    throw StateError(
      'This production participant build cannot submit ${intent.call}.',
    );
  }
  if (!enablePhase6bGovernanceActions &&
      phase6bGovernanceTransactionCalls.contains(intent.call)) {
    throw StateError(
      'Governance transaction paths are disabled in this build.',
    );
  }
}

typedef RuntimeSigningCheck = Future<EraSigningContext> Function();
typedef TransactionAuthenticator = Future<bool> Function();
typedef TransactionBeforeSubmit =
    Future<void> Function(TransactionLifecycleRecord submittingRecord);
typedef TransactionRecordListener =
    void Function(TransactionLifecycleRecord record);

class SignedEraExtrinsic {
  final Uint8List bytes;
  final BigInt nonce;
  final BigInt mortalityReferenceBlock;
  final int mortalityPeriod;

  const SignedEraExtrinsic({
    required this.bytes,
    required this.nonce,
    required this.mortalityReferenceBlock,
    required this.mortalityPeriod,
  });
}

class EraSigningContext {
  final String genesisHash;
  final int specVersion;
  final int transactionVersion;
  final String metadataHash;
  final String runtimeWasmHash;
  final int aiStorageVersion;

  const EraSigningContext({
    required this.genesisHash,
    required this.specVersion,
    required this.transactionVersion,
    required this.metadataHash,
    required this.runtimeWasmHash,
    required this.aiStorageVersion,
  });
}

class Phase6bTransactionJournal {
  static const storageKey = 'phase6b_transaction_lifecycle_v1';
  static const maximumRecords = 100;
  static Future<void> _serializedOperations = Future<void>.value();

  final FlutterSecureStorage storage;
  final TransactionLifecycleCodec codec;

  const Phase6bTransactionJournal({
    required this.storage,
    this.codec = const TransactionLifecycleCodec(),
  });

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _serializedOperations = _serializedOperations
        .catchError((Object _) {})
        .then((_) async {
          try {
            completer.complete(await operation());
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          }
        });
    return completer.future;
  }

  Future<List<TransactionLifecycleRecord>> load() => _serialized(_loadUnlocked);

  Future<List<TransactionLifecycleRecord>> _loadUnlocked() async {
    final encoded = await storage.read(key: storageKey);
    if (encoded == null || encoded.isEmpty) return const [];
    try {
      return codec.decode(encoded);
    } on Object catch (error) {
      // A corrupt or newer journal may contain an unresolved submission. Do
      // not turn it into an empty journal and silently release duplicate
      // protection.
      throw Phase6bTransactionJournalException(
        'The transaction journal could not be decoded safely.',
        error,
      );
    }
  }

  Future<void> upsert(TransactionLifecycleRecord record) =>
      _serialized(() => _upsertUnlocked(record));

  Future<void> _upsertUnlocked(TransactionLifecycleRecord record) async {
    final records = await _loadUnlocked();
    final byId = {for (final item in records) item.id: item};
    byId[record.id] = record;
    final sorted = byId.values.toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final unresolved = sorted
        .where((item) => item.protectsAgainstDuplicate)
        .toList(growable: false);
    if (unresolved.length > maximumRecords) {
      throw const Phase6bTransactionJournalException(
        'The journal contains too many unresolved transactions to retain '
        'safely.',
      );
    }
    final retained = <TransactionLifecycleRecord>[
      ...unresolved,
      ...sorted
          .where((item) => !item.protectsAgainstDuplicate)
          .take(maximumRecords - unresolved.length),
    ]..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    await storage.write(key: storageKey, value: codec.encode(retained));
  }

  Future<List<TransactionLifecycleRecord>> prepareStartupReconciliation() =>
      _serialized(_prepareStartupReconciliationUnlocked);

  Future<List<TransactionLifecycleRecord>>
  _prepareStartupReconciliationUnlocked() async {
    final records = await _loadUnlocked();
    const policy = StartupReconciliationPolicy();
    final prepared = records
        .where(
          (record) =>
              policy.actionFor(record) !=
              StartupReconciliationAction.discardUnsignedDraft,
        )
        .map(policy.prepareForStartup)
        .toList();
    await storage.write(key: storageKey, value: codec.encode(prepared));
    return policy.recordsRequiringChainVerification(prepared);
  }
}

class Phase6bTransactionJournalException implements Exception {
  final String message;
  final Object? cause;

  const Phase6bTransactionJournalException(this.message, [this.cause]);

  @override
  String toString() => message;
}

class EraExtrinsicSigner {
  final polkadart.Provider provider;
  final era_api.Era api;

  const EraExtrinsicSigner({required this.provider, required this.api});

  Future<SignedEraExtrinsic> sign({
    required String mnemonic,
    required runtime_call.RuntimeCall call,
    required EraSigningContext expectedContext,
    required String expectedSignerAddress,
  }) async {
    final finalizedHeadResponse = await provider.send(
      'chain_getFinalizedHead',
      const [],
    );
    if (finalizedHeadResponse.error != null ||
        finalizedHeadResponse.result is! String) {
      throw StateError(
        'The finalized head could not be rechecked immediately before '
        'signing. Nothing was signed.',
      );
    }
    final finalizedHash = finalizedHeadResponse.result! as String;
    final runtimeVersionResponse = await provider.send(
      'state_getRuntimeVersion',
      [finalizedHash],
    );
    final metadataResponse = await provider.send('state_getMetadata', [
      finalizedHash,
    ]);
    final runtimeCodeResponse = await provider.send('state_getStorage', [
      '0x3a636f6465',
      finalizedHash,
    ]);
    final aiStorageVersionResponse = await provider.send('state_getStorage', [
      '0x507d4f0bb08b9e2c877acf6d401c17174e7b9012096b41c4eb3aaf947f6ea429',
      finalizedHash,
    ]);
    if (runtimeVersionResponse.error != null ||
        runtimeVersionResponse.result is! Map) {
      throw StateError(
        'Runtime version could not be rechecked immediately before signing. '
        'Nothing was signed.',
      );
    }
    final runtimeVersion = runtimeVersionResponse.result! as Map;
    final specVersion = _rpcInt(runtimeVersion['specVersion']);
    final transactionVersion = _rpcInt(runtimeVersion['transactionVersion']);
    if (metadataResponse.error != null || metadataResponse.result is! String) {
      throw StateError(
        'Metadata could not be rechecked immediately before signing. Nothing '
        'was signed.',
      );
    }
    final metadataHash = await _sha256Hex(
      _rpcHex(metadataResponse.result! as String),
    );
    if (runtimeCodeResponse.error != null ||
        runtimeCodeResponse.result is! String) {
      throw StateError(
        'Runtime code could not be rechecked immediately before signing. '
        'Nothing was signed.',
      );
    }
    final runtimeWasmHash = await _sha256Hex(
      _rpcHex(runtimeCodeResponse.result! as String),
    );
    final aiStorageVersion = _storageVersion(aiStorageVersionResponse);
    if (aiStorageVersion == null) {
      throw StateError(
        'AI Predictions storage version could not be rechecked immediately '
        'before signing. Nothing was signed.',
      );
    }
    final finalizedHashBytes = _rpcHex(finalizedHash);
    final currentBlockNumber = await api.query.system.number(
      at: finalizedHashBytes,
    );
    final genesisHash = await api.query.system.blockHash(0);
    final observedGenesis = '0x${encodeHex(genesisHash)}';
    if (_normalizeHash(observedGenesis) !=
            _normalizeHash(expectedContext.genesisHash) ||
        specVersion != expectedContext.specVersion ||
        transactionVersion != expectedContext.transactionVersion ||
        _normalizeHash(metadataHash) !=
            _normalizeHash(expectedContext.metadataHash) ||
        _normalizeHash(runtimeWasmHash) !=
            _normalizeHash(expectedContext.runtimeWasmHash) ||
        aiStorageVersion != expectedContext.aiStorageVersion) {
      throw StateError(
        'Runtime identity changed after the compatibility check. Nothing was '
        'signed.',
      );
    }
    final currentBlockHash = finalizedHashBytes;
    final wallet = await Keyring().fromMnemonic(mnemonic.trim());
    if (wallet.address != expectedSignerAddress.trim()) {
      throw StateError(
        'Stored signing material does not match the selected account. Nothing '
        'was signed.',
      );
    }
    final nonce = await api.rpc.system.accountNextIndex(wallet.address);
    final encodedCall = call.encode();
    final payload = polkadart.SigningPayload(
      method: encodedCall,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      genesisHash: encodeHex(genesisHash),
      blockHash: encodeHex(currentBlockHash),
      blockNumber: currentBlockNumber,
      eraPeriod: 64,
      nonce: nonce,
      tip: 0,
    ).encode(api.registry);
    final signature = wallet.sign(payload);
    final bytes = polkadart.ExtrinsicPayload(
      signer: wallet.bytes(),
      method: encodedCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: currentBlockNumber,
      nonce: nonce,
      tip: 0,
    ).encode(api.registry, polkadart.SignatureType.sr25519);
    return SignedEraExtrinsic(
      bytes: Uint8List.fromList(bytes),
      nonce: BigInt.from(nonce),
      mortalityReferenceBlock: BigInt.from(currentBlockNumber),
      mortalityPeriod: 64,
    );
  }

  Future<BigInt?> estimateFee(SignedEraExtrinsic extrinsic) async {
    final response = await provider.send('payment_queryInfo', [
      '0x${encodeHex(extrinsic.bytes)}',
    ]);
    if (response.error != null || response.result is! Map) return null;
    final value = (response.result! as Map)['partialFee'];
    if (value == null) return null;
    final text = value.toString();
    return text.startsWith('0x')
        ? BigInt.tryParse(text.substring(2), radix: 16)
        : BigInt.tryParse(text);
  }
}

class Phase6bTransactionRunner {
  static final Set<String> _processActiveIntents = <String>{};

  final polkadart.Provider provider;
  final era_api.Era api;
  final Phase6bTransactionJournal journal;
  final DuplicateSubmissionGuard duplicateGuard;
  final Duration confirmationTimeout;

  Phase6bTransactionRunner({
    required this.provider,
    required this.api,
    required this.journal,
    DuplicateSubmissionGuard? duplicateGuard,
    this.confirmationTimeout = const Duration(minutes: 3),
  }) : duplicateGuard = duplicateGuard ?? DuplicateSubmissionGuard() {
    if (confirmationTimeout <= Duration.zero) {
      throw ArgumentError.value(
        confirmationTimeout,
        'confirmationTimeout',
        'Must be positive.',
      );
    }
  }

  /// Rehydrates unresolved intent locks before accepting a fresh submission.
  /// This preserves duplicate protection across process restarts.
  Future<void> hydrateDuplicateGuard() async {
    duplicateGuard.restore(await journal.load());
  }

  Future<TransactionLifecycleRecord> submit({
    required TransactionIntent intent,
    required RuntimeSigningCheck recheckRuntime,
    required TransactionAuthenticator authenticate,
    required Future<SignedEraExtrinsic> Function(
      EraSigningContext signingContext,
    )
    sign,
    TransactionPostStateVerifier? verifyPostState,
    bool requirePostStateVerification = false,
    TransactionBeforeSubmit? beforeSubmit,
    TransactionRecordListener? onUpdate,
  }) async {
    requirePhase6bCallEnabledForBuild(intent);
    if (_processActiveIntents.isNotEmpty ||
        !_processActiveIntents.add(intent.key)) {
      throw DuplicateSubmissionException(intent.key);
    }
    try {
      if (requirePostStateVerification && verifyPostState == null) {
        throw ArgumentError(
          'Actions requiring canonical post-state need a verifier.',
        );
      }
      var record = TransactionLifecycleRecord.preparing(
        intent: intent,
        createdAt: DateTime.now().toUtc(),
        requiresPostStateVerification: requirePostStateVerification,
      );
      duplicateGuard.register(record);

      Future<void> update(TransactionLifecycleRecord next) async {
        // Durable state is authoritative. Do not publish a transition or
        // release duplicate protection until secure storage accepted it.
        await journal.upsert(next);
        record = next;
        duplicateGuard.update(record);
        onUpdate?.call(record);
      }

      await update(
        record.transitionTo(TransactionLifecycleState.awaitingAuthentication),
      );
      late final bool authenticated;
      try {
        authenticated = await authenticate();
      } catch (_) {
        await update(record.transitionTo(TransactionLifecycleState.failed));
        rethrow;
      }
      if (!authenticated) {
        await update(record.transitionTo(TransactionLifecycleState.failed));
        return record;
      }

      // This is deliberately immediate before signing, after authentication.
      late final EraSigningContext signingContext;
      try {
        signingContext = await recheckRuntime();
      } catch (_) {
        await update(record.transitionTo(TransactionLifecycleState.failed));
        rethrow;
      }
      await update(record.transitionTo(TransactionLifecycleState.signing));
      late final SignedEraExtrinsic signed;
      try {
        signed = await sign(signingContext);
      } catch (_) {
        await update(record.transitionTo(TransactionLifecycleState.failed));
        rethrow;
      }
      final txHash =
          '0x${encodeHex(polkadart.Hasher.blake2b256.hash(signed.bytes))}';
      final submittedAt = DateTime.now().toUtc();
      final submittingRecord = record.transitionTo(
        TransactionLifecycleState.submitting,
        nonce: signed.nonce,
        genesisHash: signingContext.genesisHash,
        mortalityReferenceBlock: signed.mortalityReferenceBlock,
        mortalityPeriod: signed.mortalityPeriod,
        txHash: txHash,
        submittedAt: submittedAt,
      );
      try {
        await beforeSubmit?.call(submittingRecord);
      } catch (_) {
        await update(record.transitionTo(TransactionLifecycleState.failed));
        rethrow;
      }
      await update(submittingRecord);

      final terminal = Completer<TransactionLifecycleRecord>();
      StreamSubscription<polkadart.ExtrinsicStatus>? subscription;
      var serial = Future<void>.value();
      var closing = false;
      final deadline = DateTime.now().toUtc().add(confirmationTimeout);

      void cancelSubscription() {
        final current = subscription;
        if (current == null) return;
        unawaited(current.cancel().catchError((Object _) {}));
      }

      Future<void> ensureSubmitted() async {
        if (record.state == TransactionLifecycleState.submitting) {
          await update(
            record.transitionTo(
              TransactionLifecycleState.submitted,
              txHash: txHash,
              submittedAt: submittedAt,
            ),
          );
        }
      }

      Future<void> handle(polkadart.ExtrinsicStatus status) async {
        if (closing || terminal.isCompleted) return;
        final type = status.type.toLowerCase();
        if (type == 'ready' || type == 'broadcast') return;
        await ensureSubmitted();
        if (closing || terminal.isCompleted) return;
        if (type == 'inblock') {
          final evidence = await _evidenceAt(
            status.value.toString(),
            txHash: txHash,
            encodedExtrinsic: signed.bytes,
            deadline: deadline,
          );
          if (closing || terminal.isCompleted) return;
          if (!evidence.found) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.unknownNeedsVerification,
              ),
            );
            closing = true;
            terminal.complete(record);
            cancelSubscription();
            return;
          }
          if (record.state == TransactionLifecycleState.submitted) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.inBlock,
                inclusionBlock: evidence.block,
                relevantEvents: evidence.events,
              ),
            );
          }
          return;
        }
        if (type == 'finalized') {
          final evidence = await _evidenceAt(
            status.value.toString(),
            txHash: txHash,
            encodedExtrinsic: signed.bytes,
            deadline: deadline,
          );
          if (closing || terminal.isCompleted) return;
          if (!evidence.found) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.unknownNeedsVerification,
              ),
            );
            closing = true;
            terminal.complete(record);
            cancelSubscription();
            return;
          }
          if (record.state == TransactionLifecycleState.submitted) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.finalized,
                inclusionBlock: evidence.block,
                finalityBlock: evidence.block,
                relevantEvents: evidence.events,
                dispatchResult: evidence.dispatch,
                decodedModuleError:
                    evidence.dispatch.effectiveError?.moduleError,
              ),
            );
          } else if (record.state == TransactionLifecycleState.inBlock) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.finalized,
                finalityBlock: evidence.block,
                relevantEvents: evidence.events,
                dispatchResult: evidence.dispatch,
                decodedModuleError:
                    evidence.dispatch.effectiveError?.moduleError,
              ),
            );
          }

          if (evidence.dispatch.status == DispatchResultStatus.failure) {
            await update(record.transitionTo(TransactionLifecycleState.failed));
          } else if (evidence.dispatch.status == DispatchResultStatus.unknown) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.unknownNeedsVerification,
              ),
            );
          } else {
            await update(
              await const TransactionFinalizationPolicy()
                  .resolveSuccessfulDispatch(
                    record,
                    verifyPostState: verifyPostState == null
                        ? null
                        : (finalized) => _boundedRpc(
                            verifyPostState(finalized),
                            deadline: deadline,
                          ),
                  ),
            );
          }
          closing = true;
          terminal.complete(record);
          cancelSubscription();
          return;
        }
        if (type == 'invalid') {
          await update(record.transitionTo(TransactionLifecycleState.failed));
          closing = true;
          terminal.complete(record);
          cancelSubscription();
          return;
        }
        if (const {
          'dropped',
          'usurped',
          'retracted',
          'finalitytimeout',
        }.contains(type)) {
          await update(
            record.transitionTo(
              TransactionLifecycleState.unknownNeedsVerification,
            ),
          );
          closing = true;
          terminal.complete(record);
          cancelSubscription();
        }
      }

      Future<void> handleStatusError(Object _, StackTrace _) async {
        if (terminal.isCompleted) return;
        closing = true;
        try {
          await ensureSubmitted();
          if (const {
            TransactionLifecycleState.submitted,
            TransactionLifecycleState.inBlock,
            TransactionLifecycleState.finalized,
          }.contains(record.state)) {
            await update(
              record.transitionTo(
                TransactionLifecycleState.unknownNeedsVerification,
              ),
            );
          }
          terminal.complete(record);
        } catch (recoveryError, recoveryStackTrace) {
          terminal.completeError(recoveryError, recoveryStackTrace);
        } finally {
          cancelSubscription();
        }
      }

      Future<StreamSubscription<polkadart.ExtrinsicStatus>>? watchSubscription;
      try {
        watchSubscription = polkadart.AuthorApi(provider)
            .submitAndWatchExtrinsic(signed.bytes, (status) {
              if (closing || terminal.isCompleted) return;
              serial = serial
                  .then((_) => handle(status))
                  .catchError(handleStatusError);
            });
        subscription = await watchSubscription.timeout(_remaining(deadline));
        await ensureSubmitted();
      } catch (_) {
        // The RPC may have received the extrinsic even when its response was
        // lost. Never convert this into a retryable failure.
        closing = true;
        final pendingSubscription = watchSubscription;
        if (pendingSubscription != null) {
          unawaited(
            pendingSubscription
                .then((lateSubscription) => lateSubscription.cancel())
                .catchError((Object _) {}),
          );
        }
        try {
          await update(
            record.transitionTo(
              TransactionLifecycleState.unknownNeedsVerification,
              txHash: txHash,
              submittedAt: submittedAt,
            ),
          );
        } finally {
          cancelSubscription();
        }
        rethrow;
      }

      final remaining = _remainingOrZero(deadline);
      if (!terminal.isCompleted && remaining > Duration.zero) {
        await Future.any([terminal.future, Future<void>.delayed(remaining)]);
      }
      if (terminal.isCompleted) cancelSubscription();
      if (!terminal.isCompleted) {
        closing = true;
        await serial;
        if (!terminal.isCompleted) {
          await update(
            record.transitionTo(
              TransactionLifecycleState.unknownNeedsVerification,
            ),
          );
          terminal.complete(record);
          cancelSubscription();
        }
      }
      return await terminal.future;
    } finally {
      _processActiveIntents.remove(intent.key);
    }
  }

  Future<ChainVerificationResult> verifyUnknown(
    TransactionLifecycleRecord record, {
    int finalizedLookback = 120,
    TransactionPostStateVerifier? verifyPostState,
  }) async {
    if (finalizedLookback < 1) {
      throw ArgumentError.value(finalizedLookback, 'finalizedLookback');
    }
    if (!record.protectsAgainstDuplicate) {
      throw StateError(
        'Chain recovery accepts only unresolved transaction records.',
      );
    }
    if (record.txHash == null) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        evidence: const {'reason': 'No transaction hash was recorded.'},
      );
    }
    final expectedGenesis = record.genesisHash;
    if (expectedGenesis == null) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        evidence: const {
          'reason': 'Legacy transaction evidence has no pinned chain identity.',
        },
      );
    }
    String observedGenesis;
    try {
      final genesis = await _boundedRpc(
        provider.send('chain_getBlockHash', const [0]),
      );
      if (genesis.error != null || genesis.result is! String) {
        throw StateError('Unable to read chain genesis hash.');
      }
      observedGenesis = genesis.result! as String;
    } on Object {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        evidence: const {
          'reason': 'The recovery endpoint chain identity is unavailable.',
        },
      );
    }
    if (_normalizeHash(observedGenesis) != _normalizeHash(expectedGenesis)) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        evidence: {
          'reason': 'The recovery endpoint is a different chain.',
          'expectedGenesisHash': expectedGenesis,
          'observedGenesisHash': observedGenesis,
        },
      );
    }

    var pendingPoolAvailable = false;
    try {
      final pending = await _boundedRpc(
        provider.send('author_pendingExtrinsics', const []),
      );
      pendingPoolAvailable = pending.error == null && pending.result is List;
      if (pendingPoolAvailable) {
        for (final raw in pending.result! as List) {
          final bytes = _rpcHex(raw.toString());
          if (_extrinsicHash(bytes) == record.txHash!.toLowerCase()) {
            return ChainVerificationResult(
              status: ChainVerificationStatus.pending,
              evidence: const {'source': 'author_pendingExtrinsics'},
            );
          }
        }
      }
    } on Object {
      pendingPoolAvailable = false;
    }

    final unavailableEvidence = <String>[];
    final nonCanonicalEvidence = <String>[];
    final finalized = await _finalizedHead();
    const maximumSupportedBlockNumber = 0x7fffffff;
    if (finalized.number > BigInt.from(maximumSupportedBlockNumber)) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        evidence: const {
          'reason': 'Finalized block number exceeds the supported safe range.',
        },
      );
    }
    final finalizedNumber = finalized.number.toInt();
    final finalizedAt = Uint8List.fromList(_rpcHex(finalized.hash));

    final knownBlocks = <String, BlockReference>{
      if (record.finalityBlock != null)
        record.finalityBlock!.hash.toLowerCase(): record.finalityBlock!,
      if (record.inclusionBlock != null)
        record.inclusionBlock!.hash.toLowerCase(): record.inclusionBlock!,
    }.values;
    for (final block in knownBlocks) {
      if (block.number > finalized.number) continue;
      _ExtrinsicEvidence? evidence;
      try {
        if (!await _isCanonicalFinalizedBlock(
          block,
          finalized,
          finalizedAt: finalizedAt,
        )) {
          nonCanonicalEvidence.add(block.hash);
          continue;
        }
        evidence = await _evidenceAt(block.hash, txHash: record.txHash!);
        if (evidence.block.number != block.number) {
          throw StateError('Stored block evidence has a mismatched header.');
        }
      } on Object {
        unavailableEvidence.add(block.hash);
        continue;
      }
      if (evidence.found) {
        return _reconcileFoundEvidence(
          record,
          evidence,
          verifyPostState: verifyPostState,
        );
      }
    }

    final mortalityReferenceEvidence = record.mortalityReferenceBlock;
    if (mortalityReferenceEvidence != null &&
        mortalityReferenceEvidence > BigInt.from(maximumSupportedBlockNumber)) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        evidence: const {
          'reason': 'Mortal-era evidence exceeds the supported safe range.',
        },
      );
    }
    final mortalityReference = mortalityReferenceEvidence?.toInt();
    final mortalityPeriod = record.mortalityPeriod;
    final mortalityBirth = mortalityReference == null || mortalityPeriod == null
        ? null
        : _mortalEraBirth(mortalityReference, mortalityPeriod);
    final mortalityDeath = mortalityBirth == null || mortalityPeriod == null
        ? null
        : mortalityBirth + mortalityPeriod;
    final provingMortalityWindow =
        mortalityDeath != null &&
        finalizedNumber >= mortalityDeath &&
        pendingPoolAvailable;
    final lookbackFirst = finalizedNumber >= finalizedLookback - 1
        ? finalizedNumber - finalizedLookback + 1
        : 0;
    final first = mortalityReference ?? lookbackFirst;
    final mortalityLast = mortalityDeath == null ? null : mortalityDeath - 1;
    final last = mortalityLast == null || mortalityLast > finalizedNumber
        ? finalizedNumber
        : mortalityLast;
    var completeWindow = true;
    for (var number = last; number >= first; number--) {
      _ExtrinsicEvidence? evidence;
      String? hash;
      try {
        if (number == finalizedNumber) {
          hash = finalized.hash;
        } else {
          final hashBytes = await _boundedRpc(
            api.query.system.blockHash(number, at: finalizedAt),
          );
          hash = '0x${encodeHex(hashBytes)}';
        }
        evidence = await _evidenceAt(hash, txHash: record.txHash!);
        if (evidence.block.number != BigInt.from(number)) {
          throw StateError('Canonical block evidence has a mismatched header.');
        }
      } on Object {
        completeWindow = false;
        unavailableEvidence.add(hash ?? 'block:$number');
        continue;
      }
      if (!evidence.found) continue;
      return _reconcileFoundEvidence(
        record,
        evidence,
        verifyPostState: verifyPostState,
      );
    }

    if (provingMortalityWindow && completeWindow) {
      var notFound = record;
      if (notFound.state == TransactionLifecycleState.succeeded) {
        return ChainVerificationResult(
          status: ChainVerificationStatus.inconclusive,
          reconciledRecord: notFound,
          evidence: const {
            'reason': 'A succeeded record cannot be reclassified as absent.',
          },
        );
      }
      if (notFound.state != TransactionLifecycleState.failed) {
        notFound = notFound.transitionTo(TransactionLifecycleState.failed);
        await journal.upsert(notFound);
      }
      return ChainVerificationResult(
        status: ChainVerificationStatus.notFound,
        reconciledRecord: notFound,
        evidence: {
          'mortalityReferenceBlock': mortalityReference,
          'mortalityPeriod': mortalityPeriod,
          'mortalityBirth': mortalityBirth,
          'mortalityDeathExclusive': mortalityDeath,
          'scannedThrough': last,
          'pendingPoolChecked': true,
          'nonCanonicalStoredEvidence': nonCanonicalEvidence,
        },
      );
    }
    return ChainVerificationResult(
      status: ChainVerificationStatus.inconclusive,
      evidence: {
        'reason': mortalityDeath == null
            ? 'Not found in the bounded finalized window; legacy evidence '
                  'does not prove the full mortal era.'
            : 'The full mortal era or required archive data is not yet '
                  'available.',
        'lookback': finalizedLookback,
        'pendingPoolChecked': pendingPoolAvailable,
        'unavailableEvidence': unavailableEvidence,
        'nonCanonicalStoredEvidence': nonCanonicalEvidence,
      },
    );
  }

  Future<ChainVerificationResult> _reconcileFoundEvidence(
    TransactionLifecycleRecord record,
    _ExtrinsicEvidence evidence, {
    TransactionPostStateVerifier? verifyPostState,
  }) async {
    if (evidence.dispatch.status == DispatchResultStatus.unknown) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        reconciledRecord: record,
        evidence: {
          'blockNumber': evidence.block.number.toString(),
          'blockHash': evidence.block.hash,
          'reason': 'Transaction found but dispatch events were inconclusive.',
        },
      );
    }
    var next = record;
    if (next.state == TransactionLifecycleState.succeeded ||
        next.state == TransactionLifecycleState.failed) {
      return ChainVerificationResult(
        status: next.state == TransactionLifecycleState.succeeded
            ? ChainVerificationStatus.succeeded
            : ChainVerificationStatus.failed,
        reconciledRecord: next,
        evidence: {
          'blockNumber': evidence.block.number.toString(),
          'blockHash': evidence.block.hash,
        },
      );
    }
    if (next.state == TransactionLifecycleState.submitting ||
        next.state == TransactionLifecycleState.finalized) {
      next = next.transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
    }
    if (next.state == TransactionLifecycleState.submitted ||
        next.state == TransactionLifecycleState.inBlock ||
        next.state == TransactionLifecycleState.unknownNeedsVerification) {
      if (next.state == TransactionLifecycleState.inBlock) {
        next = next.transitionTo(
          TransactionLifecycleState.finalized,
          inclusionBlock: evidence.block,
          finalityBlock: evidence.block,
          relevantEvents: evidence.events,
          dispatchResult: evidence.dispatch,
          decodedModuleError: evidence.dispatch.effectiveError?.moduleError,
        );
      } else {
        next = next.transitionTo(
          TransactionLifecycleState.finalized,
          txHash: record.txHash,
          submittedAt: record.submittedAt ?? record.createdAt,
          inclusionBlock: evidence.block,
          finalityBlock: evidence.block,
          relevantEvents: evidence.events,
          dispatchResult: evidence.dispatch,
          decodedModuleError: evidence.dispatch.effectiveError?.moduleError,
        );
      }
    }
    if (next.state != TransactionLifecycleState.finalized) {
      return ChainVerificationResult(
        status: ChainVerificationStatus.inconclusive,
        reconciledRecord: next,
        evidence: {
          'blockNumber': evidence.block.number.toString(),
          'blockHash': evidence.block.hash,
          'reason':
              'The persisted lifecycle state could not be reconciled '
              'safely with finalized chain evidence.',
        },
      );
    }
    next = evidence.dispatch.status == DispatchResultStatus.success
        ? await const TransactionFinalizationPolicy().resolveSuccessfulDispatch(
            next,
            verifyPostState: verifyPostState,
          )
        : next.transitionTo(TransactionLifecycleState.failed);
    await journal.upsert(next);
    final status = switch (next.state) {
      TransactionLifecycleState.succeeded => ChainVerificationStatus.succeeded,
      TransactionLifecycleState.failed => ChainVerificationStatus.failed,
      _ => ChainVerificationStatus.inconclusive,
    };
    return ChainVerificationResult(
      status: status,
      reconciledRecord: next,
      evidence: {
        'blockNumber': evidence.block.number.toString(),
        'blockHash': evidence.block.hash,
        if (status == ChainVerificationStatus.inconclusive)
          'reason':
              'Dispatch was found, but required canonical post-state '
              'verification is incomplete.',
      },
    );
  }

  Future<_ExtrinsicEvidence> _evidenceAt(
    String blockHash, {
    required String txHash,
    Uint8List? encodedExtrinsic,
    DateTime? deadline,
  }) async {
    final blockResponse = await _boundedRpc(
      provider.send('chain_getBlock', [blockHash]),
      deadline: deadline,
    );
    if (blockResponse.error != null || blockResponse.result is! Map) {
      throw StateError('Unable to read inclusion block $blockHash.');
    }
    final result = blockResponse.result! as Map;
    final block = result['block'];
    if (block is! Map ||
        block['header'] is! Map ||
        block['extrinsics'] is! List) {
      throw StateError('Inclusion block response is malformed.');
    }
    final number = _rpcInteger((block['header'] as Map)['number']);
    final extrinsics = block['extrinsics'] as List;
    int? extrinsicIndex;
    for (var index = 0; index < extrinsics.length; index++) {
      final bytes = _rpcHex(extrinsics[index].toString());
      if ((encodedExtrinsic != null && _bytesEqual(bytes, encodedExtrinsic)) ||
          _extrinsicHash(bytes) == txHash.toLowerCase()) {
        extrinsicIndex = index;
        break;
      }
    }
    final reference = BlockReference(number: number, hash: blockHash);
    if (extrinsicIndex == null) {
      return _ExtrinsicEvidence.notFound(reference);
    }
    final at = Uint8List.fromList(_rpcHex(blockHash));
    final records = await _boundedRpc(
      api.query.system.events(at: at),
      deadline: deadline,
    );
    final events = <LifecycleRelevantEvent>[];
    for (final record in records) {
      final phaseJson = record.phase.toJson();
      final apply = phaseJson['ApplyExtrinsic'];
      if (apply != extrinsicIndex) continue;
      final json = record.event.toJson();
      final pallet = json.keys.single;
      final palletValue = json[pallet];
      if (palletValue == null || palletValue.isEmpty) continue;
      final event = palletValue.keys.single.toString();
      final fields = _safeFields(palletValue.values.single);
      events.add(
        LifecycleRelevantEvent(pallet: pallet, event: event, fields: fields),
      );
    }
    final dispatch = const DispatchEventDecoder().decode(
      events,
      resolveModuleError: _resolveModuleError,
    );
    return _ExtrinsicEvidence(
      found: true,
      block: reference,
      events: events,
      dispatch: dispatch,
    );
  }

  Future<BlockReference> _finalizedHead() async {
    final response = await _boundedRpc(
      provider.send('chain_getFinalizedHead', const []),
    );
    if (response.error != null || response.result is! String) {
      throw StateError('Unable to read finalized head.');
    }
    final hash = response.result! as String;
    final header = await _boundedRpc(provider.send('chain_getHeader', [hash]));
    if (header.error != null || header.result is! Map) {
      throw StateError('Unable to read finalized header.');
    }
    return BlockReference(
      number: _rpcInteger((header.result! as Map)['number']),
      hash: hash,
    );
  }

  Future<bool> _isCanonicalFinalizedBlock(
    BlockReference candidate,
    BlockReference finalized, {
    required Uint8List finalizedAt,
  }) async {
    if (candidate.number > finalized.number ||
        candidate.number > BigInt.from(0x7fffffff)) {
      return false;
    }
    if (candidate.number == finalized.number) {
      return _normalizeHash(candidate.hash) == _normalizeHash(finalized.hash);
    }
    final canonicalHash = await _boundedRpc(
      api.query.system.blockHash(candidate.number.toInt(), at: finalizedAt),
    );
    return _normalizeHash('0x${encodeHex(canonicalHash)}') ==
        _normalizeHash(candidate.hash);
  }
}

class _ExtrinsicEvidence {
  final bool found;
  final BlockReference block;
  final List<LifecycleRelevantEvent> events;
  final TransactionDispatchResult dispatch;

  const _ExtrinsicEvidence({
    required this.found,
    required this.block,
    required this.events,
    required this.dispatch,
  });

  _ExtrinsicEvidence.notFound(this.block)
    : found = false,
      events = const [],
      dispatch = const TransactionDispatchResult.unknown();
}

DecodedModuleError? _resolveModuleError(int palletIndex, List<int> bytes) {
  if (palletIndex != 12 || bytes.isEmpty) return null;
  for (final value in ai_error.Error.values) {
    if (value.codecIndex == bytes.first) {
      return DecodedModuleError(
        pallet: 'AiPredictions',
        error: value.variantName,
        palletIndex: palletIndex,
        errorBytes: bytes,
      );
    }
  }
  return DecodedModuleError(
    pallet: 'AiPredictions',
    error: 'UnknownError${bytes.first}',
    palletIndex: palletIndex,
    errorBytes: bytes,
  );
}

Map<String, Object?> _safeFields(Object? value) {
  if (value is! Map) return {'value': _safeValue(value)};
  return {
    for (final entry in value.entries)
      entry.key.toString(): _safeValue(entry.value),
  };
}

Object? _safeValue(Object? value) {
  if (value == null || value is String || value is bool || value is num) {
    return value;
  }
  if (value is BigInt) return value.toString();
  if (value is List) return value.map(_safeValue).toList(growable: false);
  if (value is Map) return _safeFields(value);
  if (value is dispatch_error.DispatchError) return value.toJson();
  return value.toString();
}

Uint8List _rpcHex(String value) {
  final hex = value.startsWith('0x') ? value.substring(2) : value;
  return Uint8List.fromList(decodeHex(hex));
}

String _extrinsicHash(Uint8List value) =>
    '0x${encodeHex(polkadart.Hasher.blake2b256.hash(value))}'.toLowerCase();

BigInt _rpcInteger(Object? value) {
  final text = value?.toString() ?? '';
  final parsed = text.startsWith('0x')
      ? BigInt.tryParse(text.substring(2), radix: 16)
      : BigInt.tryParse(text);
  if (parsed == null || parsed.isNegative) {
    throw StateError('Invalid RPC integer.');
  }
  return parsed;
}

int _rpcInt(Object? value) {
  final parsed = _rpcInteger(value);
  if (parsed > BigInt.from(0x7fffffff)) {
    throw StateError('RPC integer exceeds the supported range.');
  }
  return parsed.toInt();
}

int _mortalEraBirth(int referenceBlock, int period) {
  final quantizeFactor = period >> 12;
  final effectiveQuantizeFactor = quantizeFactor < 1 ? 1 : quantizeFactor;
  final phase = referenceBlock % period;
  final quantizedPhase =
      (phase ~/ effectiveQuantizeFactor) * effectiveQuantizeFactor;
  return referenceBlock - (phase - quantizedPhase);
}

int? _storageVersion(polkadart.RpcResponse response) {
  if (response.error != null || response.result is! String) return null;
  final bytes = _rpcHex(response.result! as String);
  if (bytes.isEmpty || bytes.length > 4) return null;
  var value = 0;
  for (var index = 0; index < bytes.length; index++) {
    value |= bytes[index] << (index * 8);
  }
  return value;
}

bool _bytesEqual(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

String _normalizeHash(String value) =>
    value.trim().toLowerCase().replaceFirst(RegExp(r'^0x'), '');

Duration _remaining(DateTime deadline) {
  final remaining = deadline.difference(DateTime.now().toUtc());
  if (remaining <= Duration.zero) {
    throw TimeoutException('The transaction confirmation deadline expired.');
  }
  return remaining;
}

Duration _remainingOrZero(DateTime deadline) {
  final remaining = deadline.difference(DateTime.now().toUtc());
  return remaining.isNegative ? Duration.zero : remaining;
}

Future<T> _boundedRpc<T>(Future<T> operation, {DateTime? deadline}) =>
    operation.timeout(
      deadline == null ? const Duration(seconds: 20) : _remaining(deadline),
    );

Future<String> _sha256Hex(List<int> bytes) async {
  final digest = await Sha256().hash(bytes);
  return digest.bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}
