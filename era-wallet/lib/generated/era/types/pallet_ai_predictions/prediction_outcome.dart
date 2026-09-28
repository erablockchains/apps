// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum PredictionOutcome {
  successful('Successful', 0),
  failed('Failed', 1),
  inconclusive('Inconclusive', 2);

  const PredictionOutcome(this.variantName, this.codecIndex);

  factory PredictionOutcome.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $PredictionOutcomeCodec codec = $PredictionOutcomeCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $PredictionOutcomeCodec with _i1.Codec<PredictionOutcome> {
  const $PredictionOutcomeCodec();

  @override
  PredictionOutcome decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PredictionOutcome.successful;
      case 1:
        return PredictionOutcome.failed;
      case 2:
        return PredictionOutcome.inconclusive;
      default:
        throw Exception('PredictionOutcome: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(PredictionOutcome value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
