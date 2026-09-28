import '../generated/era/era.dart' as era_api;
import '../generated/era/types/era_runtime/runtime_call.dart' as runtime_call;
import '../generated/era/types/pallet_ai_predictions/prediction_domain.dart';
import '../generated/era/types/pallet_ai_predictions/prediction_outcome.dart';
import '../generated/era/types/pallet_ai_predictions/prediction_outcome_side.dart';
import '../generated/era/types/pallet_ai_predictions/settlement_outcome.dart';
import 'phase6b_data.dart';
import 'phase6b_validation.dart';

enum Phase6bActionAudience { participant, testingOperator, governance }

class Phase6bCallIntent {
  final String callName;
  final int callIndex;
  final runtime_call.RuntimeCall call;
  final Map<String, Object?> arguments;
  final Phase6bActionAudience audience;
  final String expectedAuthorization;
  final String? typedConfirmation;

  const Phase6bCallIntent({
    required this.callName,
    required this.callIndex,
    required this.call,
    required this.arguments,
    required this.audience,
    required this.expectedAuthorization,
    required this.typedConfirmation,
  });

  String get callPath => 'AiPredictions.$callName';
  bool get highImpact => typedConfirmation != null;

  List<int> get encodedCall => call.encode();

  void validateEncoding() {
    final encoded = encodedCall;
    if (encoded.length < 2 || encoded[0] != 12 || encoded[1] != callIndex) {
      throw StateError(
        'Generated binding mismatch for $callPath: expected pallet/call '
        '[12, $callIndex].',
      );
    }
  }
}

class Phase6bActionAssessment {
  final bool visible;
  final bool enabled;
  final bool originEligibilityIsInformational;
  final List<String> reasons;

  const Phase6bActionAssessment({
    required this.visible,
    required this.enabled,
    required this.originEligibilityIsInformational,
    required this.reasons,
  });
}

class Phase6bActionPolicy {
  static Phase6bActionAssessment assess({
    required Phase6bCallIntent intent,
    required bool runtimeCompatible,
    required bool testingToolsEnabled,
    required bool governanceActionsEnabled,
    required bool accountSelected,
    bool stateAllowsAction = true,
    String? stateReason,
  }) {
    final visible = switch (intent.audience) {
      Phase6bActionAudience.participant => true,
      Phase6bActionAudience.testingOperator => testingToolsEnabled,
      Phase6bActionAudience.governance =>
        testingToolsEnabled && governanceActionsEnabled,
    };
    final reasons = <String>[];
    if (!runtimeCompatible) {
      reasons.add('Runtime metadata does not match the approved bindings.');
    }
    if (!accountSelected) reasons.add('Select a signing account.');
    if (!stateAllowsAction) {
      reasons.add(stateReason ?? 'The current chain state blocks this action.');
    }
    if (!visible) {
      reasons.add(
        intent.audience == Phase6bActionAudience.governance
            ? 'Governance actions are disabled in this build.'
            : 'Phase 6B testing tools are disabled in this build.',
      );
    }
    return Phase6bActionAssessment(
      visible: visible,
      enabled: visible && reasons.isEmpty,
      originEligibilityIsInformational:
          intent.audience != Phase6bActionAudience.participant,
      reasons: reasons,
    );
  }
}

class Phase6bCallFactory {
  final era_api.Era api;

  const Phase6bCallFactory(this.api);

  Phase6bCallIntent registerModel({
    required List<int> modelHash,
    required List<int> metadataUri,
  }) => _intent(
    name: 'register_model',
    index: 0,
    call: api.tx.aiPredictions.registerModel(
      modelHash: modelHash,
      metadataUri: metadataUri,
    ),
    arguments: {
      'model_hash': _hex(modelHash),
      'metadata_uri': _textOrHex(metadataUri),
    },
    audience: Phase6bActionAudience.testingOperator,
    authorization:
        'Signed registration subject to ModelOnboardingConfig; the chain '
        'is authoritative about whether public registration is permitted.',
  );

  Phase6bCallIntent approveModel(BigInt modelId) => _governanceModelIntent(
    name: 'approve_model',
    index: 36,
    modelId: modelId,
    call: api.tx.aiPredictions.approveModel(modelId: modelId),
  );

