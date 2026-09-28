// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import '../../../sp_core/crypto/account_id32.dart' as _i4;
import '../../custody_category.dart' as _i3;

/// Contains a variant per dispatchable extrinsic that this pallet has.
abstract class Call {
  const Call();

  factory Call.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $CallCodec codec = $CallCodec();

  static const $Call values = $Call();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, dynamic>> toJson();
}

class $Call {
  const $Call();

  ApproveWithdrawal approveWithdrawal({
    required _i3.CustodyCategory category,
    required BigInt requestId,
    required _i4.AccountId32 destination,
    required BigInt amount,
  }) {
    return ApproveWithdrawal(
      category: category,
      requestId: requestId,
      destination: destination,
      amount: amount,
    );
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ApproveWithdrawal._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case ApproveWithdrawal:
        (value as ApproveWithdrawal).encodeTo(output);
        break;
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Call value) {
    switch (value.runtimeType) {
      case ApproveWithdrawal:
        return (value as ApproveWithdrawal)._sizeHint();
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

/// Approve an exact category withdrawal.
///
/// The first and second distinct approvals only record intent. The third approval from the
/// remaining configured signer atomically transfers from the category's keyless subaccount.
class ApproveWithdrawal extends Call {
  const ApproveWithdrawal({
    required this.category,
    required this.requestId,
    required this.destination,
    required this.amount,
  });

  factory ApproveWithdrawal._decode(_i1.Input input) {
    return ApproveWithdrawal(
      category: _i3.CustodyCategory.codec.decode(input),
      requestId: _i1.U64Codec.codec.decode(input),
      destination: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.CompactBigIntCodec.codec.decode(input),
    );
  }

  /// CustodyCategory
  final _i3.CustodyCategory category;

  /// u64
  final BigInt requestId;

  /// T::AccountId
  final _i4.AccountId32 destination;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'approve_withdrawal': {
      'category': category.toJson(),
      'requestId': requestId,
      'destination': destination.toList(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.CustodyCategory.codec.sizeHint(category);
    size = size + _i1.U64Codec.codec.sizeHint(requestId);
    size = size + const _i4.AccountId32Codec().sizeHint(destination);
    size = size + _i1.CompactBigIntCodec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.CustodyCategory.codec.encodeTo(category, output);
    _i1.U64Codec.codec.encodeTo(requestId, output);
    const _i1.U8ArrayCodec(32).encodeTo(destination, output);
    _i1.CompactBigIntCodec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApproveWithdrawal &&
          other.category == category &&
          other.requestId == requestId &&
          _i5.listsEqual(other.destination, destination) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(category, requestId, destination, amount);
}
