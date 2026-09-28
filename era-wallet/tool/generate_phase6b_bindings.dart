import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:polkadart_cli/polkadart_cli.dart';
import 'package:substrate_metadata/substrate_metadata.dart';

const _approvedMetadataSha256 =
    '5c3715502b0f4cd3c3bc124f13f7f153cd3486e0c3877dc1d685335e57ed4c3f';

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
      'Usage: dart run tool/generate_phase6b_bindings.dart '
      '[--install] [--verbose]',
    );
    return;
  }
  final install = arguments.contains('--install');
  final verbose = arguments.contains('--verbose');
  final workspace = await _requireProjectRoot();
  final metadataFile = File(
    '$workspace${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
    'phase6b${Platform.pathSeparator}era-spec13-metadata.scale',
  );
  if (!await metadataFile.exists()) {
    throw StateError(
      'Pinned metadata is missing. Run the explicitly approved Phase 6B '
      'capture tool with --live first.',
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
    throw StateError('ERA spec 13 bindings require metadata v14.');
  }
  final aiPallet = prefixed.metadata.pallets
      .where((pallet) => pallet.name == 'AiPredictions')
      .single;
  if (aiPallet.index != 12 || aiPallet.calls == null) {
    throw StateError('Pinned AI Predictions pallet fingerprint is invalid.');
  }

  final relativeOutput = install
      ? 'lib/generated/era'
      : 'artifacts/phase6b/generated/era';
  final output = Directory(
    '$workspace${Platform.pathSeparator}'
    '${relativeOutput.replaceAll('/', Platform.pathSeparator)}',
  );
  final expectedPath =
      '$workspace${Platform.pathSeparator}${relativeOutput.replaceAll('/', Platform.pathSeparator)}';
  String normalized(String value) =>
      value.replaceAll('/', Platform.pathSeparator).toLowerCase();
  if (normalized(output.path) != normalized(expectedPath)) {
    throw StateError('Refusing unexpected generation target ${output.path}.');
  }

  final staging = Directory('${output.path}.phase6b-next');
  final backup = Directory('${output.path}.phase6b-backup');
  for (final directory in [staging, backup]) {
    if (!normalized(directory.path).startsWith(
      '${normalized(output.parent.path)}${Platform.pathSeparator}',
    )) {
      throw StateError('Refusing unsafe staging path ${directory.path}.');
    }
  }
  if (await staging.exists()) {
    await staging.delete(recursive: true);
  }
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

    final aiBinding = File('${staging.path}/pallets/ai_predictions.dart');
    final rootBinding = File('${staging.path}/era.dart');
    if (!await aiBinding.exists() || !await rootBinding.exists()) {
      throw StateError('Polkadart did not emit the required ERA bindings.');
    }

    if (await backup.exists()) {
      await backup.delete(recursive: true);
    }
    if (await output.exists()) {
      await output.rename(backup.path);
    }
    try {
      await staging.rename(output.path);
      if (await backup.exists()) {
        await backup.delete(recursive: true);
      }
    } catch (_) {
      if (!await output.exists() && await backup.exists()) {
        await backup.rename(output.path);
      }
      rethrow;
    }
  } catch (_) {
    if (await staging.exists()) {
      await staging.delete(recursive: true);
    }
    rethrow;
  }

  stdout.writeln('Generated ERA spec-13 bindings at ${output.path}');
  stdout.writeln('Metadata SHA-256: $hash');
  stdout.writeln('AiPredictions pallet index: ${aiPallet.index}');
}

Future<String> _requireProjectRoot() async {
  final workspace = Directory.current.resolveSymbolicLinksSync();
  final pubspec = File('$workspace${Platform.pathSeparator}pubspec.yaml');
  final appEntryPoint = File(
    '$workspace${Platform.pathSeparator}lib${Platform.pathSeparator}main.dart',
  );
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
  return workspace;
}

Future<void> _formatGeneratedSources(Directory output) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    '--suppress-analytics',
    'format',
    output.path,
  ]);
  if (result.exitCode != 0) {
    throw StateError(
      'Dart formatting failed for generated bindings: ${result.stderr}',
    );
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
    if (normalized != source) {
      await entity.writeAsString(normalized);
    }
  }
}
