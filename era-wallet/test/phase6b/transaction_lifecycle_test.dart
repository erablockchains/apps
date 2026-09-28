import 'dart:async';

import 'package:era_wallet/phase6b/transaction_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

const _testGenesisHash =
    '0x1111111111111111111111111111111111111111111111111111111111111111';

TransactionLifecycleRecord _finalizedRecordRequiringPostState({
  required TransactionIntent intent,
  required DateTime createdAt,
  required DateTime submittedAt,
  required BlockReference inclusion,
  required BlockReference finality,
}) {
  var record = TransactionLifecycleRecord.preparing(
    intent: intent,
    createdAt: createdAt,
    requiresPostStateVerification: true,
  );
  record = record.transitionTo(
    TransactionLifecycleState.awaitingAuthentication,
  );
  record = record.transitionTo(
    TransactionLifecycleState.signing,
    nonce: BigInt.from(9),
  );
  record = record.transitionTo(
    TransactionLifecycleState.submitting,
    genesisHash: _testGenesisHash,
    mortalityReferenceBlock: BigInt.from(96),
    mortalityPeriod: 64,
  );
  record = record.transitionTo(
    TransactionLifecycleState.submitted,
    txHash: '0xtx',
    submittedAt: submittedAt,
  );
  record = record.transitionTo(
    TransactionLifecycleState.inBlock,
    inclusionBlock: inclusion,
  );
  return record.transitionTo(
    TransactionLifecycleState.finalized,
    finalityBlock: finality,
    dispatchResult: const TransactionDispatchResult.success(),
  );
}

