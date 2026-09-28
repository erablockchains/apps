import 'dart:io';

import 'package:era_wallet/phase6b/runtime_compatibility.dart';
import 'package:era_wallet/phase6b/runtime_metadata_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adapter = Phase6bRuntimeMetadataAdapter();

  test(
    'decodes the pinned V13 V14 artifact into the reviewed 40/32 surface',
    () {
      final bytes = File(
        'artifacts/phase6b/era-spec13-metadata.scale',
      ).readAsBytesSync();
      final observed = adapter.decodeAiPredictionsPallet(bytes)!;
      final approved = Phase6bRuntimeCompatibility
          .approvedSpec13Fingerprint
          .aiPredictionsPallet!;

      expect(observed.name, approved.name);
      expect(observed.index, approved.index);
      expect(observed.storagePrefix, approved.storagePrefix);
      expect(observed.calls, hasLength(40));
      expect(observed.storage, hasLength(32));

      for (final expected in approved.calls.values) {
        final actual = observed.calls[expected.name];
        expect(actual, isNotNull, reason: 'missing call ${expected.name}');
        expect(actual!.index, expected.index, reason: expected.name);
        expect(actual.arguments, hasLength(expected.arguments.length));
        for (var index = 0; index < expected.arguments.length; index++) {
          final expectedArgument = expected.arguments[index];
          final actualArgument = actual.arguments[index];
          expect(actualArgument.name, expectedArgument.name);
          _expectType(actualArgument.type, expectedArgument.type);
        }
      }

      for (final expected in approved.storage.values) {
        final actual = observed.storage[expected.name];
        expect(actual, isNotNull, reason: 'missing storage ${expected.name}');
        expect(actual!.modifier, expected.modifier, reason: expected.name);
        expect(actual.shape, expected.shape, reason: expected.name);
        expect(actual.hashers, expected.hashers, reason: expected.name);
        _expectNullableType(actual.keyType, expected.keyType);
        _expectType(actual.valueType, expected.valueType);
      }
    },
  );

  test(
    'preserves call aliases and resolved storage map types from metadata',
    () {
      final bytes = File(
        'artifacts/phase6b/era-spec13-metadata.scale',
      ).readAsBytesSync();
      final pallet = adapter.decodeAiPredictionsPallet(bytes)!;

      final stake = pallet.calls['stake_on_prediction_outcome_side']!;
      expect(stake.index, 31);
      expect(stake.arguments.map((argument) => argument.name), [
        'token_id',
        'side',
        'amount',
      ]);
      expect(stake.arguments[0].type.metadataTypeName, 'PredictionTokenId');
      expect(stake.arguments[0].type.resolvedScaleType, 'u64');
      expect(stake.arguments[2].type.metadataTypeName, 'BalanceOf<T>');
      expect(stake.arguments[2].type.resolvedScaleType, 'u128');

      final totals = pallet.storage['PredictionTokenSideTotals']!;
      expect(totals.modifier, RuntimeStorageModifier.defaultValue);
      expect(totals.shape, RuntimeStorageShape.map);
      expect(totals.hashers, ['Blake2_128Concat', 'Blake2_128Concat']);
      expect(totals.keyType!.resolvedScaleType, '(u64, PredictionOutcomeSide)');
      expect(totals.valueType.resolvedScaleType, 'u128');
    },
  );
}

void _expectNullableType(
  RuntimeTypeSignature? actual,
  RuntimeTypeSignature? expected,
) {
  if (actual == null || expected == null) {
    expect(actual, expected);
    return;
  }
  _expectType(actual, expected);
}

void _expectType(RuntimeTypeSignature actual, RuntimeTypeSignature expected) {
  expect(actual.portableTypeId, expected.portableTypeId);
  expect(actual.metadataTypeName, expected.metadataTypeName);
  expect(actual.resolvedScaleType, expected.resolvedScaleType);
}
