// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum ObservationSource {
  localUnsignedValidation('LocalUnsignedValidation', 0),
  rehearsalImport('RehearsalImport', 1);

  const ObservationSource(this.variantName, this.codecIndex);

  factory ObservationSource.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ObservationSourceCodec codec = $ObservationSourceCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ObservationSourceCodec with _i1.Codec<ObservationSource> {
  const $ObservationSourceCodec();

  @override
  ObservationSource decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ObservationSource.localUnsignedValidation;
      case 1:
        return ObservationSource.rehearsalImport;
      default:
        throw Exception('ObservationSource: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(ObservationSource value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
