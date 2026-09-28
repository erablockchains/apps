import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:polkadart/polkadart.dart';
import 'package:substrate_metadata/substrate_metadata.dart';

const _defaultEndpoint = 'wss://eraprojects.org/';
const _expectedChainName = 'ERA-MAINNET';
const _expectedGenesisHash =
    '0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7';
const _expectedSpecName = 'era';
const _expectedSpecVersion = 13;
const _expectedTransactionVersion = 1;
const _expectedMetadataVersion = 14;
const _approvedMetadataSha256 =
    '5c3715502b0f4cd3c3bc124f13f7f153cd3486e0c3877dc1d685335e57ed4c3f';
const _approvedRuntimeWasmSha256 =
    'ecca5baddc60d4e8522c8ea6206fec0c29175d59ddf2359e6d43201f1faa44a2';
const _approvedMetadataBytes = 209828;
const _approvedRuntimeCodeBytes = 997122;
const _aiPredictionsStorageVersionKey =
    '0x507d4f0bb08b9e2c877acf6d401c17174e7b9012096b41c4eb3aaf947f6ea429';
const _runtimeCodeKey = '0x3a636f6465';

Future<void> main(List<String> arguments) async {
  final options = _DiscoveryOptions.parse(arguments);
  if (options.showHelp) {
    stdout.writeln(
      'Usage: dart run tool/phase6b_metadata_discovery.dart '
      '[--offline | --live] [--write-artifacts]\n'
      '\n'
      'No mode flag means --offline. Network access requires explicit --live.',
    );
    return;
  }
  await _requireProjectRoot();
  if (!options.live) {
    await _decodePinnedMetadata(writeArtifacts: options.writeArtifacts);
    return;
  }
  final configuredEndpoint =
      Platform.environment['ERA_WS_ENDPOINT'] ?? _defaultEndpoint;
  final endpoint = _parseLiveEndpoint(configuredEndpoint);
  final publicEndpoint = Uri(
    scheme: endpoint.scheme,
    host: endpoint.host,
    port: endpoint.hasPort ? endpoint.port : null,
  ).toString();
  // Keep credentials, paths, and query parameters confined to the connection.
  final provider = Provider.fromUri(endpoint);

  try {
    final finalizedHead =
        (await provider
                    .send('chain_getFinalizedHead', const [])
                    .timeout(const Duration(seconds: 30)))
                .result
            as String;
    final responses = await Future.wait([
      provider.send('system_chain', const []),
      provider.send('state_getRuntimeVersion', [finalizedHead]),
      provider.send('chain_getBlockHash', const [0]),
      provider.send('state_getMetadata', [finalizedHead]),
      provider.send('system_health', const []),
      provider.send('state_getStorage', [
        _aiPredictionsStorageVersionKey,
        finalizedHead,
      ]),
      provider.send('state_getStorage', [_runtimeCodeKey, finalizedHead]),
    ]).timeout(const Duration(seconds: 30));

    final chainName = responses[0].result as String;
    final runtimeVersion = Map<String, dynamic>.from(
      responses[1].result as Map,
    );
    final genesisHash = responses[2].result as String;
    final metadataHex = responses[3].result as String;
    final health = Map<String, dynamic>.from(responses[4].result as Map);
    final storageVersionHex = responses[5].result as String?;
    final runtimeCodeHex = responses[6].result as String?;
    if (storageVersionHex == null || runtimeCodeHex == null) {
      throw StateError('The node did not return required runtime storage.');
    }

    final metadataBytes = _decodeHex(metadataHex);
    final digest = await Sha256().hash(metadataBytes);
    final metadataSha256 = _encodeHex(digest.bytes);
    final prefixed = RuntimeMetadataPrefixed.fromBytes(metadataBytes);
    final metadata = prefixed.metadata;
    final runtimeCodeBytes = _decodeHex(runtimeCodeHex);
    final runtimeWasmDigest = await Sha256().hash(runtimeCodeBytes);
    final runtimeWasmSha256 = _encodeHex(runtimeWasmDigest.bytes);

    final specName = runtimeVersion['specName'] as String?;
    final specVersion = runtimeVersion['specVersion'] as int?;
    final transactionVersion = runtimeVersion['transactionVersion'] as int?;
    if (chainName != _expectedChainName ||
        genesisHash != _expectedGenesisHash) {
      throw StateError(
        'Refusing discovery for unexpected chain $chainName/$genesisHash.',
      );
    }
    if (specName != _expectedSpecName ||
        specVersion != _expectedSpecVersion ||
        transactionVersion != _expectedTransactionVersion) {
      throw StateError(
        'Refusing discovery for unexpected runtime '
        '$specName/$specVersion/$transactionVersion (expected '
        '$_expectedSpecName/$_expectedSpecVersion/'
        '$_expectedTransactionVersion).',
      );
    }
    if (metadata.runtimeMetadataVersion() != _expectedMetadataVersion) {
      throw StateError(
        'Metadata version drift detected: '
        '${metadata.runtimeMetadataVersion()}.',
      );
    }
    if (metadataSha256 != _approvedMetadataSha256) {
      throw StateError(
        'Metadata drift detected: $metadataSha256 does not match '
        '$_approvedMetadataSha256.',
      );
    }
    if (metadataBytes.length != _approvedMetadataBytes) {
      throw StateError(
        'Metadata length drift detected: ${metadataBytes.length} does not '
        'match $_approvedMetadataBytes.',
      );
    }
    if (storageVersionHex.toLowerCase() != '0x0300') {
      throw StateError(
        'AI Predictions storage-version drift detected: '
        '$storageVersionHex.',
      );
    }
    if (runtimeWasmSha256 != _approvedRuntimeWasmSha256) {
      throw StateError(
        'Runtime WASM drift detected: $runtimeWasmSha256 does not match '
        '$_approvedRuntimeWasmSha256.',
      );
    }
    if (runtimeCodeBytes.length != _approvedRuntimeCodeBytes) {
      throw StateError(
        'Runtime WASM length drift detected: ${runtimeCodeBytes.length} does '
        'not match $_approvedRuntimeCodeBytes.',
      );
    }

    final runtimeSummary = <String, dynamic>{
      'capturedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'endpoint': publicEndpoint,
      'chainName': chainName,
      'genesisHash': genesisHash,
      'runtimeVersion': runtimeVersion,
      'metadataVersion': metadata.runtimeMetadataVersion(),
      'metadataBytes': metadataBytes.length,
      'metadataSha256': metadataSha256,
      'runtimeCodeBytes': runtimeCodeBytes.length,
      'runtimeWasmSha256': runtimeWasmSha256,
      'aiPredictionsStorageVersionKey': _aiPredictionsStorageVersionKey,
      'aiPredictionsStorageVersionRaw': storageVersionHex,
      'aiPredictionsStorageVersion': 3,
      'finalizedHead': finalizedHead,
      'health': health,
      'pallets': [
        for (final pallet in metadata.pallets)
          {
            'name': pallet.name,
            'index': pallet.index,
            'storagePrefix': pallet.storage?.prefix,
            'callType': pallet.calls?.type,
            'eventType': pallet.event?.type,
            'errorType': pallet.error?.type,
          },
      ],
    };

    stdout.writeln(const JsonEncoder.withIndent('  ').convert(runtimeSummary));

    if (options.writeArtifacts) {
      final directory = Directory('artifacts/phase6b');
      await directory.create(recursive: true);
      await File(
        '${directory.path}/era-spec13-metadata.scale',
      ).writeAsBytes(metadataBytes, flush: true);
      await File('${directory.path}/era-spec13-metadata.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(prefixed.toJson()),
        flush: true,
      );
      await File('${directory.path}/era-spec13-runtime.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(runtimeSummary),
        flush: true,
      );
    }
  } finally {
    if (provider.isConnected()) {
      await provider.disconnect();
    }
  }
}

