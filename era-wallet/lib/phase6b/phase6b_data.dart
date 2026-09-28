import 'dart:convert';
import 'dart:typed_data';

import 'package:polkadart_keyring/polkadart_keyring.dart';

import '../generated/era/era.dart' as era_api;
import '../generated/era/types/pallet_ai_predictions/ai_model.dart'
    as runtime_model;
import '../generated/era/types/pallet_ai_predictions/model_governance.dart'
    as runtime_governance;
import '../generated/era/types/pallet_ai_predictions/model_onboarding_settings.dart'
    as runtime_onboarding;
import '../generated/era/types/pallet_ai_predictions/model_stats.dart'
    as runtime_stats;
import '../generated/era/types/pallet_ai_predictions/prediction.dart'
    as runtime_prediction;
import '../generated/era/types/pallet_ai_predictions/prediction_market_accounting.dart'
    as runtime_accounting;
import '../generated/era/types/pallet_ai_predictions/prediction_market_economics_settings.dart'
    as runtime_market_config;
import '../generated/era/types/pallet_ai_predictions/prediction_outcome_side.dart'
    as runtime_side;
import '../generated/era/types/pallet_ai_predictions/prediction_side_payout_claim.dart'
    as runtime_claim;
import '../generated/era/types/pallet_ai_predictions/prediction_side_stake.dart'
    as runtime_stake;
import '../generated/era/types/pallet_ai_predictions/prediction_token.dart'
    as runtime_token;
import '../generated/era/types/pallet_ai_predictions/prediction_token_settlement.dart'
    as runtime_settlement;
import '../generated/era/types/pallet_ai_predictions/staking_settings.dart'
    as runtime_staking;
import '../generated/era/types/pallet_ai_predictions/settlement_economics_settings.dart'
    as runtime_settlement_economics;
import '../generated/era/types/pallet_ai_predictions/settlement_settings.dart'
    as runtime_settlement_config;
import '../generated/era/types/pallet_ai_predictions/tokenization_settings.dart'
    as runtime_tokenization;

enum Phase6bDataProvenance {
  canonicalStorage,
  finalizedEvent,
  localPending,
  localSupplementary,
}

class Phase6bPage<T> {
  final List<T> items;
  final int offset;
  final int limit;
  final int totalAvailable;
  final int? scannedCount;
  final bool historyComplete;
  final String? limitation;

  const Phase6bPage({
    required this.items,
    required this.offset,
    required this.limit,
    required this.totalAvailable,
    this.scannedCount,
    this.historyComplete = true,
    this.limitation,
  });

  int get coveredCount => scannedCount ?? items.length;

  bool get hasMore => offset + coveredCount < totalAvailable;
}

class Phase6bModel {
  final BigInt id;
  final String owner;
  final String modelHashHex;
  final String metadataReference;
  final int registeredAt;
  final int? updatedAt;
  final bool active;
  final String governanceStatus;
  final String? authorizedSubmitter;
  final int governanceUpdatedAt;
  final BigInt totalPredictions;
  final int activePredictions;
  final List<BigInt> predictionIds;
  final Phase6bDataProvenance provenance;

  const Phase6bModel({
    required this.id,
    required this.owner,
    required this.modelHashHex,
    required this.metadataReference,
    required this.registeredAt,
    required this.updatedAt,
    required this.active,
    required this.governanceStatus,
    required this.authorizedSubmitter,
    required this.governanceUpdatedAt,
    required this.totalPredictions,
    required this.activePredictions,
    required this.predictionIds,
    this.provenance = Phase6bDataProvenance.canonicalStorage,
  });

  bool get isApproved => governanceStatus == 'Approved';
  bool get isSuspended => governanceStatus == 'Suspended';
  bool get isRejected => governanceStatus == 'Rejected';

  bool canSubmit(String address, {bool requireApproval = true}) =>
      active &&
      !isSuspended &&
      !isRejected &&
      (!requireApproval || isApproved) &&
      (owner == address || authorizedSubmitter == address);

