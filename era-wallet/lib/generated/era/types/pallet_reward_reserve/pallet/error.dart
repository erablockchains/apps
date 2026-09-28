// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  notActivated('NotActivated', 0),
  alreadyActivated('AlreadyActivated', 1),
  rewardPotMissing('RewardPotMissing', 2),
  rewardPotBelowExistentialDeposit('RewardPotBelowExistentialDeposit', 3),
  rewardPotBelowActivationReserve('RewardPotBelowActivationReserve', 4),
  treasuryPotMissing('TreasuryPotMissing', 5),
  treasuryPotBelowExistentialDeposit('TreasuryPotBelowExistentialDeposit', 6),
  feeCollectionPotMissing('FeeCollectionPotMissing', 7),
  feeCollectionPotBelowExistentialDeposit(
    'FeeCollectionPotBelowExistentialDeposit',
    8,
  ),
  pendingRoutingInconsistent('PendingRoutingInconsistent', 9),
  activationStateInvalid('ActivationStateInvalid', 10),
  feeRoutingUnavailable('FeeRoutingUnavailable', 11),
  eraNotEligible('EraNotEligible', 12),
  eraNotFinalized('EraNotFinalized', 13),
  eraAlreadyFinalized('EraAlreadyFinalized', 14),
  claimExpired('ClaimExpired', 15),
  alreadyClaimed('AlreadyClaimed', 16),
  validatorNotRewarded('ValidatorNotRewarded', 17),
  invalidRewardPoints('InvalidRewardPoints', 18),
  rewardEraSkipped('RewardEraSkipped', 19),
  rewardEraCancelled('RewardEraCancelled', 20),
  invalidLegacyZeroPointEra('InvalidLegacyZeroPointEra', 21),
  legacyLiabilityPeriodChanged('LegacyLiabilityPeriodChanged', 22),
  liabilityAlreadyCancelled('LiabilityAlreadyCancelled', 23),
  liabilityAmountMismatch('LiabilityAmountMismatch', 24),
  liabilityAlreadyPaid('LiabilityAlreadyPaid', 25),
  liabilityHasClaims('LiabilityHasClaims', 26),
  invalidExposure('InvalidExposure', 27),
  invalidPage('InvalidPage', 28),
  tooManyRewardRecipients('TooManyRewardRecipients', 29),
  arithmeticOverflow('ArithmeticOverflow', 30),
  insufficientRewardPot('InsufficientRewardPot', 31),
  insufficientEraLiability('InsufficientEraLiability', 32),
  rewardTransferFailed('RewardTransferFailed', 33),
  issuanceInvariantViolated('IssuanceInvariantViolated', 34),
  noFundingIncrease('NoFundingIncrease', 35),
  invalidFeeRoutingConfiguration('InvalidFeeRoutingConfiguration', 36),
  treasurySpendFailed('TreasurySpendFailed', 37),
  invalidTreasuryBeneficiary('InvalidTreasuryBeneficiary', 38),
  zeroAmount('ZeroAmount', 39),
  legacyClaimOnly('LegacyClaimOnly', 40);

  const Error(this.variantName, this.codecIndex);

  factory Error.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ErrorCodec codec = $ErrorCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ErrorCodec with _i1.Codec<Error> {
  const $ErrorCodec();

  @override
  Error decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return Error.notActivated;
      case 1:
        return Error.alreadyActivated;
      case 2:
        return Error.rewardPotMissing;
      case 3:
        return Error.rewardPotBelowExistentialDeposit;
      case 4:
        return Error.rewardPotBelowActivationReserve;
      case 5:
        return Error.treasuryPotMissing;
      case 6:
        return Error.treasuryPotBelowExistentialDeposit;
      case 7:
        return Error.feeCollectionPotMissing;
      case 8:
        return Error.feeCollectionPotBelowExistentialDeposit;
      case 9:
        return Error.pendingRoutingInconsistent;
      case 10:
        return Error.activationStateInvalid;
      case 11:
        return Error.feeRoutingUnavailable;
      case 12:
        return Error.eraNotEligible;
      case 13:
        return Error.eraNotFinalized;
      case 14:
        return Error.eraAlreadyFinalized;
      case 15:
        return Error.claimExpired;
      case 16:
        return Error.alreadyClaimed;
      case 17:
        return Error.validatorNotRewarded;
      case 18:
        return Error.invalidRewardPoints;
      case 19:
        return Error.rewardEraSkipped;
      case 20:
        return Error.rewardEraCancelled;
      case 21:
        return Error.invalidLegacyZeroPointEra;
      case 22:
        return Error.legacyLiabilityPeriodChanged;
      case 23:
        return Error.liabilityAlreadyCancelled;
      case 24:
        return Error.liabilityAmountMismatch;
      case 25:
        return Error.liabilityAlreadyPaid;
      case 26:
        return Error.liabilityHasClaims;
      case 27:
        return Error.invalidExposure;
      case 28:
        return Error.invalidPage;
      case 29:
        return Error.tooManyRewardRecipients;
      case 30:
        return Error.arithmeticOverflow;
      case 31:
        return Error.insufficientRewardPot;
      case 32:
        return Error.insufficientEraLiability;
      case 33:
        return Error.rewardTransferFailed;
      case 34:
        return Error.issuanceInvariantViolated;
      case 35:
        return Error.noFundingIncrease;
      case 36:
        return Error.invalidFeeRoutingConfiguration;
      case 37:
        return Error.treasurySpendFailed;
      case 38:
        return Error.invalidTreasuryBeneficiary;
      case 39:
        return Error.zeroAmount;
      case 40:
        return Error.legacyClaimOnly;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