Uri _parseLiveEndpoint(String value) {
  late final Uri endpoint;
  try {
    endpoint = Uri.parse(value);
  } on FormatException {
    throw ArgumentError('ERA_WS_ENDPOINT must be a valid WSS URL.');
  }
  if (endpoint.scheme.toLowerCase() != 'wss' || endpoint.host.isEmpty) {
    throw ArgumentError('ERA_WS_ENDPOINT must use WSS and include a host.');
  }
  return endpoint;
}

Future<void> _decodePinnedMetadata({required bool writeArtifacts}) async {
  final metadataFile = File('artifacts/phase6b/era-spec13-metadata.scale');
  final runtimeFile = File('artifacts/phase6b/era-spec13-runtime-rpc.json');
  if (!await metadataFile.exists() || !await runtimeFile.exists()) {
    throw StateError(
      'Pinned metadata is missing. Run '
      '`node tool/capture_phase6b_metadata.mjs --live` first.',
    );
  }

  final metadataBytes = await metadataFile.readAsBytes();
  final digest = await Sha256().hash(metadataBytes);
  final metadataSha256 = _encodeHex(digest.bytes);
  if (metadataSha256 != _approvedMetadataSha256) {
    throw StateError(
      'Pinned metadata drift detected: $metadataSha256 does not match '
      '$_approvedMetadataSha256.',
    );
  }

  final prefixed = RuntimeMetadataPrefixed.fromBytes(metadataBytes);
  final metadata = prefixed.metadata;
  final runtimeSummary = Map<String, dynamic>.from(
    jsonDecode(await runtimeFile.readAsString()) as Map,
  );
  final version = Map<String, dynamic>.from(
    runtimeSummary['runtimeVersion'] as Map,
  );
  if (version['specName'] != _expectedSpecName ||
      version['specVersion'] != _expectedSpecVersion ||
      version['transactionVersion'] != _expectedTransactionVersion ||
      runtimeSummary['chainName'] != _expectedChainName ||
      runtimeSummary['genesisHash'] != _expectedGenesisHash) {
    throw StateError('Pinned runtime summary is not ERA spec 13.');
  }
  if (metadata.runtimeMetadataVersion() != _expectedMetadataVersion) {
    throw StateError('Pinned metadata is not metadata V14.');
  }
  if (metadataBytes.length != _approvedMetadataBytes ||
      runtimeSummary['metadataBytes'] != metadataBytes.length ||
      runtimeSummary['metadataSha256'] != metadataSha256 ||
      runtimeSummary['metadataVersion'] != _expectedMetadataVersion) {
    throw StateError(
      'Pinned runtime summary metadata evidence does not match the SCALE '
      'artifact.',
    );
  }

  runtimeSummary['metadataVersion'] = metadata.runtimeMetadataVersion();
  final derivedStorageVersionKey =
      '0x${_encodeHex([...Hasher.twoxx128.hashString('AiPredictions'), ...Hasher.twoxx128.hashString(':__STORAGE_VERSION__:')])}';
  if (derivedStorageVersionKey != _aiPredictionsStorageVersionKey) {
    throw StateError('Derived AI Predictions storage key drifted.');
  }
  if (runtimeSummary['aiPredictionsStorageVersionKey'] !=
          derivedStorageVersionKey ||
      runtimeSummary['aiPredictionsStorageVersionRaw'] != '0x0300' ||
      runtimeSummary['aiPredictionsStorageVersion'] != 3) {
    throw StateError(
      'Pinned runtime summary AI Predictions storage-version evidence is '
      'missing or invalid.',
    );
  }
  if (runtimeSummary['runtimeCodeBytes'] != _approvedRuntimeCodeBytes ||
      runtimeSummary['runtimeWasmSha256'] != _approvedRuntimeWasmSha256) {
    throw StateError(
      'Pinned runtime summary WASM evidence is missing or invalid.',
    );
  }
  runtimeSummary['aiPredictionsStorageVersionKey'] = derivedStorageVersionKey;
  runtimeSummary['pallets'] = [
    for (final pallet in metadata.pallets)
      {
        'name': pallet.name,
        'index': pallet.index,
        'storagePrefix': pallet.storage?.prefix,
        'callType': pallet.calls?.type,
        'eventType': pallet.event?.type,
        'errorType': pallet.error?.type,
      },
  ];

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(runtimeSummary));
  if (writeArtifacts) {
    await File('artifacts/phase6b/era-spec13-metadata.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefixed.toJson()),
      flush: true,
    );
    await File('artifacts/phase6b/era-spec13-runtime.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(runtimeSummary),
      flush: true,
    );
  }
}

