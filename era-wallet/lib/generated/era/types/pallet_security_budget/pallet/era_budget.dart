// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class EraBudget {
  const EraBudget({
    required this.grossIssuance,
    required this.stakingIssuance,
    required this.treasuryIssuance,
    required this.feeStaking,
    required this.failedAuthorTips,
    required this.retainedCarry,
    required this.total,
    required this.eligibleStake,
    required this.eligiblePoints,
    required this.durationMillis,
  });

  factory EraBudget.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u128
  final BigInt grossIssuance;

  /// u128
  final BigInt stakingIssuance;

  /// u128
  final BigInt treasuryIssuance;

  /// u128
  final BigInt feeStaking;

  /// u128
  final BigInt failedAuthorTips;

  /// u128
  final BigInt retainedCarry;

  /// u128
  final BigInt total;

  /// u128
  final BigInt eligibleStake;

  /// u32
  final int eligiblePoints;

  /// u64
  final BigInt durationMillis;

  static const $EraBudgetCodec codec = $EraBudgetCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'grossIssuance': grossIssuance,
    'stakingIssuance': stakingIssuance,
    'treasuryIssuance': treasuryIssuance,
    'feeStaking': feeStaking,
    'failedAuthorTips': failedAuthorTips,
    'retainedCarry': retainedCarry,
    'total': total,
    'eligibleStake': eligibleStake,
    'eligiblePoints': eligiblePoints,
    'durationMillis': durationMillis,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraBudget &&
          other.grossIssuance == grossIssuance &&
          other.stakingIssuance == stakingIssuance &&
          other.treasuryIssuance == treasuryIssuance &&
          other.feeStaking == feeStaking &&
          other.failedAuthorTips == failedAuthorTips &&
          other.retainedCarry == retainedCarry &&
          other.total == total &&
          other.eligibleStake == eligibleStake &&
          other.eligiblePoints == eligiblePoints &&
          other.durationMillis == durationMillis;

  @override
  int get hashCode => Object.hash(
    grossIssuance,
    stakingIssuance,
    treasuryIssuance,
    feeStaking,
    failedAuthorTips,
    retainedCarry,
    total,
    eligibleStake,
    eligiblePoints,
    durationMillis,
  );
}

class $EraBudgetCodec with _i1.Codec<EraBudget> {
  const $EraBudgetCodec();

  @override
  void encodeTo(EraBudget obj, _i1.Output output) {
    _i1.U128Codec.codec.encodeTo(obj.grossIssuance, output);
    _i1.U128Codec.codec.encodeTo(obj.stakingIssuance, output);
    _i1.U128Codec.codec.encodeTo(obj.treasuryIssuance, output);
    _i1.U128Codec.codec.encodeTo(obj.feeStaking, output);
    _i1.U128Codec.codec.encodeTo(obj.failedAuthorTips, output);
    _i1.U128Codec.codec.encodeTo(obj.retainedCarry, output);
    _i1.U128Codec.codec.encodeTo(obj.total, output);
    _i1.U128Codec.codec.encodeTo(obj.eligibleStake, output);
    _i1.U32Codec.codec.encodeTo(obj.eligiblePoints, output);
    _i1.U64Codec.codec.encodeTo(obj.durationMillis, output);
  }

  @override
  EraBudget decode(_i1.Input input) {
    return EraBudget(
      grossIssuance: _i1.U128Codec.codec.decode(input),
      stakingIssuance: _i1.U128Codec.codec.decode(input),
      treasuryIssuance: _i1.U128Codec.codec.decode(input),
      feeStaking: _i1.U128Codec.codec.decode(input),
      failedAuthorTips: _i1.U128Codec.codec.decode(input),
      retainedCarry: _i1.U128Codec.codec.decode(input),
      total: _i1.U128Codec.codec.decode(input),
      eligibleStake: _i1.U128Codec.codec.decode(input),
      eligiblePoints: _i1.U32Codec.codec.decode(input),
      durationMillis: _i1.U64Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(EraBudget obj) {
    int size = 0;
    size = size + _i1.U128Codec.codec.sizeHint(obj.grossIssuance);
    size = size + _i1.U128Codec.codec.sizeHint(obj.stakingIssuance);
    size = size + _i1.U128Codec.codec.sizeHint(obj.treasuryIssuance);
    size = size + _i1.U128Codec.codec.sizeHint(obj.feeStaking);
    size = size + _i1.U128Codec.codec.sizeHint(obj.failedAuthorTips);
    size = size + _i1.U128Codec.codec.sizeHint(obj.retainedCarry);
    size = size + _i1.U128Codec.codec.sizeHint(obj.total);
    size = size + _i1.U128Codec.codec.sizeHint(obj.eligibleStake);
    size = size + _i1.U32Codec.codec.sizeHint(obj.eligiblePoints);
    size = size + _i1.U64Codec.codec.sizeHint(obj.durationMillis);
    return size;
  }
}
