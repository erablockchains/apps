// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  notActive('NotActive', 0),
  alreadyActive('AlreadyActive', 1),
  wrongStorageVersion('WrongStorageVersion', 2),
  missingActiveEra('MissingActiveEra', 3),
  missingEraStart('MissingEraStart', 4),
  invalidAccountDerivation('InvalidAccountDerivation', 5),
  legacyRoutingPending('LegacyRoutingPending', 6),
  invalidActiveValidatorCount('InvalidActiveValidatorCount', 7),
  validatorBelowMinimumBond('ValidatorBelowMinimumBond', 8),
  commissionAboveMaximum('CommissionAboveMaximum', 9),
  invalidEra('InvalidEra', 10),
  eraAlreadyFinalized('EraAlreadyFinalized', 11),
  invalidDuration('InvalidDuration', 12),
  invalidRewardPoints('InvalidRewardPoints', 13),
  invalidExposure('InvalidExposure', 14),
  tooManyValidators('TooManyValidators', 15),
  tooManyRewardRecipients('TooManyRewardRecipients', 16),
  invalidPage('InvalidPage', 17),
  alreadyClaimed('AlreadyClaimed', 18),
  claimExpired('ClaimExpired', 19),
  insufficientLiability('InsufficientLiability', 20),
  insufficientStakingPot('InsufficientStakingPot', 21),
  arithmeticOverflow('ArithmeticOverflow', 22),
  invalidCarry('InvalidCarry', 23),
  allowanceNotInitialized('AllowanceNotInitialized', 24),
  issuanceFailed('IssuanceFailed', 25),
  transferFailed('TransferFailed', 26),
  treasuryTransferFailed('TreasuryTransferFailed', 27),
  authorTransferFailed('AuthorTransferFailed', 28),
  issuanceInvariantViolated('IssuanceInvariantViolated', 29),
  allowanceInvariantViolated('AllowanceInvariantViolated', 30),
  pendingRoutingInconsistent('PendingRoutingInconsistent', 31),
  legacyLiabilityMismatch('LegacyLiabilityMismatch', 32),
  rewardBudgetExceeded('RewardBudgetExceeded', 33);

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
        return Error.notActive;
      case 1:
        return Error.alreadyActive;
      case 2:
        return Error.wrongStorageVersion;
      case 3:
        return Error.missingActiveEra;
      case 4:
        return Error.missingEraStart;
      case 5:
        return Error.invalidAccountDerivation;
      case 6:
        return Error.legacyRoutingPending;
      case 7:
        return Error.invalidActiveValidatorCount;
      case 8:
        return Error.validatorBelowMinimumBond;
      case 9:
        return Error.commissionAboveMaximum;
      case 10:
        return Error.invalidEra;
      case 11:
        return Error.eraAlreadyFinalized;
      case 12:
        return Error.invalidDuration;
      case 13:
        return Error.invalidRewardPoints;
      case 14:
        return Error.invalidExposure;
      case 15:
        return Error.tooManyValidators;
      case 16:
        return Error.tooManyRewardRecipients;
      case 17:
        return Error.invalidPage;
      case 18:
        return Error.alreadyClaimed;
      case 19:
        return Error.claimExpired;
      case 20:
        return Error.insufficientLiability;
      case 21:
        return Error.insufficientStakingPot;
      case 22:
        return Error.arithmeticOverflow;
      case 23:
        return Error.invalidCarry;
      case 24:
        return Error.allowanceNotInitialized;
      case 25:
        return Error.issuanceFailed;
      case 26:
        return Error.transferFailed;
      case 27:
        return Error.treasuryTransferFailed;
      case 28:
        return Error.authorTransferFailed;
      case 29:
        return Error.issuanceInvariantViolated;
      case 30:
        return Error.allowanceInvariantViolated;
      case 31:
        return Error.pendingRoutingInconsistent;
      case 32:
        return Error.legacyLiabilityMismatch;
      case 33:
        return Error.rewardBudgetExceeded;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
