// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class PredictionTokenSettlementClaim {
  const PredictionTokenSettlementClaim({
    required this.claimedAt,
    required this.refunded,
    required this.slashed,
  });

  factory PredictionTokenSettlementClaim.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// BlockNumber
  final int claimedAt;

  /// Balance
  final BigInt refunded;

  /// Balance
  final BigInt slashed;

  static const $PredictionTokenSettlementClaimCodec codec =
      $PredictionTokenSettlementClaimCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'claimedAt': claimedAt,
    'refunded': refunded,
    'slashed': slashed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenSettlementClaim &&
          other.claimedAt == claimedAt &&
          other.refunded == refunded &&
          other.slashed == slashed;

  @override
  int get hashCode => Object.hash(claimedAt, refunded, slashed);
}

class $PredictionTokenSettlementClaimCodec
    with _i1.Codec<PredictionTokenSettlementClaim> {
  const $PredictionTokenSettlementClaimCodec();

  @override
  void encodeTo(PredictionTokenSettlementClaim obj, _i1.Output output) {
    _i1.U32Codec.codec.encodeTo(obj.claimedAt, output);
    _i1.U128Codec.codec.encodeTo(obj.refunded, output);
    _i1.U128Codec.codec.encodeTo(obj.slashed, output);
  }

  @override
  PredictionTokenSettlementClaim decode(_i1.Input input) {
    return PredictionTokenSettlementClaim(
      claimedAt: _i1.U32Codec.codec.decode(input),
      refunded: _i1.U128Codec.codec.decode(input),
      slashed: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PredictionTokenSettlementClaim obj) {
    int size = 0;
    size = size + _i1.U32Codec.codec.sizeHint(obj.claimedAt);
    size = size + _i1.U128Codec.codec.sizeHint(obj.refunded);
    size = size + _i1.U128Codec.codec.sizeHint(obj.slashed);
    return size;
  }
}