  Phase6bCallIntent suspendModel(BigInt modelId) => _governanceModelIntent(
    name: 'suspend_model',
    index: 37,
    modelId: modelId,
    call: api.tx.aiPredictions.suspendModel(modelId: modelId),
  );

  Phase6bCallIntent rejectModel(BigInt modelId) => _governanceModelIntent(
    name: 'reject_model',
    index: 38,
    modelId: modelId,
    call: api.tx.aiPredictions.rejectModel(modelId: modelId),
  );

  Phase6bCallIntent setModelSubmitter({
    required BigInt modelId,
    required List<int>? submitter,
  }) => _intent(
    name: 'set_model_submitter',
    index: 39,
    call: api.tx.aiPredictions.setModelSubmitter(
      modelId: modelId,
      submitter: submitter,
    ),
    arguments: {
      'model_id': modelId.toString(),
      'submitter': submitter == null ? null : _hex(submitter),
    },
    audience: Phase6bActionAudience.governance,
    authorization:
        'Model administration origin; eligibility remains informational '
        'until the live chain accepts the dispatch.',
    confirmation: 'I understand this changes live model governance state.',
  );

  Phase6bCallIntent submitPrediction({
    required BigInt modelId,
    required PredictionDomain domain,
    required List<int> categoryCode,
    required List<int> predictionHash,
    required List<int> metadataUri,
    required int confidence,
    required int expiresAt,
  }) => _intent(
    name: 'submit_prediction',
    index: 2,
    call: api.tx.aiPredictions.submitPrediction(
      modelId: modelId,
      domain: domain,
      categoryCode: categoryCode,
      predictionHash: predictionHash,
      metadataUri: metadataUri,
      confidence: confidence,
      expiresAt: expiresAt,
    ),
    arguments: {
      'model_id': modelId.toString(),
      'domain': domain.variantName,
      'category_code': _textOrHex(categoryCode),
      'prediction_hash': _hex(predictionHash),
      'metadata_uri': _textOrHex(metadataUri),
      'confidence': confidence,
      'expires_at': expiresAt,
    },
    audience: Phase6bActionAudience.testingOperator,
    authorization:
        'Signed by the approved model owner or the chain-derived '
        'authorized submitter.',
  );

  Phase6bCallIntent tokenizePrediction({
    required BigInt predictionId,
    required List<int> metadataUri,
    required bool transferable,
  }) => _intent(
    name: 'tokenize_prediction',
    index: 8,
    call: api.tx.aiPredictions.tokenizePrediction(
      predictionId: predictionId,
      metadataUri: metadataUri,
      transferable: transferable,
    ),
    arguments: {
      'prediction_id': predictionId.toString(),
      'metadata_uri': _textOrHex(metadataUri),
      'transferable': transferable,
    },
    audience: Phase6bActionAudience.testingOperator,
    authorization:
        'Signed prediction owner and enabled market/tokenization config.',
  );

  Phase6bCallIntent validatePrediction({
    required BigInt predictionId,
    required PredictionOutcome outcome,
  }) => _intent(
    name: 'validate_prediction',
    index: 3,
    call: api.tx.aiPredictions.validatePrediction(
      predictionId: predictionId,
      outcome: outcome,
    ),
    arguments: {
      'prediction_id': predictionId.toString(),
      'outcome': outcome.variantName,
    },
    audience: Phase6bActionAudience.testingOperator,
    authorization: 'Signed account present in AuthorizedValidators.',
    confirmation: 'I understand this validates a live prediction.',
  );

  Phase6bCallIntent closePrediction(BigInt predictionId) => _intent(
    name: 'close_prediction',
    index: 4,
    call: api.tx.aiPredictions.closePrediction(predictionId: predictionId),
    arguments: {'prediction_id': predictionId.toString()},
    audience: Phase6bActionAudience.testingOperator,
    authorization: 'Authorized prediction lifecycle signer.',
    confirmation: 'I understand this closes a live prediction.',
  );

  Phase6bCallIntent stake({
    required BigInt tokenId,
    required PredictionOutcomeSide side,
    required BigInt amount,
  }) => _intent(
    name: 'stake_on_prediction_outcome_side',
    index: 31,
    call: api.tx.aiPredictions.stakeOnPredictionOutcomeSide(
      tokenId: tokenId,
      side: side,
      amount: amount,
    ),
    arguments: {
      'token_id': tokenId.toString(),
      'side': side.variantName,
      'amount': amount.toString(),
    },
    audience: Phase6bActionAudience.participant,
    authorization: 'Any funded signed account while the market is open.',
  );

