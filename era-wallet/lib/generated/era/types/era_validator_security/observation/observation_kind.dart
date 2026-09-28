// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum ObservationKind {
  babe('Babe', 0),
  grandpa('Grandpa', 1);

  const ObservationKind(this.variantName, this.codecIndex);

  factory ObservationKind.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ObservationKindCodec codec = $ObservationKindCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ObservationKindCodec with _i1.Codec<ObservationKind> {
  const $ObservationKindCodec();

  @override
  ObservationKind decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ObservationKind.babe;
      case 1:
        return ObservationKind.grandpa;
      default:
        throw Exception('ObservationKind: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(ObservationKind value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
