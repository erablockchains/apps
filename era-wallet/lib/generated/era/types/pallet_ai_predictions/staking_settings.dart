// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class StakingSettings {
  const StakingSettings({required this.stakingEnabled, required this.minStake});

  factory StakingSettings.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// bool
  final bool stakingEnabled;

  /// Balance
  final BigInt minStake;

  static const $StakingSettingsCodec codec = $StakingSettingsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'stakingEnabled': stakingEnabled,
    'minStake': minStake,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakingSettings &&
          other.stakingEnabled == stakingEnabled &&
          other.minStake == minStake;

  @override
  int get hashCode => Object.hash(stakingEnabled, minStake);
}

class $StakingSettingsCodec with _i1.Codec<StakingSettings> {
  const $StakingSettingsCodec();

  @override
  void encodeTo(StakingSettings obj, _i1.Output output) {
    _i1.BoolCodec.codec.encodeTo(obj.stakingEnabled, output);
    _i1.U128Codec.codec.encodeTo(obj.minStake, output);
  }

  @override
  StakingSettings decode(_i1.Input input) {
    return StakingSettings(
      stakingEnabled: _i1.BoolCodec.codec.decode(input),
      minStake: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(StakingSettings obj) {
    int size = 0;
    size = size + _i1.BoolCodec.codec.sizeHint(obj.stakingEnabled);
    size = size + _i1.U128Codec.codec.sizeHint(obj.minStake);
    return size;
  }
}
