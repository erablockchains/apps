// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

enum ActivationRejection {
  alreadyActivated('AlreadyActivated', 0),
  rewardPotMissing('RewardPotMissing', 1),
  rewardPotBelowExistentialDeposit('RewardPotBelowExistentialDeposit', 2),
  rewardPotBelowActivationReserve('RewardPotBelowActivationReserve', 3),
  treasuryPotMissing('TreasuryPotMissing', 4),
  treasuryPotBelowExistentialDeposit('TreasuryPotBelowExistentialDeposit', 5),
  feeCollectionPotMissing('FeeCollectionPotMissing', 6),
  feeCollectionPotBelowExistentialDeposit(
    'FeeCollectionPotBelowExistentialDeposit',
    7,
  ),
  invalidFeeConfiguration('InvalidFeeConfiguration', 8),
  pendingRoutingInconsistent('PendingRoutingInconsistent', 9),
  activationStateInvalid('ActivationStateInvalid', 10);

  const ActivationRejection(this.variantName, this.codecIndex);

  factory ActivationRejection.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ActivationRejectionCodec codec = $ActivationRejectionCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ActivationRejectionCodec with _i1.Codec<ActivationRejection> {
  const $ActivationRejectionCodec();

  @override
  ActivationRejection decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ActivationRejection.alreadyActivated;
      case 1:
        return ActivationRejection.rewardPotMissing;
      case 2:
        return ActivationRejection.rewardPotBelowExistentialDeposit;
      case 3:
        return ActivationRejection.rewardPotBelowActivationReserve;
      case 4:
        return ActivationRejection.treasuryPotMissing;
      case 5:
        return ActivationRejection.treasuryPotBelowExistentialDeposit;
      case 6:
        return ActivationRejection.feeCollectionPotMissing;
      case 7:
        return ActivationRejection.feeCollectionPotBelowExistentialDeposit;
      case 8:
        return ActivationRejection.invalidFeeConfiguration;
      case 9:
        return ActivationRejection.pendingRoutingInconsistent;
      case 10:
        return ActivationRejection.activationStateInvalid;
      default:
        throw Exception('ActivationRejection: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(ActivationRejection value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
