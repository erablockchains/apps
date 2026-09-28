import 'dart:async';
import 'dart:typed_data';

import 'package:era_wallet/generated/era/era.dart';
import 'package:era_wallet/phase6b/transaction_lifecycle.dart';
import 'package:era_wallet/phase6b/transaction_runner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart/scale_codec.dart' show encodeHex;

const _testGenesisHash =
    '0x1111111111111111111111111111111111111111111111111111111111111111';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'ambiguous watch status stays duplicate-protected and is persisted',
    () async {
      final provider = _WatchProvider(_WatchScenario.dropped);
      final journal = Phase6bTransactionJournal(
        storage: const FlutterSecureStorage(),
      );
      final record = await _runner(provider, journal).submit(
        intent: _intent('drop'),
        recheckRuntime: _signingContext,
        authenticate: () async => true,
        sign: (_) async => _signed(),
      );

      expect(record.state, TransactionLifecycleState.unknownNeedsVerification);
      expect(record.protectsAgainstDuplicate, isTrue);
      expect(provider.cancelled, isTrue);
      expect((await journal.load()).single.state, record.state);
    },
  );

  test(
    'missing extrinsic in callback block records no false block evidence',
    () async {
      final provider = _WatchProvider(_WatchScenario.missingFromBlock);
      final journal = Phase6bTransactionJournal(
        storage: const FlutterSecureStorage(),
      );
      final record = await _runner(provider, journal).submit(
        intent: _intent('missing'),
        recheckRuntime: _signingContext,
        authenticate: () async => true,
        sign: (_) async => _signed(),
      );

      expect(record.state, TransactionLifecycleState.unknownNeedsVerification);
      expect(record.inclusionBlock, isNull);
      expect(record.finalityBlock, isNull);
      expect(record.relevantEvents, isEmpty);
    },
  );

  test(
    'status processing failure transitions to recoverable unknown state',
    () async {
      final provider = _WatchProvider(_WatchScenario.blockReadFailure);
      final journal = Phase6bTransactionJournal(
        storage: const FlutterSecureStorage(),
      );
      final record = await _runner(provider, journal).submit(
        intent: _intent('read-error'),
        recheckRuntime: _signingContext,
        authenticate: () async => true,
        sign: (_) async => _signed(),
      );

      expect(record.state, TransactionLifecycleState.unknownNeedsVerification);
      expect(record.protectsAgainstDuplicate, isTrue);
      expect(provider.cancelled, isTrue);
    },
  );

  test('durable pre-submit hook can stop broadcast safely', () async {
    final provider = _WatchProvider(_WatchScenario.dropped);
    final journal = Phase6bTransactionJournal(
      storage: const FlutterSecureStorage(),
    );

    await expectLater(
      _runner(provider, journal).submit(
        intent: _intent('checkpoint-failure'),
        recheckRuntime: _signingContext,
        authenticate: () async => true,
        sign: (_) async => _signed(),
        beforeSubmit: (record) async {
          expect(record.state, TransactionLifecycleState.submitting);
          expect(record.txHash, isNotNull);
          throw StateError('fixture checkpoint failure');
        },
      ),
      throwsStateError,
    );

    expect(provider.subscribed, isFalse);
    expect(
      (await journal.load()).single.state,
      TransactionLifecycleState.failed,
    );
  });

  test('full finalized mortality window proves a transaction absent', () async {
    final provider = _RecoveryProvider();
    final journal = Phase6bTransactionJournal(
      storage: const FlutterSecureStorage(),
    );
    final record = _unknownRecoveryRecord('absent');

    final result = await _runner(provider, journal).verifyUnknown(record);

    expect(result.status, ChainVerificationStatus.notFound);
    expect(result.reconciledRecord?.state, TransactionLifecycleState.failed);
    expect(result.evidence['mortalityDeathExclusive'], 6);
    expect(
      (await journal.load()).single.state,
      TransactionLifecycleState.failed,
    );
  });

  test('orphan inclusion evidence is never promoted to finality', () async {
    final provider = _RecoveryProvider();
    final journal = Phase6bTransactionJournal(
      storage: const FlutterSecureStorage(),
    );
    final orphanHash = _hash(99);
    var record = _unknownRecoveryRecord('orphan', asSubmitted: true);
    record = record.transitionTo(
      TransactionLifecycleState.inBlock,
      inclusionBlock: BlockReference(number: BigInt.from(2), hash: orphanHash),
    );
    record = record.transitionTo(
      TransactionLifecycleState.unknownNeedsVerification,
    );

    final result = await _runner(provider, journal).verifyUnknown(record);

    expect(result.status, ChainVerificationStatus.notFound);
    expect(result.evidence['nonCanonicalStoredEvidence'], contains(orphanHash));
    expect(result.reconciledRecord?.finalityBlock, isNull);
  });

  test('recovery on a different genesis remains inconclusive', () async {
    final provider = _RecoveryProvider(observedGenesis: _hash(777));
    final journal = Phase6bTransactionJournal(
      storage: const FlutterSecureStorage(),
    );

    final result = await _runner(
      provider,
      journal,
    ).verifyUnknown(_unknownRecoveryRecord('wrong-chain'));

    expect(result.status, ChainVerificationStatus.inconclusive);
    expect(result.evidence['reason'], contains('different chain'));
    expect(await journal.load(), isEmpty);
  });
}

Phase6bTransactionRunner _runner(
  Provider provider,
  Phase6bTransactionJournal journal,
) => Phase6bTransactionRunner(
  provider: provider,
  api: Era(provider),
  journal: journal,
  confirmationTimeout: const Duration(seconds: 2),
);

