// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i10;

import '../../sp_core/crypto/account_id32.dart' as _i5;
import '../dispute_reason.dart' as _i7;
import '../model_onboarding_settings.dart' as _i9;
import '../prediction_domain.dart' as _i3;
import '../prediction_outcome.dart' as _i4;
import '../prediction_outcome_side.dart' as _i8;
import '../settlement_outcome.dart' as _i6;

/// Contains a variant per dispatchable extrinsic that this pallet has.
abstract class Call {
  const Call();

  factory Call.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $CallCodec codec = $CallCodec();

  static const $Call values = $Call();

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

class $Call {
  const $Call();

  RegisterModel registerModel({
    required List<int> modelHash,
    required List<int> metadataUri,
  }) {
    return RegisterModel(modelHash: modelHash, metadataUri: metadataUri);
  }

  UpdateModel updateModel({
    required BigInt modelId,
    required List<int> modelHash,
    required List<int> metadataUri,
  }) {
    return UpdateModel(
      modelId: modelId,
      modelHash: modelHash,
      metadataUri: metadataUri,
    );
  }

  SubmitPrediction submitPrediction({
    required BigInt modelId,
    required _i3.PredictionDomain domain,
    required List<int> categoryCode,
    required List<int> predictionHash,
    required List<int> metadataUri,
    required int confidence,
    required int expiresAt,
  }) {
    return SubmitPrediction(
      modelId: modelId,
      domain: domain,
      categoryCode: categoryCode,
      predictionHash: predictionHash,
      metadataUri: metadataUri,
      confidence: confidence,
      expiresAt: expiresAt,
    );
  }

  ValidatePrediction validatePrediction({
    required BigInt predictionId,
    required _i4.PredictionOutcome outcome,
  }) {
    return ValidatePrediction(predictionId: predictionId, outcome: outcome);
  }

  ClosePrediction closePrediction({required BigInt predictionId}) {
    return ClosePrediction(predictionId: predictionId);
  }

  AuthorizeValidator authorizeValidator({required _i5.AccountId32 account}) {
    return AuthorizeValidator(account: account);
  }

  RemoveValidator removeValidator({required _i5.AccountId32 account}) {
    return RemoveValidator(account: account);
  }

  SetTokenizationConfig setTokenizationConfig({
    required bool tokenizationEnabled,
    required bool transfersEnabled,
  }) {
    return SetTokenizationConfig(
      tokenizationEnabled: tokenizationEnabled,
      transfersEnabled: transfersEnabled,
    );
  }

  TokenizePrediction tokenizePrediction({
    required BigInt predictionId,
    required List<int> metadataUri,
    required bool transferable,
  }) {
    return TokenizePrediction(
      predictionId: predictionId,
      metadataUri: metadataUri,
      transferable: transferable,
    );
  }

  ApprovePredictionTokenTransfer approvePredictionTokenTransfer({
    required BigInt tokenId,
    required _i5.AccountId32 approved,
  }) {
    return ApprovePredictionTokenTransfer(tokenId: tokenId, approved: approved);
  }

  RevokePredictionTokenApproval revokePredictionTokenApproval({
    required BigInt tokenId,
  }) {
    return RevokePredictionTokenApproval(tokenId: tokenId);
  }

  TransferPredictionToken transferPredictionToken({
    required BigInt tokenId,
    required _i5.AccountId32 to,
  }) {
    return TransferPredictionToken(tokenId: tokenId, to: to);
  }

  FreezePredictionToken freezePredictionToken({required BigInt tokenId}) {
    return FreezePredictionToken(tokenId: tokenId);
  }

  UnfreezePredictionToken unfreezePredictionToken({required BigInt tokenId}) {
    return UnfreezePredictionToken(tokenId: tokenId);
  }

  BurnPredictionToken burnPredictionToken({required BigInt tokenId}) {
    return BurnPredictionToken(tokenId: tokenId);
  }

  UpdatePredictionTokenMetadata updatePredictionTokenMetadata({
    required BigInt tokenId,
    required List<int> metadataUri,
  }) {
    return UpdatePredictionTokenMetadata(
      tokenId: tokenId,
      metadataUri: metadataUri,
    );
  }

  SetStakingConfig setStakingConfig({
    required bool stakingEnabled,
    required BigInt minStake,
  }) {
    return SetStakingConfig(stakingEnabled: stakingEnabled, minStake: minStake);
  }

  StakeOnPredictionToken stakeOnPredictionToken({
    required BigInt tokenId,
    required BigInt amount,
  }) {
    return StakeOnPredictionToken(tokenId: tokenId, amount: amount);
  }

  UnstakePredictionToken unstakePredictionToken({
    required BigInt tokenId,
    required BigInt amount,
  }) {
    return UnstakePredictionToken(tokenId: tokenId, amount: amount);
  }

  LockPredictionTokenStake lockPredictionTokenStake({required BigInt tokenId}) {
    return LockPredictionTokenStake(tokenId: tokenId);
  }

  ReleasePredictionTokenStake releasePredictionTokenStake({
    required BigInt tokenId,
  }) {
    return ReleasePredictionTokenStake(tokenId: tokenId);
  }

  SetSettlementConfig setSettlementConfig({
    required bool settlementEnabled,
    required int disputeWindowBlocks,
    required BigInt minDisputeBond,
  }) {
    return SetSettlementConfig(
      settlementEnabled: settlementEnabled,
      disputeWindowBlocks: disputeWindowBlocks,
      minDisputeBond: minDisputeBond,
    );
  }

  ProposePredictionOutcome proposePredictionOutcome({
    required BigInt tokenId,
    required _i6.SettlementOutcome proposedOutcome,
    required List<int> evidenceUri,
  }) {
    return ProposePredictionOutcome(
      tokenId: tokenId,
      proposedOutcome: proposedOutcome,
      evidenceUri: evidenceUri,
    );
  }

  DisputePredictionOutcome disputePredictionOutcome({
    required BigInt tokenId,
    required _i7.DisputeReason reason,
    required List<int> evidenceUri,
    required BigInt bond,
  }) {
    return DisputePredictionOutcome(
      tokenId: tokenId,
      reason: reason,
      evidenceUri: evidenceUri,
      bond: bond,
    );
  }

  AdminFinalizePredictionOutcome adminFinalizePredictionOutcome({
    required BigInt tokenId,
    required _i6.SettlementOutcome finalOutcome,
    required List<int> evidenceUri,
  }) {
    return AdminFinalizePredictionOutcome(
      tokenId: tokenId,
      finalOutcome: finalOutcome,
      evidenceUri: evidenceUri,
    );
  }

  FinalizePredictionOutcomeAfterDisputeWindow
  finalizePredictionOutcomeAfterDisputeWindow({required BigInt tokenId}) {
    return FinalizePredictionOutcomeAfterDisputeWindow(tokenId: tokenId);
  }

  CancelPredictionSettlement cancelPredictionSettlement({
    required BigInt tokenId,
    required List<int> evidenceUri,
  }) {
    return CancelPredictionSettlement(
      tokenId: tokenId,
      evidenceUri: evidenceUri,
    );
  }

  SetSettlementEconomicsConfig setSettlementEconomicsConfig({
    required bool economicsEnabled,
    required bool slashIncorrect,
    required bool slashFraudulent,
  }) {
    return SetSettlementEconomicsConfig(
      economicsEnabled: economicsEnabled,
      slashIncorrect: slashIncorrect,
      slashFraudulent: slashFraudulent,
    );
  }