void main() {
  final createdAt = DateTime.utc(2026, 7, 16, 12);
  final submittedAt = DateTime.utc(2026, 7, 16, 12, 1);
  final inclusion = BlockReference(number: BigInt.from(101), hash: '0x101');
  final finality = BlockReference(number: BigInt.from(103), hash: '0x103');

  TransactionIntent intent({
    Map<String, Object?> arguments = const {'modelId': 7},
    String signer = '5EraSigner',
  }) => TransactionIntent(
    pallet: 'AiPredictions',
    call: 'approveModel',
    argumentsSummary: arguments,
    signer: signer,
  );

  TransactionLifecycleRecord submittingRecord({TransactionIntent? value}) {
    var record = TransactionLifecycleRecord.preparing(
      intent: value ?? intent(),
      createdAt: createdAt,
    );
    record = record.transitionTo(
      TransactionLifecycleState.awaitingAuthentication,
    );
    record = record.transitionTo(
      TransactionLifecycleState.signing,
      nonce: BigInt.from(9),
    );
    return record.transitionTo(TransactionLifecycleState.submitting);
  }

  TransactionLifecycleRecord submittedRecord() =>
      submittingRecord().transitionTo(
        TransactionLifecycleState.submitted,
        txHash: '0xtx',
        submittedAt: submittedAt,
      );

  TransactionLifecycleRecord finalizedRecord({
    TransactionDispatchResult? dispatchResult,
  }) {
    var record = submittedRecord().transitionTo(
      TransactionLifecycleState.inBlock,
      inclusionBlock: inclusion,
    );
    record = record.transitionTo(
      TransactionLifecycleState.finalized,
      finalityBlock: finality,
      dispatchResult: dispatchResult,
    );
    return record;
  }

  group('transaction intent', () {
    test('key is stable across argument map insertion order', () {
      final first = intent(
        arguments: {
          'modelId': 7,
          'settings': {'enabled': true, 'bond': BigInt.from(10)},
        },
      );
      final second = intent(
        arguments: {
          'settings': {'bond': BigInt.from(10), 'enabled': true},
          'modelId': 7,
        },
      );

      expect(first.key, second.key);
      expect(first.key, startsWith('era-intent-v1:'));
    });

    test('key changes with signer, call, or arguments', () {
      final base = intent();

      expect(intent(signer: '5Other').key, isNot(base.key));
      expect(intent(arguments: const {'modelId': 8}).key, isNot(base.key));
      expect(
        TransactionIntent(
          pallet: 'AiPredictions',
          call: 'suspendModel',
          argumentsSummary: const {'modelId': 7},
          signer: '5EraSigner',
        ).key,
        isNot(base.key),
      );
    });

    test('redacts authentication material from summaries', () {
      final value = intent(
        arguments: {
          'modelId': 7,
          'mnemonic': 'never persist these secret words',
          'nested': {'private_key': '0xsecret', 'publicValue': 'safe'},
        },
      );

      expect(value.argumentsSummary['mnemonic'], '[REDACTED]');
      expect(
        (value.argumentsSummary['nested']! as Map)['private_key'],
        '[REDACTED]',
      );
      expect((value.argumentsSummary['nested']! as Map)['publicValue'], 'safe');
    });
  });

  group('lifecycle transitions', () {
    test('supports the complete successful finalized path', () {
      final record = finalizedRecord().transitionTo(
        TransactionLifecycleState.succeeded,
        dispatchResult: const TransactionDispatchResult.success(),
        relevantEvents: [
          LifecycleRelevantEvent(
            pallet: 'AiPredictions',
            event: 'ModelApproved',
            fields: const {'modelId': 7},
          ),
        ],
        postStateVerification: PostStateVerification(
          status: PostStateVerificationStatus.confirmed,
          checkedAt: DateTime.utc(2026, 7, 16, 12, 3),
          details: const {'modelStatus': 'Approved'},
        ),
      );

      expect(record.state, TransactionLifecycleState.succeeded);
      expect(record.nonce, BigInt.from(9));
      expect(record.txHash, '0xtx');
      expect(record.inclusionBlock, inclusion);
      expect(record.finalityBlock, finality);
      expect(record.relevantEvents.single.event, 'ModelApproved');
      expect(
        record.postStateVerification.status,
        PostStateVerificationStatus.confirmed,
      );
    });

    test('rejects illegal skips and terminal transitions', () {
      final preparing = TransactionLifecycleRecord.preparing(
        intent: intent(),
        createdAt: createdAt,
      );

      expect(
        () => preparing.transitionTo(TransactionLifecycleState.submitted),
        throwsA(isA<LifecycleTransitionException>()),
      );
      final failed = preparing.transitionTo(TransactionLifecycleState.failed);
      expect(
        () => failed.transitionTo(
          TransactionLifecycleState.awaitingAuthentication,
        ),
        throwsA(isA<LifecycleTransitionException>()),
      );
    });

    test('requires chain evidence for submitted and finalized states', () {
      final submitting = submittingRecord();

      expect(
        () => submitting.transitionTo(TransactionLifecycleState.submitted),
        throwsArgumentError,
      );
      expect(
        () => submittedRecord().transitionTo(
          TransactionLifecycleState.finalized,
          finalityBlock: finality,
        ),
        throwsArgumentError,
      );
    });

    test('requires a successful dispatch result for succeeded', () {
      expect(
        () => finalizedRecord().transitionTo(
          TransactionLifecycleState.succeeded,
          dispatchResult: const TransactionDispatchResult.failure(
            systemError: RuntimeDispatchError(kind: 'BadOrigin'),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('required post-state must be confirmed before succeeded', () {
      final finalized = _finalizedRecordRequiringPostState(
        intent: intent(),
        createdAt: createdAt,
        submittedAt: submittedAt,
        inclusion: inclusion,
        finality: finality,
      );

      expect(
        () => finalized.transitionTo(TransactionLifecycleState.succeeded),
        throwsArgumentError,
      );
    });

    test('allows ambiguous submission to become unknown without a hash', () {
      final unknown = submittingRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );

      expect(unknown.state, TransactionLifecycleState.unknownNeedsVerification);
      expect(unknown.txHash, isNull);
      expect(unknown.protectsAgainstDuplicate, isTrue);
    });
  });

  group('persistence', () {
    test('round trips all receipt and verification fields', () {
      final moduleError = DecodedModuleError(
        pallet: 'AiPredictions',
        error: 'ModelNotFound',
        palletIndex: 12,
        errorBytes: const [4, 0, 0, 0],
        docs: const ['The requested model does not exist.'],
      );
      var record = _finalizedRecordRequiringPostState(
        intent: intent(),
        createdAt: createdAt,
        submittedAt: submittedAt,
        inclusion: inclusion,
        finality: finality,
      );
      record = record.transitionTo(
        TransactionLifecycleState.failed,
        dispatchResult: TransactionDispatchResult.failure(
          systemError: RuntimeDispatchError(
            kind: 'Module',
            moduleError: moduleError,
          ),
        ),
        decodedModuleError: moduleError,
        relevantEvents: [
          LifecycleRelevantEvent(
            pallet: 'System',
            event: 'ExtrinsicFailed',
            fields: const {'error': 'AiPredictions.ModelNotFound'},
          ),
        ],
        postStateVerification: PostStateVerification(
          status: PostStateVerificationStatus.contradicted,
          checkedAt: DateTime.utc(2026, 7, 16, 12, 4),
          details: const {'observed': 'Pending'},
        ),
      );

      const codec = TransactionLifecycleCodec();
      final decoded = codec.decode(codec.encode([record])).single;

      expect(decoded.id, record.id);
      expect(decoded.intentKey, record.intentKey);
      expect(decoded.state, TransactionLifecycleState.failed);
      expect(decoded.nonce, BigInt.from(9));
      expect(decoded.genesisHash, _testGenesisHash);
      expect(decoded.mortalityReferenceBlock, BigInt.from(96));
      expect(decoded.mortalityPeriod, 64);
      expect(decoded.inclusionBlock, inclusion);
      expect(decoded.finalityBlock, finality);
      expect(
        decoded.dispatchResult?.effectiveError?.moduleError?.qualifiedName,
        'AiPredictions.ModelNotFound',
      );
      expect(decoded.relevantEvents.single.event, 'ExtrinsicFailed');
      expect(
        decoded.postStateVerification.status,
        PostStateVerificationStatus.contradicted,
      );
      expect(decoded.requiresPostStateVerification, isTrue);
    });

    test('encoded journal contains no supplied secrets', () {
      final sensitiveIntent = intent(
        arguments: {
          'modelId': 7,
          'seed_phrase': 'fixture-sensitive-value',
          'password': 'hunter-nope',
        },
      );
      final record = TransactionLifecycleRecord.preparing(
        intent: sensitiveIntent,
        createdAt: createdAt,
      );

      final encoded = const TransactionLifecycleCodec().encode([record]);

      expect(encoded, isNot(contains('fixture-sensitive-value')));
      expect(encoded, isNot(contains('hunter-nope')));
      expect(encoded, contains('[REDACTED]'));
    });

    test('redacts API credentials and credential-bearing endpoint values', () {
      final sensitiveIntent = intent(
        arguments: {
          'api_key': 'fixture-api-secret',
          'endpoint': 'wss://user:fixture-token@example.invalid/rpc',
          'accessToken': 'fixture-access-token',
        },
      );
      final record = TransactionLifecycleRecord.preparing(
        intent: sensitiveIntent,
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(record.argumentsSummary['api_key'], '[REDACTED]');
      expect(record.argumentsSummary['endpoint'], '[REDACTED]');
      expect(record.argumentsSummary['accessToken'], '[REDACTED]');
    });

    test('rejects unsupported journal versions', () {
      expect(
        () => const TransactionLifecycleCodec().decode(
          '{"schemaVersion":5,"records":[]}',
        ),
        throwsFormatException,
      );
    });

    test('rejects a persisted intent-key mismatch', () {
      final json = TransactionLifecycleRecord.preparing(
        intent: intent(),
        createdAt: createdAt,
      ).toJson();
      json['intentKey'] = 'era-intent-v1:corrupt';

      expect(
        () => TransactionLifecycleRecord.fromJson(json),
        throwsFormatException,
      );
    });

    test('rejects contradictory persisted dispatch evidence', () {
      final contradictory = <Map<String, Object?>>[
        {
          'status': 'success',
          'systemError': {'kind': 'BadOrigin'},
        },
        {
          'status': 'success',
          'sudoResult': {
            'status': 'failure',
            'error': {'kind': 'BadOrigin'},
          },
        },
        {'status': 'failure'},
        {
          'status': 'failure',
          'systemError': {'kind': 'BadOrigin'},
          'sudoResult': {
            'status': 'failure',
            'error': {'kind': 'BadOrigin'},
          },
        },
        {
          'status': 'unknown',
          'systemError': {'kind': 'BadOrigin'},
        },
      ];

      for (final json in contradictory) {
        expect(
          () => TransactionDispatchResult.fromJson(json),
          throwsFormatException,
        );
      }
    });

    test('migrates schema-1 post-state policy conservatively', () {
      Map<String, Object?> legacyRecordFor(String call) {
        final json = TransactionLifecycleRecord.preparing(
          intent: TransactionIntent(
            pallet: 'AiPredictions',
            call: call,
            argumentsSummary: const {},
            signer: '5EraSigner',
          ),
          createdAt: createdAt,
        ).toJson();
        json['schemaVersion'] = 1;
        json.remove('requiresPostStateVerification');
        return json;
      }

      expect(
        TransactionLifecycleRecord.fromJson(
          legacyRecordFor('approve_model'),
        ).requiresPostStateVerification,
        isTrue,
      );
      expect(
        TransactionLifecycleRecord.fromJson(
          legacyRecordFor('claim_prediction_market_payout'),
        ).requiresPostStateVerification,
        isTrue,
      );
      expect(
        TransactionLifecycleRecord.fromJson(
          legacyRecordFor('stake_on_prediction_outcome_side'),
        ).requiresPostStateVerification,
        isFalse,
      );
    });

    test('migrates legacy unsafe success back to unknown', () {
      var legacy = _finalizedRecordRequiringPostState(
        intent: intent(),
        createdAt: createdAt,
        submittedAt: submittedAt,
        inclusion: inclusion,
        finality: finality,
      );
      legacy = legacy.transitionTo(
        TransactionLifecycleState.succeeded,
        postStateVerification: PostStateVerification(
          status: PostStateVerificationStatus.confirmed,
          checkedAt: submittedAt,
        ),
      );
      final json = legacy.toJson();
      json['schemaVersion'] = 1;
      json.remove('requiresPostStateVerification');
      json['postStateVerification'] = const PostStateVerification.notRun()
          .toJson();

      final migrated = TransactionLifecycleRecord.fromJson(json);

      expect(
        migrated.state,
        TransactionLifecycleState.unknownNeedsVerification,
      );
      expect(migrated.protectsAgainstDuplicate, isTrue);
    });
  });

  group('successful dispatch finalization policy', () {
    const policy = TransactionFinalizationPolicy();

    test(
      'requires confirmed canonical post-state when policy requires it',
      () async {
        final finalized = _finalizedRecordRequiringPostState(
          intent: intent(),
          createdAt: createdAt,
          submittedAt: submittedAt,
          inclusion: inclusion,
          finality: finality,
        );

        final confirmed = await policy.resolveSuccessfulDispatch(
          finalized,
          verifyPostState: (_) async => PostStateVerification(
            status: PostStateVerificationStatus.confirmed,
            checkedAt: createdAt,
            details: const {'status': 'Approved'},
          ),
        );
        final missing = await policy.resolveSuccessfulDispatch(finalized);
        final inconclusive = await policy.resolveSuccessfulDispatch(
          finalized,
          verifyPostState: (_) async => PostStateVerification(
            status: PostStateVerificationStatus.inconclusive,
            checkedAt: createdAt,
          ),
        );
        final failedSafely = await policy.resolveSuccessfulDispatch(
          finalized,
          verifyPostState: (_) async => throw StateError('RPC unavailable'),
        );

        expect(confirmed.state, TransactionLifecycleState.succeeded);
        for (final record in [missing, inconclusive, failedSafely]) {
          expect(
            record.state,
            TransactionLifecycleState.unknownNeedsVerification,
          );
          expect(record.protectsAgainstDuplicate, isTrue);
        }
      },
    );

    test(
      'allows participant dispatch success when no post-state is required',
      () async {
        final finalized = finalizedRecord(
          dispatchResult: const TransactionDispatchResult.success(),
        );

        final resolved = await policy.resolveSuccessfulDispatch(finalized);

        expect(resolved.state, TransactionLifecycleState.succeeded);
        expect(
          resolved.postStateVerification.status,
          PostStateVerificationStatus.notRun,
        );
      },
    );
  });

  group('duplicate submission guard', () {
    test('restores unresolved intent locks and ignores completed records', () {
      final unresolved = submittingRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
      final completedIntent = intent(arguments: const {'modelId': 8});
      final completed = TransactionLifecycleRecord.preparing(
        intent: completedIntent,
        createdAt: createdAt,
      ).transitionTo(TransactionLifecycleState.failed);
      final guard = DuplicateSubmissionGuard()
        ..restore([completed, unresolved]);

      expect(guard.tracked(completed.intentKey), isNull);
      expect(guard.tracked(unresolved.intentKey)?.id, unresolved.id);
      expect(
        () => guard.register(
          TransactionLifecycleRecord.preparing(
            intent: intent(),
            createdAt: createdAt.add(const Duration(minutes: 1)),
          ),
        ),
        throwsA(isA<DuplicateSubmissionException>()),
      );
    });

    test('rejects multiple unresolved records for one intent', () {
      final first = submittedRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
      final secondJson = Map<String, Object?>.from(first.toJson())
        ..['id'] = '${first.id}:second';
      final second = TransactionLifecycleRecord.fromJson(secondJson);

      expect(
        () => DuplicateSubmissionGuard().restore([first, second]),
        throwsStateError,
      );
    });

    test('blocks a second active record for a deterministic intent', () {
      final value = intent();
      final first = TransactionLifecycleRecord.preparing(
        intent: value,
        createdAt: createdAt,
      );
      final second = TransactionLifecycleRecord.preparing(
        intent: value,
        createdAt: createdAt.add(const Duration(seconds: 1)),
      );
      final guard = DuplicateSubmissionGuard()..register(first);

      expect(
        () => guard.register(second),
        throwsA(isA<DuplicateSubmissionException>()),
      );
    });

    test('permits a fresh intent after a definitive local failure', () {
      final value = intent();
      var first = TransactionLifecycleRecord.preparing(
        intent: value,
        createdAt: createdAt,
      );
      final guard = DuplicateSubmissionGuard()..register(first);
      first = first.transitionTo(TransactionLifecycleState.failed);
      guard.update(first);

      expect(
        () => guard.register(
          TransactionLifecycleRecord.preparing(
            intent: value,
            createdAt: createdAt.add(const Duration(minutes: 1)),
          ),
        ),
        returnsNormally,
      );
    });

    test(
      'unknown outcome stays blocked until async verification finds none',
      () async {
        final unknown = submittingRecord().transitionTo(
          TransactionLifecycleState.unknownNeedsVerification,
        );
        final guard = DuplicateSubmissionGuard()..register(unknown);
        var verificationCalls = 0;

        expect(
          () => guard.register(
            TransactionLifecycleRecord.preparing(
              intent: intent(),
              createdAt: createdAt.add(const Duration(minutes: 1)),
            ),
          ),
          throwsA(isA<DuplicateSubmissionException>()),
        );

        final decision = await guard.verifyUnknownBeforeRetry(
          unknown.intentKey,
          (record) async {
            verificationCalls += 1;
            expect(record.id, unknown.id);
            return ChainVerificationResult(
              status: ChainVerificationStatus.notFound,
              reconciledRecord: record.transitionTo(
                TransactionLifecycleState.failed,
              ),
              evidence: const {'finalizedRangeChecked': '100-150'},
            );
          },
        );

        expect(verificationCalls, 1);
        expect(decision.retryAllowed, isTrue);
        expect(guard.tracked(unknown.intentKey), isNull);
      },
    );

    test('pending and inconclusive verification never enable retry', () async {
      for (final status in const [
        ChainVerificationStatus.pending,
        ChainVerificationStatus.inconclusive,
      ]) {
        final unknown = submittingRecord().transitionTo(
          TransactionLifecycleState.unknownNeedsVerification,
        );
        final guard = DuplicateSubmissionGuard()..register(unknown);

        final decision = await guard.verifyUnknownBeforeRetry(
          unknown.intentKey,
          (_) async => ChainVerificationResult(status: status),
        );

        expect(decision.retryAllowed, isFalse, reason: status.name);
        expect(guard.tracked(unknown.intentKey), isNotNull);
      }
    });

    test(
      'succeeded verification remains blocked with matching evidence',
      () async {
        final unknown = submittedRecord().transitionTo(
          TransactionLifecycleState.unknownNeedsVerification,
        );
        var succeeded = unknown.transitionTo(
          TransactionLifecycleState.finalized,
          inclusionBlock: inclusion,
          finalityBlock: finality,
          dispatchResult: const TransactionDispatchResult.success(),
        );
        succeeded = succeeded.transitionTo(TransactionLifecycleState.succeeded);
        final guard = DuplicateSubmissionGuard()..register(unknown);

        final decision = await guard.verifyUnknownBeforeRetry(
          unknown.intentKey,
          (_) async => ChainVerificationResult(
            status: ChainVerificationStatus.succeeded,
            reconciledRecord: succeeded,
          ),
        );

        expect(decision.retryAllowed, isFalse);
        expect(
          guard.tracked(unknown.intentKey)?.state,
          TransactionLifecycleState.succeeded,
        );
      },
    );

    test('inconsistent verifier output fails closed', () async {
      final unknown = submittingRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
      final guard = DuplicateSubmissionGuard()..register(unknown);

      await expectLater(
        guard.verifyUnknownBeforeRetry(
          unknown.intentKey,
          (_) async => ChainVerificationResult(
            status: ChainVerificationStatus.notFound,
            reconciledRecord: unknown,
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(guard.tracked(unknown.intentKey), unknown);
    });

    test('failed status cannot contradict successful dispatch', () async {
      final unknown = submittedRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
      var contradictory = unknown.transitionTo(
        TransactionLifecycleState.finalized,
        inclusionBlock: inclusion,
        finalityBlock: finality,
        dispatchResult: const TransactionDispatchResult.success(),
      );
      contradictory = contradictory.transitionTo(
        TransactionLifecycleState.failed,
      );
      final guard = DuplicateSubmissionGuard()..register(unknown);

      await expectLater(
        guard.verifyUnknownBeforeRetry(
          unknown.intentKey,
          (_) async => ChainVerificationResult(
            status: ChainVerificationStatus.failed,
            reconciledRecord: contradictory,
          ),
        ),
        throwsStateError,
      );
      expect(guard.tracked(unknown.intentKey), unknown);
    });

    test('stale verification cannot overwrite a concurrent update', () async {
      final unknown = submittedRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
      final guard = DuplicateSubmissionGuard()..register(unknown);
      final completer = Completer<ChainVerificationResult>();
      final verification = guard.verifyUnknownBeforeRetry(
        unknown.intentKey,
        (_) => completer.future,
      );
      final updated = unknown.transitionTo(TransactionLifecycleState.submitted);
      guard.update(updated);
      completer.complete(
        ChainVerificationResult(status: ChainVerificationStatus.inconclusive),
      );

      await expectLater(verification, throwsStateError);
      expect(guard.tracked(unknown.intentKey), updated);
    });

    test('rejects concurrent verification for the same intent', () async {
      final unknown = submittingRecord().transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
      final guard = DuplicateSubmissionGuard()..register(unknown);
      final completer = Completer<ChainVerificationResult>();
      final first = guard.verifyUnknownBeforeRetry(
        unknown.intentKey,
        (_) => completer.future,
      );

      await expectLater(
        guard.verifyUnknownBeforeRetry(
          unknown.intentKey,
          (_) async =>
              ChainVerificationResult(status: ChainVerificationStatus.notFound),
        ),
        throwsA(isA<VerificationAlreadyInProgressException>()),
      );
      completer.complete(
        ChainVerificationResult(status: ChainVerificationStatus.inconclusive),
      );
      expect((await first).retryAllowed, isFalse);
    });
  });

  group('startup reconciliation', () {
    const policy = StartupReconciliationPolicy();

    test(
      'marks an interrupted submission unknown and requires verification',
      () {
        final recovered = policy.prepareForStartup(submittingRecord());

        expect(
          recovered.state,
          TransactionLifecycleState.unknownNeedsVerification,
        );
        expect(
          policy.actionFor(recovered),
          StartupReconciliationAction.verifyBeforeAnyRetry,
        );
      },
    );

    test(
      'resumes watchers but never treats an unsigned draft as submitted',
      () {
        final draft = TransactionLifecycleRecord.preparing(
          intent: intent(),
          createdAt: createdAt,
        );

        expect(
          policy.actionFor(draft),
          StartupReconciliationAction.discardUnsignedDraft,
        );
        expect(
          policy.actionFor(submittedRecord()),
          StartupReconciliationAction.resumeWatchingAndVerify,
        );
        expect(
          policy.actionFor(finalizedRecord()),
          StartupReconciliationAction.verifyDispatchAndPostState,
        );
      },
    );

    test('selects only records that need chain verification', () {
      final draft = TransactionLifecycleRecord.preparing(
        intent: intent(arguments: const {'modelId': 99}),
        createdAt: createdAt,
      );
      final done = finalizedRecord().transitionTo(
        TransactionLifecycleState.succeeded,
        dispatchResult: const TransactionDispatchResult.success(),
      );

      final selected = policy.recordsRequiringChainVerification([
        draft,
        submittingRecord(),
        submittedRecord(),
        done,
      ]);

      expect(selected, hasLength(2));
      expect(
        selected.map((record) => record.state),
        containsAll([
          TransactionLifecycleState.unknownNeedsVerification,
          TransactionLifecycleState.submitted,
        ]),
      );
    });
  });

  group('dispatch event decoding', () {
    const decoder = DispatchEventDecoder();

    test('decodes system.ExtrinsicSuccess', () {
      final result = decoder.decode([
        LifecycleRelevantEvent(pallet: 'System', event: 'ExtrinsicSuccess'),
      ]);

      expect(result.status, DispatchResultStatus.success);
      expect(result.effectiveError, isNull);
    });

    test('decodes and resolves system module errors', () {
      final result = decoder.decode(
        [
          LifecycleRelevantEvent(
            pallet: 'System',
            event: 'ExtrinsicFailed',
            fields: const {
              'dispatchError': {
                'Module': {'index': 12, 'error': '0x04000000'},
              },
            },
          ),
        ],
        resolveModuleError: (index, bytes) => DecodedModuleError(
          pallet: 'AiPredictions',
          error: 'ModelNotFound',
          palletIndex: index,
          errorBytes: bytes,
        ),
      );

      expect(result.status, DispatchResultStatus.failure);
      expect(result.effectiveError?.kind, 'Module');
      expect(
        result.effectiveError?.moduleError?.qualifiedName,
        'AiPredictions.ModelNotFound',
      );
      expect(result.effectiveError?.moduleError?.errorBytes, [4, 0, 0, 0]);
    });

    test('nested sudo.Sudid Err overrides system extrinsic success', () {
      final result = decoder.decode([
        LifecycleRelevantEvent(pallet: 'System', event: 'ExtrinsicSuccess'),
        LifecycleRelevantEvent(
          pallet: 'Sudo',
          event: 'Sudid',
          fields: const {
            'sudoResult': {
              'Err': {'BadOrigin': null},
            },
          },
        ),
      ]);

      expect(result.status, DispatchResultStatus.failure);
      expect(result.sudoResult?.status, DispatchResultStatus.failure);
      expect(result.effectiveError?.kind, 'BadOrigin');
    });

    test('nested sudo.Sudid Ok preserves success', () {
      final result = decoder.decode([
        LifecycleRelevantEvent(pallet: 'System', event: 'ExtrinsicSuccess'),
        LifecycleRelevantEvent(
          pallet: 'Sudo',
          event: 'Sudid',
          fields: const {
            'result': {'Ok': null},
          },
        ),
      ]);

      expect(result.status, DispatchResultStatus.success);
      expect(result.sudoResult?.status, DispatchResultStatus.success);
    });

    test('returns unknown when the system result event is absent', () {
      expect(decoder.decode(const []).status, DispatchResultStatus.unknown);
    });
  });

  group('human-safe error guidance', () {
    test(
      'explains permission, balance, nonce, and decoded module failures',
      () {
        expect(
          TransactionErrorGuidance.forError(
            const RuntimeDispatchError(kind: 'BadOrigin'),
          ).title,
          'Permission denied',
        );
        expect(
          TransactionErrorGuidance.forError(
            const RuntimeDispatchError(kind: 'Payment'),
          ).title,
          'Insufficient balance',
        );
        expect(
          TransactionErrorGuidance.forError(
            const RuntimeDispatchError(kind: 'Stale'),
          ).nextStep,
          contains('Never resubmit'),
        );
        expect(
          TransactionErrorGuidance.forError(
            RuntimeDispatchError(
              kind: 'Module',
              moduleError: DecodedModuleError(
                pallet: 'AiPredictions',
                error: 'ModelNotFound',
                docs: const ['Refresh models before trying again.'],
              ),
            ),
          ).nextStep,
          'Refresh models before trying again.',
        );
      },
    );
  });
}
