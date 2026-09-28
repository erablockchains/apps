// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum SettlementOutcome {
  correct('Correct', 0),
  incorrect('Incorrect', 1),
  inconclusive('Inconclusive', 2),
  cancelled('Cancelled', 3),
  fraudulent('Fraudulent', 4);

  const SettlementOutcome(this.variantName, this.codecIndex);

  factory SettlementOutcome.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $SettlementOutcomeCodec codec = $SettlementOutcomeCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $SettlementOutcomeCodec with _i1.Codec<SettlementOutcome> {
  const $SettlementOutcomeCodec();

  @override
  SettlementOutcome decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return SettlementOutcome.correct;
      case 1:
        return SettlementOutcome.incorrect;
      case 2:
        return SettlementOutcome.inconclusive;
      case 3:
        return SettlementOutcome.cancelled;
      case 4:
        return SettlementOutcome.fraudulent;
      default:
        throw Exception('SettlementOutcome: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(SettlementOutcome value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