  Phase6bCallIntent unstake({
    required BigInt tokenId,
    required PredictionOutcomeSide side,
    required BigInt amount,
  }) => _intent(
    name: 'unstake_from_prediction_outcome_side',
    index: 32,
    call: api.tx.aiPredictions.unstakeFromPredictionOutcomeSide(
      tokenId: tokenId,
      side: side,
      amount: amount,
    ),
    arguments: {
      'token_id': tokenId.toString(),
      'side': side.variantName,
      'amount': amount.toString(),
    },
    audience: Phase6bActionAudience.participant,
    authorization:
        'Position owner while chain market config permits unstaking.',
  );

  Phase6bCallIntent proposeOutcome({
    required BigInt tokenId,
    required SettlementOutcome outcome,
    required List<int> evidenceUri,
  }) {
    Phase6bPublicInputSafety.validateEvidenceReference(evidenceUri);
    return _intent(
      name: 'propose_prediction_outcome',
      index: 22,
      call: api.tx.aiPredictions.proposePredictionOutcome(
        tokenId: tokenId,
        proposedOutcome: outcome,
        evidenceUri: evidenceUri,
      ),
      arguments: {
        'token_id': tokenId.toString(),
        'proposed_outcome': outcome.variantName,
        'evidence_uri': _textOrHex(evidenceUri),
      },
      audience: Phase6bActionAudience.testingOperator,
      authorization: 'Authorized settlement proposer.',
      confirmation:
          'I understand this proposes a live market settlement outcome.',
    );
  }

  Phase6bCallIntent finalizeAfterDisputeWindow(BigInt tokenId) => _intent(
    name: 'finalize_prediction_outcome_after_dispute_window',
    index: 25,
    call: api.tx.aiPredictions.finalizePredictionOutcomeAfterDisputeWindow(
      tokenId: tokenId,
    ),
    arguments: {'token_id': tokenId.toString()},
    audience: Phase6bActionAudience.testingOperator,
    authorization:
        'Signed caller after the on-chain dispute window has elapsed.',
    confirmation: 'I understand this finalizes a live market settlement.',
  );

  Phase6bCallIntent adminFinalizeOutcome({
    required BigInt tokenId,
    required SettlementOutcome outcome,
    required List<int> evidenceUri,
  }) {
    Phase6bPublicInputSafety.validateEvidenceReference(evidenceUri);
    return _intent(
      name: 'admin_finalize_prediction_outcome',
      index: 24,
      call: api.tx.aiPredictions.adminFinalizePredictionOutcome(
        tokenId: tokenId,
        finalOutcome: outcome,
        evidenceUri: evidenceUri,
      ),
      arguments: {
        'token_id': tokenId.toString(),
        'final_outcome': outcome.variantName,
        'evidence_uri': _textOrHex(evidenceUri),
      },
      audience: Phase6bActionAudience.governance,
      authorization:
          'Privileged settlement administration origin; the chain is '
          'authoritative.',
      confirmation:
          'I understand this finalizes live settlement governance state.',
    );
  }

  Phase6bCallIntent claim(BigInt tokenId) => _intent(
    name: 'claim_prediction_market_payout',
    index: 33,
    call: api.tx.aiPredictions.claimPredictionMarketPayout(tokenId: tokenId),
    arguments: {'token_id': tokenId.toString()},
    audience: Phase6bActionAudience.participant,
    authorization: 'Winning position owner with an unclaimed payout.',
  );

  Phase6bCallIntent _governanceModelIntent({
    required String name,
    required int index,
    required BigInt modelId,
    required runtime_call.RuntimeCall call,
  }) => _intent(
    name: name,
    index: index,
    call: call,
    arguments: {'model_id': modelId.toString()},
    audience: Phase6bActionAudience.governance,
    authorization:
        'Model administration origin; the wallet does not claim this '
        'account is authorized before dispatch.',
    confirmation: 'I understand this changes live model governance state.',
  );

