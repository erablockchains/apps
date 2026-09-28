// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum LiabilityCancellationReason {
  noRewardPoints('NoRewardPoints', 0);

  const LiabilityCancellationReason(this.variantName, this.codecIndex);

  factory LiabilityCancellationReason.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $LiabilityCancellationReasonCodec codec =
      $LiabilityCancellationReasonCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $LiabilityCancellationReasonCodec
    with _i1.Codec<LiabilityCancellationReason> {
  const $LiabilityCancellationReasonCodec();

  @override
  LiabilityCancellationReason decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return LiabilityCancellationReason.noRewardPoints;
      default:
        throw Exception(
          'LiabilityCancellationReason: Invalid variant index: "$index"',
        );
    }
  }

  @override
  void encodeTo(LiabilityCancellationReason value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
