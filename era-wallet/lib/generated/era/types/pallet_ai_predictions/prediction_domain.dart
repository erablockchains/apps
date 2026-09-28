// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum PredictionDomain {
  enterprise('Enterprise', 0),
  finance('Finance', 1),
  risk('Risk', 2),
  market('Market', 3),
  supplyChain('SupplyChain', 4),
  mediaEntertainment('MediaEntertainment', 5),
  gamingVirtualEconomy('GamingVirtualEconomy', 6),
  aiBenchmark('AiBenchmark', 7),
  weatherClimate('WeatherClimate', 8),
  communitySocial('CommunitySocial', 9),
  sportsEventsPermitted('SportsEventsPermitted', 10),
  eraEcosystem('EraEcosystem', 11),
  other('Other', 12);

  const PredictionDomain(this.variantName, this.codecIndex);

  factory PredictionDomain.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $PredictionDomainCodec codec = $PredictionDomainCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $PredictionDomainCodec with _i1.Codec<PredictionDomain> {
  const $PredictionDomainCodec();

  @override
  PredictionDomain decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PredictionDomain.enterprise;
      case 1:
        return PredictionDomain.finance;
      case 2:
        return PredictionDomain.risk;
      case 3:
        return PredictionDomain.market;
      case 4:
        return PredictionDomain.supplyChain;
      case 5:
        return PredictionDomain.mediaEntertainment;
      case 6:
        return PredictionDomain.gamingVirtualEconomy;
      case 7:
        return PredictionDomain.aiBenchmark;
      case 8:
        return PredictionDomain.weatherClimate;
      case 9:
        return PredictionDomain.communitySocial;
      case 10:
        return PredictionDomain.sportsEventsPermitted;
      case 11:
        return PredictionDomain.eraEcosystem;
      case 12:
        return PredictionDomain.other;
      default:
        throw Exception('PredictionDomain: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(PredictionDomain value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