  Phase6bCallIntent _intent({
    required String name,
    required int index,
    required runtime_call.RuntimeCall call,
    required Map<String, Object?> arguments,
    required Phase6bActionAudience audience,
    required String authorization,
    String? confirmation,
  }) {
    final intent = Phase6bCallIntent(
      callName: name,
      callIndex: index,
      call: call,
      arguments: arguments,
      audience: audience,
      expectedAuthorization: authorization,
      typedConfirmation: confirmation,
    );
    intent.validateEncoding();
    return intent;
  }
}

class Phase6bLifecyclePolicy {
  static bool canTokenize({
    required Phase6bPrediction prediction,
    required Phase6bModel model,
    required Phase6bChainConfiguration config,
    required String signer,
  }) =>
      prediction.isOpen &&
      !prediction.isTokenized &&
      (!config.requireModelApproval || model.isApproved) &&
      model.active &&
      config.marketCreationEnabled &&
      config.tokenizationEnabled &&
      (prediction.submitter == signer || model.owner == signer);

  static bool canStake({
    required Phase6bMarket market,
    required Phase6bChainConfiguration config,
  }) =>
      config.stakingEnabled &&
      config.marketEnabled &&
      !market.frozen &&
      !market.locked &&
      !market.burned &&
      !market.isSettled;

  static bool canUnstake({
    required Phase6bMarket market,
    required Phase6bChainConfiguration config,
    required Phase6bPosition? position,
  }) =>
      canStake(market: market, config: config) &&
      config.allowUnstakeBeforeSettlement &&
      position != null &&
      position.amount > BigInt.zero;

  static bool canClaim({
    required Phase6bMarket market,
    required Phase6bPosition? position,
  }) =>
      market.isSettled &&
      position != null &&
      position.amount > BigInt.zero &&
      !position.claimed &&
      _positionCanClaimOutcome(market.finalOutcome, position.side);

  static bool _positionCanClaimOutcome(String? outcome, String side) =>
      switch (outcome) {
        'Correct' => side == 'Yes',
        'Incorrect' || 'Fraudulent' => side == 'No',
        'Inconclusive' || 'Cancelled' => true,
        _ => false,
      };
}

/// Fail-closed policy applied to canonical state re-read after authentication.
///
/// Origin checks whose exact runtime rule is not represented in storage remain
/// chain-authoritative. Known configuration, ownership, lifecycle and position
/// requirements are enforced here before any signing operation begins.
abstract final class Phase6bActionPreflight {
  static void ensureAllowed({
    required Phase6bCallIntent intent,
    required Phase6bChainConfiguration configuration,
    required String signer,
    Phase6bModel? model,
    Phase6bPrediction? prediction,
    Phase6bMarket? market,
    Phase6bPosition? position,
    int? currentFinalizedBlock,
  }) {
    final reason = blockingReason(
      intent: intent,
      configuration: configuration,
      signer: signer,
      model: model,
      prediction: prediction,
      market: market,
      position: position,
      currentFinalizedBlock: currentFinalizedBlock,
    );
    if (reason != null) {
      throw StateError(
        'Fresh chain preflight blocked ${intent.callPath}: '
        '$reason',
      );
    }
  }

  static String? blockingReason({
    required Phase6bCallIntent intent,
    required Phase6bChainConfiguration configuration,
    required String signer,
    Phase6bModel? model,
    Phase6bPrediction? prediction,
    Phase6bMarket? market,
    Phase6bPosition? position,
    int? currentFinalizedBlock,
  }) => switch (intent.callName) {
    'register_model' => _registration(configuration),
    'approve_model' ||
    'suspend_model' ||
    'reject_model' ||
    'set_model_submitter' => _governanceModel(intent, model),
    'submit_prediction' => _predictionSubmission(
      intent,
      configuration,
      signer,
      model,
      currentFinalizedBlock,
    ),
    'tokenize_prediction' => _tokenization(
      intent,
      configuration,
      signer,
      model,
      prediction,
    ),
    'validate_prediction' => _validation(
      intent,
      configuration,
      signer,
      prediction,
      currentFinalizedBlock,
    ),
    'close_prediction' => _close(intent, signer, prediction),
    'propose_prediction_outcome' => _proposeSettlement(
      intent,
      configuration,
      market,
    ),
    'finalize_prediction_outcome_after_dispute_window' => _finalizeSettlement(
      intent,
      configuration,
      market,
      currentFinalizedBlock,
    ),
    'admin_finalize_prediction_outcome' => _adminFinalize(
      intent,
      configuration,
      market,
    ),
    'stake_on_prediction_outcome_side' => _stake(intent, configuration, market),
    'unstake_from_prediction_outcome_side' => _unstake(
      intent,
      configuration,
      market,
      position,
    ),
    'claim_prediction_market_payout' => _claim(
      intent,
      configuration,
      market,
      position,
    ),
    _ => null,
  };

