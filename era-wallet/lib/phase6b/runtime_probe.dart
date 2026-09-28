import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show decodeHex;
import 'package:polkadart_keyring/polkadart_keyring.dart';

import '../config.dart';
import '../generated/era/era.dart' as era_api;
import 'runtime_compatibility.dart';
import 'runtime_metadata_adapter.dart';

const String phase6bAiStorageVersionKey =
    '0x507d4f0bb08b9e2c877acf6d401c17174e7b9012096b41c4eb3aaf947f6ea429';
const String phase6bRuntimeCodeKey = '0x3a636f6465';

class Phase6bRuntimeDiagnostics {
  final String endpoint;
  final String chainName;
  final String genesisHash;
  final String specName;
  final int specVersion;
  final int transactionVersion;
  final int metadataVersion;
  final String metadataHash;
  final String runtimeWasmHash;
  final int? aiStorageVersion;
  final int latestBestBlock;
  final int latestFinalizedBlock;
  final int peerCount;
  final bool syncing;
  final String? activeAccount;
  final int? accountNonce;
  final BigInt? freeBalance;
  final DateTime refreshedAt;
  final RuntimePalletFingerprint? aiPredictionsPallet;
  final RuntimeCompatibilityResult compatibility;
  final List<String> warnings;

  const Phase6bRuntimeDiagnostics({
    required this.endpoint,
    required this.chainName,
    required this.genesisHash,
    required this.specName,
    required this.specVersion,
    required this.transactionVersion,
    required this.metadataVersion,
    required this.metadataHash,
    required this.runtimeWasmHash,
    required this.aiStorageVersion,
    required this.latestBestBlock,
    required this.latestFinalizedBlock,
    required this.peerCount,
    required this.syncing,
    required this.activeAccount,
    required this.accountNonce,
    required this.freeBalance,
    required this.refreshedAt,
    required this.aiPredictionsPallet,
    required this.compatibility,
    required this.warnings,
  });

  List<String> get discoveredCalls {
    if (!compatibility.metadataCompatible) return const [];
    final calls = aiPredictionsPallet?.calls.values.toList(growable: false);
    if (calls == null) return const [];
    calls.sort((left, right) {
      final byIndex = left.index.compareTo(right.index);
      return byIndex != 0 ? byIndex : left.name.compareTo(right.name);
    });
    return calls
        .map((call) => '${call.index}: ${call.name}')
        .toList(growable: false);
  }

  List<String> get discoveredStorage {
    if (!compatibility.metadataCompatible) return const [];
    return aiPredictionsPallet?.storage.values
            .map((storage) => storage.name)
            .toList(growable: false) ??
        const [];
  }

  Map<String, Object?> toJson({
    int pendingTransactions = 0,
    int unresolvedTransactions = 0,
  }) => {
    'rpcEndpoint': endpoint,
    'chainName': chainName,
    'genesisHash': genesisHash,
    'runtime': {
      'specName': specName,
      'specVersion': specVersion,
      'transactionVersion': transactionVersion,
    },
    'metadata': {
      'version': metadataVersion,
      'sha256': metadataHash,
      'compatible': compatibility.metadataCompatible,
      'driftDetected': compatibility.metadataDriftDetected,
    },
    'runtimeWasmSha256': runtimeWasmHash,
    'aiPredictions': {
      'palletName': aiPredictionsPallet?.name,
      'palletIndex': aiPredictionsPallet?.index,
      'storagePrefix': aiPredictionsPallet?.storagePrefix,
      'storageVersion': aiStorageVersion,
      'calls': discoveredCalls,
      'storage': discoveredStorage,
    },
    'latestBestBlock': latestBestBlock,
    'latestFinalizedBlock': latestFinalizedBlock,
    'peerCount': peerCount,
    'syncing': syncing,
    'activeAccount': activeAccount,
    'accountNonce': accountNonce,
    'freeBalanceBaseUnits': freeBalance?.toString(),
    'compatibilityMode': compatibility.level.label,
    'participantSigningEnabled': compatibility.participantSigningEnabled,
    'operatorToolsEnabled': compatibility.testingToolsEnabled,
    'governanceActionsEnabled': compatibility.governanceActionsEnabled,
    'lastMetadataRefresh': refreshedAt.toUtc().toIso8601String(),
    'pendingTransactionCount': pendingTransactions,
    'unresolvedTransactionCount': unresolvedTransactions,
    'warnings': [
      ...warnings,
      ...compatibility.warnings,
      ...compatibility.issues.map((issue) => issue.explanation),
    ],
  };

