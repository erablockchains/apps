// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum RewardEraSkipReason {
  partialPointSourceEra('PartialPointSourceEra', 0),
  noRewardPoints('NoRewardPoints', 1),
  allocationPaused('AllocationPaused', 2);

  const RewardEraSkipReason(this.variantName, this.codecIndex);

  factory RewardEraSkipReason.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $RewardEraSkipReasonCodec codec = $RewardEraSkipReasonCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $RewardEraSkipReasonCodec with _i1.Codec<RewardEraSkipReason> {
  const $RewardEraSkipReasonCodec();

  @override
  RewardEraSkipReason decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RewardEraSkipReason.partialPointSourceEra;
      case 1:
        return RewardEraSkipReason.noRewardPoints;
      case 2:
        return RewardEraSkipReason.allocationPaused;
      default:
        throw Exception('RewardEraSkipReason: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(RewardEraSkipReason value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