  static String? _registration(Phase6bChainConfiguration config) {
    if (!config.modelRegistrationEnabled) {
      return 'model registration is disabled.';
    }
    if (!config.publicModelRegistrationEnabled) {
      return 'public signed model registration is disabled.';
    }
    return null;
  }

  static String? _predictionSubmission(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    String signer,
    Phase6bModel? model,
    int? currentFinalizedBlock,
  ) {
    if (!config.predictionSubmissionEnabled) {
      return 'prediction submission is disabled.';
    }
    if (model == null || model.id != _id(intent, 'model_id')) {
      return 'the selected model no longer exists.';
    }
    if (!model.active) return 'the selected model is inactive.';
    if (config.requireModelApproval && !model.isApproved) {
      return 'the selected model is not approved.';
    }
    if (model.owner != signer && model.authorizedSubmitter != signer) {
      return 'the signer is no longer the model owner or authorized submitter.';
    }
    if (model.activePredictions >= config.maxActivePredictionsPerModel) {
      return 'the model reached its active-prediction limit.';
    }
    final expiresAt = _integer(intent, 'expires_at');
    if (expiresAt == null ||
        expiresAt > PredictionSubmissionInput.maxExpiryBlock) {
      return 'the expiry is outside the runtime u32 range.';
    }
    if (currentFinalizedBlock == null || expiresAt <= currentFinalizedBlock) {
      return 'the expiry is not after the latest finalized block.';
    }
    return null;
  }

  static String? _governanceModel(
    Phase6bCallIntent intent,
    Phase6bModel? model,
  ) {
    if (model == null || model.id != _id(intent, 'model_id')) {
      return 'the target model no longer exists.';
    }
    return switch (intent.callName) {
      'approve_model' when model.isApproved =>
        'the target model is already approved.',
      'approve_model' when model.isRejected =>
        'a rejected model cannot be approved from stale wallet state.',
      'suspend_model' when model.isSuspended =>
        'the target model is already suspended.',
      'suspend_model' when model.isRejected => 'the target model is rejected.',
      'reject_model' when model.isRejected =>
        'the target model is already rejected.',
      'set_model_submitter' when model.isRejected =>
        'the target model is rejected.',
      _ => null,
    };
  }

  static String? _tokenization(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    String signer,
    Phase6bModel? model,
    Phase6bPrediction? prediction,
  ) {
    if (!config.marketCreationEnabled) return 'market creation is disabled.';
    if (!config.tokenizationEnabled) return 'tokenization is disabled.';
    if (prediction == null || prediction.id != _id(intent, 'prediction_id')) {
      return 'the prediction no longer exists.';
    }
    if (model == null || model.id != prediction.modelId) {
      return 'the prediction model no longer exists.';
    }
    if (!Phase6bLifecyclePolicy.canTokenize(
      prediction: prediction,
      model: model,
      config: config,
      signer: signer,
    )) {
      return 'fresh prediction, model, or signer state does not permit tokenization.';
    }
    if (intent.arguments['transferable'] == true && !config.transfersEnabled) {
      return 'transferable tokens are disabled.';
    }
    return null;
  }

  static String? _validation(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    String signer,
    Phase6bPrediction? prediction,
    int? currentFinalizedBlock,
  ) {
    if (!config.isAuthorizedValidator(signer)) {
      return 'the signer is not in AuthorizedValidators.';
    }
    if (prediction == null || prediction.id != _id(intent, 'prediction_id')) {
      return 'the prediction no longer exists.';
    }
    if (!prediction.isOpen) return 'the prediction is no longer open.';
    if (currentFinalizedBlock == null ||
        prediction.expiresAt <= currentFinalizedBlock) {
      return 'the prediction has expired at the latest finalized block.';
    }
    return null;
  }