  String exportJson({
    int pendingTransactions = 0,
    int unresolvedTransactions = 0,
  }) => const JsonEncoder.withIndent('  ').convert(
    toJson(
      pendingTransactions: pendingTransactions,
      unresolvedTransactions: unresolvedTransactions,
    ),
  );
}

class Phase6bRuntimeProbe {
  final polkadart.Provider provider;
  final era_api.Era api;
  final String endpoint;
  final Phase6bBuildFlags flags;
  final Phase6bRuntimeMetadataAdapter metadataAdapter;
  final Future<String> Function(List<int> bytes) runtimeCodeHasher;

  const Phase6bRuntimeProbe({
    required this.provider,
    required this.api,
    this.endpoint = kDefaultEraWsEndpoint,
    this.flags = const Phase6bBuildFlags.fromEnvironment(),
    this.metadataAdapter = const Phase6bRuntimeMetadataAdapter(),
    this.runtimeCodeHasher = _sha256,
  });

  Future<Phase6bRuntimeDiagnostics> refresh({String? activeAccount}) async {
    final warnings = <String>[];
    final finalizedHeadResponse = await provider.send(
      'chain_getFinalizedHead',
      const [],
    );
    final finalizedHash = _requiredString(
      finalizedHeadResponse,
      'chain_getFinalizedHead',
    );
    final results = await Future.wait([
      provider.send('system_chain', const []),
      provider.send('chain_getBlockHash', const [0]),
      provider.send('state_getRuntimeVersion', [finalizedHash]),
      provider.send('state_getMetadata', [finalizedHash]),
      provider.send('state_getStorage', [
        phase6bAiStorageVersionKey,
        finalizedHash,
      ]),
      provider.send('state_getStorage', [phase6bRuntimeCodeKey, finalizedHash]),
      provider.send('chain_getHeader', const []),
      provider.send('chain_getHeader', [finalizedHash]),
      provider.send('system_health', const []),
    ]);

    final chainName = _requiredString(results[0], 'system_chain');
    final genesisHash = _requiredString(results[1], 'chain_getBlockHash(0)');
    final runtime = _requiredMap(results[2], 'state_getRuntimeVersion');
    final metadataHex = _requiredString(results[3], 'state_getMetadata');
    final metadataBytes = _decodeRpcHex(metadataHex);
    final metadataHash = await _sha256(metadataBytes);
    final runtimeWasmHex = _requiredString(
      results[5],
      'state_getStorage(:code)',
    );
    final runtimeWasmHash = await runtimeCodeHasher(
      _decodeRpcHex(runtimeWasmHex),
    );
    final metadataVersion = _metadataVersion(metadataBytes);
    RuntimePalletFingerprint? aiPredictionsPallet;
    try {
      aiPredictionsPallet = metadataAdapter.decodeAiPredictionsPallet(
        metadataBytes,
      );
    } catch (error) {
      warnings.add(
        'AI Predictions metadata observation failed: ${_safeError(error)}',
      );
    }
    final aiStorageVersion = _decodeStorageVersion(results[4].result);
    if (aiStorageVersion == null) {
      warnings.add('AI Predictions pallet storage version was unavailable.');
    }
    final bestHeader = _requiredMap(results[6], 'chain_getHeader');
    final finalizedHeader = _requiredMap(
      results[7],
      'chain_getHeader(finalized)',
    );
    final health = _requiredMap(results[8], 'system_health');

    final specName = runtime['specName']?.toString() ?? '';
    final specVersion = _rpcInt(runtime['specVersion']);
    final transactionVersion = _rpcInt(runtime['transactionVersion']);
    final metadataMatchesPin =
        _normalizeHash(metadataHash) ==
            Phase6bRuntimeCompatibility.approvedMetadataHash &&
        metadataVersion == Phase6bRuntimeCompatibility.approvedMetadataVersion;
    if (!metadataMatchesPin) {
      warnings.add(
        'Live metadata does not match the pinned spec-13 capture. The decoded '
        'metadata surface will be evaluated fail-closed.',
      );
    }

    final observed = EraRuntimeFingerprint(
      genesisHash: genesisHash,
      specName: specName,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      metadataVersion: metadataVersion,
      metadataHash: metadataHash,
      runtimeWasmHash: runtimeWasmHash,
      aiPredictionsStorageVersion: aiStorageVersion,
      aiPredictionsPallet: aiPredictionsPallet,
    );
    final compatibility = const Phase6bRuntimeCompatibility().assess(
      observed,
      flags: flags,
    );

    int? nonce;
    BigInt? balance;
    if (activeAccount != null && activeAccount.trim().isNotEmpty) {
      try {
        final publicKey = Keyring().decodeAddress(activeAccount.trim());
        final account = await api.query.system.account(
          publicKey,
          at: Uint8List.fromList(_decodeRpcHex(finalizedHash)),
        );
        nonce = account.nonce;
        balance = account.data.free;
      } catch (error) {
        warnings.add('Active-account state unavailable: ${_safeError(error)}');
      }
    }

    return Phase6bRuntimeDiagnostics(
      endpoint: endpoint,
      chainName: chainName,
      genesisHash: genesisHash,
      specName: specName,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      metadataVersion: metadataVersion,
      metadataHash: metadataHash,
      runtimeWasmHash: runtimeWasmHash,
      aiStorageVersion: aiStorageVersion,
      latestBestBlock: _rpcInt(bestHeader['number']),
      latestFinalizedBlock: _rpcInt(finalizedHeader['number']),
      peerCount: _rpcInt(health['peers']),
      syncing: health['isSyncing'] == true,
      activeAccount: activeAccount,
      accountNonce: nonce,
      freeBalance: balance,
      refreshedAt: DateTime.now().toUtc(),
      aiPredictionsPallet: aiPredictionsPallet,
      compatibility: compatibility,
      warnings: warnings,
    );
  }
}

