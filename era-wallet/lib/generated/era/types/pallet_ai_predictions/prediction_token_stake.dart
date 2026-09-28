// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class PredictionTokenStake {
  const PredictionTokenStake({
    required this.amount,
    required this.createdAt,
    this.updatedAt,
  });

  factory PredictionTokenStake.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// Balance
  final BigInt amount;

  /// BlockNumber
  final int createdAt;

  /// Option<BlockNumber>
  final int? updatedAt;

  static const $PredictionTokenStakeCodec codec = $PredictionTokenStakeCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenStake &&
          other.amount == amount &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(amount, createdAt, updatedAt);
}

class $PredictionTokenStakeCodec with _i1.Codec<PredictionTokenStake> {
  const $PredictionTokenStakeCodec();

  @override
  void encodeTo(PredictionTokenStake obj, _i1.Output output) {
    _i1.U128Codec.codec.encodeTo(obj.amount, output);
    _i1.U32Codec.codec.encodeTo(obj.createdAt, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.updatedAt, output);
  }

  @override
  PredictionTokenStake decode(_i1.Input input) {
    return PredictionTokenStake(
      amount: _i1.U128Codec.codec.decode(input),
      createdAt: _i1.U32Codec.codec.decode(input),
      updatedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
    );
  }

  @override
  int sizeHint(PredictionTokenStake obj) {
    int size = 0;
    size = size + _i1.U128Codec.codec.sizeHint(obj.amount);
    size = size + _i1.U32Codec.codec.sizeHint(obj.createdAt);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(obj.updatedAt);
    return size;
  }
}
