import 'dart:async';
import 'dart:io';

import 'package:era_wallet/generated/era/era.dart';
import 'package:era_wallet/phase6b/runtime_compatibility.dart';
import 'package:era_wallet/phase6b/runtime_metadata_adapter.dart';
import 'package:era_wallet/phase6b/runtime_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart';

void main() {
  late List<int> metadataBytes;
  late _ArtifactProvider provider;

  setUp(() {
    metadataBytes = File(
      'artifacts/phase6b/era-spec13-metadata.scale',
    ).readAsBytesSync();
    provider = _ArtifactProvider(metadataBytes);
  });

  test(
    'probe observes the pinned artifact instead of supplying signatures',
    () async {
      final diagnostics = await Phase6bRuntimeProbe(
        provider: provider,
        api: Era(provider),
        endpoint: 'ws://artifact.test',
        runtimeCodeHasher: (_) async =>
            Phase6bRuntimeCompatibility.approvedRuntimeWasmHash,
      ).refresh();

      expect(diagnostics.compatibility.metadataCompatible, isTrue);
      expect(diagnostics.discoveredCalls, hasLength(40));
      expect(diagnostics.discoveredCalls.first, '0: register_model');
      expect(diagnostics.discoveredCalls.last, '39: set_model_submitter');
      expect(diagnostics.discoveredStorage, hasLength(32));
      expect(diagnostics.aiPredictionsPallet!.calls, hasLength(40));
      expect(diagnostics.aiPredictionsPallet!.storage, hasLength(32));
    },
  );

  test('unavailable diagnostics do not claim a signing surface', () async {
    final diagnostics = await Phase6bRuntimeProbe(
      provider: provider,
      api: Era(provider),
      metadataAdapter: const _DropApproveModelAdapter(),
      runtimeCodeHasher: (_) async =>
          Phase6bRuntimeCompatibility.approvedRuntimeWasmHash,
    ).refresh();

    expect(diagnostics.compatibility.level, Phase6bCapabilityLevel.unavailable);
    expect(diagnostics.compatibility.signingEnabled, isFalse);
    expect(diagnostics.discoveredCalls, isEmpty);
    expect(diagnostics.discoveredStorage, isEmpty);
    expect(diagnostics.aiPredictionsPallet!.calls, hasLength(39));
    expect(
      diagnostics.compatibility.issues.map((issue) => issue.code),
      contains('missing_call_approve_model'),
    );
  });

  test('legacy diagnostics do not claim the spec-13 surface', () async {
    provider = _ArtifactProvider(
      metadataBytes,
      specVersion: 8,
      storageVersion: 2,
    );
    final diagnostics = await Phase6bRuntimeProbe(
      provider: provider,
      api: Era(provider),
      metadataAdapter: const _LegacySurfaceAdapter(),
      runtimeCodeHasher: (_) async =>
          Phase6bRuntimeCompatibility.approvedRuntimeWasmHash,
    ).refresh();

    expect(
      diagnostics.compatibility.level,
      Phase6bCapabilityLevel.phase6aParticipant,
    );
    expect(diagnostics.discoveredCalls, [
      '31: stake_on_prediction_outcome_side',
      '32: unstake_from_prediction_outcome_side',
      '33: claim_prediction_market_payout',
    ]);
    expect(diagnostics.discoveredStorage, hasLength(9));
    expect(diagnostics.discoveredCalls, isNot(contains('36: approve_model')));
  });
}

class _DropApproveModelAdapter extends Phase6bRuntimeMetadataAdapter {
  const _DropApproveModelAdapter();

  @override
  RuntimePalletFingerprint? decodeAiPredictionsPallet(List<int> metadataBytes) {
    final observed = super.decodeAiPredictionsPallet(metadataBytes)!;
    final calls = Map<String, RuntimeCallSignature>.of(observed.calls)
      ..remove('approve_model');
    return observed.copyWith(calls: calls);
  }
}

class _LegacySurfaceAdapter extends Phase6bRuntimeMetadataAdapter {
  const _LegacySurfaceAdapter();

  @override
  RuntimePalletFingerprint? decodeAiPredictionsPallet(List<int> metadataBytes) {
    final observed = super.decodeAiPredictionsPallet(metadataBytes)!;
    final callNames = Phase6bRuntimeCompatibility.phase6aParticipantCalls
        .map((call) => call.name)
        .toSet();
    final storageNames = Phase6bRuntimeCompatibility.phase6aParticipantStorage
        .map((storage) => storage.name)
        .toSet();
    return observed.copyWith(
      calls: Map.fromEntries(
        observed.calls.entries.where((entry) => callNames.contains(entry.key)),
      ),
      storage: Map.fromEntries(
        observed.storage.entries.where(
          (entry) => storageNames.contains(entry.key),
        ),
      ),
    );
  }
}

class _ArtifactProvider extends Provider {
  _ArtifactProvider(
    List<int> metadataBytes, {
    this.specVersion = Phase6bRuntimeCompatibility.approvedSpecVersion,
    this.storageVersion = Phase6bRuntimeCompatibility.approvedAiStorageVersion,
  }) : metadataHex = '0x${_encodeHex(metadataBytes)}';

  final String metadataHex;
  final int specVersion;
  final int storageVersion;

  @override
  Future<RpcResponse> send(String method, List<dynamic> params) async {
    final result = switch (method) {
      'system_chain' => 'ERA Artifact',
      'chain_getBlockHash' => Phase6bRuntimeCompatibility.approvedGenesisHash,
      'state_getRuntimeVersion' => <String, Object>{
        'specName': Phase6bRuntimeCompatibility.approvedSpecName,
        'specVersion': specVersion,
        'transactionVersion':
            Phase6bRuntimeCompatibility.approvedTransactionVersion,
      },
      'state_getMetadata' => metadataHex,
      'state_getStorage' =>
        '0x${storageVersion.toRadixString(16).padLeft(2, '0')}',
      'chain_getHeader' => <String, Object>{
        'number': params.isEmpty ? '0x64' : '0x60',
      },
      'chain_getFinalizedHead' => '0xfinalized',
      'system_health' => <String, Object>{'peers': 5, 'isSyncing': false},
      _ => throw StateError('Unexpected RPC method $method.'),
    };
    return RpcResponse(id: 1, result: result);
  }

  @override
  bool isConnected() => true;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) {
    throw UnsupportedError('Subscriptions are not used by this test.');
  }
}

String _encodeHex(List<int> bytes) =>
    bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
