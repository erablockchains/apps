// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum FeeRoutingFailure {
  invalidConfiguration('InvalidConfiguration', 0),
  destinationsNotReady('DestinationsNotReady', 1),
  collectionPotResolution('CollectionPotResolution', 2),
  rewardPotResolution('RewardPotResolution', 3),
  ecosystemTreasuryResolution('EcosystemTreasuryResolution', 4),
  missingBlockAuthor('MissingBlockAuthor', 5),
  authorTipResolution('AuthorTipResolution', 6),
  pendingRoutingInconsistent('PendingRoutingInconsistent', 7);

  const FeeRoutingFailure(this.variantName, this.codecIndex);

  factory FeeRoutingFailure.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $FeeRoutingFailureCodec codec = $FeeRoutingFailureCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $FeeRoutingFailureCodec with _i1.Codec<FeeRoutingFailure> {
  const $FeeRoutingFailureCodec();

  @override
  FeeRoutingFailure decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return FeeRoutingFailure.invalidConfiguration;
      case 1:
        return FeeRoutingFailure.destinationsNotReady;
      case 2:
        return FeeRoutingFailure.collectionPotResolution;
      case 3:
        return FeeRoutingFailure.rewardPotResolution;
      case 4:
        return FeeRoutingFailure.ecosystemTreasuryResolution;
      case 5:
        return FeeRoutingFailure.missingBlockAuthor;
      case 6:
        return FeeRoutingFailure.authorTipResolution;
      case 7:
        return FeeRoutingFailure.pendingRoutingInconsistent;
      default:
        throw Exception('FeeRoutingFailure: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(FeeRoutingFailure value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