  Map<String, Object?> toJson() => {
    'id': id.toString(),
    'owner': owner,
    'modelHash': modelHashHex,
    'metadataReference': metadataReference,
    'registeredAt': registeredAt,
    'updatedAt': updatedAt,
    'active': active,
    'governanceStatus': governanceStatus,
    'authorizedSubmitter': authorizedSubmitter,
    'governanceUpdatedAt': governanceUpdatedAt,
    'totalPredictions': totalPredictions.toString(),
    'activePredictions': activePredictions,
    'predictionIds': predictionIds.map((value) => value.toString()).toList(),
    'provenance': provenance.name,
  };
}

class Phase6bPrediction {
  final BigInt id;
  final BigInt modelId;
  final String submitter;
  final String domain;
  final String categoryCode;
  final String predictionHashHex;
  final String metadataReference;
  final List<int> metadataUriBytes;
  final int confidence;
  final int createdAt;
  final int expiresAt;
  final String status;
  final String? outcome;
  final String? validator;
  final int? validatedAt;
  final BigInt? tokenId;
  final Phase6bDataProvenance provenance;

  const Phase6bPrediction({
    required this.id,
    required this.modelId,
    required this.submitter,
    required this.domain,
    required this.categoryCode,
    required this.predictionHashHex,
    required this.metadataReference,
    required this.metadataUriBytes,
    required this.confidence,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.outcome,
    required this.validator,
    required this.validatedAt,
    required this.tokenId,
    this.provenance = Phase6bDataProvenance.canonicalStorage,
  });

  bool get isOpen => status == 'Open';
  bool get isValidated => status == 'Validated';
  bool get isClosed => status == 'Closed';
  bool get isTokenized => tokenId != null;

  Map<String, Object?> toJson() => {
    'id': id.toString(),
    'modelId': modelId.toString(),
    'submitter': submitter,
    'domain': domain,
    'categoryCode': categoryCode,
    'predictionHash': predictionHashHex,
    'metadataReference': metadataReference,
    'confidence': confidence,
    'createdAt': createdAt,
    'expiresAt': expiresAt,
    'status': status,
    'outcome': outcome,
    'validator': validator,
    'validatedAt': validatedAt,
    'tokenId': tokenId?.toString(),
    'provenance': provenance.name,
  };
}

class Phase6bMarket {
  final BigInt tokenId;
  final BigInt predictionId;
  final String owner;
  final String metadataReference;
  final int createdAt;
  final bool transferable;
  final bool frozen;
  final bool burned;
  final bool locked;
  final BigInt yesTotal;
  final BigInt noTotal;
  final String settlementStatus;
  final String? proposedOutcome;
  final String? finalOutcome;
  final int? disputeUntil;
  final BigInt totalStakeAtFinalization;
  final BigInt feesCollected;
  final BigInt remaindersCollected;
  final BigInt totalPaid;
  final BigInt totalRefunded;
  final BigInt totalSlashed;
  final Phase6bDataProvenance provenance;

  const Phase6bMarket({
    required this.tokenId,
    required this.predictionId,
    required this.owner,
    required this.metadataReference,
    required this.createdAt,
    required this.transferable,
    required this.frozen,
    required this.burned,
    required this.locked,
    required this.yesTotal,
    required this.noTotal,
    required this.settlementStatus,
    required this.proposedOutcome,
    required this.finalOutcome,
    this.disputeUntil,
    required this.totalStakeAtFinalization,
    required this.feesCollected,
    required this.remaindersCollected,
    required this.totalPaid,
    required this.totalRefunded,
    required this.totalSlashed,
    this.provenance = Phase6bDataProvenance.canonicalStorage,
  });

  BigInt get totalStake => yesTotal + noTotal;
  bool get isSettled => settlementStatus == 'Finalized';

