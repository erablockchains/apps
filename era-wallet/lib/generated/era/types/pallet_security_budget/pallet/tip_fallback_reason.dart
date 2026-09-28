// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum TipFallbackReason {
  missingAuthor('MissingAuthor', 0),
  unreceivableAuthor('UnreceivableAuthor', 1);

  const TipFallbackReason(this.variantName, this.codecIndex);

  factory TipFallbackReason.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $TipFallbackReasonCodec codec = $TipFallbackReasonCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $TipFallbackReasonCodec with _i1.Codec<TipFallbackReason> {
  const $TipFallbackReasonCodec();

  @override
  TipFallbackReason decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return TipFallbackReason.missingAuthor;
      case 1:
        return TipFallbackReason.unreceivableAuthor;
      default:
        throw Exception('TipFallbackReason: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(TipFallbackReason value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