Map _requiredMap(polkadart.RpcResponse response, String method) {
  if (response.error != null || response.result is! Map) {
    throw StateError('$method returned an invalid RPC response.');
  }
  return response.result! as Map;
}

String _requiredString(polkadart.RpcResponse response, String method) {
  if (response.error != null || response.result is! String) {
    throw StateError('$method returned an invalid RPC response.');
  }
  return response.result! as String;
}

int _rpcInt(Object? value) {
  if (value is int) return value;
  if (value is BigInt) return value.toInt();
  final text = value?.toString() ?? '';
  final parsed = text.startsWith('0x')
      ? BigInt.tryParse(text.substring(2), radix: 16)
      : BigInt.tryParse(text);
  if (parsed == null || parsed.isNegative || parsed > BigInt.from(0x7fffffff)) {
    throw StateError(
      'RPC integer is missing or outside the wallet safe range.',
    );
  }
  return parsed.toInt();
}

List<int> _decodeRpcHex(String value) {
  final hex = value.startsWith('0x') ? value.substring(2) : value;
  if (hex.length.isOdd) throw StateError('RPC returned malformed hex.');
  return decodeHex(hex);
}

int _metadataVersion(List<int> bytes) {
  if (bytes.length < 5 ||
      bytes[0] != 0x6d ||
      bytes[1] != 0x65 ||
      bytes[2] != 0x74 ||
      bytes[3] != 0x61) {
    throw StateError('Runtime metadata is missing the SCALE metadata prefix.');
  }
  return bytes[4];
}

int? _decodeStorageVersion(Object? value) {
  if (value is! String || value == '0x') return null;
  final bytes = _decodeRpcHex(value);
  if (bytes.isEmpty || bytes.length > 4) return null;
  var decoded = 0;
  for (var index = 0; index < bytes.length; index++) {
    decoded |= bytes[index] << (8 * index);
  }
  return decoded;
}

Future<String> _sha256(List<int> bytes) async {
  final digest = await Sha256().hash(bytes);
  return digest.bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}

String _normalizeHash(String value) =>
    value.trim().toLowerCase().replaceFirst(RegExp(r'^0x'), '');

String _safeError(Object error) {
  final text = error.toString().replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  return text.length <= 200 ? text : '${text.substring(0, 200)}…';
}
