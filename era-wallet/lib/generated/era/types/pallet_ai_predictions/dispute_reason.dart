// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum DisputeReason {
  wrongOutcome('WrongOutcome', 0),
  invalidSource('InvalidSource', 1),
  sourceUnavailable('SourceUnavailable', 2),
  ambiguousPrediction('AmbiguousPrediction', 3),
  marketManipulation('MarketManipulation', 4),
  duplicateOrFraudulentPrediction('DuplicateOrFraudulentPrediction', 5),
  technicalError('TechnicalError', 6),
  other('Other', 7);

  const DisputeReason(this.variantName, this.codecIndex);

  factory DisputeReason.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $DisputeReasonCodec codec = $DisputeReasonCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $DisputeReasonCodec with _i1.Codec<DisputeReason> {
  const $DisputeReasonCodec();

  @override
  DisputeReason decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return DisputeReason.wrongOutcome;
      case 1:
        return DisputeReason.invalidSource;
      case 2:
        return DisputeReason.sourceUnavailable;
      case 3:
        return DisputeReason.ambiguousPrediction;
      case 4:
        return DisputeReason.marketManipulation;
      case 5:
        return DisputeReason.duplicateOrFraudulentPrediction;
      case 6:
        return DisputeReason.technicalError;
      case 7:
        return DisputeReason.other;
      default:
        throw Exception('DisputeReason: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(DisputeReason value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
