// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class SettlementSettings {
  const SettlementSettings({
    required this.settlementEnabled,
    required this.disputeWindowBlocks,
    required this.minDisputeBond,
  });

  factory SettlementSettings.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// bool
  final bool settlementEnabled;

  /// BlockNumber
  final int disputeWindowBlocks;

  /// Balance
  final BigInt minDisputeBond;

  static const $SettlementSettingsCodec codec = $SettlementSettingsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'settlementEnabled': settlementEnabled,
    'disputeWindowBlocks': disputeWindowBlocks,
    'minDisputeBond': minDisputeBond,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementSettings &&
          other.settlementEnabled == settlementEnabled &&
          other.disputeWindowBlocks == disputeWindowBlocks &&
          other.minDisputeBond == minDisputeBond;

  @override
  int get hashCode =>
      Object.hash(settlementEnabled, disputeWindowBlocks, minDisputeBond);
}

class $SettlementSettingsCodec with _i1.Codec<SettlementSettings> {
  const $SettlementSettingsCodec();

  @override
  void encodeTo(SettlementSettings obj, _i1.Output output) {
    _i1.BoolCodec.codec.encodeTo(obj.settlementEnabled, output);
    _i1.U32Codec.codec.encodeTo(obj.disputeWindowBlocks, output);
    _i1.U128Codec.codec.encodeTo(obj.minDisputeBond, output);
  }

  @override
  SettlementSettings decode(_i1.Input input) {
    return SettlementSettings(
      settlementEnabled: _i1.BoolCodec.codec.decode(input),
      disputeWindowBlocks: _i1.U32Codec.codec.decode(input),
      minDisputeBond: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(SettlementSettings obj) {
    int size = 0;
    size = size + _i1.BoolCodec.codec.sizeHint(obj.settlementEnabled);
    size = size + _i1.U32Codec.codec.sizeHint(obj.disputeWindowBlocks);
    size = size + _i1.U128Codec.codec.sizeHint(obj.minDisputeBond);
    return size;
  }
}
