// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum TreasurySource {
  newIssuance('NewIssuance', 0),
  normalFee('NormalFee', 1),
  receivableTip('ReceivableTip', 2),
  failedAuthorTip('FailedAuthorTip', 3);

  const TreasurySource(this.variantName, this.codecIndex);

  factory TreasurySource.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $TreasurySourceCodec codec = $TreasurySourceCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $TreasurySourceCodec with _i1.Codec<TreasurySource> {
  const $TreasurySourceCodec();

  @override
  TreasurySource decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return TreasurySource.newIssuance;
      case 1:
        return TreasurySource.normalFee;
      case 2:
        return TreasurySource.receivableTip;
      case 3:
        return TreasurySource.failedAuthorTip;
      default:
        throw Exception('TreasurySource: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(TreasurySource value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
