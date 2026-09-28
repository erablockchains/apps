import 'dart:convert';
import 'dart:io';

import 'package:era_wallet/phase6b/runtime_metadata_adapter.dart';

void main(List<String> arguments) {
  if (arguments.isNotEmpty) {
    throw ArgumentError('This offline tool accepts no arguments.');
  }
  final bytes = File(
    'artifacts/phase6b/era-spec13-metadata.scale',
  ).readAsBytesSync();
  final pallet = const Phase6bRuntimeMetadataAdapter()
      .decodeAiPredictionsPallet(bytes)!;
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'name': pallet.name,
      'index': pallet.index,
      'storagePrefix': pallet.storagePrefix,
      'calls': {
        for (final call in pallet.calls.values)
          call.name: {
            'index': call.index,
            'arguments': [
              for (final argument in call.arguments)
                {
                  'name': argument.name,
                  'portableTypeId': argument.type.portableTypeId,
                  'metadataTypeName': argument.type.metadataTypeName,
                  'resolvedScaleType': argument.type.resolvedScaleType,
                },
            ],
          },
      },
      'storage': {
        for (final entry in pallet.storage.values)
          entry.name: {
            'modifier': entry.modifier.name,
            'shape': entry.shape.name,
            'hashers': entry.hashers,
            'keyTypeId': entry.keyType?.portableTypeId,
            'keyType': entry.keyType?.resolvedScaleType,
            'valueTypeId': entry.valueType.portableTypeId,
            'valueType': entry.valueType.resolvedScaleType,
          },
      },
    }),
  );
}
