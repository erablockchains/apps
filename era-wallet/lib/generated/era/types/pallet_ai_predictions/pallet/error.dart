// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  modelNotFound('ModelNotFound', 0),
  predictionNotFound('PredictionNotFound', 1),
  notModelOwner('NotModelOwner', 2),
  invalidConfidence('InvalidConfidence', 3),
  predictionExpired('PredictionExpired', 4),
  predictionAlreadyValidated('PredictionAlreadyValidated', 5),
  predictionAlreadyClosed('PredictionAlreadyClosed', 6),
  notAuthorizedValidator('NotAuthorizedValidator', 7),
  invalidMetadata('InvalidMetadata', 8),
  invalidModelHash('InvalidModelHash', 9),
  invalidPredictionHash('InvalidPredictionHash', 10),
  invalidCategoryCode('InvalidCategoryCode', 11),
  modelInactive('ModelInactive', 12),
  overflow('Overflow', 13),
  tokenizationDisabled('TokenizationDisabled', 14),
  transfersDisabled('TransfersDisabled', 15),
  predictionAlreadyTokenized('PredictionAlreadyTokenized', 16),
  predictionTokenNotFound('PredictionTokenNotFound', 17),
  notPredictionOwner('NotPredictionOwner', 18),
  notPredictionTokenOwner('NotPredictionTokenOwner', 19),
  tokenFrozen('TokenFrozen', 20),
  tokenBurned('TokenBurned', 21),
  tokenNotTransferable('TokenNotTransferable', 22),
  transferNotApproved('TransferNotApproved', 23),
  cannotTransferToSelf('CannotTransferToSelf', 24),
  stakingDisabled('StakingDisabled', 25),
  stakeAmountZero('StakeAmountZero', 26),
  stakeBelowMinimum('StakeBelowMinimum', 27),
  stakeNotFound('StakeNotFound', 28),
  insufficientStake('InsufficientStake', 29),
  stakeLocked('StakeLocked', 30),
  settlementDisabled('SettlementDisabled', 31),
  settlementAlreadyStarted('SettlementAlreadyStarted', 32),
  settlementNotFound('SettlementNotFound', 33),
  settlementAlreadyFinalized('SettlementAlreadyFinalized', 34),
  settlementNotFinalizable('SettlementNotFinalizable', 35),
  settlementNotDisputable('SettlementNotDisputable', 36),
  disputeWindowClosed('DisputeWindowClosed', 37),
  disputeWindowStillOpen('DisputeWindowStillOpen', 38),
  disputeBondBelowMinimum('DisputeBondBelowMinimum', 39),
  invalidSettlementEvidence('InvalidSettlementEvidence', 40),
  outcomeNotProposed('OutcomeNotProposed', 41),
  cannotDisputeFinalizedSettlement('CannotDisputeFinalizedSettlement', 42),
  notAuthorizedSettlementProposer('NotAuthorizedSettlementProposer', 43),
  settlementEconomicsDisabled('SettlementEconomicsDisabled', 44),
  settlementNotFinalized('SettlementNotFinalized', 45),
  settlementAlreadyClaimed('SettlementAlreadyClaimed', 46),
  settlementClaimNotAvailable('SettlementClaimNotAvailable', 47),
  disputeNotFound('DisputeNotFound', 48),
  disputeAlreadyResolved('DisputeAlreadyResolved', 49),
  marketEconomicsDisabled('MarketEconomicsDisabled', 50),
  marketAlreadyLocked('MarketAlreadyLocked', 51),
  marketStakeAmountZero('MarketStakeAmountZero', 52),
  marketStakeNotFound('MarketStakeNotFound', 53),
  marketStakeSideMismatch('MarketStakeSideMismatch', 54),
  marketUnstakeDisabled('MarketUnstakeDisabled', 55),
  marketPayoutAlreadyClaimed('MarketPayoutAlreadyClaimed', 56),
  marketPayoutNotAvailable('MarketPayoutNotAvailable', 57),
  marketNoWinningStake('MarketNoWinningStake', 58),
  marketLosingSideCannotClaim('MarketLosingSideCannotClaim', 59),
  marketFeeBpsTooHigh('MarketFeeBpsTooHigh', 60),
  invalidMarketOutcome('InvalidMarketOutcome', 61),
  notPermitted('NotPermitted', 62),
  modelRegistrationDisabled('ModelRegistrationDisabled', 63),
  publicModelRegistrationDisabled('PublicModelRegistrationDisabled', 64),
  predictionSubmissionDisabled('PredictionSubmissionDisabled', 65),
  marketCreationDisabled('MarketCreationDisabled', 66),
  modelNotApproved('ModelNotApproved', 67),
  modelSuspended('ModelSuspended', 68),
  modelRejected('ModelRejected', 69),
  notAuthorizedModelAdmin('NotAuthorizedModelAdmin', 70),
  notAuthorizedModelSubmitter('NotAuthorizedModelSubmitter', 71),
  modelOwnerIndexFull('ModelOwnerIndexFull', 72),
  predictionModelIndexFull('PredictionModelIndexFull', 73),
  tooManyActivePredictions('TooManyActivePredictions', 74),
  predictionNotOpen('PredictionNotOpen', 75),
  reserveInvariant('ReserveInvariant', 76),
  invalidPenaltyDestination('InvalidPenaltyDestination', 77),
  invalidBondAdjudication('InvalidBondAdjudication', 78),
  financialModeDisabled('FinancialModeDisabled', 79),
  evaluationSubmissionRequired('EvaluationSubmissionRequired', 80),
  evaluationEvidenceRequired('EvaluationEvidenceRequired', 81),
  evaluationRequestConflict('EvaluationRequestConflict', 82),
  evaluationArtifactChanged('EvaluationArtifactChanged', 83),
  evaluationTooEarly('EvaluationTooEarly', 84),
  evaluationReviewerConflict('EvaluationReviewerConflict', 85),
  evaluationRevisionConflict('EvaluationRevisionConflict', 86);

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
        return Error.modelNotFound;
      case 1:
        return Error.predictionNotFound;
      case 2:
        return Error.notModelOwner;
      case 3:
        return Error.invalidConfidence;
      case 4:
        return Error.predictionExpired;
      case 5:
        return Error.predictionAlreadyValidated;
      case 6:
        return Error.predictionAlreadyClosed;
      case 7:
        return Error.notAuthorizedValidator;
      case 8:
        return Error.invalidMetadata;
      case 9:
        return Error.invalidModelHash;
      case 10:
        return Error.invalidPredictionHash;
      case 11:
        return Error.invalidCategoryCode;
      case 12:
        return Error.modelInactive;
      case 13:
        return Error.overflow;
      case 14:
        return Error.tokenizationDisabled;
      case 15:
        return Error.transfersDisabled;
      case 16:
        return Error.predictionAlreadyTokenized;
      case 17:
        return Error.predictionTokenNotFound;
      case 18:
        return Error.notPredictionOwner;
      case 19:
        return Error.notPredictionTokenOwner;
      case 20:
        return Error.tokenFrozen;
      case 21:
        return Error.tokenBurned;
      case 22:
        return Error.tokenNotTransferable;
      case 23:
        return Error.transferNotApproved;
      case 24:
        return Error.cannotTransferToSelf;
      case 25:
        return Error.stakingDisabled;
      case 26:
        return Error.stakeAmountZero;
      case 27:
        return Error.stakeBelowMinimum;
      case 28:
        return Error.stakeNotFound;
      case 29:
        return Error.insufficientStake;
      case 30:
        return Error.stakeLocked;
      case 31:
        return Error.settlementDisabled;
      case 32:
        return Error.settlementAlreadyStarted;
      case 33:
        return Error.settlementNotFound;
      case 34:
        return Error.settlementAlreadyFinalized;
      case 35:
        return Error.settlementNotFinalizable;
      case 36:
        return Error.settlementNotDisputable;
      case 37:
        return Error.disputeWindowClosed;
      case 38:
        return Error.disputeWindowStillOpen;
      case 39:
        return Error.disputeBondBelowMinimum;
      case 40:
        return Error.invalidSettlementEvidence;
      case 41:
        return Error.outcomeNotProposed;
      case 42:
        return Error.cannotDisputeFinalizedSettlement;
      case 43:
        return Error.notAuthorizedSettlementProposer;
      case 44:
        return Error.settlementEconomicsDisabled;
      case 45:
        return Error.settlementNotFinalized;
      case 46:
        return Error.settlementAlreadyClaimed;
      case 47:
        return Error.settlementClaimNotAvailable;
      case 48:
        return Error.disputeNotFound;
      case 49:
        return Error.disputeAlreadyResolved;
      case 50:
        return Error.marketEconomicsDisabled;
      case 51:
        return Error.marketAlreadyLocked;
      case 52:
        return Error.marketStakeAmountZero;
      case 53:
        return Error.marketStakeNotFound;
      case 54:
        return Error.marketStakeSideMismatch;
      case 55:
        return Error.marketUnstakeDisabled;
      case 56:
        return Error.marketPayoutAlreadyClaimed;
      case 57:
        return Error.marketPayoutNotAvailable;
      case 58:
        return Error.marketNoWinningStake;
      case 59:
        return Error.marketLosingSideCannotClaim;
      case 60:
        return Error.marketFeeBpsTooHigh;
      case 61:
        return Error.invalidMarketOutcome;
      case 62:
        return Error.notPermitted;
      case 63:
        return Error.modelRegistrationDisabled;
      case 64:
        return Error.publicModelRegistrationDisabled;
      case 65:
        return Error.predictionSubmissionDisabled;
      case 66:
        return Error.marketCreationDisabled;
      case 67:
        return Error.modelNotApproved;
      case 68:
        return Error.modelSuspended;
      case 69:
        return Error.modelRejected;
      case 70:
        return Error.notAuthorizedModelAdmin;
      case 71:
        return Error.notAuthorizedModelSubmitter;
      case 72:
        return Error.modelOwnerIndexFull;
      case 73:
        return Error.predictionModelIndexFull;
      case 74:
        return Error.tooManyActivePredictions;
      case 75:
        return Error.predictionNotOpen;
      case 76:
        return Error.reserveInvariant;
      case 77:
        return Error.invalidPenaltyDestination;
      case 78:
        return Error.invalidBondAdjudication;
      case 79:
        return Error.financialModeDisabled;
      case 80:
        return Error.evaluationSubmissionRequired;
      case 81:
        return Error.evaluationEvidenceRequired;
      case 82:
        return Error.evaluationRequestConflict;
      case 83:
        return Error.evaluationArtifactChanged;
      case 84:
        return Error.evaluationTooEarly;
      case 85:
        return Error.evaluationReviewerConflict;
      case 86:
        return Error.evaluationRevisionConflict;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
