// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum CustodyCategory {
  presale('Presale', 0),
  ecosystem('Ecosystem', 1),
  liquidity('Liquidity', 2);

  const CustodyCategory(this.variantName, this.codecIndex);

  factory CustodyCategory.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $CustodyCategoryCodec codec = $CustodyCategoryCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $CustodyCategoryCodec with _i1.Codec<CustodyCategory> {
  const $CustodyCategoryCodec();

  @override
  CustodyCategory decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return CustodyCategory.presale;
      case 1:
        return CustodyCategory.ecosystem;
      case 2:
        return CustodyCategory.liquidity;
      default:
        throw Exception('CustodyCategory: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(CustodyCategory value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
