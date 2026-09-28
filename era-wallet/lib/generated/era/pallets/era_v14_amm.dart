// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:typed_data' as _i8;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i6;

import '../types/era_v14_amm/v1/asset.dart' as _i3;
import '../types/era_v14_amm/v1/pool_record.dart' as _i4;
import '../types/sp_core/crypto/account_id32.dart' as _i5;
import '../types/tuples.dart' as _i2;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageMap<_i2.Tuple2<_i3.Asset, _i3.Asset>, _i4.PoolRecord>
  _pools =
      const _i1.StorageMap<_i2.Tuple2<_i3.Asset, _i3.Asset>, _i4.PoolRecord>(
        prefix: 'EraV14Amm',
        storage: 'Pools',
        valueCodec: _i4.PoolRecord.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(
          _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
            _i3.Asset.codec,
            _i3.Asset.codec,
          ),
        ),
      );

  final _i1.StorageMap<_i5.AccountId32, _i2.Tuple2<_i3.Asset, _i3.Asset>>
  _custodies =
      const _i1.StorageMap<_i5.AccountId32, _i2.Tuple2<_i3.Asset, _i3.Asset>>(
        prefix: 'EraV14Amm',
        storage: 'Custodies',
        valueCodec: _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
          _i3.Asset.codec,
          _i3.Asset.codec,
        ),
        hasher: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageValue<int> _poolCount = const _i1.StorageValue<int>(
    prefix: 'EraV14Amm',
    storage: 'PoolCount',
    valueCodec: _i6.U32Codec.codec,
  );

  final _i1.StorageMap<int, _i2.Tuple2<_i3.Asset, _i3.Asset>> _poolIndex =
      const _i1.StorageMap<int, _i2.Tuple2<_i3.Asset, _i3.Asset>>(
        prefix: 'EraV14Amm',
        storage: 'PoolIndex',
        valueCodec: _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
          _i3.Asset.codec,
          _i3.Asset.codec,
        ),
        hasher: _i1.StorageHasher.twoxx64Concat(_i6.U32Codec.codec),
      );

  final _i1.StorageMap<_i2.Tuple2<_i3.Asset, _i3.Asset>, int> _poolOrdinal =
      const _i1.StorageMap<_i2.Tuple2<_i3.Asset, _i3.Asset>, int>(
        prefix: 'EraV14Amm',
        storage: 'PoolOrdinal',
        valueCodec: _i6.U32Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(
          _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
            _i3.Asset.codec,
            _i3.Asset.codec,
          ),
        ),
      );

  final _i1.StorageDoubleMap<
    _i2.Tuple2<_i3.Asset, _i3.Asset>,
    _i5.AccountId32,
    BigInt
  >
  _positions =
      const _i1.StorageDoubleMap<
        _i2.Tuple2<_i3.Asset, _i3.Asset>,
        _i5.AccountId32,
        BigInt
      >(
        prefix: 'EraV14Amm',
        storage: 'Positions',
        valueCodec: _i6.U128Codec.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(
          _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
            _i3.Asset.codec,
            _i3.Asset.codec,
          ),
        ),
        hasher2: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageMap<_i5.AccountId32, List<_i2.Tuple2<_i3.Asset, _i3.Asset>>>
  _accountPools =
      const _i1.StorageMap<
        _i5.AccountId32,
        List<_i2.Tuple2<_i3.Asset, _i3.Asset>>
      >(
        prefix: 'EraV14Amm',
        storage: 'AccountPools',
        valueCodec: _i6.SequenceCodec<_i2.Tuple2<_i3.Asset, _i3.Asset>>(
          _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
            _i3.Asset.codec,
            _i3.Asset.codec,
          ),
        ),
        hasher: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageMap<_i2.Tuple2<_i3.Asset, _i3.Asset>, List<_i5.AccountId32>>
  _providers =
      const _i1.StorageMap<
        _i2.Tuple2<_i3.Asset, _i3.Asset>,
        List<_i5.AccountId32>
      >(
        prefix: 'EraV14Amm',
        storage: 'Providers',
        valueCodec: _i6.SequenceCodec<_i5.AccountId32>(_i5.AccountId32Codec()),
        hasher: _i1.StorageHasher.blake2b128Concat(
          _i2.Tuple2Codec<_i3.Asset, _i3.Asset>(
            _i3.Asset.codec,
            _i3.Asset.codec,
          ),
        ),
      );

  final _i1.StorageValue<bool> _busy = const _i1.StorageValue<bool>(
    prefix: 'EraV14Amm',
    storage: 'Busy',
    valueCodec: _i6.BoolCodec.codec,
  );

  _i7.Future<_i4.PoolRecord?> pools(
    _i2.Tuple2<_i3.Asset, _i3.Asset> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _pools.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pools.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i7.Future<_i2.Tuple2<_i3.Asset, _i3.Asset>?> custodies(
    _i5.AccountId32 key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _custodies.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _custodies.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i7.Future<int> poolCount({_i1.BlockHash? at}) async {
    final hashedKey = _poolCount.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _poolCount.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i7.Future<_i2.Tuple2<_i3.Asset, _i3.Asset>?> poolIndex(
    int key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _poolIndex.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _poolIndex.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i7.Future<int?> poolOrdinal(
    _i2.Tuple2<_i3.Asset, _i3.Asset> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _poolOrdinal.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _poolOrdinal.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i7.Future<BigInt?> positions(
    _i2.Tuple2<_i3.Asset, _i3.Asset> key1,
    _i5.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _positions.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _positions.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i7.Future<List<_i2.Tuple2<_i3.Asset, _i3.Asset>>> accountPools(
    _i5.AccountId32 key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _accountPools.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _accountPools.decodeValue(bytes);
    }
    return []; /* Default */
  }

  _i7.Future<List<_i5.AccountId32>> providers(
    _i2.Tuple2<_i3.Asset, _i3.Asset> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _providers.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _providers.decodeValue(bytes);
    }
    return []; /* Default */
  }

  _i7.Future<bool> busy({_i1.BlockHash? at}) async {
    final hashedKey = _busy.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _busy.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i7.Future<List<_i4.PoolRecord?>> multiPools(
    List<_i2.Tuple2<_i3.Asset, _i3.Asset>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _pools.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes.map((v) => _pools.decodeValue(v.key)).toList();
    }
    return []; /* Nullable */
  }

  _i7.Future<List<_i2.Tuple2<_i3.Asset, _i3.Asset>?>> multiCustodies(
    List<_i5.AccountId32> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _custodies.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _custodies.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i7.Future<List<_i2.Tuple2<_i3.Asset, _i3.Asset>?>> multiPoolIndex(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _poolIndex.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _poolIndex.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i7.Future<List<int?>> multiPoolOrdinal(
    List<_i2.Tuple2<_i3.Asset, _i3.Asset>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _poolOrdinal.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _poolOrdinal.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i7.Future<List<List<_i2.Tuple2<_i3.Asset, _i3.Asset>>>> multiAccountPools(
    List<_i5.AccountId32> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _accountPools.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _accountPools.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => []).toList()
        as List<List<_i2.Tuple2<_i3.Asset, _i3.Asset>>>); /* Default */
  }

  _i7.Future<List<List<_i5.AccountId32>>> multiProviders(
    List<_i2.Tuple2<_i3.Asset, _i3.Asset>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _providers.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _providers.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => []).toList()
        as List<List<_i5.AccountId32>>); /* Default */
  }

  /// Returns the storage key for `pools`.
  _i8.Uint8List poolsKey(_i2.Tuple2<_i3.Asset, _i3.Asset> key1) {
    final hashedKey = _pools.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `custodies`.
  _i8.Uint8List custodiesKey(_i5.AccountId32 key1) {
    final hashedKey = _custodies.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `poolCount`.
  _i8.Uint8List poolCountKey() {
    final hashedKey = _poolCount.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `poolIndex`.
  _i8.Uint8List poolIndexKey(int key1) {
    final hashedKey = _poolIndex.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `poolOrdinal`.
  _i8.Uint8List poolOrdinalKey(_i2.Tuple2<_i3.Asset, _i3.Asset> key1) {
    final hashedKey = _poolOrdinal.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `positions`.
  _i8.Uint8List positionsKey(
    _i2.Tuple2<_i3.Asset, _i3.Asset> key1,
    _i5.AccountId32 key2,
  ) {
    final hashedKey = _positions.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `accountPools`.
  _i8.Uint8List accountPoolsKey(_i5.AccountId32 key1) {
    final hashedKey = _accountPools.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `providers`.
  _i8.Uint8List providersKey(_i2.Tuple2<_i3.Asset, _i3.Asset> key1) {
    final hashedKey = _providers.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `busy`.
  _i8.Uint8List busyKey() {
    final hashedKey = _busy.hashedKey();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `pools`.
  _i8.Uint8List poolsMapPrefix() {
    final hashedKey = _pools.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `custodies`.
  _i8.Uint8List custodiesMapPrefix() {
    final hashedKey = _custodies.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `poolIndex`.
  _i8.Uint8List poolIndexMapPrefix() {
    final hashedKey = _poolIndex.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `poolOrdinal`.
  _i8.Uint8List poolOrdinalMapPrefix() {
    final hashedKey = _poolOrdinal.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `positions`.
  _i8.Uint8List positionsMapPrefix(_i2.Tuple2<_i3.Asset, _i3.Asset> key1) {
    final hashedKey = _positions.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `accountPools`.
  _i8.Uint8List accountPoolsMapPrefix() {
    final hashedKey = _accountPools.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `providers`.
  _i8.Uint8List providersMapPrefix() {
    final hashedKey = _providers.mapPrefix();
    return hashedKey;
  }
}
