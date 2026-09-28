// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum EraSkipReason {
  noRewardPoints('NoRewardPoints', 0),
  noEligibleValidators('NoEligibleValidators', 1),
  noFundedBudget('NoFundedBudget', 2),
  lifetimeRewardBudgetExhausted('LifetimeRewardBudgetExhausted', 3);

  const EraSkipReason(this.variantName, this.codecIndex);

  factory EraSkipReason.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $EraSkipReasonCodec codec = $EraSkipReasonCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $EraSkipReasonCodec with _i1.Codec<EraSkipReason> {
  const $EraSkipReasonCodec();

  @override
  EraSkipReason decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return EraSkipReason.noRewardPoints;
      case 1:
        return EraSkipReason.noEligibleValidators;
      case 2:
        return EraSkipReason.noFundedBudget;
      case 3:
        return EraSkipReason.lifetimeRewardBudgetExhausted;
      default:
        throw Exception('EraSkipReason: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(EraSkipReason value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
