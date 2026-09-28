// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../../sp_core/crypto/account_id32.dart' as _i3;

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

  Issued issued({
    required _i3.AccountId32 beneficiary,
    required BigInt amount,
    required BigInt remainingAllowance,
  }) {
    return Issued(
      beneficiary: beneficiary,
      amount: amount,
      remainingAllowance: remainingAllowance,
    );
  }

  GrossIssued grossIssued({
    required _i3.AccountId32 stakingBeneficiary,
    required BigInt stakingAmount,
    required _i3.AccountId32 treasuryBeneficiary,
    required BigInt treasuryAmount,
    required BigInt grossAmount,
    required BigInt remainingAllowance,
    required int carryBefore,
    required int carryAfter,
  }) {
    return GrossIssued(
      stakingBeneficiary: stakingBeneficiary,
      stakingAmount: stakingAmount,
      treasuryBeneficiary: treasuryBeneficiary,
      treasuryAmount: treasuryAmount,
      grossAmount: grossAmount,
      remainingAllowance: remainingAllowance,
      carryBefore: carryBefore,
      carryAfter: carryAfter,
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
        return Issued._decode(input);
      case 1:
        return GrossIssued._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case Issued:
        (value as Issued).encodeTo(output);
        break;
      case GrossIssued:
        (value as GrossIssued).encodeTo(output);
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
      case Issued:
        return (value as Issued)._sizeHint();
      case GrossIssued:
        return (value as GrossIssued)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

/// New ETKN was created through the single controlled interface.
class Issued extends Event {
  const Issued({
    required this.beneficiary,
    required this.amount,
    required this.remainingAllowance,
  });

  factory Issued._decode(_i1.Input input) {
    return Issued(
      beneficiary: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      remainingAllowance: _i1.U128Codec.codec.decode(input),
    );
  }

  /// T::AccountId
  final _i3.AccountId32 beneficiary;

  /// Balance
  final BigInt amount;

  /// Balance
  final BigInt remainingAllowance;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'Issued': {
      'beneficiary': beneficiary.toList(),
      'amount': amount,
      'remainingAllowance': remainingAllowance,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(beneficiary);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(remainingAllowance);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    const _i1.U8ArrayCodec(32).encodeTo(beneficiary, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(remainingAllowance, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Issued &&
          _i4.listsEqual(other.beneficiary, beneficiary) &&
          other.amount == amount &&
          other.remainingAllowance == remainingAllowance;

  @override
  int get hashCode => Object.hash(beneficiary, amount, remainingAllowance);
}

/// One complete V14 gross issuance was atomically split between protocol accounts.
class GrossIssued extends Event {
  const GrossIssued({
    required this.stakingBeneficiary,
    required this.stakingAmount,
    required this.treasuryBeneficiary,
    required this.treasuryAmount,
    required this.grossAmount,
    required this.remainingAllowance,
    required this.carryBefore,
    required this.carryAfter,
  });

  factory GrossIssued._decode(_i1.Input input) {
    return GrossIssued(
      stakingBeneficiary: const _i1.U8ArrayCodec(32).decode(input),
      stakingAmount: _i1.U128Codec.codec.decode(input),
      treasuryBeneficiary: const _i1.U8ArrayCodec(32).decode(input),
      treasuryAmount: _i1.U128Codec.codec.decode(input),
      grossAmount: _i1.U128Codec.codec.decode(input),
      remainingAllowance: _i1.U128Codec.codec.decode(input),
      carryBefore: _i1.U8Codec.codec.decode(input),
      carryAfter: _i1.U8Codec.codec.decode(input),
    );
  }

  /// T::AccountId
  final _i3.AccountId32 stakingBeneficiary;

  /// Balance
  final BigInt stakingAmount;

  /// T::AccountId
  final _i3.AccountId32 treasuryBeneficiary;

  /// Balance
  final BigInt treasuryAmount;

  /// Balance
  final BigInt grossAmount;

  /// Balance
  final BigInt remainingAllowance;

  /// u8
  final int carryBefore;

  /// u8
  final int carryAfter;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'GrossIssued': {
      'stakingBeneficiary': stakingBeneficiary.toList(),
      'stakingAmount': stakingAmount,
      'treasuryBeneficiary': treasuryBeneficiary.toList(),
      'treasuryAmount': treasuryAmount,
      'grossAmount': grossAmount,
      'remainingAllowance': remainingAllowance,
      'carryBefore': carryBefore,
      'carryAfter': carryAfter,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(stakingBeneficiary);
    size = size + _i1.U128Codec.codec.sizeHint(stakingAmount);
    size = size + const _i3.AccountId32Codec().sizeHint(treasuryBeneficiary);
    size = size + _i1.U128Codec.codec.sizeHint(treasuryAmount);
    size = size + _i1.U128Codec.codec.sizeHint(grossAmount);
    size = size + _i1.U128Codec.codec.sizeHint(remainingAllowance);
    size = size + _i1.U8Codec.codec.sizeHint(carryBefore);
    size = size + _i1.U8Codec.codec.sizeHint(carryAfter);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    const _i1.U8ArrayCodec(32).encodeTo(stakingBeneficiary, output);
    _i1.U128Codec.codec.encodeTo(stakingAmount, output);
    const _i1.U8ArrayCodec(32).encodeTo(treasuryBeneficiary, output);
    _i1.U128Codec.codec.encodeTo(treasuryAmount, output);
    _i1.U128Codec.codec.encodeTo(grossAmount, output);
    _i1.U128Codec.codec.encodeTo(remainingAllowance, output);
    _i1.U8Codec.codec.encodeTo(carryBefore, output);
    _i1.U8Codec.codec.encodeTo(carryAfter, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrossIssued &&
          _i4.listsEqual(other.stakingBeneficiary, stakingBeneficiary) &&
          other.stakingAmount == stakingAmount &&
          _i4.listsEqual(other.treasuryBeneficiary, treasuryBeneficiary) &&
          other.treasuryAmount == treasuryAmount &&
          other.grossAmount == grossAmount &&
          other.remainingAllowance == remainingAllowance &&
          other.carryBefore == carryBefore &&
          other.carryAfter == carryAfter;

  @override
  int get hashCode => Object.hash(
    stakingBeneficiary,
    stakingAmount,
    treasuryBeneficiary,
    treasuryAmount,
    grossAmount,
    remainingAllowance,
    carryBefore,
    carryAfter,
  );
}