  ClaimPredictionTokenSettlement claimPredictionTokenSettlement({
    required BigInt tokenId,
  }) {
    return ClaimPredictionTokenSettlement(tokenId: tokenId);
  }

  ResolvePredictionDisputeBond resolvePredictionDisputeBond({
    required BigInt disputeId,
    required bool accepted,
  }) {
    return ResolvePredictionDisputeBond(
      disputeId: disputeId,
      accepted: accepted,
    );
  }

  SetMarketEconomicsConfig setMarketEconomicsConfig({
    required bool marketEnabled,
    required bool allowUnstakeBeforeSettlement,
  }) {
    return SetMarketEconomicsConfig(
      marketEnabled: marketEnabled,
      allowUnstakeBeforeSettlement: allowUnstakeBeforeSettlement,
    );
  }

  StakeOnPredictionOutcomeSide stakeOnPredictionOutcomeSide({
    required BigInt tokenId,
    required _i8.PredictionOutcomeSide side,
    required BigInt amount,
  }) {
    return StakeOnPredictionOutcomeSide(
      tokenId: tokenId,
      side: side,
      amount: amount,
    );
  }

  UnstakeFromPredictionOutcomeSide unstakeFromPredictionOutcomeSide({
    required BigInt tokenId,
    required _i8.PredictionOutcomeSide side,
    required BigInt amount,
  }) {
    return UnstakeFromPredictionOutcomeSide(
      tokenId: tokenId,
      side: side,
      amount: amount,
    );
  }

  ClaimPredictionMarketPayout claimPredictionMarketPayout({
    required BigInt tokenId,
  }) {
    return ClaimPredictionMarketPayout(tokenId: tokenId);
  }

  SetMarketFeeConfig setMarketFeeConfig({
    required bool feesEnabled,
    required int feeBps,
    required bool treasuryEnabled,
  }) {
    return SetMarketFeeConfig(
      feesEnabled: feesEnabled,
      feeBps: feeBps,
      treasuryEnabled: treasuryEnabled,
    );
  }

  SetModelOnboardingConfig setModelOnboardingConfig({
    required _i9.ModelOnboardingSettings config,
  }) {
    return SetModelOnboardingConfig(config: config);
  }

  ApproveModel approveModel({required BigInt modelId}) {
    return ApproveModel(modelId: modelId);
  }

  SuspendModel suspendModel({required BigInt modelId}) {
    return SuspendModel(modelId: modelId);
  }

  RejectModel rejectModel({required BigInt modelId}) {
    return RejectModel(modelId: modelId);
  }

  SetModelSubmitter setModelSubmitter({
    required BigInt modelId,
    _i5.AccountId32? submitter,
  }) {
    return SetModelSubmitter(modelId: modelId, submitter: submitter);
  }

  AdjudicatePredictionDisputeBond adjudicatePredictionDisputeBond({
    required BigInt disputeId,
    required bool accepted,
    required bool fraudulent,
    required List<int> evidenceHash,
  }) {
    return AdjudicatePredictionDisputeBond(
      disputeId: disputeId,
      accepted: accepted,
      fraudulent: fraudulent,
      evidenceHash: evidenceHash,
    );
  }

  SubmitEvaluation submitEvaluation({
    required BigInt modelId,
    required List<int> requestId,
    required List<int> artifact,
    required List<int> predictionHash,
    required List<int> metadataUri,
    required int confidence,
    required int expiresAt,
    required BigInt cutoffUtc,
    required BigInt evidenceAfterUtc,
  }) {
    return SubmitEvaluation(
      modelId: modelId,
      requestId: requestId,
      artifact: artifact,
      predictionHash: predictionHash,
      metadataUri: metadataUri,
      confidence: confidence,
      expiresAt: expiresAt,
      cutoffUtc: cutoffUtc,
      evidenceAfterUtc: evidenceAfterUtc,
    );
  }

