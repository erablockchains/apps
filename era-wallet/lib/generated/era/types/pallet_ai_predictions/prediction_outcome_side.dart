// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum PredictionOutcomeSide {
  yes('Yes', 0),
  no('No', 1);

  const PredictionOutcomeSide(this.variantName, this.codecIndex);

  factory PredictionOutcomeSide.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $PredictionOutcomeSideCodec codec =
      $PredictionOutcomeSideCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $PredictionOutcomeSideCodec with _i1.Codec<PredictionOutcomeSide> {
  const $PredictionOutcomeSideCodec();

  @override
  PredictionOutcomeSide decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PredictionOutcomeSide.yes;
      case 1:
        return PredictionOutcomeSide.no;
      default:
        throw Exception(
          'PredictionOutcomeSide: Invalid variant index: "$index"',
        );
    }
  }

  @override
  void encodeTo(PredictionOutcomeSide value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