  Map<String, Object?> toJson() => {
    'tokenId': tokenId.toString(),
    'predictionId': predictionId.toString(),
    'owner': owner,
    'metadataReference': metadataReference,
    'createdAt': createdAt,
    'transferable': transferable,
    'frozen': frozen,
    'burned': burned,
    'locked': locked,
    'yesTotal': yesTotal.toString(),
    'noTotal': noTotal.toString(),
    'settlementStatus': settlementStatus,
    'proposedOutcome': proposedOutcome,
    'finalOutcome': finalOutcome,
    'disputeUntil': disputeUntil,
    'totalStakeAtFinalization': totalStakeAtFinalization.toString(),
    'feesCollected': feesCollected.toString(),
    'remaindersCollected': remaindersCollected.toString(),
    'totalPaid': totalPaid.toString(),
    'totalRefunded': totalRefunded.toString(),
    'totalSlashed': totalSlashed.toString(),
    'provenance': provenance.name,
  };
}

class Phase6bPosition {
  final BigInt tokenId;
  final BigInt predictionId;
  final String account;
  final String side;
  final BigInt amount;
  final int stakedAt;
  final int? updatedAt;
  final bool claimed;
  final BigInt stakeReturned;
  final BigInt rewardPaid;
  final BigInt slashed;
  final Phase6bDataProvenance provenance;

  const Phase6bPosition({
    required this.tokenId,
    required this.predictionId,
    required this.account,
    required this.side,
    required this.amount,
    required this.stakedAt,
    required this.updatedAt,
    required this.claimed,
    required this.stakeReturned,
    required this.rewardPaid,
    required this.slashed,
    this.provenance = Phase6bDataProvenance.canonicalStorage,
  });

  bool get claimableEvidence => amount > BigInt.zero && !claimed;

  Map<String, Object?> toJson() => {
    'tokenId': tokenId.toString(),
    'predictionId': predictionId.toString(),
    'account': account,
    'side': side,
    'amount': amount.toString(),
    'stakedAt': stakedAt,
    'updatedAt': updatedAt,
    'claimed': claimed,
    'stakeReturned': stakeReturned.toString(),
    'rewardPaid': rewardPaid.toString(),
    'slashed': slashed.toString(),
    'provenance': provenance.name,
  };
}

class Phase6bChainConfiguration {
  final bool modelRegistrationEnabled;
  final bool predictionSubmissionEnabled;
  final bool marketCreationEnabled;
  final bool publicModelRegistrationEnabled;
  final bool requireModelApproval;
  final int maxActivePredictionsPerModel;
  final bool tokenizationEnabled;
  final bool transfersEnabled;
  final bool stakingEnabled;
  final BigInt minimumStake;
  final bool settlementEnabled;
  final int disputeWindowBlocks;
  final BigInt minimumDisputeBond;
  final bool settlementEconomicsEnabled;
  final bool slashIncorrect;
  final bool slashFraudulent;
  final bool marketEnabled;
  final bool allowUnstakeBeforeSettlement;
  final bool feesEnabled;
  final int feeBps;
  final bool treasuryEnabled;
  final String? authorizedValidatorAddress;
  final bool signerIsAuthorizedValidator;

  const Phase6bChainConfiguration({
    required this.modelRegistrationEnabled,
    required this.predictionSubmissionEnabled,
    required this.marketCreationEnabled,
    required this.publicModelRegistrationEnabled,
    required this.requireModelApproval,
    required this.maxActivePredictionsPerModel,
    this.tokenizationEnabled = false,
    this.transfersEnabled = false,
    required this.stakingEnabled,
    required this.minimumStake,
    this.settlementEnabled = false,
    this.disputeWindowBlocks = 0,
    required this.minimumDisputeBond,
    this.settlementEconomicsEnabled = false,
    this.slashIncorrect = false,
    this.slashFraudulent = false,
    required this.marketEnabled,
    required this.allowUnstakeBeforeSettlement,
    required this.feesEnabled,
    required this.feeBps,
    required this.treasuryEnabled,
    this.authorizedValidatorAddress,
    this.signerIsAuthorizedValidator = false,
  });

  bool isAuthorizedValidator(String address) =>
      signerIsAuthorizedValidator &&
      (authorizedValidatorAddress == null ||
          authorizedValidatorAddress == address.trim());

  BigInt get minDisputeBond => minimumDisputeBond;

  bool get economicsEnabled => settlementEconomicsEnabled;
}

