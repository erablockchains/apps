// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum PredictionStatus {
  open('Open', 0),
  validated('Validated', 1),
  closed('Closed', 2),
  expired('Expired', 3);

  const PredictionStatus(this.variantName, this.codecIndex);

  factory PredictionStatus.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $PredictionStatusCodec codec = $PredictionStatusCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $PredictionStatusCodec with _i1.Codec<PredictionStatus> {
  const $PredictionStatusCodec();

  @override
  PredictionStatus decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PredictionStatus.open;
      case 1:
        return PredictionStatus.validated;
      case 2:
        return PredictionStatus.closed;
      case 3:
        return PredictionStatus.expired;
      default:
        throw Exception('PredictionStatus: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(PredictionStatus value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
