// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum IssuanceLimit {
  none('None', 0),
  annualCeiling('AnnualCeiling', 1),
  lifetimeAllowance('LifetimeAllowance', 2),
  annualCeilingAndLifetimeAllowance('AnnualCeilingAndLifetimeAllowance', 3),
  lifetimeRewardBudget('LifetimeRewardBudget', 4),
  multiple('Multiple', 5);

  const IssuanceLimit(this.variantName, this.codecIndex);

  factory IssuanceLimit.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $IssuanceLimitCodec codec = $IssuanceLimitCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $IssuanceLimitCodec with _i1.Codec<IssuanceLimit> {
  const $IssuanceLimitCodec();

  @override
  IssuanceLimit decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return IssuanceLimit.none;
      case 1:
        return IssuanceLimit.annualCeiling;
      case 2:
        return IssuanceLimit.lifetimeAllowance;
      case 3:
        return IssuanceLimit.annualCeilingAndLifetimeAllowance;
      case 4:
        return IssuanceLimit.lifetimeRewardBudget;
      case 5:
        return IssuanceLimit.multiple;
      default:
        throw Exception('IssuanceLimit: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(IssuanceLimit value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
