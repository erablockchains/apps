// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i10;

import '../../sp_core/crypto/account_id32.dart' as _i3;
import '../dispute_reason.dart' as _i8;
import '../model_onboarding_settings.dart' as _i4;
import '../prediction_domain.dart' as _i5;
import '../prediction_outcome.dart' as _i6;
import '../prediction_outcome_side.dart' as _i9;
import '../settlement_outcome.dart' as _i7;

/// The `Event` enum of this pallet
abstract class Event {
  const Event();

  factory Event.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $EventCodec codec = $EventCodec();

  static const $Event values = $Event();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, dynamic>> toJson();
}

class $Event {
  const $Event();

  ModelRegistered modelRegistered({
    required BigInt modelId,
    required _i3.AccountId32 owner,
  }) {
    return ModelRegistered(modelId: modelId, owner: owner);
  }

  ModelUpdated modelUpdated({
    required BigInt modelId,
    required _i3.AccountId32 owner,
  }) {
    return ModelUpdated(modelId: modelId, owner: owner);
  }

  ModelApproved modelApproved({required BigInt modelId}) {
    return ModelApproved(modelId: modelId);
  }

  ModelSuspended modelSuspended({required BigInt modelId}) {
    return ModelSuspended(modelId: modelId);
  }

  ModelRejected modelRejected({required BigInt modelId}) {
    return ModelRejected(modelId: modelId);
  }

  ModelSubmitterUpdated modelSubmitterUpdated({
    required BigInt modelId,
    _i3.AccountId32? submitter,
  }) {
    return ModelSubmitterUpdated(modelId: modelId, submitter: submitter);
  }

  ModelOnboardingConfigUpdated modelOnboardingConfigUpdated({
    required _i4.ModelOnboardingSettings config,
  }) {
    return ModelOnboardingConfigUpdated(config: config);
  }

  PredictionOpened predictionOpened({
    required BigInt predictionId,
    required BigInt modelId,
  }) {
    return PredictionOpened(predictionId: predictionId, modelId: modelId);
  }

  PredictionSubmitted predictionSubmitted({
    required BigInt predictionId,
    required BigInt modelId,
    required _i3.AccountId32 submitter,
    required _i5.PredictionDomain domain,
  }) {
    return PredictionSubmitted(
      predictionId: predictionId,
      modelId: modelId,
      submitter: submitter,
      domain: domain,
    );
  }

  PredictionValidated predictionValidated({
    required BigInt predictionId,
    required BigInt modelId,
    required _i3.AccountId32 validator,
    required _i6.PredictionOutcome outcome,
  }) {
    return PredictionValidated(
      predictionId: predictionId,
      modelId: modelId,
      validator: validator,
      outcome: outcome,
    );
  }

  PredictionClosed predictionClosed({required BigInt predictionId}) {
    return PredictionClosed(predictionId: predictionId);
  }

  TokenizationConfigUpdated tokenizationConfigUpdated({
    required bool tokenizationEnabled,
    required bool transfersEnabled,
  }) {
    return TokenizationConfigUpdated(
      tokenizationEnabled: tokenizationEnabled,
      transfersEnabled: transfersEnabled,
    );
  }

  PredictionTokenized predictionTokenized({
    required BigInt predictionId,
    required BigInt tokenId,
    required _i3.AccountId32 owner,
  }) {
    return PredictionTokenized(
      predictionId: predictionId,
      tokenId: tokenId,
      owner: owner,
    );
  }

  PredictionTokenTransferred predictionTokenTransferred({
    required BigInt tokenId,
    required _i3.AccountId32 from,
    required _i3.AccountId32 to,
  }) {
    return PredictionTokenTransferred(tokenId: tokenId, from: from, to: to);
  }

  PredictionTokenTransferApproved predictionTokenTransferApproved({
    required BigInt tokenId,
    required _i3.AccountId32 owner,
    required _i3.AccountId32 approved,
  }) {
    return PredictionTokenTransferApproved(
      tokenId: tokenId,
      owner: owner,
      approved: approved,
    );
  }

  PredictionTokenApprovalRevoked predictionTokenApprovalRevoked({
    required BigInt tokenId,
    required _i3.AccountId32 owner,
  }) {
    return PredictionTokenApprovalRevoked(tokenId: tokenId, owner: owner);
  }

  PredictionTokenFrozen predictionTokenFrozen({required BigInt tokenId}) {
    return PredictionTokenFrozen(tokenId: tokenId);
  }

  PredictionTokenUnfrozen predictionTokenUnfrozen({required BigInt tokenId}) {
    return PredictionTokenUnfrozen(tokenId: tokenId);
  }

  PredictionTokenBurned predictionTokenBurned({required BigInt tokenId}) {
    return PredictionTokenBurned(tokenId: tokenId);
  }

  PredictionTokenMetadataUpdated predictionTokenMetadataUpdated({
    required BigInt tokenId,
    required _i3.AccountId32 owner,
  }) {
    return PredictionTokenMetadataUpdated(tokenId: tokenId, owner: owner);
  }

  StakingConfigUpdated stakingConfigUpdated({
    required bool stakingEnabled,
    required BigInt minStake,
  }) {
    return StakingConfigUpdated(
      stakingEnabled: stakingEnabled,
      minStake: minStake,
    );
  }

  PredictionTokenStakeAdded predictionTokenStakeAdded({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required BigInt amount,
    required BigInt totalStake,
  }) {
    return PredictionTokenStakeAdded(
      tokenId: tokenId,
      staker: staker,
      amount: amount,
      totalStake: totalStake,
    );
  }

  PredictionTokenStakeRemoved predictionTokenStakeRemoved({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required BigInt amount,
    required BigInt remainingStake,
  }) {
    return PredictionTokenStakeRemoved(
      tokenId: tokenId,
      staker: staker,
      amount: amount,
      remainingStake: remainingStake,
    );
  }

  PredictionTokenStakeLocked predictionTokenStakeLocked({
    required BigInt tokenId,
  }) {
    return PredictionTokenStakeLocked(tokenId: tokenId);
  }

  PredictionTokenStakeReleased predictionTokenStakeReleased({
    required BigInt tokenId,
  }) {
    return PredictionTokenStakeReleased(tokenId: tokenId);
  }

  SettlementConfigUpdated settlementConfigUpdated({
    required bool settlementEnabled,
    required int disputeWindowBlocks,
    required BigInt minDisputeBond,
  }) {
    return SettlementConfigUpdated(
      settlementEnabled: settlementEnabled,
      disputeWindowBlocks: disputeWindowBlocks,
      minDisputeBond: minDisputeBond,
    );
  }

  PredictionOutcomeProposed predictionOutcomeProposed({
    required BigInt tokenId,
    required _i7.SettlementOutcome proposedOutcome,
    _i3.AccountId32? proposedBy,
    required int disputeUntil,
  }) {
    return PredictionOutcomeProposed(
      tokenId: tokenId,
      proposedOutcome: proposedOutcome,
      proposedBy: proposedBy,
      disputeUntil: disputeUntil,
    );
  }

  PredictionOutcomeDisputed predictionOutcomeDisputed({
    required BigInt tokenId,
    required BigInt disputeId,
    required _i3.AccountId32 disputedBy,
    required _i8.DisputeReason reason,
    required BigInt bond,
  }) {
    return PredictionOutcomeDisputed(
      tokenId: tokenId,
      disputeId: disputeId,
      disputedBy: disputedBy,
      reason: reason,
      bond: bond,
    );
  }

  PredictionOutcomeFinalized predictionOutcomeFinalized({
    required BigInt tokenId,
    required _i7.SettlementOutcome finalOutcome,
    _i3.AccountId32? finalizedBy,
  }) {
    return PredictionOutcomeFinalized(
      tokenId: tokenId,
      finalOutcome: finalOutcome,
      finalizedBy: finalizedBy,
    );
  }

  PredictionSettlementCancelled predictionSettlementCancelled({
    required BigInt tokenId,
  }) {
    return PredictionSettlementCancelled(tokenId: tokenId);
  }

  ValidatorAuthorized validatorAuthorized({required _i3.AccountId32 account}) {
    return ValidatorAuthorized(account: account);
  }

  ValidatorRemoved validatorRemoved({required _i3.AccountId32 account}) {
    return ValidatorRemoved(account: account);
  }

  SettlementEconomicsConfigUpdated settlementEconomicsConfigUpdated({
    required bool economicsEnabled,
    required bool slashIncorrect,
    required bool slashFraudulent,
  }) {
    return SettlementEconomicsConfigUpdated(
      economicsEnabled: economicsEnabled,
      slashIncorrect: slashIncorrect,
      slashFraudulent: slashFraudulent,
    );
  }

  PredictionTokenSettlementClaimed predictionTokenSettlementClaimed({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required BigInt refunded,
    required BigInt slashed,
  }) {
    return PredictionTokenSettlementClaimed(
      tokenId: tokenId,
      staker: staker,
      refunded: refunded,
      slashed: slashed,
    );
  }

