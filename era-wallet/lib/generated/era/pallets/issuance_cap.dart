// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/era_runtime/issuance_cap/pallet/v13_completion.dart' as _i3;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<BigInt> _remainingAllowance =
      const _i1.StorageValue<BigInt>(
        prefix: 'IssuanceCap',
        storage: 'RemainingAllowance',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<_i3.V13Completion> _v13MigrationCompleted =
      const _i1.StorageValue<_i3.V13Completion>(
        prefix: 'IssuanceCap',
        storage: 'V13MigrationCompleted',
        valueCodec: _i3.V13Completion.codec,
      );

  /// Burn-independent ETKN issuance still authorized after the V13 retained-supply baseline.
  /// `None` is deliberately distinct from a fully consumed allowance of `Some(0)`.
  _i4.Future<BigInt?> remainingAllowance({_i1.BlockHash? at}) async {
    final hashedKey = _remainingAllowance.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _remainingAllowance.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Explicit V13 completion marker, independent of FRAME pallet storage-version setup.
  _i4.Future<_i3.V13Completion?> v13MigrationCompleted({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _v13MigrationCompleted.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _v13MigrationCompleted.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Returns the storage key for `remainingAllowance`.
  _i5.Uint8List remainingAllowanceKey() {
    final hashedKey = _remainingAllowance.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `v13MigrationCompleted`.
  _i5.Uint8List v13MigrationCompletedKey() {
    final hashedKey = _v13MigrationCompleted.hashedKey();
    return hashedKey;
  }
}
