// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../sp_core/crypto/account_id32.dart' as _i2;

class WithdrawalRequest {
  const WithdrawalRequest({
    required this.requestId,
    required this.destination,
    required this.amount,
    required this.approvals,
  });

  factory WithdrawalRequest.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u64
  final BigInt requestId;

  /// T::AccountId
  final _i2.AccountId32 destination;

  /// BalanceOf<T>
  final BigInt amount;

  /// u8
  final int approvals;

  static const $WithdrawalRequestCodec codec = $WithdrawalRequestCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'destination': destination.toList(),
    'amount': amount,
    'approvals': approvals,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalRequest &&
          other.requestId == requestId &&
          _i4.listsEqual(other.destination, destination) &&
          other.amount == amount &&
          other.approvals == approvals;

  @override
  int get hashCode => Object.hash(requestId, destination, amount, approvals);
}

class $WithdrawalRequestCodec with _i1.Codec<WithdrawalRequest> {
  const $WithdrawalRequestCodec();

  @override
  void encodeTo(WithdrawalRequest obj, _i1.Output output) {
    _i1.U64Codec.codec.encodeTo(obj.requestId, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.destination, output);
    _i1.U128Codec.codec.encodeTo(obj.amount, output);
    _i1.U8Codec.codec.encodeTo(obj.approvals, output);
  }

  @override
  WithdrawalRequest decode(_i1.Input input) {
    return WithdrawalRequest(
      requestId: _i1.U64Codec.codec.decode(input),
      destination: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      approvals: _i1.U8Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(WithdrawalRequest obj) {
    int size = 0;
    size = size + _i1.U64Codec.codec.sizeHint(obj.requestId);
    size = size + const _i2.AccountId32Codec().sizeHint(obj.destination);
    size = size + _i1.U128Codec.codec.sizeHint(obj.amount);
    size = size + _i1.U8Codec.codec.sizeHint(obj.approvals);
    return size;
  }
}
