// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import '../../../sp_core/crypto/account_id32.dart' as _i4;
import '../../custody_category.dart' as _i3;

/// The `Event` enum of this pallet
abstract class Event {
  const Event();

  factory Event.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $EventCodec codec = $EventCodec();

  static const $Event values = $Event();

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

class $Event {
  const $Event();

  ApprovalRecorded approvalRecorded({
    required _i3.CustodyCategory category,
    required BigInt requestId,
    required _i4.AccountId32 signer,
    required int approvalCount,
  }) {
    return ApprovalRecorded(
      category: category,
      requestId: requestId,
      signer: signer,
      approvalCount: approvalCount,
    );
  }

  WithdrawalExecuted withdrawalExecuted({
    required _i3.CustodyCategory category,
    required BigInt requestId,
    required _i4.AccountId32 destination,
    required BigInt amount,
  }) {
    return WithdrawalExecuted(
      category: category,
      requestId: requestId,
      destination: destination,
      amount: amount,
    );
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ApprovalRecorded._decode(input);
      case 1:
        return WithdrawalExecuted._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case ApprovalRecorded:
        (value as ApprovalRecorded).encodeTo(output);
        break;
      case WithdrawalExecuted:
        (value as WithdrawalExecuted).encodeTo(output);
        break;
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Event value) {
    switch (value.runtimeType) {
      case ApprovalRecorded:
        return (value as ApprovalRecorded)._sizeHint();
      case WithdrawalExecuted:
        return (value as WithdrawalExecuted)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class ApprovalRecorded extends Event {
  const ApprovalRecorded({
    required this.category,
    required this.requestId,
    required this.signer,
    required this.approvalCount,
  });

  factory ApprovalRecorded._decode(_i1.Input input) {
    return ApprovalRecorded(
      category: _i3.CustodyCategory.codec.decode(input),
      requestId: _i1.U64Codec.codec.decode(input),
      signer: const _i1.U8ArrayCodec(32).decode(input),
      approvalCount: _i1.U8Codec.codec.decode(input),
    );
  }

  /// CustodyCategory
  final _i3.CustodyCategory category;

  /// u64
  final BigInt requestId;

  /// T::AccountId
  final _i4.AccountId32 signer;

  /// u8
  final int approvalCount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ApprovalRecorded': {
      'category': category.toJson(),
      'requestId': requestId,
      'signer': signer.toList(),
      'approvalCount': approvalCount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.CustodyCategory.codec.sizeHint(category);
    size = size + _i1.U64Codec.codec.sizeHint(requestId);
    size = size + const _i4.AccountId32Codec().sizeHint(signer);
    size = size + _i1.U8Codec.codec.sizeHint(approvalCount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.CustodyCategory.codec.encodeTo(category, output);
    _i1.U64Codec.codec.encodeTo(requestId, output);
    const _i1.U8ArrayCodec(32).encodeTo(signer, output);
    _i1.U8Codec.codec.encodeTo(approvalCount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovalRecorded &&
          other.category == category &&
          other.requestId == requestId &&
          _i5.listsEqual(other.signer, signer) &&
          other.approvalCount == approvalCount;

  @override
  int get hashCode => Object.hash(category, requestId, signer, approvalCount);
}

class WithdrawalExecuted extends Event {
  const WithdrawalExecuted({
    required this.category,
    required this.requestId,
    required this.destination,
    required this.amount,
  });

  factory WithdrawalExecuted._decode(_i1.Input input) {
    return WithdrawalExecuted(
      category: _i3.CustodyCategory.codec.decode(input),
      requestId: _i1.U64Codec.codec.decode(input),
      destination: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
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
    'WithdrawalExecuted': {
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
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i3.CustodyCategory.codec.encodeTo(category, output);
    _i1.U64Codec.codec.encodeTo(requestId, output);
    const _i1.U8ArrayCodec(32).encodeTo(destination, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalExecuted &&
          other.category == category &&
          other.requestId == requestId &&
          _i5.listsEqual(other.destination, destination) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(category, requestId, destination, amount);
}