  RecordEvaluationEvidence recordEvaluationEvidence({
    required BigInt predictionId,
    required int revision,
    required List<int> evidence,
    required _i4.PredictionOutcome outcome,
  }) {
    return RecordEvaluationEvidence(
      predictionId: predictionId,
      revision: revision,
      evidence: evidence,
      outcome: outcome,
    );
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RegisterModel._decode(input);
      case 1:
        return UpdateModel._decode(input);
      case 2:
        return SubmitPrediction._decode(input);
      case 3:
        return ValidatePrediction._decode(input);
      case 4:
        return ClosePrediction._decode(input);
      case 5:
        return AuthorizeValidator._decode(input);
      case 6:
        return RemoveValidator._decode(input);
      case 7:
        return SetTokenizationConfig._decode(input);
      case 8:
        return TokenizePrediction._decode(input);
      case 9:
        return ApprovePredictionTokenTransfer._decode(input);
      case 10:
        return RevokePredictionTokenApproval._decode(input);
      case 11:
        return TransferPredictionToken._decode(input);
      case 12:
        return FreezePredictionToken._decode(input);
      case 13:
        return UnfreezePredictionToken._decode(input);
      case 14:
        return BurnPredictionToken._decode(input);
      case 15:
        return UpdatePredictionTokenMetadata._decode(input);
      case 16:
        return SetStakingConfig._decode(input);
      case 17:
        return StakeOnPredictionToken._decode(input);
      case 18:
        return UnstakePredictionToken._decode(input);
      case 19:
        return LockPredictionTokenStake._decode(input);
      case 20:
        return ReleasePredictionTokenStake._decode(input);
      case 21:
        return SetSettlementConfig._decode(input);
      case 22:
        return ProposePredictionOutcome._decode(input);
      case 23:
        return DisputePredictionOutcome._decode(input);
      case 24:
        return AdminFinalizePredictionOutcome._decode(input);
      case 25:
        return FinalizePredictionOutcomeAfterDisputeWindow._decode(input);
      case 26:
        return CancelPredictionSettlement._decode(input);
      case 27:
        return SetSettlementEconomicsConfig._decode(input);
      case 28:
        return ClaimPredictionTokenSettlement._decode(input);
      case 29:
        return ResolvePredictionDisputeBond._decode(input);
      case 30:
        return SetMarketEconomicsConfig._decode(input);
      case 31:
        return StakeOnPredictionOutcomeSide._decode(input);
      case 32:
        return UnstakeFromPredictionOutcomeSide._decode(input);
      case 33:
        return ClaimPredictionMarketPayout._decode(input);
      case 34:
        return SetMarketFeeConfig._decode(input);
      case 35:
        return SetModelOnboardingConfig._decode(input);
      case 36:
        return ApproveModel._decode(input);
      case 37:
        return SuspendModel._decode(input);
      case 38:
        return RejectModel._decode(input);
      case 39:
        return SetModelSubmitter._decode(input);
      case 40:
        return AdjudicatePredictionDisputeBond._decode(input);
      case 41:
        return SubmitEvaluation._decode(input);
      case 42:
        return RecordEvaluationEvidence._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case RegisterModel:
        (value as RegisterModel).encodeTo(output);
        break;
      case UpdateModel:
        (value as UpdateModel).encodeTo(output);
        break;
      case SubmitPrediction:
        (value as SubmitPrediction).encodeTo(output);
        break;
      case ValidatePrediction:
        (value as ValidatePrediction).encodeTo(output);
        break;
      case ClosePrediction:
        (value as ClosePrediction).encodeTo(output);
        break;
      case AuthorizeValidator:
        (value as AuthorizeValidator).encodeTo(output);
        break;
      case RemoveValidator:
        (value as RemoveValidator).encodeTo(output);
        break;
      case SetTokenizationConfig:
        (value as SetTokenizationConfig).encodeTo(output);
        break;
      case TokenizePrediction:
        (value as TokenizePrediction).encodeTo(output);
        break;
      case ApprovePredictionTokenTransfer:
        (value as ApprovePredictionTokenTransfer).encodeTo(output);
        break;
      case RevokePredictionTokenApproval:
        (value as RevokePredictionTokenApproval).encodeTo(output);
        break;
      case TransferPredictionToken:
        (value as TransferPredictionToken).encodeTo(output);
        break;
      case FreezePredictionToken:
        (value as FreezePredictionToken).encodeTo(output);
        break;
      case UnfreezePredictionToken:
        (value as UnfreezePredictionToken).encodeTo(output);
        break;
      case BurnPredictionToken:
        (value as BurnPredictionToken).encodeTo(output);
        break;
      case UpdatePredictionTokenMetadata:
        (value as UpdatePredictionTokenMetadata).encodeTo(output);
        break;
      case SetStakingConfig:
        (value as SetStakingConfig).encodeTo(output);
        break;
      case StakeOnPredictionToken:
        (value as StakeOnPredictionToken).encodeTo(output);
        break;
      case UnstakePredictionToken:
        (value as UnstakePredictionToken).encodeTo(output);
        break;
      case LockPredictionTokenStake:
        (value as LockPredictionTokenStake).encodeTo(output);
        break;
      case ReleasePredictionTokenStake:
        (value as ReleasePredictionTokenStake).encodeTo(output);
        break;
      case SetSettlementConfig:
        (value as SetSettlementConfig).encodeTo(output);
        break;
      case ProposePredictionOutcome:
        (value as ProposePredictionOutcome).encodeTo(output);
        break;
      case DisputePredictionOutcome:
        (value as DisputePredictionOutcome).encodeTo(output);
        break;
      case AdminFinalizePredictionOutcome:
        (value as AdminFinalizePredictionOutcome).encodeTo(output);
        break;
      case FinalizePredictionOutcomeAfterDisputeWindow:
        (value as FinalizePredictionOutcomeAfterDisputeWindow).encodeTo(output);
        break;
      case CancelPredictionSettlement:
        (value as CancelPredictionSettlement).encodeTo(output);
        break;
      case SetSettlementEconomicsConfig:
        (value as SetSettlementEconomicsConfig).encodeTo(output);
        break;
      case ClaimPredictionTokenSettlement:
        (value as ClaimPredictionTokenSettlement).encodeTo(output);
        break;
      case ResolvePredictionDisputeBond:
        (value as ResolvePredictionDisputeBond).encodeTo(output);
        break;
      case SetMarketEconomicsConfig:
        (value as SetMarketEconomicsConfig).encodeTo(output);
        break;
      case StakeOnPredictionOutcomeSide:
        (value as StakeOnPredictionOutcomeSide).encodeTo(output);
        break;
      case UnstakeFromPredictionOutcomeSide:
        (value as UnstakeFromPredictionOutcomeSide).encodeTo(output);
        break;
      case ClaimPredictionMarketPayout:
        (value as ClaimPredictionMarketPayout).encodeTo(output);
        break;
      case SetMarketFeeConfig:
        (value as SetMarketFeeConfig).encodeTo(output);
        break;
      case SetModelOnboardingConfig:
        (value as SetModelOnboardingConfig).encodeTo(output);
        break;
      case ApproveModel:
        (value as ApproveModel).encodeTo(output);
        break;
      case SuspendModel:
        (value as SuspendModel).encodeTo(output);
        break;
      case RejectModel:
        (value as RejectModel).encodeTo(output);
        break;
      case SetModelSubmitter:
        (value as SetModelSubmitter).encodeTo(output);
        break;
      case AdjudicatePredictionDisputeBond:
        (value as AdjudicatePredictionDisputeBond).encodeTo(output);
        break;
      case SubmitEvaluation:
        (value as SubmitEvaluation).encodeTo(output);
        break;
      case RecordEvaluationEvidence:
        (value as RecordEvaluationEvidence).encodeTo(output);
        break;
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Call value) {
    switch (value.runtimeType) {
      case RegisterModel:
        return (value as RegisterModel)._sizeHint();
      case UpdateModel:
        return (value as UpdateModel)._sizeHint();
      case SubmitPrediction:
        return (value as SubmitPrediction)._sizeHint();
      case ValidatePrediction:
        return (value as ValidatePrediction)._sizeHint();
      case ClosePrediction:
        return (value as ClosePrediction)._sizeHint();
      case AuthorizeValidator:
        return (value as AuthorizeValidator)._sizeHint();
      case RemoveValidator:
        return (value as RemoveValidator)._sizeHint();
      case SetTokenizationConfig:
        return (value as SetTokenizationConfig)._sizeHint();
      case TokenizePrediction:
        return (value as TokenizePrediction)._sizeHint();
      case ApprovePredictionTokenTransfer:
        return (value as ApprovePredictionTokenTransfer)._sizeHint();
      case RevokePredictionTokenApproval:
        return (value as RevokePredictionTokenApproval)._sizeHint();
      case TransferPredictionToken:
        return (value as TransferPredictionToken)._sizeHint();
      case FreezePredictionToken:
        return (value as FreezePredictionToken)._sizeHint();
      case UnfreezePredictionToken:
        return (value as UnfreezePredictionToken)._sizeHint();
      case BurnPredictionToken:
        return (value as BurnPredictionToken)._sizeHint();
      case UpdatePredictionTokenMetadata:
        return (value as UpdatePredictionTokenMetadata)._sizeHint();
      case SetStakingConfig:
        return (value as SetStakingConfig)._sizeHint();
      case StakeOnPredictionToken:
        return (value as StakeOnPredictionToken)._sizeHint();
      case UnstakePredictionToken:
        return (value as UnstakePredictionToken)._sizeHint();
      case LockPredictionTokenStake:
        return (value as LockPredictionTokenStake)._sizeHint();
      case ReleasePredictionTokenStake:
        return (value as ReleasePredictionTokenStake)._sizeHint();
      case SetSettlementConfig:
        return (value as SetSettlementConfig)._sizeHint();
      case ProposePredictionOutcome:
        return (value as ProposePredictionOutcome)._sizeHint();
      case DisputePredictionOutcome:
        return (value as DisputePredictionOutcome)._sizeHint();
      case AdminFinalizePredictionOutcome:
        return (value as AdminFinalizePredictionOutcome)._sizeHint();
      case FinalizePredictionOutcomeAfterDisputeWindow:
        return (value as FinalizePredictionOutcomeAfterDisputeWindow)
            ._sizeHint();
      case CancelPredictionSettlement:
        return (value as CancelPredictionSettlement)._sizeHint();
      case SetSettlementEconomicsConfig:
        return (value as SetSettlementEconomicsConfig)._sizeHint();
      case ClaimPredictionTokenSettlement:
        return (value as ClaimPredictionTokenSettlement)._sizeHint();
      case ResolvePredictionDisputeBond:
        return (value as ResolvePredictionDisputeBond)._sizeHint();
      case SetMarketEconomicsConfig:
        return (value as SetMarketEconomicsConfig)._sizeHint();
      case StakeOnPredictionOutcomeSide:
        return (value as StakeOnPredictionOutcomeSide)._sizeHint();
      case UnstakeFromPredictionOutcomeSide:
        return (value as UnstakeFromPredictionOutcomeSide)._sizeHint();
      case ClaimPredictionMarketPayout:
        return (value as ClaimPredictionMarketPayout)._sizeHint();
      case SetMarketFeeConfig:
        return (value as SetMarketFeeConfig)._sizeHint();
      case SetModelOnboardingConfig:
        return (value as SetModelOnboardingConfig)._sizeHint();
      case ApproveModel:
        return (value as ApproveModel)._sizeHint();
      case SuspendModel:
        return (value as SuspendModel)._sizeHint();
      case RejectModel:
        return (value as RejectModel)._sizeHint();
      case SetModelSubmitter:
        return (value as SetModelSubmitter)._sizeHint();
      case AdjudicatePredictionDisputeBond:
        return (value as AdjudicatePredictionDisputeBond)._sizeHint();
      case SubmitEvaluation:
        return (value as SubmitEvaluation)._sizeHint();
      case RecordEvaluationEvidence:
        return (value as RecordEvaluationEvidence)._sizeHint();
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class RegisterModel extends Call {
  const RegisterModel({required this.modelHash, required this.metadataUri});

  factory RegisterModel._decode(_i1.Input input) {
    return RegisterModel(
      modelHash: _i1.U8SequenceCodec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// Vec<u8>
  final List<int> modelHash;

  /// Vec<u8>
  final List<int> metadataUri;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'register_model': {'modelHash': modelHash, 'metadataUri': metadataUri},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(modelHash);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(metadataUri);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U8SequenceCodec.codec.encodeTo(modelHash, output);
    _i1.U8SequenceCodec.codec.encodeTo(metadataUri, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterModel &&
          _i10.listsEqual(other.modelHash, modelHash) &&
          _i10.listsEqual(other.metadataUri, metadataUri);

  @override
  int get hashCode => Object.hash(modelHash, metadataUri);
}

class UpdateModel extends Call {
  const UpdateModel({
    required this.modelId,
    required this.modelHash,
    required this.metadataUri,
  });

  factory UpdateModel._decode(_i1.Input input) {
    return UpdateModel(
      modelId: _i1.U64Codec.codec.decode(input),
      modelHash: _i1.U8SequenceCodec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// Vec<u8>
  final List<int> modelHash;

  /// Vec<u8>
  final List<int> metadataUri;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'update_model': {
      'modelId': modelId,
      'modelHash': modelHash,
      'metadataUri': metadataUri,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(modelHash);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(metadataUri);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    _i1.U8SequenceCodec.codec.encodeTo(modelHash, output);
    _i1.U8SequenceCodec.codec.encodeTo(metadataUri, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateModel &&
          other.modelId == modelId &&
          _i10.listsEqual(other.modelHash, modelHash) &&
          _i10.listsEqual(other.metadataUri, metadataUri);

  @override
  int get hashCode => Object.hash(modelId, modelHash, metadataUri);
}

class SubmitPrediction extends Call {
  const SubmitPrediction({
    required this.modelId,
    required this.domain,
    required this.categoryCode,
    required this.predictionHash,
    required this.metadataUri,
    required this.confidence,
    required this.expiresAt,
  });

  factory SubmitPrediction._decode(_i1.Input input) {
    return SubmitPrediction(
      modelId: _i1.U64Codec.codec.decode(input),
      domain: _i3.PredictionDomain.codec.decode(input),
      categoryCode: _i1.U8SequenceCodec.codec.decode(input),
      predictionHash: _i1.U8SequenceCodec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
      confidence: _i1.U8Codec.codec.decode(input),
      expiresAt: _i1.U32Codec.codec.decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// PredictionDomain
  final _i3.PredictionDomain domain;

  /// Vec<u8>
  final List<int> categoryCode;

  /// Vec<u8>
  final List<int> predictionHash;

  /// Vec<u8>
  final List<int> metadataUri;

  /// u8
  final int confidence;

  /// BlockNumberFor<T>
  final int expiresAt;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'submit_prediction': {
      'modelId': modelId,
      'domain': domain.toJson(),
      'categoryCode': categoryCode,
      'predictionHash': predictionHash,
      'metadataUri': metadataUri,
      'confidence': confidence,
      'expiresAt': expiresAt,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + _i3.PredictionDomain.codec.sizeHint(domain);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(categoryCode);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(predictionHash);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(metadataUri);
    size = size + _i1.U8Codec.codec.sizeHint(confidence);
    size = size + _i1.U32Codec.codec.sizeHint(expiresAt);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    _i3.PredictionDomain.codec.encodeTo(domain, output);
    _i1.U8SequenceCodec.codec.encodeTo(categoryCode, output);
    _i1.U8SequenceCodec.codec.encodeTo(predictionHash, output);
    _i1.U8SequenceCodec.codec.encodeTo(metadataUri, output);
    _i1.U8Codec.codec.encodeTo(confidence, output);
    _i1.U32Codec.codec.encodeTo(expiresAt, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitPrediction &&
          other.modelId == modelId &&
          other.domain == domain &&
          _i10.listsEqual(other.categoryCode, categoryCode) &&
          _i10.listsEqual(other.predictionHash, predictionHash) &&
          _i10.listsEqual(other.metadataUri, metadataUri) &&
          other.confidence == confidence &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(
    modelId,
    domain,
    categoryCode,
    predictionHash,
    metadataUri,
    confidence,
    expiresAt,
  );
}

class ValidatePrediction extends Call {
  const ValidatePrediction({required this.predictionId, required this.outcome});

  factory ValidatePrediction._decode(_i1.Input input) {
    return ValidatePrediction(
      predictionId: _i1.U64Codec.codec.decode(input),
      outcome: _i4.PredictionOutcome.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// PredictionOutcome
  final _i4.PredictionOutcome outcome;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'validate_prediction': {
      'predictionId': predictionId,
      'outcome': outcome.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i4.PredictionOutcome.codec.sizeHint(outcome);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i4.PredictionOutcome.codec.encodeTo(outcome, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatePrediction &&
          other.predictionId == predictionId &&
          other.outcome == outcome;

  @override
  int get hashCode => Object.hash(predictionId, outcome);
}

class ClosePrediction extends Call {
  const ClosePrediction({required this.predictionId});

  factory ClosePrediction._decode(_i1.Input input) {
    return ClosePrediction(predictionId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionId
  final BigInt predictionId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'close_prediction': {'predictionId': predictionId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClosePrediction && other.predictionId == predictionId;

  @override
  int get hashCode => predictionId.hashCode;
}

class AuthorizeValidator extends Call {
  const AuthorizeValidator({required this.account});

  factory AuthorizeValidator._decode(_i1.Input input) {
    return AuthorizeValidator(
      account: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// T::AccountId
  final _i5.AccountId32 account;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'authorize_validator': {'account': account.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i5.AccountId32Codec().sizeHint(account);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    const _i1.U8ArrayCodec(32).encodeTo(account, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizeValidator && _i10.listsEqual(other.account, account);

  @override
  int get hashCode => account.hashCode;
}

class RemoveValidator extends Call {
  const RemoveValidator({required this.account});

  factory RemoveValidator._decode(_i1.Input input) {
    return RemoveValidator(account: const _i1.U8ArrayCodec(32).decode(input));
  }

  /// T::AccountId
  final _i5.AccountId32 account;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'remove_validator': {'account': account.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i5.AccountId32Codec().sizeHint(account);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    const _i1.U8ArrayCodec(32).encodeTo(account, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoveValidator && _i10.listsEqual(other.account, account);

  @override
  int get hashCode => account.hashCode;
}

class SetTokenizationConfig extends Call {
  const SetTokenizationConfig({
    required this.tokenizationEnabled,
    required this.transfersEnabled,
  });

  factory SetTokenizationConfig._decode(_i1.Input input) {
    return SetTokenizationConfig(
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
    'set_tokenization_config': {
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
    _i1.U8Codec.codec.encodeTo(7, output);
    _i1.BoolCodec.codec.encodeTo(tokenizationEnabled, output);
    _i1.BoolCodec.codec.encodeTo(transfersEnabled, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetTokenizationConfig &&
          other.tokenizationEnabled == tokenizationEnabled &&
          other.transfersEnabled == transfersEnabled;

  @override
  int get hashCode => Object.hash(tokenizationEnabled, transfersEnabled);
}

class TokenizePrediction extends Call {
  const TokenizePrediction({
    required this.predictionId,
    required this.metadataUri,
    required this.transferable,
  });

  factory TokenizePrediction._decode(_i1.Input input) {
    return TokenizePrediction(
      predictionId: _i1.U64Codec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
      transferable: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// Vec<u8>
  final List<int> metadataUri;

  /// bool
  final bool transferable;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'tokenize_prediction': {
      'predictionId': predictionId,
      'metadataUri': metadataUri,
      'transferable': transferable,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(predictionId);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(metadataUri);
    size = size + _i1.BoolCodec.codec.sizeHint(transferable);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(8, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U8SequenceCodec.codec.encodeTo(metadataUri, output);
    _i1.BoolCodec.codec.encodeTo(transferable, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenizePrediction &&
          other.predictionId == predictionId &&
          _i10.listsEqual(other.metadataUri, metadataUri) &&
          other.transferable == transferable;

  @override
  int get hashCode => Object.hash(predictionId, metadataUri, transferable);
}

class ApprovePredictionTokenTransfer extends Call {
  const ApprovePredictionTokenTransfer({
    required this.tokenId,
    required this.approved,
  });

  factory ApprovePredictionTokenTransfer._decode(_i1.Input input) {
    return ApprovePredictionTokenTransfer(
      tokenId: _i1.U64Codec.codec.decode(input),
      approved: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i5.AccountId32 approved;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'approve_prediction_token_transfer': {
      'tokenId': tokenId,
      'approved': approved.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i5.AccountId32Codec().sizeHint(approved);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(9, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(approved, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovePredictionTokenTransfer &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.approved, approved);

  @override
  int get hashCode => Object.hash(tokenId, approved);
}

class RevokePredictionTokenApproval extends Call {
  const RevokePredictionTokenApproval({required this.tokenId});

  factory RevokePredictionTokenApproval._decode(_i1.Input input) {
    return RevokePredictionTokenApproval(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'revoke_prediction_token_approval': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevokePredictionTokenApproval && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class TransferPredictionToken extends Call {
  const TransferPredictionToken({required this.tokenId, required this.to});

  factory TransferPredictionToken._decode(_i1.Input input) {
    return TransferPredictionToken(
      tokenId: _i1.U64Codec.codec.decode(input),
      to: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// T::AccountId
  final _i5.AccountId32 to;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'transfer_prediction_token': {'tokenId': tokenId, 'to': to.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + const _i5.AccountId32Codec().sizeHint(to);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(to, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferPredictionToken &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.to, to);

  @override
  int get hashCode => Object.hash(tokenId, to);
}

class FreezePredictionToken extends Call {
  const FreezePredictionToken({required this.tokenId});

  factory FreezePredictionToken._decode(_i1.Input input) {
    return FreezePredictionToken(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'freeze_prediction_token': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(12, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreezePredictionToken && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class UnfreezePredictionToken extends Call {
  const UnfreezePredictionToken({required this.tokenId});

  factory UnfreezePredictionToken._decode(_i1.Input input) {
    return UnfreezePredictionToken(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'unfreeze_prediction_token': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(13, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnfreezePredictionToken && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class BurnPredictionToken extends Call {
  const BurnPredictionToken({required this.tokenId});

  factory BurnPredictionToken._decode(_i1.Input input) {
    return BurnPredictionToken(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'burn_prediction_token': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(14, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BurnPredictionToken && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class UpdatePredictionTokenMetadata extends Call {
  const UpdatePredictionTokenMetadata({
    required this.tokenId,
    required this.metadataUri,
  });

  factory UpdatePredictionTokenMetadata._decode(_i1.Input input) {
    return UpdatePredictionTokenMetadata(
      tokenId: _i1.U64Codec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// Vec<u8>
  final List<int> metadataUri;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'update_prediction_token_metadata': {
      'tokenId': tokenId,
      'metadataUri': metadataUri,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(metadataUri);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(15, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i1.U8SequenceCodec.codec.encodeTo(metadataUri, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePredictionTokenMetadata &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.metadataUri, metadataUri);

  @override
  int get hashCode => Object.hash(tokenId, metadataUri);
}

class SetStakingConfig extends Call {
  const SetStakingConfig({
    required this.stakingEnabled,
    required this.minStake,
  });

  factory SetStakingConfig._decode(_i1.Input input) {
    return SetStakingConfig(
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
    'set_staking_config': {
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
    _i1.U8Codec.codec.encodeTo(16, output);
    _i1.BoolCodec.codec.encodeTo(stakingEnabled, output);
    _i1.U128Codec.codec.encodeTo(minStake, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetStakingConfig &&
          other.stakingEnabled == stakingEnabled &&
          other.minStake == minStake;

  @override
  int get hashCode => Object.hash(stakingEnabled, minStake);
}

class StakeOnPredictionToken extends Call {
  const StakeOnPredictionToken({required this.tokenId, required this.amount});

  factory StakeOnPredictionToken._decode(_i1.Input input) {
    return StakeOnPredictionToken(
      tokenId: _i1.U64Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'stake_on_prediction_token': {'tokenId': tokenId, 'amount': amount},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(17, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeOnPredictionToken &&
          other.tokenId == tokenId &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(tokenId, amount);
}

class UnstakePredictionToken extends Call {
  const UnstakePredictionToken({required this.tokenId, required this.amount});

  factory UnstakePredictionToken._decode(_i1.Input input) {
    return UnstakePredictionToken(
      tokenId: _i1.U64Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'unstake_prediction_token': {'tokenId': tokenId, 'amount': amount},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(18, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnstakePredictionToken &&
          other.tokenId == tokenId &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(tokenId, amount);
}

class LockPredictionTokenStake extends Call {
  const LockPredictionTokenStake({required this.tokenId});

  factory LockPredictionTokenStake._decode(_i1.Input input) {
    return LockPredictionTokenStake(tokenId: _i1.U64Codec.codec.decode(input));
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'lock_prediction_token_stake': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(19, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockPredictionTokenStake && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class ReleasePredictionTokenStake extends Call {
  const ReleasePredictionTokenStake({required this.tokenId});

  factory ReleasePredictionTokenStake._decode(_i1.Input input) {
    return ReleasePredictionTokenStake(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'release_prediction_token_stake': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(20, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReleasePredictionTokenStake && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class SetSettlementConfig extends Call {
  const SetSettlementConfig({
    required this.settlementEnabled,
    required this.disputeWindowBlocks,
    required this.minDisputeBond,
  });

  factory SetSettlementConfig._decode(_i1.Input input) {
    return SetSettlementConfig(
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
    'set_settlement_config': {
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
    _i1.U8Codec.codec.encodeTo(21, output);
    _i1.BoolCodec.codec.encodeTo(settlementEnabled, output);
    _i1.U32Codec.codec.encodeTo(disputeWindowBlocks, output);
    _i1.U128Codec.codec.encodeTo(minDisputeBond, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetSettlementConfig &&
          other.settlementEnabled == settlementEnabled &&
          other.disputeWindowBlocks == disputeWindowBlocks &&
          other.minDisputeBond == minDisputeBond;

  @override
  int get hashCode =>
      Object.hash(settlementEnabled, disputeWindowBlocks, minDisputeBond);
}

class ProposePredictionOutcome extends Call {
  const ProposePredictionOutcome({
    required this.tokenId,
    required this.proposedOutcome,
    required this.evidenceUri,
  });

  factory ProposePredictionOutcome._decode(_i1.Input input) {
    return ProposePredictionOutcome(
      tokenId: _i1.U64Codec.codec.decode(input),
      proposedOutcome: _i6.SettlementOutcome.codec.decode(input),
      evidenceUri: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// SettlementOutcome
  final _i6.SettlementOutcome proposedOutcome;

  /// Vec<u8>
  final List<int> evidenceUri;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'propose_prediction_outcome': {
      'tokenId': tokenId,
      'proposedOutcome': proposedOutcome.toJson(),
      'evidenceUri': evidenceUri,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i6.SettlementOutcome.codec.sizeHint(proposedOutcome);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(evidenceUri);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(22, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i6.SettlementOutcome.codec.encodeTo(proposedOutcome, output);
    _i1.U8SequenceCodec.codec.encodeTo(evidenceUri, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposePredictionOutcome &&
          other.tokenId == tokenId &&
          other.proposedOutcome == proposedOutcome &&
          _i10.listsEqual(other.evidenceUri, evidenceUri);

  @override
  int get hashCode => Object.hash(tokenId, proposedOutcome, evidenceUri);
}

class DisputePredictionOutcome extends Call {
  const DisputePredictionOutcome({
    required this.tokenId,
    required this.reason,
    required this.evidenceUri,
    required this.bond,
  });

  factory DisputePredictionOutcome._decode(_i1.Input input) {
    return DisputePredictionOutcome(
      tokenId: _i1.U64Codec.codec.decode(input),
      reason: _i7.DisputeReason.codec.decode(input),
      evidenceUri: _i1.U8SequenceCodec.codec.decode(input),
      bond: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// DisputeReason
  final _i7.DisputeReason reason;

  /// Vec<u8>
  final List<int> evidenceUri;

  /// BalanceOf<T>
  final BigInt bond;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'dispute_prediction_outcome': {
      'tokenId': tokenId,
      'reason': reason.toJson(),
      'evidenceUri': evidenceUri,
      'bond': bond,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i7.DisputeReason.codec.sizeHint(reason);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(evidenceUri);
    size = size + _i1.U128Codec.codec.sizeHint(bond);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(23, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i7.DisputeReason.codec.encodeTo(reason, output);
    _i1.U8SequenceCodec.codec.encodeTo(evidenceUri, output);
    _i1.U128Codec.codec.encodeTo(bond, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisputePredictionOutcome &&
          other.tokenId == tokenId &&
          other.reason == reason &&
          _i10.listsEqual(other.evidenceUri, evidenceUri) &&
          other.bond == bond;

  @override
  int get hashCode => Object.hash(tokenId, reason, evidenceUri, bond);
}

class AdminFinalizePredictionOutcome extends Call {
  const AdminFinalizePredictionOutcome({
    required this.tokenId,
    required this.finalOutcome,
    required this.evidenceUri,
  });

  factory AdminFinalizePredictionOutcome._decode(_i1.Input input) {
    return AdminFinalizePredictionOutcome(
      tokenId: _i1.U64Codec.codec.decode(input),
      finalOutcome: _i6.SettlementOutcome.codec.decode(input),
      evidenceUri: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// SettlementOutcome
  final _i6.SettlementOutcome finalOutcome;

  /// Vec<u8>
  final List<int> evidenceUri;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'admin_finalize_prediction_outcome': {
      'tokenId': tokenId,
      'finalOutcome': finalOutcome.toJson(),
      'evidenceUri': evidenceUri,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i6.SettlementOutcome.codec.sizeHint(finalOutcome);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(evidenceUri);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(24, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i6.SettlementOutcome.codec.encodeTo(finalOutcome, output);
    _i1.U8SequenceCodec.codec.encodeTo(evidenceUri, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminFinalizePredictionOutcome &&
          other.tokenId == tokenId &&
          other.finalOutcome == finalOutcome &&
          _i10.listsEqual(other.evidenceUri, evidenceUri);

  @override
  int get hashCode => Object.hash(tokenId, finalOutcome, evidenceUri);
}

class FinalizePredictionOutcomeAfterDisputeWindow extends Call {
  const FinalizePredictionOutcomeAfterDisputeWindow({required this.tokenId});

  factory FinalizePredictionOutcomeAfterDisputeWindow._decode(_i1.Input input) {
    return FinalizePredictionOutcomeAfterDisputeWindow(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'finalize_prediction_outcome_after_dispute_window': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(25, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinalizePredictionOutcomeAfterDisputeWindow &&
          other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class CancelPredictionSettlement extends Call {
  const CancelPredictionSettlement({
    required this.tokenId,
    required this.evidenceUri,
  });

  factory CancelPredictionSettlement._decode(_i1.Input input) {
    return CancelPredictionSettlement(
      tokenId: _i1.U64Codec.codec.decode(input),
      evidenceUri: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// Vec<u8>
  final List<int> evidenceUri;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'cancel_prediction_settlement': {
      'tokenId': tokenId,
      'evidenceUri': evidenceUri,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(evidenceUri);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(26, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i1.U8SequenceCodec.codec.encodeTo(evidenceUri, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancelPredictionSettlement &&
          other.tokenId == tokenId &&
          _i10.listsEqual(other.evidenceUri, evidenceUri);

  @override
  int get hashCode => Object.hash(tokenId, evidenceUri);
}

class SetSettlementEconomicsConfig extends Call {
  const SetSettlementEconomicsConfig({
    required this.economicsEnabled,
    required this.slashIncorrect,
    required this.slashFraudulent,
  });

  factory SetSettlementEconomicsConfig._decode(_i1.Input input) {
    return SetSettlementEconomicsConfig(
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
    'set_settlement_economics_config': {
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
    _i1.U8Codec.codec.encodeTo(27, output);
    _i1.BoolCodec.codec.encodeTo(economicsEnabled, output);
    _i1.BoolCodec.codec.encodeTo(slashIncorrect, output);
    _i1.BoolCodec.codec.encodeTo(slashFraudulent, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetSettlementEconomicsConfig &&
          other.economicsEnabled == economicsEnabled &&
          other.slashIncorrect == slashIncorrect &&
          other.slashFraudulent == slashFraudulent;

  @override
  int get hashCode =>
      Object.hash(economicsEnabled, slashIncorrect, slashFraudulent);
}

class ClaimPredictionTokenSettlement extends Call {
  const ClaimPredictionTokenSettlement({required this.tokenId});

  factory ClaimPredictionTokenSettlement._decode(_i1.Input input) {
    return ClaimPredictionTokenSettlement(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'claim_prediction_token_settlement': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(28, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimPredictionTokenSettlement && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class ResolvePredictionDisputeBond extends Call {
  const ResolvePredictionDisputeBond({
    required this.disputeId,
    required this.accepted,
  });

  factory ResolvePredictionDisputeBond._decode(_i1.Input input) {
    return ResolvePredictionDisputeBond(
      disputeId: _i1.U64Codec.codec.decode(input),
      accepted: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// DisputeId
  final BigInt disputeId;

  /// bool
  final bool accepted;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'resolve_prediction_dispute_bond': {
      'disputeId': disputeId,
      'accepted': accepted,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(disputeId);
    size = size + _i1.BoolCodec.codec.sizeHint(accepted);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(29, output);
    _i1.U64Codec.codec.encodeTo(disputeId, output);
    _i1.BoolCodec.codec.encodeTo(accepted, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvePredictionDisputeBond &&
          other.disputeId == disputeId &&
          other.accepted == accepted;

  @override
  int get hashCode => Object.hash(disputeId, accepted);
}

class SetMarketEconomicsConfig extends Call {
  const SetMarketEconomicsConfig({
    required this.marketEnabled,
    required this.allowUnstakeBeforeSettlement,
  });

  factory SetMarketEconomicsConfig._decode(_i1.Input input) {
    return SetMarketEconomicsConfig(
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
    'set_market_economics_config': {
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
    _i1.U8Codec.codec.encodeTo(30, output);
    _i1.BoolCodec.codec.encodeTo(marketEnabled, output);
    _i1.BoolCodec.codec.encodeTo(allowUnstakeBeforeSettlement, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetMarketEconomicsConfig &&
          other.marketEnabled == marketEnabled &&
          other.allowUnstakeBeforeSettlement == allowUnstakeBeforeSettlement;

  @override
  int get hashCode => Object.hash(marketEnabled, allowUnstakeBeforeSettlement);
}

class StakeOnPredictionOutcomeSide extends Call {
  const StakeOnPredictionOutcomeSide({
    required this.tokenId,
    required this.side,
    required this.amount,
  });

  factory StakeOnPredictionOutcomeSide._decode(_i1.Input input) {
    return StakeOnPredictionOutcomeSide(
      tokenId: _i1.U64Codec.codec.decode(input),
      side: _i8.PredictionOutcomeSide.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// PredictionOutcomeSide
  final _i8.PredictionOutcomeSide side;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'stake_on_prediction_outcome_side': {
      'tokenId': tokenId,
      'side': side.toJson(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i8.PredictionOutcomeSide.codec.sizeHint(side);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(31, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i8.PredictionOutcomeSide.codec.encodeTo(side, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeOnPredictionOutcomeSide &&
          other.tokenId == tokenId &&
          other.side == side &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(tokenId, side, amount);
}

class UnstakeFromPredictionOutcomeSide extends Call {
  const UnstakeFromPredictionOutcomeSide({
    required this.tokenId,
    required this.side,
    required this.amount,
  });

  factory UnstakeFromPredictionOutcomeSide._decode(_i1.Input input) {
    return UnstakeFromPredictionOutcomeSide(
      tokenId: _i1.U64Codec.codec.decode(input),
      side: _i8.PredictionOutcomeSide.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  /// PredictionOutcomeSide
  final _i8.PredictionOutcomeSide side;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'unstake_from_prediction_outcome_side': {
      'tokenId': tokenId,
      'side': side.toJson(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    size = size + _i8.PredictionOutcomeSide.codec.sizeHint(side);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(32, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
    _i8.PredictionOutcomeSide.codec.encodeTo(side, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnstakeFromPredictionOutcomeSide &&
          other.tokenId == tokenId &&
          other.side == side &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(tokenId, side, amount);
}

class ClaimPredictionMarketPayout extends Call {
  const ClaimPredictionMarketPayout({required this.tokenId});

  factory ClaimPredictionMarketPayout._decode(_i1.Input input) {
    return ClaimPredictionMarketPayout(
      tokenId: _i1.U64Codec.codec.decode(input),
    );
  }

  /// PredictionTokenId
  final BigInt tokenId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'claim_prediction_market_payout': {'tokenId': tokenId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(tokenId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(33, output);
    _i1.U64Codec.codec.encodeTo(tokenId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimPredictionMarketPayout && other.tokenId == tokenId;

  @override
  int get hashCode => tokenId.hashCode;
}

class SetMarketFeeConfig extends Call {
  const SetMarketFeeConfig({
    required this.feesEnabled,
    required this.feeBps,
    required this.treasuryEnabled,
  });

  factory SetMarketFeeConfig._decode(_i1.Input input) {
    return SetMarketFeeConfig(
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
    'set_market_fee_config': {
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
    _i1.U8Codec.codec.encodeTo(34, output);
    _i1.BoolCodec.codec.encodeTo(feesEnabled, output);
    _i1.U16Codec.codec.encodeTo(feeBps, output);
    _i1.BoolCodec.codec.encodeTo(treasuryEnabled, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetMarketFeeConfig &&
          other.feesEnabled == feesEnabled &&
          other.feeBps == feeBps &&
          other.treasuryEnabled == treasuryEnabled;

  @override
  int get hashCode => Object.hash(feesEnabled, feeBps, treasuryEnabled);
}

class SetModelOnboardingConfig extends Call {
  const SetModelOnboardingConfig({required this.config});

  factory SetModelOnboardingConfig._decode(_i1.Input input) {
    return SetModelOnboardingConfig(
      config: _i9.ModelOnboardingSettings.codec.decode(input),
    );
  }

  /// ModelOnboardingSettings
  final _i9.ModelOnboardingSettings config;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'set_model_onboarding_config': {'config': config.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i9.ModelOnboardingSettings.codec.sizeHint(config);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(35, output);
    _i9.ModelOnboardingSettings.codec.encodeTo(config, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetModelOnboardingConfig && other.config == config;

  @override
  int get hashCode => config.hashCode;
}

class ApproveModel extends Call {
  const ApproveModel({required this.modelId});

  factory ApproveModel._decode(_i1.Input input) {
    return ApproveModel(modelId: _i1.U64Codec.codec.decode(input));
  }

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'approve_model': {'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(36, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApproveModel && other.modelId == modelId;

  @override
  int get hashCode => modelId.hashCode;
}

class SuspendModel extends Call {
  const SuspendModel({required this.modelId});

  factory SuspendModel._decode(_i1.Input input) {
    return SuspendModel(modelId: _i1.U64Codec.codec.decode(input));
  }

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'suspend_model': {'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(37, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuspendModel && other.modelId == modelId;

  @override
  int get hashCode => modelId.hashCode;
}

class RejectModel extends Call {
  const RejectModel({required this.modelId});

  factory RejectModel._decode(_i1.Input input) {
    return RejectModel(modelId: _i1.U64Codec.codec.decode(input));
  }

  /// ModelId
  final BigInt modelId;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'reject_model': {'modelId': modelId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(38, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RejectModel && other.modelId == modelId;

  @override
  int get hashCode => modelId.hashCode;
}

class SetModelSubmitter extends Call {
  const SetModelSubmitter({required this.modelId, this.submitter});

  factory SetModelSubmitter._decode(_i1.Input input) {
    return SetModelSubmitter(
      modelId: _i1.U64Codec.codec.decode(input),
      submitter: const _i1.OptionCodec<_i5.AccountId32>(
        _i5.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// Option<T::AccountId>
  final _i5.AccountId32? submitter;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'set_model_submitter': {
      'modelId': modelId,
      'submitter': submitter?.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size =
        size +
        const _i1.OptionCodec<_i5.AccountId32>(
          _i5.AccountId32Codec(),
        ).sizeHint(submitter);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(39, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.OptionCodec<_i5.AccountId32>(
      _i5.AccountId32Codec(),
    ).encodeTo(submitter, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetModelSubmitter &&
          other.modelId == modelId &&
          other.submitter == submitter;

  @override
  int get hashCode => Object.hash(modelId, submitter);
}

/// Explicit fraud finding; ordinary unsuccessful disputes are refunded by call29.
class AdjudicatePredictionDisputeBond extends Call {
  const AdjudicatePredictionDisputeBond({
    required this.disputeId,
    required this.accepted,
    required this.fraudulent,
    required this.evidenceHash,
  });

  factory AdjudicatePredictionDisputeBond._decode(_i1.Input input) {
    return AdjudicatePredictionDisputeBond(
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
    'adjudicate_prediction_dispute_bond': {
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
    _i1.U8Codec.codec.encodeTo(40, output);
    _i1.U64Codec.codec.encodeTo(disputeId, output);
    _i1.BoolCodec.codec.encodeTo(accepted, output);
    _i1.BoolCodec.codec.encodeTo(fraudulent, output);
    const _i1.U8ArrayCodec(32).encodeTo(evidenceHash, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdjudicatePredictionDisputeBond &&
          other.disputeId == disputeId &&
          other.accepted == accepted &&
          other.fraudulent == fraudulent &&
          _i10.listsEqual(other.evidenceHash, evidenceHash);

  @override
  int get hashCode =>
      Object.hash(disputeId, accepted, fraudulent, evidenceHash);
}

/// The existing prediction hash commits canonical model/version/input/horizon/terms.
/// A duplicate exact business request succeeds without a second prediction.
class SubmitEvaluation extends Call {
  const SubmitEvaluation({
    required this.modelId,
    required this.requestId,
    required this.artifact,
    required this.predictionHash,
    required this.metadataUri,
    required this.confidence,
    required this.expiresAt,
    required this.cutoffUtc,
    required this.evidenceAfterUtc,
  });

  factory SubmitEvaluation._decode(_i1.Input input) {
    return SubmitEvaluation(
      modelId: _i1.U64Codec.codec.decode(input),
      requestId: const _i1.U8ArrayCodec(32).decode(input),
      artifact: const _i1.U8ArrayCodec(32).decode(input),
      predictionHash: const _i1.U8ArrayCodec(32).decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
      confidence: _i1.U8Codec.codec.decode(input),
      expiresAt: _i1.U32Codec.codec.decode(input),
      cutoffUtc: _i1.U64Codec.codec.decode(input),
      evidenceAfterUtc: _i1.U64Codec.codec.decode(input),
    );
  }

  /// ModelId
  final BigInt modelId;

  /// [u8; 32]
  final List<int> requestId;

  /// [u8; 32]
  final List<int> artifact;

  /// [u8; 32]
  final List<int> predictionHash;

  /// Vec<u8>
  final List<int> metadataUri;

  /// u8
  final int confidence;

  /// BlockNumberFor<T>
  final int expiresAt;

  /// u64
  final BigInt cutoffUtc;

  /// u64
  final BigInt evidenceAfterUtc;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'submit_evaluation': {
      'modelId': modelId,
      'requestId': requestId.toList(),
      'artifact': artifact.toList(),
      'predictionHash': predictionHash.toList(),
      'metadataUri': metadataUri,
      'confidence': confidence,
      'expiresAt': expiresAt,
      'cutoffUtc': cutoffUtc,
      'evidenceAfterUtc': evidenceAfterUtc,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U64Codec.codec.sizeHint(modelId);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(requestId);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(artifact);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(predictionHash);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(metadataUri);
    size = size + _i1.U8Codec.codec.sizeHint(confidence);
    size = size + _i1.U32Codec.codec.sizeHint(expiresAt);
    size = size + _i1.U64Codec.codec.sizeHint(cutoffUtc);
    size = size + _i1.U64Codec.codec.sizeHint(evidenceAfterUtc);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(41, output);
    _i1.U64Codec.codec.encodeTo(modelId, output);
    const _i1.U8ArrayCodec(32).encodeTo(requestId, output);
    const _i1.U8ArrayCodec(32).encodeTo(artifact, output);
    const _i1.U8ArrayCodec(32).encodeTo(predictionHash, output);
    _i1.U8SequenceCodec.codec.encodeTo(metadataUri, output);
    _i1.U8Codec.codec.encodeTo(confidence, output);
    _i1.U32Codec.codec.encodeTo(expiresAt, output);
    _i1.U64Codec.codec.encodeTo(cutoffUtc, output);
    _i1.U64Codec.codec.encodeTo(evidenceAfterUtc, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitEvaluation &&
          other.modelId == modelId &&
          _i10.listsEqual(other.requestId, requestId) &&
          _i10.listsEqual(other.artifact, artifact) &&
          _i10.listsEqual(other.predictionHash, predictionHash) &&
          _i10.listsEqual(other.metadataUri, metadataUri) &&
          other.confidence == confidence &&
          other.expiresAt == expiresAt &&
          other.cutoffUtc == cutoffUtc &&
          other.evidenceAfterUtc == evidenceAfterUtc;

  @override
  int get hashCode => Object.hash(
    modelId,
    requestId,
    artifact,
    predictionHash,
    metadataUri,
    confidence,
    expiresAt,
    cutoffUtc,
    evidenceAfterUtc,
  );
}

/// Authorized independent account publishes evidence; corrections append, never erase.
class RecordEvaluationEvidence extends Call {
  const RecordEvaluationEvidence({
    required this.predictionId,
    required this.revision,
    required this.evidence,
    required this.outcome,
  });

  factory RecordEvaluationEvidence._decode(_i1.Input input) {
    return RecordEvaluationEvidence(
      predictionId: _i1.U64Codec.codec.decode(input),
      revision: _i1.U32Codec.codec.decode(input),
      evidence: const _i1.U8ArrayCodec(32).decode(input),
      outcome: _i4.PredictionOutcome.codec.decode(input),
    );
  }

  /// PredictionId
  final BigInt predictionId;

  /// u32
  final int revision;

  /// [u8; 32]
  final List<int> evidence;

  /// PredictionOutcome
  final _i4.PredictionOutcome outcome;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'record_evaluation_evidence': {
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
    size = size + _i4.PredictionOutcome.codec.sizeHint(outcome);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(42, output);
    _i1.U64Codec.codec.encodeTo(predictionId, output);
    _i1.U32Codec.codec.encodeTo(revision, output);
    const _i1.U8ArrayCodec(32).encodeTo(evidence, output);
    _i4.PredictionOutcome.codec.encodeTo(outcome, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordEvaluationEvidence &&
          other.predictionId == predictionId &&
          other.revision == revision &&
          _i10.listsEqual(other.evidence, evidence) &&
          other.outcome == outcome;

  @override
  int get hashCode => Object.hash(predictionId, revision, evidence, outcome);
}
