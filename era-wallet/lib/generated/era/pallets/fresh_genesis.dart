// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/sp_core/crypto/account_id32.dart' as _i3;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<bool> _enabled = const _i1.StorageValue<bool>(
    prefix: 'FreshGenesis',
    storage: 'Enabled',
    valueCodec: _i2.BoolCodec.codec,
  );

  final _i1.StorageValue<List<_i3.AccountId32>> _signers =
      const _i1.StorageValue<List<_i3.AccountId32>>(
        prefix: 'FreshGenesis',
        storage: 'Signers',
        valueCodec: _i2.ArrayCodec<_i3.AccountId32>(_i3.AccountId32Codec(), 3),
      );

  _i4.Future<bool> enabled({_i1.BlockHash? at}) async {
    final hashedKey = _enabled.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _enabled.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i4.Future<List<_i3.AccountId32>?> signers({_i1.BlockHash? at}) async {
    final hashedKey = _signers.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _signers.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Returns the storage key for `enabled`.
  _i5.Uint8List enabledKey() {
    final hashedKey = _enabled.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `signers`.
  _i5.Uint8List signersKey() {
    final hashedKey = _signers.hashedKey();
    return hashedKey;
  }
}
