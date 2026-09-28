import 'dart:typed_data';

import 'package:substrate_metadata/substrate_metadata.dart';

import 'runtime_compatibility.dart';

/// Decodes the AI Predictions compatibility surface directly from SCALE
/// runtime metadata.
///
/// No approved signature data is consulted here. The adapter's output is an
/// observation; [Phase6bRuntimeCompatibility] decides whether that observation
/// matches a reviewed runtime.
class Phase6bRuntimeMetadataAdapter {
  const Phase6bRuntimeMetadataAdapter();

  RuntimePalletFingerprint? decodeAiPredictionsPallet(List<int> metadataBytes) {
    final prefixed = RuntimeMetadataPrefixed.fromBytes(
      Uint8List.fromList(metadataBytes),
    );
    final metadata = prefixed.metadata;
    if (metadata.runtimeMetadataVersion() != 14) {
      throw FormatException(
        'Expected V14 runtime metadata, got '
        'V${metadata.runtimeMetadataVersion()}.',
      );
    }
    final typeIds = <int>{};
    for (final portableType in metadata.types) {
      if (!typeIds.add(portableType.id)) {
        throw FormatException(
          'Runtime metadata contains duplicate portable type '
          '${portableType.id}.',
        );
      }
    }

    final matchingPallets = metadata.pallets
        .where((pallet) => pallet.name == 'AiPredictions')
        .toList(growable: false);
    if (matchingPallets.isEmpty) return null;
    if (matchingPallets.length != 1) {
      throw const FormatException(
        'Runtime metadata contains duplicate AiPredictions pallets.',
      );
    }

    final pallet = matchingPallets.single;
    final resolver = _PortableTypeResolver(metadata);
    final calls = _decodeCalls(
      metadata: metadata,
      callTypeId: pallet.calls?.type,
      resolver: resolver,
    );
    final storage = _decodeStorage(
      entries: pallet.storage?.entries ?? const [],
      resolver: resolver,
    );

    return RuntimePalletFingerprint(
      name: pallet.name,
      index: pallet.index,
      storagePrefix: pallet.storage?.prefix ?? '',
      calls: calls,
      storage: storage,
    );
  }

  Map<String, RuntimeCallSignature> _decodeCalls({
    required RuntimeMetadata metadata,
    required int? callTypeId,
    required _PortableTypeResolver resolver,
  }) {
    if (callTypeId == null) return const {};
    final callType = metadata.typeById(callTypeId).type.typeDef;
    if (callType is! TypeDefVariant) {
      throw FormatException(
        'AiPredictions call type $callTypeId is not a SCALE variant.',
      );
    }

    final result = <String, RuntimeCallSignature>{};
    for (final variant in callType.variants) {
      final arguments = <RuntimeCallArgumentSignature>[];
      for (
        var fieldIndex = 0;
        fieldIndex < variant.fields.length;
        fieldIndex++
      ) {
        final field = variant.fields[fieldIndex];
        final fieldName = field.name;
        if (fieldName == null || fieldName.isEmpty) {
          throw FormatException(
            'AiPredictions call `${variant.name}` field $fieldIndex has no '
            'metadata name.',
          );
        }
        arguments.add(
          RuntimeCallArgumentSignature(
            name: fieldName,
            type: RuntimeTypeSignature(
              portableTypeId: field.type,
              metadataTypeName: field.typeName,
              resolvedScaleType: resolver.resolve(field.type),
            ),
          ),
        );
      }

      final previous = result[variant.name];
      if (previous != null) {
        throw FormatException(
          'AiPredictions contains duplicate call `${variant.name}`.',
        );
      }
      result[variant.name] = RuntimeCallSignature(
        name: variant.name,
        index: variant.index,
        arguments: arguments,
      );
    }
    return result;
  }