  static String? _close(
    Phase6bCallIntent intent,
    String signer,
    Phase6bPrediction? prediction,
  ) {
    if (prediction == null || prediction.id != _id(intent, 'prediction_id')) {
      return 'the prediction no longer exists.';
    }
    if (!prediction.isOpen && !prediction.isValidated) {
      return 'the prediction can no longer be closed.';
    }
    if (prediction.submitter != signer) {
      return 'the signer is not the canonical prediction submitter.';
    }
    return null;
  }

  static String? _proposeSettlement(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
  ) {
    final common = _settlementCommon(intent, config, market);
    if (common != null) return common;
    if (market!.settlementStatus != 'NotStarted') {
      return 'settlement has already started.';
    }
    return null;
  }

  static String? _finalizeSettlement(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
    int? currentFinalizedBlock,
  ) {
    final common = _settlementCommon(intent, config, market);
    if (common != null) return common;
    if (!const {
      'OutcomeProposed',
      'DisputeWindowOpen',
    }.contains(market!.settlementStatus)) {
      return 'settlement is not awaiting dispute-window finalization.';
    }
    if (market.disputeUntil == null || currentFinalizedBlock == null) {
      return 'the dispute-window state is unavailable.';
    }
    if (currentFinalizedBlock < market.disputeUntil!) {
      return 'the dispute window is still open.';
    }
    return null;
  }

  static String? _adminFinalize(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
  ) => _settlementCommon(intent, config, market);

  static String? _settlementCommon(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
  ) {
    if (!config.settlementEnabled) return 'settlement is disabled.';
    if (market == null || market.tokenId != _id(intent, 'token_id')) {
      return 'the market no longer exists.';
    }
    if (market.burned) return 'the market token is burned.';
    if (market.isSettled) return 'the market is already settled.';
    return null;
  }

  static String? _stake(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
  ) {
    if (market == null || market.tokenId != _id(intent, 'token_id')) {
      return 'the market no longer exists.';
    }
    if (!Phase6bLifecyclePolicy.canStake(market: market, config: config)) {
      return 'fresh market configuration or state no longer permits staking.';
    }
    final amount = _bigInt(intent, 'amount');
    if (amount == null || amount < config.minimumStake) {
      return 'the amount is below the current minimum stake.';
    }
    return null;
  }

  static String? _unstake(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
    Phase6bPosition? position,
  ) {
    if (market == null || market.tokenId != _id(intent, 'token_id')) {
      return 'the market no longer exists.';
    }
    if (!Phase6bLifecyclePolicy.canUnstake(
      market: market,
      config: config,
      position: position,
    )) {
      return 'fresh market or position state no longer permits unstaking.';
    }
    final amount = _bigInt(intent, 'amount');
    if (amount == null || amount <= BigInt.zero || amount > position!.amount) {
      return 'the unstake amount exceeds the current position.';
    }
    if (intent.arguments['side'] != position.side) {
      return 'the selected side no longer matches the canonical position.';
    }
    return null;
  }

  static String? _claim(
    Phase6bCallIntent intent,
    Phase6bChainConfiguration config,
    Phase6bMarket? market,
    Phase6bPosition? position,
  ) {
    if (!config.marketEnabled) return 'market economics are disabled.';
    if (market == null || market.tokenId != _id(intent, 'token_id')) {
      return 'the market no longer exists.';
    }
    if (!Phase6bLifecyclePolicy.canClaim(market: market, position: position)) {
      return 'fresh settlement or position state is not claimable.';
    }
    return null;
  }

  static BigInt? _id(Phase6bCallIntent intent, String name) =>
      _bigInt(intent, name);

  static BigInt? _bigInt(Phase6bCallIntent intent, String name) {
    final value = intent.arguments[name];
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    return BigInt.tryParse(value?.toString() ?? '');
  }

  static int? _integer(Phase6bCallIntent intent, String name) {
    final value = intent.arguments[name];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

String _hex(List<int> bytes) =>
    '0x${bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join()}';

String _textOrHex(List<int> bytes) =>
    bytes.every((value) => value >= 32 && value <= 126)
    ? String.fromCharCodes(bytes)
    : _hex(bytes);
