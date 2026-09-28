// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class FeeRoutingConfiguration {
  const FeeRoutingConfiguration({
    required this.rewardPotPercent,
    required this.ecosystemTreasuryPercent,
    required this.burnPercent,
    required this.tipToAuthorPercent,
  });

  factory FeeRoutingConfiguration.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u8
  final int rewardPotPercent;

  /// u8
  final int ecosystemTreasuryPercent;

  /// u8
  final int burnPercent;

  /// u8
  final int tipToAuthorPercent;

  static const $FeeRoutingConfigurationCodec codec =
      $FeeRoutingConfigurationCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, int> toJson() => {
    'rewardPotPercent': rewardPotPercent,
    'ecosystemTreasuryPercent': ecosystemTreasuryPercent,
    'burnPercent': burnPercent,
    'tipToAuthorPercent': tipToAuthorPercent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRoutingConfiguration &&
          other.rewardPotPercent == rewardPotPercent &&
          other.ecosystemTreasuryPercent == ecosystemTreasuryPercent &&
          other.burnPercent == burnPercent &&
          other.tipToAuthorPercent == tipToAuthorPercent;

  @override
  int get hashCode => Object.hash(
    rewardPotPercent,
    ecosystemTreasuryPercent,
    burnPercent,
    tipToAuthorPercent,
  );
}

class $FeeRoutingConfigurationCodec with _i1.Codec<FeeRoutingConfiguration> {
  const $FeeRoutingConfigurationCodec();

  @override
  void encodeTo(FeeRoutingConfiguration obj, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(obj.rewardPotPercent, output);
    _i1.U8Codec.codec.encodeTo(obj.ecosystemTreasuryPercent, output);
    _i1.U8Codec.codec.encodeTo(obj.burnPercent, output);
    _i1.U8Codec.codec.encodeTo(obj.tipToAuthorPercent, output);
  }

  @override
  FeeRoutingConfiguration decode(_i1.Input input) {
    return FeeRoutingConfiguration(
      rewardPotPercent: _i1.U8Codec.codec.decode(input),
      ecosystemTreasuryPercent: _i1.U8Codec.codec.decode(input),
      burnPercent: _i1.U8Codec.codec.decode(input),
      tipToAuthorPercent: _i1.U8Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(FeeRoutingConfiguration obj) {
    int size = 0;
    size = size + _i1.U8Codec.codec.sizeHint(obj.rewardPotPercent);
    size = size + _i1.U8Codec.codec.sizeHint(obj.ecosystemTreasuryPercent);
    size = size + _i1.U8Codec.codec.sizeHint(obj.burnPercent);
    size = size + _i1.U8Codec.codec.sizeHint(obj.tipToAuthorPercent);
    return size;
  }
}