class Phase6bChainRepository {
  static const int defaultPageSize = 25;
  static const int maximumPageSize = 100;

  final era_api.Era api;
  final Keyring _keyring;

  Phase6bChainRepository(this.api, {Keyring? keyring})
    : _keyring = keyring ?? Keyring();

  Future<Phase6bChainConfiguration> loadConfiguration({
    String? accountAddress,
    Uint8List? at,
  }) async {
    final checkedAddress = accountAddress?.trim();
    final validator = checkedAddress == null || checkedAddress.isEmpty
        ? Future<bool>.value(false)
        : isAuthorizedValidator(checkedAddress, at: at);
    final values = await Future.wait<Object>([
      api.query.aiPredictions.modelOnboardingConfig(at: at),
      api.query.aiPredictions.tokenizationConfig(at: at),
      api.query.aiPredictions.stakingConfig(at: at),
      api.query.aiPredictions.settlementConfig(at: at),
      api.query.aiPredictions.settlementEconomicsConfig(at: at),
      api.query.aiPredictions.predictionMarketEconomicsConfig(at: at),
      validator,
    ]);
    final onboarding = values[0] as runtime_onboarding.ModelOnboardingSettings;
    final tokenization = values[1] as runtime_tokenization.TokenizationSettings;
    final staking = values[2] as runtime_staking.StakingSettings;
    final settlement =
        values[3] as runtime_settlement_config.SettlementSettings;
    final settlementEconomics =
        values[4] as runtime_settlement_economics.SettlementEconomicsSettings;
    final market =
        values[5] as runtime_market_config.PredictionMarketEconomicsSettings;
    return Phase6bChainConfiguration(
      modelRegistrationEnabled: onboarding.modelRegistrationEnabled,
      predictionSubmissionEnabled: onboarding.predictionSubmissionEnabled,
      marketCreationEnabled: onboarding.marketCreationEnabled,
      publicModelRegistrationEnabled: onboarding.publicModelRegistrationEnabled,
      requireModelApproval: onboarding.requireModelApproval,
      maxActivePredictionsPerModel: onboarding.maxActivePredictionsPerModel,
      tokenizationEnabled: tokenization.tokenizationEnabled,
      transfersEnabled: tokenization.transfersEnabled,
      stakingEnabled: staking.stakingEnabled,
      minimumStake: staking.minStake,
      settlementEnabled: settlement.settlementEnabled,
      disputeWindowBlocks: settlement.disputeWindowBlocks,
      minimumDisputeBond: settlement.minDisputeBond,
      settlementEconomicsEnabled: settlementEconomics.economicsEnabled,
      slashIncorrect: settlementEconomics.slashIncorrect,
      slashFraudulent: settlementEconomics.slashFraudulent,
      marketEnabled: market.marketEnabled,
      allowUnstakeBeforeSettlement: market.allowUnstakeBeforeSettlement,
      feesEnabled: market.feesEnabled,
      feeBps: market.feeBps,
      treasuryEnabled: market.treasuryEnabled,
      authorizedValidatorAddress:
          checkedAddress == null || checkedAddress.isEmpty
          ? null
          : checkedAddress,
      signerIsAuthorizedValidator: values[6] as bool,
    );
  }

  Future<bool> isAuthorizedValidator(String accountAddress, {Uint8List? at}) {
    final account = _keyring.decodeAddress(accountAddress.trim());
    return api.query.aiPredictions.authorizedValidators(account, at: at);
  }

  Future<Phase6bPage<Phase6bModel>> loadModels({
    int offset = 0,
    int limit = defaultPageSize,
    String? ownerAddress,
  }) async {
    _validatePage(offset, limit);
    late final List<BigInt> ids;
    late final int total;
    if (ownerAddress != null && ownerAddress.trim().isNotEmpty) {
      final owner = _keyring.decodeAddress(ownerAddress.trim());
      final owned = await api.query.aiPredictions.modelIdsByOwner(owner);
      total = owned.length;
      ids = owned.skip(offset).take(limit).toList(growable: false);
    } else {
      final nextId = await api.query.aiPredictions.nextModelId();
      total = _safeCount(nextId);
      ids = _idPage(total: total, offset: offset, limit: limit);
    }

    final records = await api.query.aiPredictions.multiModels(ids);
    final items = <Phase6bModel>[];
    for (var index = 0; index < ids.length; index++) {
      final record = records[index];
      if (record == null) continue;
      items.add(await _loadModel(ids[index], record));
    }
    return Phase6bPage(
      items: items,
      offset: offset,
      limit: limit,
      totalAvailable: total,
    );
  }

