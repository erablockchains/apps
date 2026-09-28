// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i6;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/era_runtime/runtime_call.dart' as _i7;
import '../types/era_runtime/v14_amm/pallet/call.dart' as _i8;
import '../types/era_v14_amm/v1/asset.dart' as _i4;
import '../types/sp_core/crypto/account_id32.dart' as _i9;
import '../types/tuples.dart' as _i3;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<bool> _enabled = const _i1.StorageValue<bool>(
    prefix: 'Amm',
    storage: 'Enabled',
    valueCodec: _i2.BoolCodec.codec,
  );

  final _i1.StorageMap<_i3.Tuple2<_i4.Asset, _i4.Asset>, dynamic>
  _approvedPairs =
      const _i1.StorageMap<_i3.Tuple2<_i4.Asset, _i4.Asset>, dynamic>(
        prefix: 'Amm',
        storage: 'ApprovedPairs',
        valueCodec: _i2.NullCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(
          _i3.Tuple2Codec<_i4.Asset, _i4.Asset>(
            _i4.Asset.codec,
            _i4.Asset.codec,
          ),
        ),
      );

  final _i1.StorageValue<int> _pairCount = const _i1.StorageValue<int>(
    prefix: 'Amm',
    storage: 'PairCount',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageMap<int, BigInt> _admittedAssets =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'Amm',
        storage: 'AdmittedAssets',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  _i5.Future<bool> enabled({_i1.BlockHash? at}) async {
    final hashedKey = _enabled.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _enabled.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i5.Future<dynamic> approvedPairs(
    _i3.Tuple2<_i4.Asset, _i4.Asset> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _approvedPairs.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _approvedPairs.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i5.Future<int> pairCount({_i1.BlockHash? at}) async {
    final hashedKey = _pairCount.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pairCount.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i5.Future<BigInt?> admittedAssets(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _admittedAssets.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _admittedAssets.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i5.Future<List<dynamic>> multiApprovedPairs(
    List<_i3.Tuple2<_i4.Asset, _i4.Asset>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _approvedPairs.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _approvedPairs.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i5.Future<List<BigInt?>> multiAdmittedAssets(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _admittedAssets.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _admittedAssets.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Returns the storage key for `enabled`.
  _i6.Uint8List enabledKey() {
    final hashedKey = _enabled.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `approvedPairs`.
  _i6.Uint8List approvedPairsKey(_i3.Tuple2<_i4.Asset, _i4.Asset> key1) {
    final hashedKey = _approvedPairs.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `pairCount`.
  _i6.Uint8List pairCountKey() {
    final hashedKey = _pairCount.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `admittedAssets`.
  _i6.Uint8List admittedAssetsKey(int key1) {
    final hashedKey = _admittedAssets.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `approvedPairs`.
  _i6.Uint8List approvedPairsMapPrefix() {
    final hashedKey = _approvedPairs.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `admittedAssets`.
  _i6.Uint8List admittedAssetsMapPrefix() {
    final hashedKey = _admittedAssets.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  _i7.Amm createPool({
    required _i4.Asset assetA,
    required _i4.Asset assetB,
    required int deadline,
  }) {
    return _i7.Amm(
      _i8.CreatePool(assetA: assetA, assetB: assetB, deadline: deadline),
    );
  }

  _i7.Amm addLiquidity({
    required _i4.Asset assetA,
    required _i4.Asset assetB,
    required BigInt desiredA,
    required BigInt desiredB,
    required BigInt minA,
    required BigInt minB,
    required int deadline,
  }) {
    return _i7.Amm(
      _i8.AddLiquidity(
        assetA: assetA,
        assetB: assetB,
        desiredA: desiredA,
        desiredB: desiredB,
        minA: minA,
        minB: minB,
        deadline: deadline,
      ),
    );
  }

  _i7.Amm removeLiquidity({
    required _i4.Asset assetA,
    required _i4.Asset assetB,
    required BigInt lp,
    required BigInt minA,
    required BigInt minB,
    required _i9.AccountId32 recipient,
    required int deadline,
  }) {
    return _i7.Amm(
      _i8.RemoveLiquidity(
        assetA: assetA,
        assetB: assetB,
        lp: lp,
        minA: minA,
        minB: minB,
        recipient: recipient,
        deadline: deadline,
      ),
    );
  }

  _i7.Amm swapExactInput({
    required _i4.Asset assetIn,
    required _i4.Asset assetOut,
    required BigInt amountIn,
    required BigInt minOut,
    required _i9.AccountId32 recipient,
    required int deadline,
  }) {
    return _i7.Amm(
      _i8.SwapExactInput(
        assetIn: assetIn,
        assetOut: assetOut,
        amountIn: amountIn,
        minOut: minOut,
        recipient: recipient,
        deadline: deadline,
      ),
    );
  }

  _i7.Amm swapExactOutput({
    required _i4.Asset assetIn,
    required _i4.Asset assetOut,
    required BigInt amountOut,
    required BigInt maxIn,
    required _i9.AccountId32 recipient,
    required int deadline,
  }) {
    return _i7.Amm(
      _i8.SwapExactOutput(
        assetIn: assetIn,
        assetOut: assetOut,
        amountOut: amountOut,
        maxIn: maxIn,
        recipient: recipient,
        deadline: deadline,
      ),
    );
  }

  _i7.Amm approvePair({required _i4.Asset assetA, required _i4.Asset assetB}) {
    return _i7.Amm(_i8.ApprovePair(assetA: assetA, assetB: assetB));
  }

  _i7.Amm activate() {
    return _i7.Amm(_i8.Activate());
  }
}
