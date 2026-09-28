// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum ProxyType {
  auditOnly('AuditOnly', 0),
  presale('Presale', 1),
  ecosystem('Ecosystem', 2),
  liquidity('Liquidity', 3),
  community('Community', 4);

  const ProxyType(this.variantName, this.codecIndex);

  factory ProxyType.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ProxyTypeCodec codec = $ProxyTypeCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ProxyTypeCodec with _i1.Codec<ProxyType> {
  const $ProxyTypeCodec();

  @override
  ProxyType decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ProxyType.auditOnly;
      case 1:
        return ProxyType.presale;
      case 2:
        return ProxyType.ecosystem;
      case 3:
        return ProxyType.liquidity;
      case 4:
        return ProxyType.community;
      default:
        throw Exception('ProxyType: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(ProxyType value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
