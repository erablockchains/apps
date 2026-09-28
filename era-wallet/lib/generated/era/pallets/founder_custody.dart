// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i6;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i4;

import '../types/era_runtime/runtime_call.dart' as _i7;
import '../types/era_v14_custody_governance/active/pallet/call.dart' as _i9;
import '../types/era_v14_custody_governance/active/withdrawal_request.dart'
    as _i3;
import '../types/era_v14_custody_governance/custody_category.dart' as _i2;
import '../types/frame_support/pallet_id.dart' as _i10;
import '../types/sp_core/crypto/account_id32.dart' as _i8;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageMap<_i2.CustodyCategory, _i3.WithdrawalRequest>
  _pendingWithdrawal =
      const _i1.StorageMap<_i2.CustodyCategory, _i3.WithdrawalRequest>(
        prefix: 'FounderCustody',
        storage: 'PendingWithdrawal',
        valueCodec: _i3.WithdrawalRequest.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.CustodyCategory.codec),
      );

  final _i1.StorageMap<_i2.CustodyCategory, BigInt> _nextRequestId =
      const _i1.StorageMap<_i2.CustodyCategory, BigInt>(
        prefix: 'FounderCustody',
        storage: 'NextRequestId',
        valueCodec: _i4.U64Codec.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.CustodyCategory.codec),
      );

  _i5.Future<_i3.WithdrawalRequest?> pendingWithdrawal(
    _i2.CustodyCategory key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _pendingWithdrawal.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingWithdrawal.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i5.Future<BigInt> nextRequestId(
    _i2.CustodyCategory key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _nextRequestId.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextRequestId.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i5.Future<List<_i3.WithdrawalRequest?>> multiPendingWithdrawal(
    List<_i2.CustodyCategory> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _pendingWithdrawal.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _pendingWithdrawal.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i5.Future<List<BigInt>> multiNextRequestId(
    List<_i2.CustodyCategory> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _nextRequestId.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _nextRequestId.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  /// Returns the storage key for `pendingWithdrawal`.
  _i6.Uint8List pendingWithdrawalKey(_i2.CustodyCategory key1) {
    final hashedKey = _pendingWithdrawal.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `nextRequestId`.
  _i6.Uint8List nextRequestIdKey(_i2.CustodyCategory key1) {
    final hashedKey = _nextRequestId.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `pendingWithdrawal`.
  _i6.Uint8List pendingWithdrawalMapPrefix() {
    final hashedKey = _pendingWithdrawal.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `nextRequestId`.
  _i6.Uint8List nextRequestIdMapPrefix() {
    final hashedKey = _nextRequestId.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  /// Approve an exact category withdrawal.
  ///
  /// The first and second distinct approvals only record intent. The third approval from the
  /// remaining configured signer atomically transfers from the category's keyless subaccount.
  _i7.FounderCustody approveWithdrawal({
    required _i2.CustodyCategory category,
    required BigInt requestId,
    required _i8.AccountId32 destination,
    required BigInt amount,
  }) {
    return _i7.FounderCustody(
      _i9.ApproveWithdrawal(
        category: category,
        requestId: requestId,
        destination: destination,
        amount: amount,
      ),
    );
  }
}

class Constants {
  Constants();

  final _i10.PalletId custodyPalletId = const <int>[
    101,
    114,
    97,
    47,
    118,
    97,
    109,
    109,
  ];
}