  Future<Phase6bModel?> loadModel(BigInt modelId, {Uint8List? at}) async {
    final record = await api.query.aiPredictions.models(modelId, at: at);
    return record == null ? null : _loadModel(modelId, record, at: at);
  }

  Future<Phase6bPage<Phase6bPrediction>> loadPredictions({
    int offset = 0,
    int limit = defaultPageSize,
    BigInt? modelId,
  }) async {
    _validatePage(offset, limit);
    late final List<BigInt> ids;
    late final int total;
    if (modelId != null) {
      final related = await api.query.aiPredictions.predictionIdsByModel(
        modelId,
      );
      total = related.length;
      ids = related.skip(offset).take(limit).toList(growable: false);
    } else {
      final nextId = await api.query.aiPredictions.nextPredictionId();
      total = _safeCount(nextId);
      ids = _idPage(total: total, offset: offset, limit: limit);
    }
    final records = await api.query.aiPredictions.multiPredictions(ids);
    final items = <Phase6bPrediction>[];
    for (var index = 0; index < ids.length; index++) {
      final record = records[index];
      if (record == null) continue;
      final tokenId = await api.query.aiPredictions.predictionTokenByPrediction(
        ids[index],
      );
      items.add(_predictionView(ids[index], record, tokenId));
    }
    return Phase6bPage(
      items: items,
      offset: offset,
      limit: limit,
      totalAvailable: total,
    );
  }

  Future<Phase6bPrediction?> loadPrediction(
    BigInt predictionId, {
    Uint8List? at,
  }) async {
    final values = await Future.wait<Object?>([
      api.query.aiPredictions.predictions(predictionId, at: at),
      api.query.aiPredictions.predictionTokenByPrediction(predictionId, at: at),
    ]);
    final prediction = values[0] as runtime_prediction.Prediction?;
    if (prediction == null) return null;
    return _predictionView(predictionId, prediction, values[1] as BigInt?);
  }

  Future<Phase6bPage<Phase6bMarket>> loadMarkets({
    int offset = 0,
    int limit = defaultPageSize,
  }) async {
    _validatePage(offset, limit);
    final nextId = await api.query.aiPredictions.nextPredictionTokenId();
    final total = _safeCount(nextId);
    final ids = _idPage(total: total, offset: offset, limit: limit);
    final tokens = await api.query.aiPredictions.multiPredictionTokens(ids);
    final items = <Phase6bMarket>[];
    for (var index = 0; index < ids.length; index++) {
      final token = tokens[index];
      if (token == null) continue;
      items.add(await _loadMarket(ids[index], token));
    }
    return Phase6bPage(
      items: items,
      offset: offset,
      limit: limit,
      totalAvailable: total,
    );
  }

  Future<Phase6bMarket?> loadMarket(BigInt tokenId, {Uint8List? at}) async {
    final token = await api.query.aiPredictions.predictionTokens(
      tokenId,
      at: at,
    );
    return token == null ? null : _loadMarket(tokenId, token, at: at);
  }

