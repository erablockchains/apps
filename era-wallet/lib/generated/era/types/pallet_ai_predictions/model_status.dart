// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum ModelStatus {
  pending('Pending', 0),
  approved('Approved', 1),
  suspended('Suspended', 2),
  rejected('Rejected', 3);

  const ModelStatus(this.variantName, this.codecIndex);

  factory ModelStatus.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ModelStatusCodec codec = $ModelStatusCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ModelStatusCodec with _i1.Codec<ModelStatus> {
  const $ModelStatusCodec();

  @override
  ModelStatus decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ModelStatus.pending;
      case 1:
        return ModelStatus.approved;
      case 2:
        return ModelStatus.suspended;
      case 3:
        return ModelStatus.rejected;
      default:
        throw Exception('ModelStatus: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(ModelStatus value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
