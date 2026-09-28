import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show decodeHex;

import '../era_v14_compatibility.dart';
import '../generated/era/era.dart' as era_api;
import '../phase6b/transaction_lifecycle.dart';
import '../phase6b/transaction_runner.dart';
import 'v14_chain_services.dart';

typedef V14AuthenticateAndLoadMnemonic =
    Future<String?> Function(String reason);

class V14RuntimeContextProbe {
  static const _runtimeCodeKey = '0x3a636f6465';
  static const _aiStorageVersionKey =
      '0x507d4f0bb08b9e2c877acf6d401c17174e7b9012096b41c4eb3aaf947f6ea429';

  final polkadart.Provider provider;

  const V14RuntimeContextProbe(this.provider);

  Future<EraSigningContext> verify() async {
    final snapshot = await EraV14RuntimeGuard(provider).verify();
    final responses = await Future.wait([
      provider.send('system_health', const []),
      provider.send('state_getStorage', [
        _runtimeCodeKey,
        snapshot.finalizedHead,
      ]),
      provider.send('state_getStorage', [
        _aiStorageVersionKey,
        snapshot.finalizedHead,
      ]),
    ]);
    final health = responses[0].result;
    if (responses[0].error != null || health is! Map) {
      throw StateError('ERA endpoint health is unavailable.');
    }
    if (health['isSyncing'] == true) {
      throw StateError('ERA endpoint is still syncing.');
    }
    final code = _requiredHex(responses[1], 'runtime code');
    final codeHash = await _sha256Hex(code);
    if (codeHash != kEraRuntimeWasmSha256) {
      throw StateError(
        'The deployed runtime code is not the approved V14 code.',
      );
    }
    final storageVersionBytes = _requiredHex(
      responses[2],
      'AI storage version',
    );
    if (storageVersionBytes.length != 2 ||
        storageVersionBytes[0] != 3 ||
        storageVersionBytes[1] != 0) {
      throw StateError('The AI storage-version preservation gate failed.');
    }
    return EraSigningContext(
      genesisHash: snapshot.identity.genesisHash,
      specVersion: snapshot.identity.specVersion,
      transactionVersion: snapshot.identity.transactionVersion,
      metadataHash: snapshot.metadata.sha256,
      runtimeWasmHash: codeHash,
      aiStorageVersion: 3,
    );
  }
}

class V14PreparedReview {
  final V14CallPlan plan;
  final String signer;
  final BigInt estimatedFee;
  final String encodedCallHex;

  const V14PreparedReview({
    required this.plan,
    required this.signer,
    required this.estimatedFee,
    required this.encodedCallHex,
  });
}

class V14TransactionExecutor {
  final polkadart.Provider provider;
  final era_api.Era api;
  final Phase6bTransactionJournal journal;
  final Duration confirmationTimeout;

  V14TransactionExecutor({
    required this.provider,
    required this.api,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    this.confirmationTimeout = const Duration(minutes: 3),
  }) : journal = Phase6bTransactionJournal(storage: storage);

  Future<V14PreparedReview?> prepareReview({
    required V14CallPlan plan,
    required String signer,
    required V14AuthenticateAndLoadMnemonic authenticateAndLoadMnemonic,
  }) async {
    String? mnemonic;
    try {
      mnemonic = await authenticateAndLoadMnemonic(
        'Authenticate to estimate the ${plan.pallet}.${plan.callName} fee',
      );
      if (mnemonic == null) return null;
      final context = await V14RuntimeContextProbe(provider).verify();
      final signerService = EraExtrinsicSigner(provider: provider, api: api);
      final signed = await signerService.sign(
        mnemonic: mnemonic,
        call: plan.call,
        expectedContext: context,
        expectedSignerAddress: signer,
      );
      final fee = await signerService.estimateFee(signed);
      if (fee == null) {
        throw StateError('The exact V14 fee could not be estimated.');
      }
      return V14PreparedReview(
        plan: plan,
        signer: signer,
        estimatedFee: fee,
        encodedCallHex: _hex(plan.call.encode()),
      );
    } finally {
      mnemonic = null;
    }
  }

  Future<TransactionLifecycleRecord> submitReviewed({
    required V14PreparedReview review,
    required BigInt maximumFee,
    required V14AuthenticateAndLoadMnemonic authenticateAndLoadMnemonic,
    TransactionPostStateVerifier? verifyPostState,
    bool requirePostStateVerification = true,
    TransactionRecordListener? onUpdate,
  }) async {
    if (review.estimatedFee > maximumFee) {
      throw StateError('The reviewed fee exceeds the approved ceiling.');
    }
    final runner = Phase6bTransactionRunner(
      provider: provider,
      api: api,
      journal: journal,
      confirmationTimeout: confirmationTimeout,
    );
    await runner.hydrateDuplicateGuard();
    String? mnemonic;
    try {
      return await runner.submit(
        intent: TransactionIntent(
          pallet: review.plan.pallet,
          call: review.plan.callName,
          argumentsSummary: review.plan.arguments,
          signer: review.signer,
        ),
        authenticate: () async {
          mnemonic = await authenticateAndLoadMnemonic(
            'Authenticate to sign ${review.plan.pallet}.${review.plan.callName}',
          );
          return mnemonic != null;
        },
        recheckRuntime: () => V14RuntimeContextProbe(provider).verify(),
        sign: (context) async {
          final secret = mnemonic;
          if (secret == null) {
            throw StateError(
              'Authentication did not provide signing material.',
            );
          }
          final signerService = EraExtrinsicSigner(
            provider: provider,
            api: api,
          );
          final signed = await signerService.sign(
            mnemonic: secret,
            call: review.plan.call,
            expectedContext: context,
            expectedSignerAddress: review.signer,
          );
          final freshFee = await signerService.estimateFee(signed);
          if (freshFee == null || freshFee > maximumFee) {
            throw StateError(
              'The fresh fee is unavailable or exceeds the approved ceiling.',
            );
          }
          return signed;
        },
        verifyPostState: verifyPostState,
        requirePostStateVerification: requirePostStateVerification,
        onUpdate: onUpdate,
      );
    } finally {
      mnemonic = null;
    }
  }
}

Uint8List _requiredHex(polkadart.RpcResponse response, String label) {
  if (response.error != null || response.result is! String) {
    throw StateError('The $label is unavailable.');
  }
  final text = response.result! as String;
  final normalized = text.startsWith('0x') ? text.substring(2) : text;
  return Uint8List.fromList(decodeHex(normalized));
}

Future<String> _sha256Hex(List<int> bytes) async {
  final digest = await Sha256().hash(bytes);
  return digest.bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}

String _hex(List<int> bytes) =>
    '0x${bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join()}';