  Future<Phase6bPage<Phase6bPosition>> loadPositions({
    required String accountAddress,
    int offset = 0,
    int limit = defaultPageSize,
  }) async {
    _validatePage(offset, limit);
    final account = _keyring.decodeAddress(accountAddress);
    final nextId = await api.query.aiPredictions.nextPredictionTokenId();
    final total = _safeCount(nextId);
    final ids = _idPage(total: total, offset: offset, limit: limit);
    final items = <Phase6bPosition>[];
    for (final tokenId in ids) {
      final position = await _loadPosition(
        accountAddress: accountAddress,
        account: account,
        tokenId: tokenId,
      );
      if (position != null) items.add(position);
    }
    return Phase6bPage(
      items: items,
      offset: offset,
      limit: limit,
      totalAvailable: total,
      scannedCount: ids.length,
      historyComplete: offset + ids.length >= total,
      limitation: offset + ids.length < total
          ? 'Only this bounded token page has been reconciled. Load more to '
                'complete the account scan.'
          : null,
    );
  }

  Future<Phase6bPosition?> loadPosition({
    required String accountAddress,
    required BigInt tokenId,
    Uint8List? at,
  }) {
    if (tokenId.isNegative) {
      throw ArgumentError.value(tokenId, 'tokenId', 'Must not be negative.');
    }
    final normalizedAddress = accountAddress.trim();
    return _loadPosition(
      accountAddress: normalizedAddress,
      account: _keyring.decodeAddress(normalizedAddress),
      tokenId: tokenId,
      at: at,
    );
  }

  Future<Phase6bPosition?> _loadPosition({
    required String accountAddress,
    required List<int> account,
    required BigInt tokenId,
    Uint8List? at,
  }) async {
    final values = await Future.wait<Object?>([
      api.query.aiPredictions.predictionTokens(tokenId, at: at),
      api.query.aiPredictions.predictionTokenSideStakes(
        tokenId,
        account,
        at: at,
      ),
      api.query.aiPredictions.predictionTokenSidePayoutClaims(
        tokenId,
        account,
        at: at,
      ),
    ]);
    final token = values[0] as runtime_token.PredictionToken?;
    final stake = values[1] as runtime_stake.PredictionSideStake?;
    final claim = values[2] as runtime_claim.PredictionSidePayoutClaim?;
    if (token == null || (stake == null && claim == null)) return null;
    return Phase6bPosition(
      tokenId: tokenId,
      predictionId: token.predictionId,
      account: accountAddress,
      side: stake?.side.variantName ?? 'Unknown',
      amount: stake?.amount ?? BigInt.zero,
      stakedAt: stake?.stakedAt ?? 0,
      updatedAt: stake?.updatedAt,
      claimed: claim != null,
      stakeReturned: claim?.stakeReturned ?? BigInt.zero,
      rewardPaid: claim?.rewardPaid ?? BigInt.zero,
      slashed: claim?.slashed ?? BigInt.zero,
    );
  }

  Future<Phase6bModel> _loadModel(
    BigInt id,
    runtime_model.AiModel model, {
    Uint8List? at,
  }) async {
    final values = await Future.wait<Object?>([
      api.query.aiPredictions.modelGovernanceById(id, at: at),
      api.query.aiPredictions.modelStatsById(id, at: at),
      api.query.aiPredictions.activePredictionCountByModel(id, at: at),
      api.query.aiPredictions.predictionIdsByModel(id, at: at),
    ]);
    final governance = values[0] as runtime_governance.ModelGovernance?;
    final stats = values[1] as runtime_stats.ModelStats?;
    return Phase6bModel(
      id: id,
      owner: _keyring.encodeAddress(model.owner),
      modelHashHex: _hex(model.modelHash),
      metadataReference: _humanBytes(model.metadataUri),
      registeredAt: model.registeredAt,
      updatedAt: model.updatedAt,
      active: model.active,
      governanceStatus: governance?.status.variantName ?? 'Pending',
      authorizedSubmitter: governance?.authorizedSubmitter == null
          ? null
          : _keyring.encodeAddress(governance!.authorizedSubmitter!),
      governanceUpdatedAt: governance?.updatedAt ?? model.registeredAt,
      totalPredictions: stats?.totalPredictions ?? BigInt.zero,
      activePredictions: values[2] as int,
      predictionIds: values[3] as List<BigInt>,
    );
  }

