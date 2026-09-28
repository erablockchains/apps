// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i3;

import '../types/era_runtime/runtime_call.dart' as _i6;
import '../types/pallet_era_worlds/pallet/call.dart' as _i7;
import '../types/pallet_era_worlds/pallet/world_record.dart' as _i2;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageMap<List<int>, _i2.WorldRecord> _worlds =
      const _i1.StorageMap<List<int>, _i2.WorldRecord>(
        prefix: 'EraWorlds',
        storage: 'Worlds',
        valueCodec: _i2.WorldRecord.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i3.U8SequenceCodec.codec),
      );

  final _i1.StorageValue<bool> _paused = const _i1.StorageValue<bool>(
    prefix: 'EraWorlds',
    storage: 'Paused',
    valueCodec: _i3.BoolCodec.codec,
  );

  _i4.Future<_i2.WorldRecord?> worlds(
    List<int> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _worlds.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _worlds.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i4.Future<bool> paused({_i1.BlockHash? at}) async {
    final hashedKey = _paused.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _paused.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i4.Future<List<_i2.WorldRecord?>> multiWorlds(
    List<List<int>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _worlds.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _worlds.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Returns the storage key for `worlds`.
  _i5.Uint8List worldsKey(List<int> key1) {
    final hashedKey = _worlds.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `paused`.
  _i5.Uint8List pausedKey() {
    final hashedKey = _paused.hashedKey();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `worlds`.
  _i5.Uint8List worldsMapPrefix() {
    final hashedKey = _worlds.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  _i6.EraWorlds registerWorld({
    required List<int> worldId,
    required List<int> commitment,
  }) {
    return _i6.EraWorlds(
      _i7.RegisterWorld(worldId: worldId, commitment: commitment),
    );
  }

  _i6.EraWorlds updateCommitment({
    required List<int> worldId,
    required List<int> commitment,
  }) {
    return _i6.EraWorlds(
      _i7.UpdateCommitment(worldId: worldId, commitment: commitment),
    );
  }

  _i6.EraWorlds deregisterWorld({required List<int> worldId}) {
    return _i6.EraWorlds(_i7.DeregisterWorld(worldId: worldId));
  }

  _i6.EraWorlds adminRemoveWorld({required List<int> worldId}) {
    return _i6.EraWorlds(_i7.AdminRemoveWorld(worldId: worldId));
  }

  _i6.EraWorlds pause() {
    return _i6.EraWorlds(_i7.Pause());
  }

  _i6.EraWorlds unpause() {
    return _i6.EraWorlds(_i7.Unpause());
  }
}

class Constants {
  Constants();

  final BigInt registrationDeposit = BigInt.parse(
    '10000000000000000000',
    radix: 10,
  );

  final int maxWorldIdLength = 64;
}