  PredictionDisputeBondResolved predictionDisputeBondResolved({
    required BigInt disputeId,
    required BigInt tokenId,
    required _i3.AccountId32 disputedBy,
    required bool accepted,
    required BigInt bond,
  }) {
    return PredictionDisputeBondResolved(
      disputeId: disputeId,
      tokenId: tokenId,
      disputedBy: disputedBy,
      accepted: accepted,
      bond: bond,
    );
  }

  PredictionMarketEconomicsConfigUpdated
  predictionMarketEconomicsConfigUpdated({
    required bool marketEnabled,
    required bool allowUnstakeBeforeSettlement,
  }) {
    return PredictionMarketEconomicsConfigUpdated(
      marketEnabled: marketEnabled,
      allowUnstakeBeforeSettlement: allowUnstakeBeforeSettlement,
    );
  }

  PredictionOutcomeSideStaked predictionOutcomeSideStaked({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required _i9.PredictionOutcomeSide side,
    required BigInt amount,
    required BigInt totalForSide,
  }) {
    return PredictionOutcomeSideStaked(
      tokenId: tokenId,
      staker: staker,
      side: side,
      amount: amount,
      totalForSide: totalForSide,
    );
  }

  PredictionOutcomeSideUnstaked predictionOutcomeSideUnstaked({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required _i9.PredictionOutcomeSide side,
    required BigInt amount,
    required BigInt remainingStake,
  }) {
    return PredictionOutcomeSideUnstaked(
      tokenId: tokenId,
      staker: staker,
      side: side,
      amount: amount,
      remainingStake: remainingStake,
    );
  }

  PredictionTokenMarketLocked predictionTokenMarketLocked({
    required BigInt tokenId,
  }) {
    return PredictionTokenMarketLocked(tokenId: tokenId);
  }

  PredictionMarketPayoutClaimed predictionMarketPayoutClaimed({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required _i9.PredictionOutcomeSide side,
    required BigInt stakeReturned,
    required BigInt rewardPaid,
    required BigInt slashed,
  }) {
    return PredictionMarketPayoutClaimed(
      tokenId: tokenId,
      staker: staker,
      side: side,
      stakeReturned: stakeReturned,
      rewardPaid: rewardPaid,
      slashed: slashed,
    );
  }

  PredictionMarketFeeConfigUpdated predictionMarketFeeConfigUpdated({
    required bool feesEnabled,
    required int feeBps,
    required bool treasuryEnabled,
  }) {
    return PredictionMarketFeeConfigUpdated(
      feesEnabled: feesEnabled,
      feeBps: feeBps,
      treasuryEnabled: treasuryEnabled,
    );
  }

  PredictionMarketAccountingUpdated predictionMarketAccountingUpdated({
    required BigInt tokenId,
    required BigInt feesCollected,
    required BigInt remaindersCollected,
    required BigInt totalPaid,
    required BigInt totalRefunded,
    required BigInt totalSlashed,
  }) {
    return PredictionMarketAccountingUpdated(
      tokenId: tokenId,
      feesCollected: feesCollected,
      remaindersCollected: remaindersCollected,
      totalPaid: totalPaid,
      totalRefunded: totalRefunded,
      totalSlashed: totalSlashed,
    );
  }

  ReservedPenaltyTransferred reservedPenaltyTransferred({
    required _i3.AccountId32 payer,
    required _i3.AccountId32 destination,
    required BigInt amount,
    required int source,
    required BigInt reference,
  }) {
    return ReservedPenaltyTransferred(
      payer: payer,
      destination: destination,
      amount: amount,
      source: source,
      reference: reference,
    );
  }

  DisputeBondAdjudicated disputeBondAdjudicated({
    required BigInt disputeId,
    required bool accepted,
    required bool fraudulent,
    required List<int> evidenceHash,
  }) {
    return DisputeBondAdjudicated(
      disputeId: disputeId,
      accepted: accepted,
      fraudulent: fraudulent,
      evidenceHash: evidenceHash,
    );
  }

  PredictionMarketNoWinnerRefund predictionMarketNoWinnerRefund({
    required BigInt tokenId,
    required _i3.AccountId32 staker,
    required BigInt amount,
  }) {
    return PredictionMarketNoWinnerRefund(
      tokenId: tokenId,
      staker: staker,
      amount: amount,
    );
  }

  EvaluationRecorded evaluationRecorded({
    required BigInt predictionId,
    required List<int> requestId,
    required List<int> artifact,
  }) {
    return EvaluationRecorded(
      predictionId: predictionId,
      requestId: requestId,
      artifact: artifact,
    );
  }

