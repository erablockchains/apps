// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class PredictionMarketEconomicsSettings {
  const PredictionMarketEconomicsSettings({
    required this.marketEnabled,
    required this.allowUnstakeBeforeSettlement,
    required this.feesEnabled,
    required this.feeBps,
    required this.treasuryEnabled,
  });

  factory PredictionMarketEconomicsSettings.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// bool
  final bool marketEnabled;

  /// bool
  final bool allowUnstakeBeforeSettlement;

  /// bool
  final bool feesEnabled;

  /// u16
  final int feeBps;

  /// bool
  final bool treasuryEnabled;

  static const $PredictionMarketEconomicsSettingsCodec codec =
      $PredictionMarketEconomicsSettingsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'marketEnabled': marketEnabled,
    'allowUnstakeBeforeSettlement': allowUnstakeBeforeSettlement,
    'feesEnabled': feesEnabled,
    'feeBps': feeBps,
    'treasuryEnabled': treasuryEnabled,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketEconomicsSettings &&
          other.marketEnabled == marketEnabled &&
          other.allowUnstakeBeforeSettlement == allowUnstakeBeforeSettlement &&
          other.feesEnabled == feesEnabled &&
          other.feeBps == feeBps &&
          other.treasuryEnabled == treasuryEnabled;

  @override
  int get hashCode => Object.hash(
    marketEnabled,
    allowUnstakeBeforeSettlement,
    feesEnabled,
    feeBps,
    treasuryEnabled,
  );
}

class $PredictionMarketEconomicsSettingsCodec
    with _i1.Codec<PredictionMarketEconomicsSettings> {
  const $PredictionMarketEconomicsSettingsCodec();

  @override
  void encodeTo(PredictionMarketEconomicsSettings obj, _i1.Output output) {
    _i1.BoolCodec.codec.encodeTo(obj.marketEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.allowUnstakeBeforeSettlement, output);
    _i1.BoolCodec.codec.encodeTo(obj.feesEnabled, output);
    _i1.U16Codec.codec.encodeTo(obj.feeBps, output);
    _i1.BoolCodec.codec.encodeTo(obj.treasuryEnabled, output);
  }

  @override
  PredictionMarketEconomicsSettings decode(_i1.Input input) {
    return PredictionMarketEconomicsSettings(
      marketEnabled: _i1.BoolCodec.codec.decode(input),
      allowUnstakeBeforeSettlement: _i1.BoolCodec.codec.decode(input),
      feesEnabled: _i1.BoolCodec.codec.decode(input),
      feeBps: _i1.U16Codec.codec.decode(input),
      treasuryEnabled: _i1.BoolCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PredictionMarketEconomicsSettings obj) {
    int size = 0;
    size = size + _i1.BoolCodec.codec.sizeHint(obj.marketEnabled);
    size =
        size + _i1.BoolCodec.codec.sizeHint(obj.allowUnstakeBeforeSettlement);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.feesEnabled);
    size = size + _i1.U16Codec.codec.sizeHint(obj.feeBps);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.treasuryEnabled);
    return size;
  }
}