TransactionIntent _intent(String suffix) => TransactionIntent(
  pallet: 'AiPredictions',
  call: 'stake_on_prediction_outcome_side',
  argumentsSummary: {'token_id': suffix},
  signer: '5FixturePublicSigner',
);

Future<EraSigningContext> _signingContext() async => const EraSigningContext(
  genesisHash: _testGenesisHash,
  specVersion: 9,
  transactionVersion: 1,
  metadataHash: 'metadata',
  runtimeWasmHash: 'wasm',
  aiStorageVersion: 3,
);

SignedEraExtrinsic _signed() => SignedEraExtrinsic(
  bytes: Uint8List.fromList(const [1, 2, 3, 4]),
  nonce: BigInt.one,
  mortalityReferenceBlock: BigInt.from(42),
  mortalityPeriod: 64,
);

TransactionLifecycleRecord _unknownRecoveryRecord(
  String suffix, {
  bool asSubmitted = false,
}) {
  final signed = _signed();
  final txHash = '0x${encodeHex(Hasher.blake2b256.hash(signed.bytes))}';
  var record = TransactionLifecycleRecord.preparing(
    intent: _intent(suffix),
    createdAt: DateTime.utc(2026, 7, 16, 12),
  );
  record = record.transitionTo(
    TransactionLifecycleState.awaitingAuthentication,
  );
  record = record.transitionTo(TransactionLifecycleState.signing);
  record = record.transitionTo(
    TransactionLifecycleState.submitting,
    nonce: signed.nonce,
    genesisHash: _RecoveryProvider.genesisHash,
    mortalityReferenceBlock: BigInt.from(2),
    mortalityPeriod: 4,
    txHash: txHash,
    submittedAt: DateTime.utc(2026, 7, 16, 12, 1),
  );
  record = record.transitionTo(TransactionLifecycleState.submitted);
  return asSubmitted
      ? record
      : record.transitionTo(TransactionLifecycleState.unknownNeedsVerification);
}

enum _WatchScenario { dropped, missingFromBlock, blockReadFailure }

class _WatchProvider extends Provider {
  static const blockHash =
      '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  final _WatchScenario scenario;
  bool cancelled = false;
  bool subscribed = false;

  _WatchProvider(this.scenario);

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  bool isConnected() => true;

  @override
  Future<RpcResponse> send(String method, List<dynamic> params) async {
    if (method == 'author_unwatchExtrinsic') {
      return RpcResponse(id: 1, result: true);
    }
    if (method == 'chain_getBlock') {
      if (scenario == _WatchScenario.blockReadFailure) {
        return RpcResponse(id: 2, error: 'fixture block read failure');
      }
      return RpcResponse(
        id: 2,
        result: {
          'block': {
            'header': {'number': '0x2a'},
            'extrinsics': <String>[],
          },
        },
      );
    }
    throw StateError('Unexpected RPC method in test: $method');
  }

  @override
  Future<SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) async {
    if (method != 'author_submitAndWatchExtrinsic') {
      throw StateError('Unexpected subscription method in test: $method');
    }
    subscribed = true;
    late final StreamController<SubscriptionMessage> controller;
    controller = StreamController<SubscriptionMessage>(
      onCancel: () async {
        cancelled = true;
        await onCancel?.call('fixture-subscription');
      },
    );
    scheduleMicrotask(() {
      controller.add(
        SubscriptionMessage(
          method: 'author_extrinsicUpdate',
          subscription: 'fixture-subscription',
          result: scenario == _WatchScenario.dropped
              ? 'dropped'
              : {'inBlock': blockHash},
        ),
      );
    });
    return SubscriptionResponse(
      id: 'fixture-subscription',
      stream: controller.stream,
    );
  }
}

String _hash(int number) => '0x${number.toRadixString(16).padLeft(64, '0')}';

class _RecoveryProvider extends Provider {
  static const genesisHash =
      '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
  final String observedGenesis;

  _RecoveryProvider({this.observedGenesis = genesisHash});

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  bool isConnected() => true;

  @override
  Future<RpcResponse> send(String method, List<dynamic> params) async {
    switch (method) {
      case 'author_pendingExtrinsics':
        return RpcResponse(id: 1, result: <String>[]);
      case 'chain_getBlockHash':
        return RpcResponse(id: 6, result: observedGenesis);
      case 'chain_getFinalizedHead':
        return RpcResponse(id: 2, result: _hash(6));
      case 'chain_getHeader':
        return RpcResponse(id: 3, result: {'number': '0x6'});
      case 'state_getStorage':
        final key = params.first as String;
        final encoded = key.substring(key.length - 8);
        final bytes = <int>[
          for (var offset = 0; offset < 8; offset += 2)
            int.parse(encoded.substring(offset, offset + 2), radix: 16),
        ];
        final number =
            bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24);
        return RpcResponse(id: 4, result: _hash(number));
      case 'chain_getBlock':
        final hash = params.single as String;
        final orphan = hash == _hash(99);
        final number = orphan
            ? 2
            : int.parse(hash.substring(hash.length - 8), radix: 16);
        return RpcResponse(
          id: 5,
          result: {
            'block': {
              'header': {'number': '0x${number.toRadixString(16)}'},
              'extrinsics': orphan ? <String>['0x01020304'] : <String>[],
            },
          },
        );
    }
    throw StateError('Unexpected recovery RPC method in test: $method');
  }

  @override
  Future<SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) => throw UnsupportedError('Recovery tests do not subscribe.');
}