  Map<String, RuntimeStorageSignature> _decodeStorage({
    required List<StorageEntryMetadata> entries,
    required _PortableTypeResolver resolver,
  }) {
    final result = <String, RuntimeStorageSignature>{};
    for (final entry in entries) {
      if (result.containsKey(entry.name)) {
        throw FormatException(
          'AiPredictions contains duplicate storage `${entry.name}`.',
        );
      }

      final keyTypeId = entry.type.key;
      result[entry.name] = RuntimeStorageSignature(
        name: entry.name,
        modifier: switch (entry.modifier) {
          StorageEntryModifier.default_ => RuntimeStorageModifier.defaultValue,
          StorageEntryModifier.optional => RuntimeStorageModifier.optional,
        },
        shape: keyTypeId == null
            ? RuntimeStorageShape.plain
            : RuntimeStorageShape.map,
        keyType: keyTypeId == null
            ? null
            : RuntimeTypeSignature(
                portableTypeId: keyTypeId,
                resolvedScaleType: resolver.resolve(
                  keyTypeId,
                  qualifyRootPalletType: true,
                ),
              ),
        hashers: entry.type.hashers
            .map((hasher) => hasher.toString())
            .toList(growable: false),
        valueType: RuntimeTypeSignature(
          portableTypeId: entry.type.value,
          resolvedScaleType: resolver.resolve(
            entry.type.value,
            qualifyRootPalletType: true,
          ),
        ),
      );
    }
    return result;
  }
}

class _PortableTypeResolver {
  final RuntimeMetadata metadata;

  const _PortableTypeResolver(this.metadata);

  String resolve(
    int typeId, {
    bool qualifyRootPalletType = false,
    Set<int> resolving = const {},
  }) {
    if (resolving.contains(typeId)) {
      throw FormatException('Recursive anonymous SCALE type $typeId.');
    }
    final portable = metadata.typeById(typeId);
    final type = portable.type;
    final path = type.path;
    final concreteParameters = type.params
        .where((parameter) => parameter.type != null)
        .toList(growable: false);

    if (path.isNotEmpty) {
      final last = path.last;
      if (qualifyRootPalletType && path.first == 'pallet_ai_predictions') {
        return 'pallet_ai_predictions::$last';
      }
      if (concreteParameters.isEmpty || path.first == 'pallet_ai_predictions') {
        return last;
      }
      final parameters = concreteParameters
          .map((parameter) => resolve(parameter.type!))
          .join(', ');
      return '$last<$parameters>';
    }

    final nextResolving = {...resolving, typeId};
    return switch (type.typeDef) {
      TypeDefPrimitive(:final primitive) => primitive.name.toLowerCase(),
      TypeDefSequence(:final type) =>
        'Vec<${resolve(type, resolving: nextResolving)}>',
      TypeDefArray(:final type, :final length) =>
        '[${resolve(type, resolving: nextResolving)}; $length]',
      TypeDefTuple(:final fields) =>
        '(${fields.map((field) => resolve(field, resolving: nextResolving)).join(', ')})',
      TypeDefCompact(:final type) =>
        'Compact<${resolve(type, resolving: nextResolving)}>',
      TypeDefComposite(:final fields) => _resolveAnonymousComposite(
        fields,
        nextResolving,
      ),
      TypeDefVariant(:final variants) =>
        'Variant<${variants.map((variant) => variant.name).join('|')}>',
      TypeDefBitSequence(:final bitStoreType, :final bitOrderType) =>
        'BitVec<${resolve(bitStoreType, resolving: nextResolving)}, '
            '${resolve(bitOrderType, resolving: nextResolving)}>',
      _ => throw FormatException('Unsupported SCALE type $typeId.'),
    };
  }

  String _resolveAnonymousComposite(List<Field> fields, Set<int> resolving) {
    if (fields.isEmpty) return '()';
    if (fields.length == 1 && fields.single.name == null) {
      return resolve(fields.single.type, resolving: resolving);
    }
    return '(${fields.map((field) => resolve(field.type, resolving: resolving)).join(', ')})';
  }
}
