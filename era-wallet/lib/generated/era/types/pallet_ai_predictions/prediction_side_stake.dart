// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;

import 'prediction_outcome_side.dart' as _i2;

class PredictionSideStake {
  const PredictionSideStake({
    required this.side,
    required this.amount,
    required this.stakedAt,
    this.updatedAt,
  });

  factory PredictionSideStake.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// PredictionOutcomeSide
  final _i2.PredictionOutcomeSide side;

  /// Balance
  final BigInt amount;

  /// BlockNumber
  final int stakedAt;

  /// Option<BlockNumber>
  final int? updatedAt;

  static const $PredictionSideStakeCodec codec = $PredictionSideStakeCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'side': side.toJson(),
    'amount': amount,
    'stakedAt': stakedAt,
    'updatedAt': updatedAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionSideStake &&
          other.side == side &&
          other.amount == amount &&
          other.stakedAt == stakedAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(side, amount, stakedAt, updatedAt);
}

class $PredictionSideStakeCodec with _i1.Codec<PredictionSideStake> {
  const $PredictionSideStakeCodec();

  @override
  void encodeTo(PredictionSideStake obj, _i1.Output output) {
    _i2.PredictionOutcomeSide.codec.encodeTo(obj.side, output);
    _i1.U128Codec.codec.encodeTo(obj.amount, output);
    _i1.U32Codec.codec.encodeTo(obj.stakedAt, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.updatedAt, output);
  }

  @override
  PredictionSideStake decode(_i1.Input input) {
    return PredictionSideStake(
      side: _i2.PredictionOutcomeSide.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      stakedAt: _i1.U32Codec.codec.decode(input),
      updatedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
    );
  }

  @override
  int sizeHint(PredictionSideStake obj) {
    int size = 0;
    size = size + _i2.PredictionOutcomeSide.codec.sizeHint(obj.side);
    size = size + _i1.U128Codec.codec.sizeHint(obj.amount);
    size = size + _i1.U32Codec.codec.sizeHint(obj.stakedAt);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(obj.updatedAt);
    return size;
  }
}
