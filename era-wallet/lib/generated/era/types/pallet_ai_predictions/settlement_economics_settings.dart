// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class SettlementEconomicsSettings {
  const SettlementEconomicsSettings({
    required this.economicsEnabled,
    required this.slashIncorrect,
    required this.slashFraudulent,
  });

  factory SettlementEconomicsSettings.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// bool
  final bool economicsEnabled;

  /// bool
  final bool slashIncorrect;

  /// bool
  final bool slashFraudulent;

  static const $SettlementEconomicsSettingsCodec codec =
      $SettlementEconomicsSettingsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, bool> toJson() => {
    'economicsEnabled': economicsEnabled,
    'slashIncorrect': slashIncorrect,
    'slashFraudulent': slashFraudulent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementEconomicsSettings &&
          other.economicsEnabled == economicsEnabled &&
          other.slashIncorrect == slashIncorrect &&
          other.slashFraudulent == slashFraudulent;

  @override
  int get hashCode =>
      Object.hash(economicsEnabled, slashIncorrect, slashFraudulent);
}

class $SettlementEconomicsSettingsCodec
    with _i1.Codec<SettlementEconomicsSettings> {
  const $SettlementEconomicsSettingsCodec();

  @override
  void encodeTo(SettlementEconomicsSettings obj, _i1.Output output) {
    _i1.BoolCodec.codec.encodeTo(obj.economicsEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.slashIncorrect, output);
    _i1.BoolCodec.codec.encodeTo(obj.slashFraudulent, output);
  }

  @override
  SettlementEconomicsSettings decode(_i1.Input input) {
    return SettlementEconomicsSettings(
      economicsEnabled: _i1.BoolCodec.codec.decode(input),
      slashIncorrect: _i1.BoolCodec.codec.decode(input),
      slashFraudulent: _i1.BoolCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(SettlementEconomicsSettings obj) {
    int size = 0;
    size = size + _i1.BoolCodec.codec.sizeHint(obj.economicsEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.slashIncorrect);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.slashFraudulent);
    return size;
  }
}
