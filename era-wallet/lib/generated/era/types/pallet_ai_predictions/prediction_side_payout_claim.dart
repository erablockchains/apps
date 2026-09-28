// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class PredictionSidePayoutClaim {
  const PredictionSidePayoutClaim({
    required this.claimedAt,
    required this.stakeReturned,
    required this.rewardPaid,
    required this.slashed,
  });

  factory PredictionSidePayoutClaim.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// BlockNumber
  final int claimedAt;

  /// Balance
  final BigInt stakeReturned;

  /// Balance
  final BigInt rewardPaid;

  /// Balance
  final BigInt slashed;

  static const $PredictionSidePayoutClaimCodec codec =
      $PredictionSidePayoutClaimCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'claimedAt': claimedAt,
    'stakeReturned': stakeReturned,
    'rewardPaid': rewardPaid,
    'slashed': slashed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionSidePayoutClaim &&
          other.claimedAt == claimedAt &&
          other.stakeReturned == stakeReturned &&
          other.rewardPaid == rewardPaid &&
          other.slashed == slashed;

  @override
  int get hashCode =>
      Object.hash(claimedAt, stakeReturned, rewardPaid, slashed);
}

class $PredictionSidePayoutClaimCodec
    with _i1.Codec<PredictionSidePayoutClaim> {
  const $PredictionSidePayoutClaimCodec();

  @override
  void encodeTo(PredictionSidePayoutClaim obj, _i1.Output output) {
    _i1.U32Codec.codec.encodeTo(obj.claimedAt, output);
    _i1.U128Codec.codec.encodeTo(obj.stakeReturned, output);
    _i1.U128Codec.codec.encodeTo(obj.rewardPaid, output);
    _i1.U128Codec.codec.encodeTo(obj.slashed, output);
  }

  @override
  PredictionSidePayoutClaim decode(_i1.Input input) {
    return PredictionSidePayoutClaim(
      claimedAt: _i1.U32Codec.codec.decode(input),
      stakeReturned: _i1.U128Codec.codec.decode(input),
      rewardPaid: _i1.U128Codec.codec.decode(input),
      slashed: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PredictionSidePayoutClaim obj) {
    int size = 0;
    size = size + _i1.U32Codec.codec.sizeHint(obj.claimedAt);
    size = size + _i1.U128Codec.codec.sizeHint(obj.stakeReturned);
    size = size + _i1.U128Codec.codec.sizeHint(obj.rewardPaid);
    size = size + _i1.U128Codec.codec.sizeHint(obj.slashed);
    return size;
  }
}