Uint8List _decodeHex(String value) {
  final normalized = value.startsWith('0x') ? value.substring(2) : value;
  if (normalized.length.isOdd) {
    throw const FormatException('Metadata hex has an odd number of digits.');
  }
  return Uint8List.fromList([
    for (var offset = 0; offset < normalized.length; offset += 2)
      int.parse(normalized.substring(offset, offset + 2), radix: 16),
  ]);
}

String _encodeHex(List<int> bytes) =>
    bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();

Future<void> _requireProjectRoot() async {
  final pubspec = File('pubspec.yaml');
  final appEntryPoint = File('lib/main.dart');
  if (!await pubspec.exists() || !await appEntryPoint.exists()) {
    throw StateError(
      'Run this tool from the ERA Wallet project root (pubspec.yaml and '
      'lib/main.dart are required).',
    );
  }
  final pubspecSource = await pubspec.readAsString();
  if (!RegExp(
    r'^name:\s*era_wallet\s*$',
    multiLine: true,
  ).hasMatch(pubspecSource)) {
    throw StateError('The current project is not the ERA Wallet package.');
  }
}

final class _DiscoveryOptions {
  const _DiscoveryOptions({
    required this.live,
    required this.writeArtifacts,
    required this.showHelp,
  });

  final bool live;
  final bool writeArtifacts;
  final bool showHelp;

  static _DiscoveryOptions parse(List<String> arguments) {
    const allowed = {'--offline', '--live', '--write-artifacts', '--help'};
    final unknown = arguments.where((argument) => !allowed.contains(argument));
    if (unknown.isNotEmpty) {
      throw ArgumentError('Unknown argument(s): ${unknown.join(', ')}');
    }
    if (arguments.toSet().length != arguments.length) {
      throw ArgumentError('Duplicate command-line flags are not allowed.');
    }
    final offline = arguments.contains('--offline');
    final live = arguments.contains('--live');
    if (offline && live) {
      throw ArgumentError('--offline and --live cannot be used together.');
    }
    final help = arguments.contains('--help');
    if (help && arguments.length != 1) {
      throw ArgumentError('--help cannot be combined with other flags.');
    }
    return _DiscoveryOptions(
      live: live,
      writeArtifacts: arguments.contains('--write-artifacts'),
      showHelp: help,
    );
  }
}