  Phase6bPrediction _predictionView(
    BigInt id,
    runtime_prediction.Prediction prediction,
    BigInt? tokenId,
  ) {
    return Phase6bPrediction(
      id: id,
      modelId: prediction.modelId,
      submitter: _keyring.encodeAddress(prediction.submitter),
      domain: prediction.domain.variantName,
      categoryCode: _humanBytes(prediction.categoryCode),
      predictionHashHex: _hex(prediction.predictionHash),
      metadataReference: _humanBytes(prediction.metadataUri),
      metadataUriBytes: List<int>.unmodifiable(prediction.metadataUri),
      confidence: prediction.confidence,
      createdAt: prediction.createdAt,
      expiresAt: prediction.expiresAt,
      status: prediction.status.variantName,
      outcome: prediction.outcome?.variantName,
      validator: prediction.validator == null
          ? null
          : _keyring.encodeAddress(prediction.validator!),
      validatedAt: prediction.validatedAt,
      tokenId: tokenId,
    );
  }

  Future<Phase6bMarket> _loadMarket(
    BigInt tokenId,
    runtime_token.PredictionToken token, {
    Uint8List? at,
  }) async {
    final values = await Future.wait<Object?>([
      api.query.aiPredictions.predictionTokenSideTotals(
        tokenId,
        runtime_side.PredictionOutcomeSide.yes,
        at: at,
      ),
      api.query.aiPredictions.predictionTokenSideTotals(
        tokenId,
        runtime_side.PredictionOutcomeSide.no,
        at: at,
      ),
      api.query.aiPredictions.predictionTokenSettlements(tokenId, at: at),
      api.query.aiPredictions.predictionTokenMarketLocked(tokenId, at: at),
      api.query.aiPredictions.predictionTokenMarketAccounting(tokenId, at: at),
    ]);
    final settlement =
        values[2] as runtime_settlement.PredictionTokenSettlement?;
    final accounting =
        values[4] as runtime_accounting.PredictionMarketAccounting;
    return Phase6bMarket(
      tokenId: tokenId,
      predictionId: token.predictionId,
      owner: _keyring.encodeAddress(token.owner),
      metadataReference: _humanBytes(token.metadataUri),
      createdAt: token.createdAt,
      transferable: token.transferable,
      frozen: token.frozen,
      burned: token.burned,
      locked: values[3] as bool,
      yesTotal: values[0] as BigInt,
      noTotal: values[1] as BigInt,
      settlementStatus: settlement?.status.variantName ?? 'NotStarted',
      proposedOutcome: settlement?.proposedOutcome?.variantName,
      finalOutcome: settlement?.finalOutcome?.variantName,
      disputeUntil: settlement?.disputeUntil,
      totalStakeAtFinalization:
          settlement?.totalStakeAtFinalization ?? BigInt.zero,
      feesCollected: accounting.feesCollected,
      remaindersCollected: accounting.remaindersCollected,
      totalPaid: accounting.totalPaid,
      totalRefunded: accounting.totalRefunded,
      totalSlashed: accounting.totalSlashed,
    );
  }

  static List<BigInt> _idPage({
    required int total,
    required int offset,
    required int limit,
  }) {
    final end = (offset + limit).clamp(0, total);
    return [for (var id = offset; id < end; id++) BigInt.from(id)];
  }

  static int _safeCount(BigInt value) {
    if (value.isNegative || value > BigInt.from(0x7fffffff)) {
      throw StateError('Runtime counter is outside the safe wallet range.');
    }
    return value.toInt();
  }

  static void _validatePage(int offset, int limit) {
    if (offset < 0) throw ArgumentError.value(offset, 'offset');
    if (limit < 1 || limit > maximumPageSize) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Use a visible bounded page size from 1 to $maximumPageSize.',
      );
    }
  }

  static String _hex(List<int> bytes) =>
      '0x${bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join()}';

  static String _humanBytes(List<int> bytes) {
    if (bytes.isEmpty) return '';
    try {
      final value = utf8.decode(bytes);
      final printable = value.runes.every(
        (rune) => rune == 9 || rune == 10 || rune == 13 || rune >= 32,
      );
      if (printable) return value;
    } catch (_) {}
    return _hex(bytes);
  }
}
