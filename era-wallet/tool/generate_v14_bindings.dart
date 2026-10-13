import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:polkadart_cli/polkadart_cli.dart';
import 'package:substrate_metadata/substrate_metadata.dart';

const _approvedMetadataSha256 =
    '574931f693241cb62e1ad2990eda55e2250c36c9c0de852b0380eac480c8496a';

const _requiredPallets = <String, int>{
  'Balances': 2,
  'Staking': 10,
  'AiPredictions': 12,
  'Nfts': 17,
  'SecurityBudget': 20,
  'EraV14AssetAllocator': 27,
};

Future<void> main(List<String> arguments) async {
  const allowedArguments = {'--install', '--verbose', '--help'};
  final unknown = arguments.where(
    (argument) => !allowedArguments.contains(argument),
  );
  if (unknown.isNotEmpty) {
    throw ArgumentError('Unknown argument(s): ${unknown.join(', ')}');
  }
  if (arguments.toSet().length != arguments.length) {
    throw ArgumentError('Duplicate command-line flags are not allowed.');
  }
  if (arguments.contains('--help')) {
    if (arguments.length != 1) {
      throw ArgumentError('--help cannot be combined with other flags.');
    }
    stdout.writeln(
      'Usage: dart run tool/generate_v14_bindings.dart '
      '[--install] [--verbose]',
    );
    return;
  }

  final install = arguments.contains('--install');
  final verbose = arguments.contains('--verbose');
  final workspace = await _requireProjectRoot();
  final metadataFile = File(
    '$workspace${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
    'v14${Platform.pathSeparator}era-spec16-metadata.scale',
  );
  if (!await metadataFile.exists()) {
    throw StateError(
      'The authenticated ERA spec16 metadata artifact is missing.',
    );
  }

  final bytes = await metadataFile.readAsBytes();
  final digest = await Sha256().hash(bytes);
  final hash = digest.bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  if (hash != _approvedMetadataSha256) {
    throw StateError('Refusing to generate from unapproved metadata $hash.');
  }

  final prefixed = RuntimeMetadataPrefixed.fromBytes(bytes);
  if (prefixed.metadata.runtimeMetadataVersion() != 14) {
    throw StateError('ERA spec16 bindings require metadata V14.');
  }
  for (final entry in _requiredPallets.entries) {
    final matches = prefixed.metadata.pallets.where(
      (pallet) => pallet.name == entry.key,
    );
    if (matches.length != 1) {
      throw StateError(
        'Required pallet ${entry.key} is missing or duplicated.',
      );
    }
    final pallet = matches.single;
    if (pallet.index != entry.value || pallet.calls == null) {
      throw StateError(
        'Required pallet ${entry.key} has an unexpected index or no calls.',
      );
    }
  }

  final relativeOutput = install
      ? 'lib/generated/era'
      : 'artifacts/v14/generated/era';
  final output = Directory(
    '$workspace${Platform.pathSeparator}'
    '${relativeOutput.replaceAll('/', Platform.pathSeparator)}',
  );
  final expectedPath =
      '$workspace${Platform.pathSeparator}'
      '${relativeOutput.replaceAll('/', Platform.pathSeparator)}';
  String normalized(String value) =>
      value.replaceAll('/', Platform.pathSeparator).toLowerCase();
  if (normalized(output.path) != normalized(expectedPath)) {
    throw StateError('Refusing unexpected generation target ${output.path}.');
  }

  final staging = Directory('${output.path}.v14-next');
  final backup = Directory('${output.path}.v14-backup');
  for (final directory in [staging, backup]) {
    if (!normalized(directory.path).startsWith(
      '${normalized(output.parent.path)}${Platform.pathSeparator}',
    )) {
      throw StateError('Refusing unsafe staging path ${directory.path}.');
    }
  }
  if (await staging.exists()) await staging.delete(recursive: true);
  await output.parent.create(recursive: true);
  await staging.create(recursive: false);

  final generator = ChainGenerator.fromMetadata(
    basePath: staging,
    chainName: 'era',
    metadata: prefixed.metadata,
  );
  try {
    await generator.build(verbose: verbose);
    await _normalizeGeneratedImportUris(staging);
    await _formatGeneratedSources(staging);

    for (final relative in [
      'era.dart',
      'pallets/nfts.dart',
      'pallets/security_budget.dart',
      'pallets/era_v14_asset_allocator.dart',
    ]) {
      if (!await File('${staging.path}/$relative').exists()) {
        throw StateError('Polkadart did not emit required binding $relative.');
      }
    }

    if (await backup.exists()) await backup.delete(recursive: true);
    if (await output.exists()) await output.rename(backup.path);
    try {
      await staging.rename(output.path);
      if (await backup.exists()) await backup.delete(recursive: true);
    } catch (_) {
      if (!await output.exists() && await backup.exists()) {
        await backup.rename(output.path);
      }
      rethrow;
    }
  } catch (_) {
    if (await staging.exists()) await staging.delete(recursive: true);
    rethrow;
  }

  stdout.writeln('Generated ERA spec16 bindings at ${output.path}');
  stdout.writeln('Metadata SHA-256: $hash');
}

Future<String> _requireProjectRoot() async {
  final workspace = Directory.current.resolveSymbolicLinksSync();
  final pubspec = File('$workspace${Platform.pathSeparator}pubspec.yaml');
  final appEntryPoint = File(
    '$workspace${Platform.pathSeparator}lib${Platform.pathSeparator}main.dart',
  );
  if (!await pubspec.exists() || !await appEntryPoint.exists()) {
    throw StateError('Run this tool from the ERA Wallet project root.');
  }
  final source = await pubspec.readAsString();
  if (!RegExp(r'^name:\s*era_wallet\s*$', multiLine: true).hasMatch(source)) {
    throw StateError('The current project is not the ERA Wallet package.');
  }
  return workspace;
}

Future<void> _formatGeneratedSources(Directory output) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    '--suppress-analytics',
    'format',
    output.path,
  ]);
  if (result.exitCode != 0) {
    throw StateError('Dart formatting failed: ${result.stderr}');
  }
}

Future<void> _normalizeGeneratedImportUris(Directory output) async {
  await for (final entity in output.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = await entity.readAsString();
    final normalized = source
        .split('\n')
        .map((line) {
          final trimmed = line.trimLeft();
          if (trimmed.startsWith("import '") ||
              trimmed.startsWith("export '")) {
            return line.replaceAll('\\', '/').trimRight();
          }
          return line.trimRight();
        })
        .join('\n');
    if (normalized != source) await entity.writeAsString(normalized);
  }
}