  EvaluationEvidenceRecorded evaluationEvidenceRecorded({
    required BigInt predictionId,
    required int revision,
    required List<int> evidence,
    required _i6.PredictionOutcome outcome,
  }) {
    return EvaluationEvidenceRecorded(
      predictionId: predictionId,
      revision: revision,
      evidence: evidence,
      outcome: outcome,
    );
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ModelRegistered._decode(input);
      case 1:
        return ModelUpdated._decode(input);
      case 2:
        return ModelApproved._decode(input);
      case 3:
        return ModelSuspended._decode(input);
      case 4:
        return ModelRejected._decode(input);
      case 5:
        return ModelSubmitterUpdated._decode(input);
      case 6:
        return ModelOnboardingConfigUpdated._decode(input);
      case 7:
        return PredictionOpened._decode(input);
      case 8:
        return PredictionSubmitted._decode(input);
      case 9:
        return PredictionValidated._decode(input);
      case 10:
        return PredictionClosed._decode(input);
      case 11:
        return TokenizationConfigUpdated._decode(input);
      case 12:
        return PredictionTokenized._decode(input);
      case 13:
        return PredictionTokenTransferred._decode(input);
      case 14:
        return PredictionTokenTransferApproved._decode(input);
      case 15:
        return PredictionTokenApprovalRevoked._decode(input);
      case 16:
        return PredictionTokenFrozen._decode(input);
      case 17:
        return PredictionTokenUnfrozen._decode(input);
      case 18:
        return PredictionTokenBurned._decode(input);
      case 19:
        return PredictionTokenMetadataUpdated._decode(input);
      case 20:
        return StakingConfigUpdated._decode(input);
      case 21:
        return PredictionTokenStakeAdded._decode(input);
      case 22:
        return PredictionTokenStakeRemoved._decode(input);
      case 23:
        return PredictionTokenStakeLocked._decode(input);
      case 24:
        return PredictionTokenStakeReleased._decode(input);
      case 25:
        return SettlementConfigUpdated._decode(input);
      case 26:
        return PredictionOutcomeProposed._decode(input);
      case 27:
        return PredictionOutcomeDisputed._decode(input);
      case 28:
        return PredictionOutcomeFinalized._decode(input);
      case 29:
        return PredictionSettlementCancelled._decode(input);
      case 30:
        return ValidatorAuthorized._decode(input);
      case 31:
        return ValidatorRemoved._decode(input);
      case 32:
        return SettlementEconomicsConfigUpdated._decode(input);
      case 33:
        return PredictionTokenSettlementClaimed._decode(input);
      case 34:
        return PredictionDisputeBondResolved._decode(input);
      case 35:
        return PredictionMarketEconomicsConfigUpdated._decode(input);
      case 36:
        return PredictionOutcomeSideStaked._decode(input);
      case 37:
        return PredictionOutcomeSideUnstaked._decode(input);
      case 38:
        return PredictionTokenMarketLocked._decode(input);
      case 39:
        return PredictionMarketPayoutClaimed._decode(input);
      case 40:
        return PredictionMarketFeeConfigUpdated._decode(input);
      case 41:
        return PredictionMarketAccountingUpdated._decode(input);
      case 42:
        return ReservedPenaltyTransferred._decode(input);
      case 43:
        return DisputeBondAdjudicated._decode(input);
      case 44:
        return PredictionMarketNoWinnerRefund._decode(input);
      case 45:
        return EvaluationRecorded._decode(input);
      case 46:
        return EvaluationEvidenceRecorded._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case ModelRegistered:
        (value as ModelRegistered).encodeTo(output);
        break;
      case ModelUpdated:
        (value as ModelUpdated).encodeTo(output);
        break;
      case ModelApproved:
        (value as ModelApproved).encodeTo(output);
        break;
      case ModelSuspended:
        (value as ModelSuspended).encodeTo(output);
        break;
      case ModelRejected:
        (value as ModelRejected).encodeTo(output);
        break;
      case ModelSubmitterUpdated:
        (value as ModelSubmitterUpdated).encodeTo(output);
        break;
      case ModelOnboardingConfigUpdated:
        (value as ModelOnboardingConfigUpdated).encodeTo(output);
        break;
      case PredictionOpened:
        (value as PredictionOpened).encodeTo(output);
        break;
      case PredictionSubmitted:
        (value as PredictionSubmitted).encodeTo(output);
        break;
      case PredictionValidated:
        (value as PredictionValidated).encodeTo(output);
        break;
      case PredictionClosed:
        (value as PredictionClosed).encodeTo(output);
        break;
      case TokenizationConfigUpdated:
        (value as TokenizationConfigUpdated).encodeTo(output);
        break;
      case PredictionTokenized:
        (value as PredictionTokenized).encodeTo(output);
        break;
      case PredictionTokenTransferred:
        (value as PredictionTokenTransferred).encodeTo(output);
        break;
      case PredictionTokenTransferApproved:
        (value as PredictionTokenTransferApproved).encodeTo(output);
        break;
      case PredictionTokenApprovalRevoked:
        (value as PredictionTokenApprovalRevoked).encodeTo(output);
        break;
      case PredictionTokenFrozen:
        (value as PredictionTokenFrozen).encodeTo(output);
        break;
      case PredictionTokenUnfrozen:
        (value as PredictionTokenUnfrozen).encodeTo(output);
        break;
      case PredictionTokenBurned:
        (value as PredictionTokenBurned).encodeTo(output);
        break;
      case PredictionTokenMetadataUpdated:
        (value as PredictionTokenMetadataUpdated).encodeTo(output);
        break;
      case StakingConfigUpdated:
        (value as StakingConfigUpdated).encodeTo(output);
        break;
      case PredictionTokenStakeAdded:
        (value as PredictionTokenStakeAdded).encodeTo(output);
        break;
      case PredictionTokenStakeRemoved:
        (value as PredictionTokenStakeRemoved).encodeTo(output);
        break;
      case PredictionTokenStakeLocked:
        (value as PredictionTokenStakeLocked).encodeTo(output);
        break;
      case PredictionTokenStakeReleased:
        (value as PredictionTokenStakeReleased).encodeTo(output);
        break;
      case SettlementConfigUpdated:
        (value as SettlementConfigUpdated).encodeTo(output);
        break;
      case PredictionOutcomeProposed:
        (value as PredictionOutcomeProposed).encodeTo(output);
        break;
      case PredictionOutcomeDisputed:
        (value as PredictionOutcomeDisputed).encodeTo(output);
        break;
      case PredictionOutcomeFinalized:
        (value as PredictionOutcomeFinalized).encodeTo(output);
        break;
      case PredictionSettlementCancelled:
        (value as PredictionSettlementCancelled).encodeTo(output);
        break;
      case ValidatorAuthorized:
        (value as ValidatorAuthorized).encodeTo(output);
        break;
      case ValidatorRemoved:
        (value as ValidatorRemoved).encodeTo(output);
        break;
      case SettlementEconomicsConfigUpdated:
        (value as SettlementEconomicsConfigUpdated).encodeTo(output);
        break;
      case PredictionTokenSettlementClaimed:
        (value as PredictionTokenSettlementClaimed).encodeTo(output);
        break;
      case PredictionDisputeBondResolved:
        (value as PredictionDisputeBondResolved).encodeTo(output);
        break;
      case PredictionMarketEconomicsConfigUpdated:
        (value as PredictionMarketEconomicsConfigUpdated).encodeTo(output);
        break;
      case PredictionOutcomeSideStaked:
        (value as PredictionOutcomeSideStaked).encodeTo(output);
        break;
      case PredictionOutcomeSideUnstaked:
        (value as PredictionOutcomeSideUnstaked).encodeTo(output);
        break;
      case PredictionTokenMarketLocked:
        (value as PredictionTokenMarketLocked).encodeTo(output);
        break;
      case PredictionMarketPayoutClaimed:
        (value as PredictionMarketPayoutClaimed).encodeTo(output);
        break;
      case PredictionMarketFeeConfigUpdated:
        (value as PredictionMarketFeeConfigUpdated).encodeTo(output);
        break;
      case PredictionMarketAccountingUpdated:
        (value as PredictionMarketAccountingUpdated).encodeTo(output);
        break;
      case ReservedPenaltyTransferred:
        (value as ReservedPenaltyTransferred).encodeTo(output);
        break;
      case DisputeBondAdjudicated:
        (value as DisputeBondAdjudicated).encodeTo(output);
        break;
      case PredictionMarketNoWinnerRefund:
        (value as PredictionMarketNoWinnerRefund).encodeTo(output);
        break;
      case EvaluationRecorded:
        (value as EvaluationRecorded).encodeTo(output);
        break;
      case EvaluationEvidenceRecorded:
        (value as EvaluationEvidenceRecorded).encodeTo(output);
        break;
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Event value) {
    switch (value.runtimeType) {
      case ModelRegistered:
        return (value as ModelRegistered)._sizeHint();
      case ModelUpdated:
        return (value as ModelUpdated)._sizeHint();
      case ModelApproved:
        return (value as ModelApproved)._sizeHint();
      case ModelSuspended:
        return (value as ModelSuspended)._sizeHint();
      case ModelRejected:
        return (value as ModelRejected)._sizeHint();
      case ModelSubmitterUpdated:
        return (value as ModelSubmitterUpdated)._sizeHint();
      case ModelOnboardingConfigUpdated:
        return (value as ModelOnboardingConfigUpdated)._sizeHint();
      case PredictionOpened:
        return (value as PredictionOpened)._sizeHint();
      case PredictionSubmitted:
        return (value as PredictionSubmitted)._sizeHint();
      case PredictionValidated:
        return (value as PredictionValidated)._sizeHint();
      case PredictionClosed:
        return (value as PredictionClosed)._sizeHint();
      case TokenizationConfigUpdated:
        return (value as TokenizationConfigUpdated)._sizeHint();
      case PredictionTokenized:
        return (value as PredictionTokenized)._sizeHint();
      case PredictionTokenTransferred:
        return (value as PredictionTokenTransferred)._sizeHint();
      case PredictionTokenTransferApproved:
        return (value as PredictionTokenTransferApproved)._sizeHint();
      case PredictionTokenApprovalRevoked:
        return (value as PredictionTokenApprovalRevoked)._sizeHint();
      case PredictionTokenFrozen:
        return (value as PredictionTokenFrozen)._sizeHint();
      case PredictionTokenUnfrozen:
        return (value as PredictionTokenUnfrozen)._sizeHint();
      case PredictionTokenBurned:
        return (value as PredictionTokenBurned)._sizeHint();
      case PredictionTokenMetadataUpdated:
        return (value as PredictionTokenMetadataUpdated)._sizeHint();
      case StakingConfigUpdated:
        return (value as StakingConfigUpdated)._sizeHint();
      case PredictionTokenStakeAdded:
        return (value as PredictionTokenStakeAdded)._sizeHint();
      case PredictionTokenStakeRemoved:
        return (value as PredictionTokenStakeRemoved)._sizeHint();
      case PredictionTokenStakeLocked:
        return (value as PredictionTokenStakeLocked)._sizeHint();
      case PredictionTokenStakeReleased:
        return (value as PredictionTokenStakeReleased)._sizeHint();
      case SettlementConfigUpdated:
        return (value as SettlementConfigUpdated)._sizeHint();
      case PredictionOutcomeProposed:
        return (value as PredictionOutcomeProposed)._sizeHint();
      case PredictionOutcomeDisputed:
        return (value as PredictionOutcomeDisputed)._sizeHint();
      case PredictionOutcomeFinalized:
        return (value as PredictionOutcomeFinalized)._sizeHint();
      case PredictionSettlementCancelled:
        return (value as PredictionSettlementCancelled)._sizeHint();
      case ValidatorAuthorized:
        return (value as ValidatorAuthorized)._sizeHint();
      case ValidatorRemoved:
        return (value as ValidatorRemoved)._sizeHint();
      case SettlementEconomicsConfigUpdated:
        return (value as SettlementEconomicsConfigUpdated)._sizeHint();
      case PredictionTokenSettlementClaimed:
        return (value as PredictionTokenSettlementClaimed)._sizeHint();
      case PredictionDisputeBondResolved:
        return (value as PredictionDisputeBondResolved)._sizeHint();
      case PredictionMarketEconomicsConfigUpdated:
        return (value as PredictionMarketEconomicsConfigUpdated)._sizeHint();
      case PredictionOutcomeSideStaked:
        return (value as PredictionOutcomeSideStaked)._sizeHint();
      case PredictionOutcomeSideUnstaked:
        return (value as PredictionOutcomeSideUnstaked)._sizeHint();
      case PredictionTokenMarketLocked:
        return (value as PredictionTokenMarketLocked)._sizeHint();
      case PredictionMarketPayoutClaimed:
        return (value as PredictionMarketPayoutClaimed)._sizeHint();
      case PredictionMarketFeeConfigUpdated:
        return (value as PredictionMarketFeeConfigUpdated)._sizeHint();
      case PredictionMarketAccountingUpdated:
        return (value as PredictionMarketAccountingUpdated)._sizeHint();
      case ReservedPenaltyTransferred:
        return (value as ReservedPenaltyTransferred)._sizeHint();
      case DisputeBondAdjudicated:
        return (value as DisputeBondAdjudicated)._sizeHint();
      case PredictionMarketNoWinnerRefund:
        return (value as PredictionMarketNoWinnerRefund)._sizeHint();
      case EvaluationRecorded:
        return (value as EvaluationRecorded)._sizeHint();
      case EvaluationEvidenceRecorded:
        return (value as EvaluationEvidenceRecorded)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class ModelRegistered extends Event {
  const ModelRegistered({required this.modelId, required this.owner});

  factory ModelRegistered._decode(_i1.Input input) {
    return ModelRegistered(
      modelId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ModelRegistered': {'modelId': modelId, 'owner': owner.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelRegistered &&
          other.modelId == modelId &&
          _i10.listsEqual(other.owner, owner);

  @override
  int get hashCode => Object.hash(modelId, owner);
}

class ModelUpdated extends Event {
  const ModelUpdated({required this.modelId, required this.owner});

  factory ModelUpdated._decode(_i1.Input input) {
    return ModelUpdated(
      modelId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ModelUpdated': {'modelId': modelId, 'owner': owner.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelUpdated &&
          other.modelId == modelId &&
          _i10.listsEqual(other.owner, owner);

  @override
  int get hashCode => Object.hash(modelId, owner);
}

class ModelApproved extends Event {
  const ModelApproved({required this.modelId});

  factory ModelApproved._decode(_i1.Input input) {
    return ModelApproved(modelId: _i1.U64Codec.codec.decode(input));
  }

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'ModelApproved': {'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelApproved && other.modelId == modelId;

  @override
  int get hashCode => modelId.hashCode;
}

class ModelSuspended extends Event {
  const ModelSuspended({required this.modelId});

  factory ModelSuspended._decode(_i1.Input input) {
    return ModelSuspended(modelId: _i1.U64Codec.codec.decode(input));
  }

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'ModelSuspended': {'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSuspended && other.modelId == modelId;

  @override
  int get hashCode => modelId.hashCode;
}

class ModelRejected extends Event {
  const ModelRejected({required this.modelId});

  factory ModelRejected._decode(_i1.Input input) {
    return ModelRejected(modelId: _i1.U64Codec.codec.decode(input));
  }

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'ModelRejected': {'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelRejected && other.modelId == modelId;

  @override
  int get hashCode => modelId.hashCode;
}

class ModelSubmitterUpdated extends Event {
  const ModelSubmitterUpdated({required this.modelId, this.submitter});

  factory ModelSubmitterUpdated._decode(_i1.Input input) {
    return ModelSubmitterUpdated(
      modelId: _i1.U64Codec.codec.decode(input),
      submitter: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// Option<T::AccountId>
  final _i3.AccountId32? submitter;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ModelSubmitterUpdated': {
      'modelId': modelId,
      'submitter': submitter?.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(submitter);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(submitter, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSubmitterUpdated &&
          other.modelId == modelId &&
          other.submitter == submitter;

  @override
  int get hashCode => Object.hash(modelId, submitter);
}

class ModelOnboardingConfigUpdated extends Event {
  const ModelOnboardingConfigUpdated({required this.config});

  factory ModelOnboardingConfigUpdated._decode(_i1.Input input) {
    return ModelOnboardingConfigUpdated(
      config: _i4.ModelOnboardingSettings.codec.decode(input),
    );
  }

  /// ModelOnboardingSettings
  final _i4.ModelOnboardingSettings config;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'ModelOnboardingConfigUpdated': {'config': config.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i4.ModelOnboardingSettings.codec.sizeHint(config);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    _i4.ModelOnboardingSettings.codec.encodeTo(config, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelOnboardingConfigUpdated && other.config == config;

  @override
  int get hashCode => config.hashCode;
}

class PredictionOpened extends Event {
  const PredictionOpened({required this.predictionId, required this.modelId});

  factory PredictionOpened._decode(_i1.Input input) {
    return PredictionOpened(
      predictionId: _i1.U64Codec.codec.decode(input),
      modelId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionOpened': {'predictionId': predictionId, 'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(7, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionOpened &&
          other.predictionId == predictionId &&
          other.modelId == modelId;

  @override
  int get hashCode => Object.hash(predictionId, modelId);
}

class PredictionSubmitted extends Event {
  const PredictionSubmitted({
    required this.predictionId,
    required this.modelId,
    required this.submitter,
    required this.domain,
  });

  factory PredictionSubmitted._decode(_i1.Input input) {
    return PredictionSubmitted(
      predictionId: _i1.U64Codec.codec.decode(input),
      modelId: _i1.U64Codec.codec.decode(input),
      submitter: const _i1.U8ArrayCodec(32).decode(input),
      domain: _i5.PredictionDomain.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// ModelId
  final BigInt modelId;

  /// T::AccountId
  final _i3.AccountId32 submitter;

  /// PredictionDomain
  final _i5.PredictionDomain domain;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionSubmitted': {
      'predictionId': predictionId,
      'modelId': modelId,
      'submitter': submitter.toList(),
      'domain': domain.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + const _i3.AccountId32Codec().sizeHint(submitter);
    size = size + _i5.PredictionDomain.codec.sizeHint(domain);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(8, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.U8ArrayCodec(32).encodeTo(submitter, output);
    _i5.PredictionDomain.codec.encodeTo(domain, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionSubmitted &&
          other.predictionId == predictionId &&
          other.modelId == modelId &&
          _i10.listsEqual(other.submitter, submitter) &&
          other.domain == domain;

  @override
  int get hashCode => Object.hash(predictionId, modelId, submitter, domain);
}

class PredictionValidated extends Event {
  const PredictionValidated({
    required this.predictionId,
    required this.modelId,
    required this.validator,
    required this.outcome,
  });

  factory PredictionValidated._decode(_i1.Input input) {
    return PredictionValidated(
      predictionId: _i1.U64Codec.codec.decode(input),
      modelId: _i1.U64Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      outcome: _i6.PredictionOutcome.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// ModelId
  final BigInt modelId;

  /// T::AccountId
  final _i3.AccountId32 validator;

  /// PredictionOutcome
  final _i6.PredictionOutcome outcome;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionValidated': {
      'predictionId': predictionId,
      'modelId': modelId,
      'validator': validator.toList(),
      'outcome': outcome.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + const _i3.AccountId32Codec().sizeHint(validator);
    size = size + _i6.PredictionOutcome.codec.sizeHint(outcome);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(9, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    _i6.PredictionOutcome.codec.encodeTo(outcome, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionValidated &&
          other.predictionId == predictionId &&
          other.modelId == modelId &&
          _i10.listsEqual(other.validator, validator) &&
          other.outcome == outcome;

  @override
  int get hashCode => Object.hash(predictionId, modelId, validator, outcome);
}

class PredictionClosed extends Event {
  const PredictionClosed({required this.predictionId});

  factory PredictionClosed._decode(_i1.Input input) {
    return PredictionClosed(predictionId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionId
  final BigInt predictionId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionClosed': {'predictionId': predictionId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionClosed && other.predictionId == predictionId;

  @override
  int get hashCode => predictionId.hashCode;
}

class TokenizationConfigUpdated extends Event {
  const TokenizationConfigUpdated({
    required this.tokenizationEnabled,
    required this.transfersEnabled,
  });

  factory TokenizationConfigUpdated._decode(_i1.Input input) {
    return TokenizationConfigUpdated(
      tokenizationEnabled: _i1.BoolCodec.codec.decode(input),
      transfersEnabled: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// bool
  final bool tokenizationEnabled;

  /// bool
  final bool transfersEnabled;

  @override
  Map<String, Map<String, bool>> toJson() => {
    'TokenizationConfigUpdated': {
      'tokenizationEnabled': tokenizationEnabled,
      'transfersEnabled': transfersEnabled,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.BoolCodec.codec.sizeHint(tokenizationEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(transfersEnabled);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
    _i1.BoolCodec.codec.encodeTo(tokenizationEnabled, output);
    _i1.BoolCodec.codec.encodeTo(transfersEnabled, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenizationConfigUpdated &&
          other.tokenizationEnabled == tokenizationEnabled &&
          other.transfersEnabled == transfersEnabled;

  @override
  int get hashCode => Object.hash(tokenizationEnabled, transfersEnabled);
}

class PredictionTokenized extends Event {
  const PredictionTokenized({
    required this.predictionId,
    required this.tokenId,
    required this.owner,
  });

  factory PredictionTokenized._decode(_i1.Input input) {
    return PredictionTokenized(
      predictionId: _i1.U64Codec.codec.decode(input),
      tokenId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenized': {
      'predictionId': predictionId,
      'tokenId': tokenId,
      'owner': owner.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(12, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenized &&
          other.predictionId == predictionId &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.owner, owner);

  @override
  int get hashCode => Object.hash(predictionId, tokenId, owner);
}

class PredictionTokenTransferred extends Event {
  const PredictionTokenTransferred({
    required this.tokenId,
    required this.from,
    required this.to,
  });

  factory PredictionTokenTransferred._decode(_i1.Input input) {
    return PredictionTokenTransferred(
      tokenId: _i1.U64Codec.codec.decode(input),
      from: const _i1.U8ArrayCodec(32).decode(input),
      to: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 from;

  /// T::AccountId
  final _i3.AccountId32 to;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenTransferred': {
      'tokenId': tokenId,
      'from': from.toList(),
      'to': to.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(from);
    size = size + const _i3.AccountId32Codec().sizeHint(to);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(13, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(from, output);
    const _i1.U8ArrayCodec(32).encodeTo(to, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenTransferred &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.from, from) &&
          _i10.listsEqual(other.to, to);

  @override
  int get hashCode => Object.hash(tokenId, from, to);
}

class PredictionTokenTransferApproved extends Event {
  const PredictionTokenTransferApproved({
    required this.tokenId,
    required this.owner,
    required this.approved,
  });

  factory PredictionTokenTransferApproved._decode(_i1.Input input) {
    return PredictionTokenTransferApproved(
      tokenId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
      approved: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  /// T::AccountId
  final _i3.AccountId32 approved;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenTransferApproved': {
      'tokenId': tokenId,
      'owner': owner.toList(),
      'approved': approved.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    size = size + const _i3.AccountId32Codec().sizeHint(approved);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(14, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
    const _i1.U8ArrayCodec(32).encodeTo(approved, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenTransferApproved &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.owner, owner) &&
          _i10.listsEqual(other.approved, approved);

  @override
  int get hashCode => Object.hash(tokenId, owner, approved);
}

class PredictionTokenApprovalRevoked extends Event {
  const PredictionTokenApprovalRevoked({
    required this.tokenId,
    required this.owner,
  });

  factory PredictionTokenApprovalRevoked._decode(_i1.Input input) {
    return PredictionTokenApprovalRevoked(
      tokenId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenApprovalRevoked': {
      'tokenId': tokenId,
      'owner': owner.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(15, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenApprovalRevoked &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.owner, owner);

  @override
  int get hashCode => Object.hash(tokenId, owner);
}

class PredictionTokenFrozen extends Event {
  const PredictionTokenFrozen({required this.tokenId});

  factory PredictionTokenFrozen._decode(_i1.Input input) {
    return PredictionTokenFrozen(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionTokenFrozen': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(16, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenFrozen && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class PredictionTokenUnfrozen extends Event {
  const PredictionTokenUnfrozen({required this.tokenId});

  factory PredictionTokenUnfrozen._decode(_i1.Input input) {
    return PredictionTokenUnfrozen(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionTokenUnfrozen': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(17, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenUnfrozen && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class PredictionTokenBurned extends Event {
  const PredictionTokenBurned({required this.tokenId});

  factory PredictionTokenBurned._decode(_i1.Input input) {
    return PredictionTokenBurned(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionTokenBurned': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(18, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenBurned && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class PredictionTokenMetadataUpdated extends Event {
  const PredictionTokenMetadataUpdated({
    required this.tokenId,
    required this.owner,
  });

  factory PredictionTokenMetadataUpdated._decode(_i1.Input input) {
    return PredictionTokenMetadataUpdated(
      tokenId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenMetadataUpdated': {
      'tokenId': tokenId,
      'owner': owner.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(19, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenMetadataUpdated &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.owner, owner);

  @override
  int get hashCode => Object.hash(tokenId, owner);
}

class StakingConfigUpdated extends Event {
  const StakingConfigUpdated({
    required this.stakingEnabled,
    required this.minStake,
  });

  factory StakingConfigUpdated._decode(_i1.Input input) {
    return StakingConfigUpdated(
      stakingEnabled: _i1.BoolCodec.codec.decode(input),
      minStake: _i1.U128Codec.codec.decode(input),
    );
  }

  /// bool
  final bool stakingEnabled;

  /// BalanceOf<T>
  final BigInt minStake;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'StakingConfigUpdated': {
      'stakingEnabled': stakingEnabled,
      'minStake': minStake,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.BoolCodec.codec.sizeHint(stakingEnabled);
    size = size + _i1.U128Codec.codec.sizeHint(minStake);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(20, output);
    _i1.BoolCodec.codec.encodeTo(stakingEnabled, output);
    _i1.U128Codec.codec.encodeTo(minStake, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakingConfigUpdated &&
          other.stakingEnabled == stakingEnabled &&
          other.minStake == minStake;

  @override
  int get hashCode => Object.hash(stakingEnabled, minStake);
}

class PredictionTokenStakeAdded extends Event {
  const PredictionTokenStakeAdded({
    required this.tokenId,
    required this.staker,
    required this.amount,
    required this.totalStake,
  });

  factory PredictionTokenStakeAdded._decode(_i1.Input input) {
    return PredictionTokenStakeAdded(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      totalStake: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt totalStake;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenStakeAdded': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'amount': amount,
      'totalStake': totalStake,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(totalStake);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(21, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(totalStake, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenStakeAdded &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.amount == amount &&
          other.totalStake == totalStake;

  @override
  int get hashCode => Object.hash(tokenId, staker, amount, totalStake);
}

class PredictionTokenStakeRemoved extends Event {
  const PredictionTokenStakeRemoved({
    required this.tokenId,
    required this.staker,
    required this.amount,
    required this.remainingStake,
  });

  factory PredictionTokenStakeRemoved._decode(_i1.Input input) {
    return PredictionTokenStakeRemoved(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      remainingStake: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt remainingStake;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenStakeRemoved': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'amount': amount,
      'remainingStake': remainingStake,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(remainingStake);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(22, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(remainingStake, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenStakeRemoved &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.amount == amount &&
          other.remainingStake == remainingStake;

  @override
  int get hashCode => Object.hash(tokenId, staker, amount, remainingStake);
}

class PredictionTokenStakeLocked extends Event {
  const PredictionTokenStakeLocked({required this.tokenId});

  factory PredictionTokenStakeLocked._decode(_i1.Input input) {
    return PredictionTokenStakeLocked(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionTokenStakeLocked': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(23, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenStakeLocked && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class PredictionTokenStakeReleased extends Event {
  const PredictionTokenStakeReleased({required this.tokenId});

  factory PredictionTokenStakeReleased._decode(_i1.Input input) {
    return PredictionTokenStakeReleased(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionTokenStakeReleased': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(24, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenStakeReleased && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class SettlementConfigUpdated extends Event {
  const SettlementConfigUpdated({
    required this.settlementEnabled,
    required this.disputeWindowBlocks,
    required this.minDisputeBond,
  });

  factory SettlementConfigUpdated._decode(_i1.Input input) {
    return SettlementConfigUpdated(
      settlementEnabled: _i1.BoolCodec.codec.decode(input),
      disputeWindowBlocks: _i1.U32Codec.codec.decode(input),
      minDisputeBond: _i1.U128Codec.codec.decode(input),
    );
  }

  /// bool
  final bool settlementEnabled;

  /// BlockNumberFor<T>
  final int disputeWindowBlocks;

  /// BalanceOf<T>
  final BigInt minDisputeBond;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'SettlementConfigUpdated': {
      'settlementEnabled': settlementEnabled,
      'disputeWindowBlocks': disputeWindowBlocks,
      'minDisputeBond': minDisputeBond,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.BoolCodec.codec.sizeHint(settlementEnabled);
    size = size + _i1.U32Codec.codec.sizeHint(disputeWindowBlocks);
    size = size + _i1.U128Codec.codec.sizeHint(minDisputeBond);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(25, output);
    _i1.BoolCodec.codec.encodeTo(settlementEnabled, output);
    _i1.U32Codec.codec.encodeTo(disputeWindowBlocks, output);
    _i1.U128Codec.codec.encodeTo(minDisputeBond, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementConfigUpdated &&
          other.settlementEnabled == settlementEnabled &&
          other.disputeWindowBlocks == disputeWindowBlocks &&
          other.minDisputeBond == minDisputeBond;

  @override
  int get hashCode =>
      Object.hash(settlementEnabled, disputeWindowBlocks, minDisputeBond);
}

class PredictionOutcomeProposed extends Event {
  const PredictionOutcomeProposed({
    required this.tokenId,
    required this.proposedOutcome,
    this.proposedBy,
    required this.disputeUntil,
  });

  factory PredictionOutcomeProposed._decode(_i1.Input input) {
    return PredictionOutcomeProposed(
      tokenId: _i1.U64Codec.codec.decode(input),
      proposedOutcome: _i7.SettlementOutcome.codec.decode(input),
      proposedBy: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
      disputeUntil: _i1.U32Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// SettlementOutcome
  final _i7.SettlementOutcome proposedOutcome;

  /// Option<T::AccountId>
  final _i3.AccountId32? proposedBy;

  /// BlockNumberFor<T>
  final int disputeUntil;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionOutcomeProposed': {
      'tokenId': tokenId,
      'proposedOutcome': proposedOutcome.toJson(),
      'proposedBy': proposedBy?.toList(),
      'disputeUntil': disputeUntil,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i7.SettlementOutcome.codec.sizeHint(proposedOutcome);
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(proposedBy);
    size = size + _i1.U32Codec.codec.sizeHint(disputeUntil);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(26, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i7.SettlementOutcome.codec.encodeTo(proposedOutcome, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(proposedBy, output);
    _i1.U32Codec.codec.encodeTo(disputeUntil, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionOutcomeProposed &&
          other.tokenId == tokenId &&
          other.proposedOutcome == proposedOutcome &&
          other.proposedBy == proposedBy &&
          other.disputeUntil == disputeUntil;

  @override
  int get hashCode =>
      Object.hash(tokenId, proposedOutcome, proposedBy, disputeUntil);
}

class PredictionOutcomeDisputed extends Event {
  const PredictionOutcomeDisputed({
    required this.tokenId,
    required this.disputeId,
    required this.disputedBy,
    required this.reason,
    required this.bond,
  });

  factory PredictionOutcomeDisputed._decode(_i1.Input input) {
    return PredictionOutcomeDisputed(
      tokenId: _i1.U64Codec.codec.decode(input),
      disputeId: _i1.U64Codec.codec.decode(input),
      disputedBy: const _i1.U8ArrayCodec(32).decode(input),
      reason: _i8.DisputeReason.codec.decode(input),
      bond: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// DisputeId
  final BigInt disputeId;

  /// T::AccountId
  final _i3.AccountId32 disputedBy;

  /// DisputeReason
  final _i8.DisputeReason reason;

  /// BalanceOf<T>
  final BigInt bond;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionOutcomeDisputed': {
      'tokenId': tokenId,
      'disputeId': disputeId,
      'disputedBy': disputedBy.toList(),
      'reason': reason.toJson(),
      'bond': bond,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i1.U64Codec.codec.sizeHint(disputeId);
    size = size + const _i3.AccountId32Codec().sizeHint(disputedBy);
    size = size + _i8.DisputeReason.codec.sizeHint(reason);
    size = size + _i1.U128Codec.codec.sizeHint(bond);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(27, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i1.U64Codec.codec.encodeTo(disputeId, output);
    const _i1.U8ArrayCodec(32).encodeTo(disputedBy, output);
    _i8.DisputeReason.codec.encodeTo(reason, output);
    _i1.U128Codec.codec.encodeTo(bond, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionOutcomeDisputed &&
          other.tokenId == tokenId &&
          other.disputeId == disputeId &&
          _i10.listsEqual(other.disputedBy, disputedBy) &&
          other.reason == reason &&
          other.bond == bond;

  @override
  int get hashCode => Object.hash(tokenId, disputeId, disputedBy, reason, bond);
}

class PredictionOutcomeFinalized extends Event {
  const PredictionOutcomeFinalized({
    required this.tokenId,
    required this.finalOutcome,
    this.finalizedBy,
  });

  factory PredictionOutcomeFinalized._decode(_i1.Input input) {
    return PredictionOutcomeFinalized(
      tokenId: _i1.U64Codec.codec.decode(input),
      finalOutcome: _i7.SettlementOutcome.codec.decode(input),
      finalizedBy: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// SettlementOutcome
  final _i7.SettlementOutcome finalOutcome;

  /// Option<T::AccountId>
  final _i3.AccountId32? finalizedBy;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionOutcomeFinalized': {
      'tokenId': tokenId,
      'finalOutcome': finalOutcome.toJson(),
      'finalizedBy': finalizedBy?.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i7.SettlementOutcome.codec.sizeHint(finalOutcome);
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(finalizedBy);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(28, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i7.SettlementOutcome.codec.encodeTo(finalOutcome, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(finalizedBy, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionOutcomeFinalized &&
          other.tokenId == tokenId &&
          other.finalOutcome == finalOutcome &&
          other.finalizedBy == finalizedBy;

  @override
  int get hashCode => Object.hash(tokenId, finalOutcome, finalizedBy);
}

class PredictionSettlementCancelled extends Event {
  const PredictionSettlementCancelled({required this.tokenId});

  factory PredictionSettlementCancelled._decode(_i1.Input input) {
    return PredictionSettlementCancelled(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionSettlementCancelled': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(29, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionSettlementCancelled && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class ValidatorAuthorized extends Event {
  const ValidatorAuthorized({required this.account});

  factory ValidatorAuthorized._decode(_i1.Input input) {
    return ValidatorAuthorized(
      account: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// T::AccountId
  final _i3.AccountId32 account;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'ValidatorAuthorized': {'account': account.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(account);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(30, output);
    const _i1.U8ArrayCodec(32).encodeTo(account, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatorAuthorized && _i10.listsEqual(other.account, account);

  @override
  int get hashCode => account.hashCode;
}

class ValidatorRemoved extends Event {
  const ValidatorRemoved({required this.account});

  factory ValidatorRemoved._decode(_i1.Input input) {
    return ValidatorRemoved(account: const _i1.U8ArrayCodec(32).decode(input));
  }

  /// T::AccountId
  final _i3.AccountId32 account;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'ValidatorRemoved': {'account': account.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(account);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(31, output);
    const _i1.U8ArrayCodec(32).encodeTo(account, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatorRemoved && _i10.listsEqual(other.account, account);

  @override
  int get hashCode => account.hashCode;
}

class SettlementEconomicsConfigUpdated extends Event {
  const SettlementEconomicsConfigUpdated({
    required this.economicsEnabled,
    required this.slashIncorrect,
    required this.slashFraudulent,
  });

  factory SettlementEconomicsConfigUpdated._decode(_i1.Input input) {
    return SettlementEconomicsConfigUpdated(
      economicsEnabled: _i1.BoolCodec.codec.decode(input),
      slashIncorrect: _i1.BoolCodec.codec.decode(input),
      slashFraudulent: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// bool
  final bool economicsEnabled;

  /// bool
  final bool slashIncorrect;

  /// bool
  final bool slashFraudulent;

  @override
  Map<String, Map<String, bool>> toJson() => {
    'SettlementEconomicsConfigUpdated': {
      'economicsEnabled': economicsEnabled,
      'slashIncorrect': slashIncorrect,
      'slashFraudulent': slashFraudulent,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.BoolCodec.codec.sizeHint(economicsEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(slashIncorrect);
    size = size + _i1.BoolCodec.codec.sizeHint(slashFraudulent);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(32, output);
    _i1.BoolCodec.codec.encodeTo(economicsEnabled, output);
    _i1.BoolCodec.codec.encodeTo(slashIncorrect, output);
    _i1.BoolCodec.codec.encodeTo(slashFraudulent, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementEconomicsConfigUpdated &&
          other.economicsEnabled == economicsEnabled &&
          other.slashIncorrect == slashIncorrect &&
          other.slashFraudulent == slashFraudulent;

  @override
  int get hashCode =>
      Object.hash(economicsEnabled, slashIncorrect, slashFraudulent);
}

class PredictionTokenSettlementClaimed extends Event {
  const PredictionTokenSettlementClaimed({
    required this.tokenId,
    required this.staker,
    required this.refunded,
    required this.slashed,
  });

  factory PredictionTokenSettlementClaimed._decode(_i1.Input input) {
    return PredictionTokenSettlementClaimed(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      refunded: _i1.U128Codec.codec.decode(input),
      slashed: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// BalanceOf<T>
  final BigInt refunded;

  /// BalanceOf<T>
  final BigInt slashed;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionTokenSettlementClaimed': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'refunded': refunded,
      'slashed': slashed,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i1.U128Codec.codec.sizeHint(refunded);
    size = size + _i1.U128Codec.codec.sizeHint(slashed);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(33, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i1.U128Codec.codec.encodeTo(refunded, output);
    _i1.U128Codec.codec.encodeTo(slashed, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenSettlementClaimed &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.refunded == refunded &&
          other.slashed == slashed;

  @override
  int get hashCode => Object.hash(tokenId, staker, refunded, slashed);
}

class PredictionDisputeBondResolved extends Event {
  const PredictionDisputeBondResolved({
    required this.disputeId,
    required this.tokenId,
    required this.disputedBy,
    required this.accepted,
    required this.bond,
  });

  factory PredictionDisputeBondResolved._decode(_i1.Input input) {
    return PredictionDisputeBondResolved(
      disputeId: _i1.U64Codec.codec.decode(input),
      tokenId: _i1.U64Codec.codec.decode(input),
      disputedBy: const _i1.U8ArrayCodec(32).decode(input),
      accepted: _i1.BoolCodec.codec.decode(input),
      bond: _i1.U128Codec.codec.decode(input),
    );
  }

  /// DisputeId
  final BigInt disputeId;

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 disputedBy;

  /// bool
  final bool accepted;

  /// BalanceOf<T>
  final BigInt bond;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionDisputeBondResolved': {
      'disputeId': disputeId,
      'tokenId': tokenId,
      'disputedBy': disputedBy.toList(),
      'accepted': accepted,
      'bond': bond,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(disputeId);
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(disputedBy);
    size = size + _i1.BoolCodec.codec.sizeHint(accepted);
    size = size + _i1.U128Codec.codec.sizeHint(bond);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(34, output);
    _i1.U64Codec.codec.encodeTo(disputeId, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(disputedBy, output);
    _i1.BoolCodec.codec.encodeTo(accepted, output);
    _i1.U128Codec.codec.encodeTo(bond, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionDisputeBondResolved &&
          other.disputeId == disputeId &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.disputedBy, disputedBy) &&
          other.accepted == accepted &&
          other.bond == bond;

  @override
  int get hashCode =>
      Object.hash(disputeId, tokenId, disputedBy, accepted, bond);
}

class PredictionMarketEconomicsConfigUpdated extends Event {
  const PredictionMarketEconomicsConfigUpdated({
    required this.marketEnabled,
    required this.allowUnstakeBeforeSettlement,
  });

  factory PredictionMarketEconomicsConfigUpdated._decode(_i1.Input input) {
    return PredictionMarketEconomicsConfigUpdated(
      marketEnabled: _i1.BoolCodec.codec.decode(input),
      allowUnstakeBeforeSettlement: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// bool
  final bool marketEnabled;

  /// bool
  final bool allowUnstakeBeforeSettlement;

  @override
  Map<String, Map<String, bool>> toJson() => {
    'PredictionMarketEconomicsConfigUpdated': {
      'marketEnabled': marketEnabled,
      'allowUnstakeBeforeSettlement': allowUnstakeBeforeSettlement,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.BoolCodec.codec.sizeHint(marketEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(allowUnstakeBeforeSettlement);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(35, output);
    _i1.BoolCodec.codec.encodeTo(marketEnabled, output);
    _i1.BoolCodec.codec.encodeTo(allowUnstakeBeforeSettlement, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketEconomicsConfigUpdated &&
          other.marketEnabled == marketEnabled &&
          other.allowUnstakeBeforeSettlement == allowUnstakeBeforeSettlement;

  @override
  int get hashCode => Object.hash(marketEnabled, allowUnstakeBeforeSettlement);
}

class PredictionOutcomeSideStaked extends Event {
  const PredictionOutcomeSideStaked({
    required this.tokenId,
    required this.staker,
    required this.side,
    required this.amount,
    required this.totalForSide,
  });

  factory PredictionOutcomeSideStaked._decode(_i1.Input input) {
    return PredictionOutcomeSideStaked(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      side: _i9.PredictionOutcomeSide.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      totalForSide: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// PredictionOutcomeSide
  final _i9.PredictionOutcomeSide side;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt totalForSide;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionOutcomeSideStaked': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'side': side.toJson(),
      'amount': amount,
      'totalForSide': totalForSide,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i9.PredictionOutcomeSide.codec.sizeHint(side);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(totalForSide);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(36, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i9.PredictionOutcomeSide.codec.encodeTo(side, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(totalForSide, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionOutcomeSideStaked &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.side == side &&
          other.amount == amount &&
          other.totalForSide == totalForSide;

  @override
  int get hashCode => Object.hash(tokenId, staker, side, amount, totalForSide);
}

class PredictionOutcomeSideUnstaked extends Event {
  const PredictionOutcomeSideUnstaked({
    required this.tokenId,
    required this.staker,
    required this.side,
    required this.amount,
    required this.remainingStake,
  });

  factory PredictionOutcomeSideUnstaked._decode(_i1.Input input) {
    return PredictionOutcomeSideUnstaked(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      side: _i9.PredictionOutcomeSide.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      remainingStake: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// PredictionOutcomeSide
  final _i9.PredictionOutcomeSide side;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt remainingStake;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionOutcomeSideUnstaked': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'side': side.toJson(),
      'amount': amount,
      'remainingStake': remainingStake,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i9.PredictionOutcomeSide.codec.sizeHint(side);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(remainingStake);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(37, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i9.PredictionOutcomeSide.codec.encodeTo(side, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(remainingStake, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionOutcomeSideUnstaked &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.side == side &&
          other.amount == amount &&
          other.remainingStake == remainingStake;

  @override
  int get hashCode =>
      Object.hash(tokenId, staker, side, amount, remainingStake);
}

class PredictionTokenMarketLocked extends Event {
  const PredictionTokenMarketLocked({required this.tokenId});

  factory PredictionTokenMarketLocked._decode(_i1.Input input) {
    return PredictionTokenMarketLocked(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionTokenMarketLocked': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(38, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenMarketLocked && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class PredictionMarketPayoutClaimed extends Event {
  const PredictionMarketPayoutClaimed({
    required this.tokenId,
    required this.staker,
    required this.side,
    required this.stakeReturned,
    required this.rewardPaid,
    required this.slashed,
  });

  factory PredictionMarketPayoutClaimed._decode(_i1.Input input) {
    return PredictionMarketPayoutClaimed(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      side: _i9.PredictionOutcomeSide.codec.decode(input),
      stakeReturned: _i1.U128Codec.codec.decode(input),
      rewardPaid: _i1.U128Codec.codec.decode(input),
      slashed: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// PredictionOutcomeSide
  final _i9.PredictionOutcomeSide side;

  /// BalanceOf<T>
  final BigInt stakeReturned;

  /// BalanceOf<T>
  final BigInt rewardPaid;

  /// BalanceOf<T>
  final BigInt slashed;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionMarketPayoutClaimed': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'side': side.toJson(),
      'stakeReturned': stakeReturned,
      'rewardPaid': rewardPaid,
      'slashed': slashed,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i9.PredictionOutcomeSide.codec.sizeHint(side);
    size = size + _i1.U128Codec.codec.sizeHint(stakeReturned);
    size = size + _i1.U128Codec.codec.sizeHint(rewardPaid);
    size = size + _i1.U128Codec.codec.sizeHint(slashed);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(39, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i9.PredictionOutcomeSide.codec.encodeTo(side, output);
    _i1.U128Codec.codec.encodeTo(stakeReturned, output);
    _i1.U128Codec.codec.encodeTo(rewardPaid, output);
    _i1.U128Codec.codec.encodeTo(slashed, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketPayoutClaimed &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.side == side &&
          other.stakeReturned == stakeReturned &&
          other.rewardPaid == rewardPaid &&
          other.slashed == slashed;

  @override
  int get hashCode =>
      Object.hash(tokenId, staker, side, stakeReturned, rewardPaid, slashed);
}

class PredictionMarketFeeConfigUpdated extends Event {
  const PredictionMarketFeeConfigUpdated({
    required this.feesEnabled,
    required this.feeBps,
    required this.treasuryEnabled,
  });

  factory PredictionMarketFeeConfigUpdated._decode(_i1.Input input) {
    return PredictionMarketFeeConfigUpdated(
      feesEnabled: _i1.BoolCodec.codec.decode(input),
      feeBps: _i1.U16Codec.codec.decode(input),
      treasuryEnabled: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// bool
  final bool feesEnabled;

  /// u16
  final int feeBps;

  /// bool
  final bool treasuryEnabled;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionMarketFeeConfigUpdated': {
      'feesEnabled': feesEnabled,
      'feeBps': feeBps,
      'treasuryEnabled': treasuryEnabled,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.BoolCodec.codec.sizeHint(feesEnabled);
    size = size + _i1.U16Codec.codec.sizeHint(feeBps);
    size = size + _i1.BoolCodec.codec.sizeHint(treasuryEnabled);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(40, output);
    _i1.BoolCodec.codec.encodeTo(feesEnabled, output);
    _i1.U16Codec.codec.encodeTo(feeBps, output);
    _i1.BoolCodec.codec.encodeTo(treasuryEnabled, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketFeeConfigUpdated &&
          other.feesEnabled == feesEnabled &&
          other.feeBps == feeBps &&
          other.treasuryEnabled == treasuryEnabled;

  @override
  int get hashCode => Object.hash(feesEnabled, feeBps, treasuryEnabled);
}

class PredictionMarketAccountingUpdated extends Event {
  const PredictionMarketAccountingUpdated({
    required this.tokenId,
    required this.feesCollected,
    required this.remaindersCollected,
    required this.totalPaid,
    required this.totalRefunded,
    required this.totalSlashed,
  });

  factory PredictionMarketAccountingUpdated._decode(_i1.Input input) {
    return PredictionMarketAccountingUpdated(
      tokenId: _i1.U64Codec.codec.decode(input),
      feesCollected: _i1.U128Codec.codec.decode(input),
      remaindersCollected: _i1.U128Codec.codec.decode(input),
      totalPaid: _i1.U128Codec.codec.decode(input),
      totalRefunded: _i1.U128Codec.codec.decode(input),
      totalSlashed: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// BalanceOf<T>
  final BigInt feesCollected;

  /// BalanceOf<T>
  final BigInt remaindersCollected;

  /// BalanceOf<T>
  final BigInt totalPaid;

  /// BalanceOf<T>
  final BigInt totalRefunded;

  /// BalanceOf<T>
  final BigInt totalSlashed;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'PredictionMarketAccountingUpdated': {
      'tokenId': tokenId,
      'feesCollected': feesCollected,
      'remaindersCollected': remaindersCollected,
      'totalPaid': totalPaid,
      'totalRefunded': totalRefunded,
      'totalSlashed': totalSlashed,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i1.U128Codec.codec.sizeHint(feesCollected);
    size = size + _i1.U128Codec.codec.sizeHint(remaindersCollected);
    size = size + _i1.U128Codec.codec.sizeHint(totalPaid);
    size = size + _i1.U128Codec.codec.sizeHint(totalRefunded);
    size = size + _i1.U128Codec.codec.sizeHint(totalSlashed);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(41, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i1.U128Codec.codec.encodeTo(feesCollected, output);
    _i1.U128Codec.codec.encodeTo(remaindersCollected, output);
    _i1.U128Codec.codec.encodeTo(totalPaid, output);
    _i1.U128Codec.codec.encodeTo(totalRefunded, output);
    _i1.U128Codec.codec.encodeTo(totalSlashed, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketAccountingUpdated &&
          other.tokenId == tokenId &&
          other.feesCollected == feesCollected &&
          other.remaindersCollected == remaindersCollected &&
          other.totalPaid == totalPaid &&
          other.totalRefunded == totalRefunded &&
          other.totalSlashed == totalSlashed;

  @override
  int get hashCode => Object.hash(
    tokenId,
    feesCollected,
    remaindersCollected,
    totalPaid,
    totalRefunded,
    totalSlashed,
  );
}

class ReservedPenaltyTransferred extends Event {
  const ReservedPenaltyTransferred({
    required this.payer,
    required this.destination,
    required this.amount,
    required this.source,
    required this.reference,
  });

  factory ReservedPenaltyTransferred._decode(_i1.Input input) {
    return ReservedPenaltyTransferred(
      payer: const _i1.U8ArrayCodec(32).decode(input),
      destination: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      source: _i1.U8Codec.codec.decode(input),
      reference: _i1.U64Codec.codec.decode(input),
    );
  }

  /// T::AccountId
  final _i3.AccountId32 payer;

  /// T::AccountId
  final _i3.AccountId32 destination;

  /// BalanceOf<T>
  final BigInt amount;

  /// u8
  /// 0: incorrect prediction, 1: fraudulent prediction, 2: explicitly adjudicated fraudulent dispute bond.
  final int source;

  /// u64
  final BigInt reference;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ReservedPenaltyTransferred': {
      'payer': payer.toList(),
      'destination': destination.toList(),
      'amount': amount,
      'source': source,
      'reference': reference,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(payer);
    size = size + const _i3.AccountId32Codec().sizeHint(destination);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U8Codec.codec.sizeHint(source);
    size = size + _i1.U64Codec.codec.sizeHint(reference);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(42, output);
    const _i1.U8ArrayCodec(32).encodeTo(payer, output);
    const _i1.U8ArrayCodec(32).encodeTo(destination, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U8Codec.codec.encodeTo(source, output);
    _i1.U64Codec.codec.encodeTo(reference, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservedPenaltyTransferred &&
          _i10.listsEqual(other.payer, payer) &&
          _i10.listsEqual(other.destination, destination) &&
          other.amount == amount &&
          other.source == source &&
          other.reference == reference;

  @override
  int get hashCode =>
      Object.hash(payer, destination, amount, source, reference);
}

class DisputeBondAdjudicated extends Event {
  const DisputeBondAdjudicated({
    required this.disputeId,
    required this.accepted,
    required this.fraudulent,
    required this.evidenceHash,
  });

  factory DisputeBondAdjudicated._decode(_i1.Input input) {
    return DisputeBondAdjudicated(
      disputeId: _i1.U64Codec.codec.decode(input),
      accepted: _i1.BoolCodec.codec.decode(input),
      fraudulent: _i1.BoolCodec.codec.decode(input),
      evidenceHash: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// DisputeId
  final BigInt disputeId;

  /// bool
  final bool accepted;

  /// bool
  final bool fraudulent;

  /// [u8; 32]
  final List<int> evidenceHash;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'DisputeBondAdjudicated': {
      'disputeId': disputeId,
      'accepted': accepted,
      'fraudulent': fraudulent,
      'evidenceHash': evidenceHash.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(disputeId);
    size = size + _i1.BoolCodec.codec.sizeHint(accepted);
    size = size + _i1.BoolCodec.codec.sizeHint(fraudulent);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(evidenceHash);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(43, output);
    _i1.U64Codec.codec.encodeTo(disputeId, output);
    _i1.BoolCodec.codec.encodeTo(accepted, output);
    _i1.BoolCodec.codec.encodeTo(fraudulent, output);
    const _i1.U8ArrayCodec(32).encodeTo(evidenceHash, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisputeBondAdjudicated &&
          other.disputeId == disputeId &&
          other.accepted == accepted &&
          other.fraudulent == fraudulent &&
          _i10.listsEqual(other.evidenceHash, evidenceHash);

  @override
  int get hashCode =>
      Object.hash(disputeId, accepted, fraudulent, evidenceHash);
}

class PredictionMarketNoWinnerRefund extends Event {
  const PredictionMarketNoWinnerRefund({
    required this.tokenId,
    required this.staker,
    required this.amount,
  });

  factory PredictionMarketNoWinnerRefund._decode(_i1.Input input) {
    return PredictionMarketNoWinnerRefund(
      tokenId: _i1.U64Codec.codec.decode(input),
      staker: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i3.AccountId32 staker;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PredictionMarketNoWinnerRefund': {
      'tokenId': tokenId,
      'staker': staker.toList(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i3.AccountId32Codec().sizeHint(staker);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(44, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(staker, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketNoWinnerRefund &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.staker, staker) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(tokenId, staker, amount);
}

class EvaluationRecorded extends Event {
  const EvaluationRecorded({
    required this.predictionId,
    required this.requestId,
    required this.artifact,
  });

  factory EvaluationRecorded._decode(_i1.Input input) {
    return EvaluationRecorded(
      predictionId: _i1.U64Codec.codec.decode(input),
      requestId: const _i1.U8ArrayCodec(32).decode(input),
      artifact: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// [u8; 32]
  final List<int> requestId;

  /// [u8; 32]
  final List<int> artifact;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EvaluationRecorded': {
      'predictionId': predictionId,
      'requestId': requestId.toList(),
      'artifact': artifact.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(requestId);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(artifact);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(45, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    const _i1.U8ArrayCodec(32).encodeTo(requestId, output);
    const _i1.U8ArrayCodec(32).encodeTo(artifact, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRecorded &&
          other.predictionId == predictionId &&
          _i10.listsEqual(other.requestId, requestId) &&
          _i10.listsEqual(other.artifact, artifact);

  @override
  int get hashCode => Object.hash(predictionId, requestId, artifact);
}

class EvaluationEvidenceRecorded extends Event {
  const EvaluationEvidenceRecorded({
    required this.predictionId,
    required this.revision,
    required this.evidence,
    required this.outcome,
  });

  factory EvaluationEvidenceRecorded._decode(_i1.Input input) {
    return EvaluationEvidenceRecorded(
      predictionId: _i1.U64Codec.codec.decode(input),
      revision: _i1.U32Codec.codec.decode(input),
      evidence: const _i1.U8ArrayCodec(32).decode(input),
      outcome: _i6.PredictionOutcome.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// u32
  final int revision;

  /// [u8; 32]
  final List<int> evidence;

  /// PredictionOutcome
  final _i6.PredictionOutcome outcome;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EvaluationEvidenceRecorded': {
      'predictionId': predictionId,
      'revision': revision,
      'evidence': evidence.toList(),
      'outcome': outcome.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i1.U32Codec.codec.sizeHint(revision);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(evidence);
    size = size + _i6.PredictionOutcome.codec.sizeHint(outcome);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(46, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U32Codec.codec.encodeTo(revision, output);
    const _i1.U8ArrayCodec(32).encodeTo(evidence, output);
    _i6.PredictionOutcome.codec.encodeTo(outcome, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationEvidenceRecorded &&
          other.predictionId == predictionId &&
          other.revision == revision &&
          _i10.listsEqual(other.evidence, evidence) &&
          other.outcome == outcome;

  @override
  int get hashCode => Object.hash(predictionId, revision, evidence, outcome);
}
