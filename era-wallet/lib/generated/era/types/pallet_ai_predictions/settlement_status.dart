// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum SettlementStatus {
  notStarted('NotStarted', 0),
  outcomeProposed('OutcomeProposed', 1),
  disputeWindowOpen('DisputeWindowOpen', 2),
  disputed('Disputed', 3),
  finalized('Finalized', 4),
  cancelled('Cancelled', 5);

  const SettlementStatus(this.variantName, this.codecIndex);

  factory SettlementStatus.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $SettlementStatusCodec codec = $SettlementStatusCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $SettlementStatusCodec with _i1.Codec<SettlementStatus> {
  const $SettlementStatusCodec();

  @override
  SettlementStatus decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return SettlementStatus.notStarted;
      case 1:
        return SettlementStatus.outcomeProposed;
      case 2:
        return SettlementStatus.disputeWindowOpen;
      case 3:
        return SettlementStatus.disputed;
      case 4:
        return SettlementStatus.finalized;
      case 5:
        return SettlementStatus.cancelled;
      default:
        throw Exception('SettlementStatus: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(SettlementStatus value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
