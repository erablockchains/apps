// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i26;
import 'dart:typed_data' as _i27;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/era_runtime/runtime_call.dart' as _i28;
import '../types/pallet_ai_predictions/ai_model.dart' as _i7;
import '../types/pallet_ai_predictions/dispute_reason.dart' as _i32;
import '../types/pallet_ai_predictions/model_governance.dart' as _i10;
import '../types/pallet_ai_predictions/model_onboarding_settings.dart' as _i11;
import '../types/pallet_ai_predictions/model_stats.dart' as _i9;
import '../types/pallet_ai_predictions/pallet/call.dart' as _i29;
import '../types/pallet_ai_predictions/prediction.dart' as _i8;
import '../types/pallet_ai_predictions/prediction_domain.dart' as _i30;
import '../types/pallet_ai_predictions/prediction_market_accounting.dart'
    as _i25;
import '../types/pallet_ai_predictions/prediction_market_economics_settings.dart'
    as _i21;
import '../types/pallet_ai_predictions/prediction_outcome.dart' as _i6;
import '../types/pallet_ai_predictions/prediction_outcome_side.dart' as _i23;
import '../types/pallet_ai_predictions/prediction_side_payout_claim.dart'
    as _i24;
import '../types/pallet_ai_predictions/prediction_side_stake.dart' as _i22;
import '../types/pallet_ai_predictions/prediction_token.dart' as _i12;
import '../types/pallet_ai_predictions/prediction_token_dispute.dart' as _i18;
import '../types/pallet_ai_predictions/prediction_token_settlement.dart'
    as _i17;
import '../types/pallet_ai_predictions/prediction_token_settlement_claim.dart'
    as _i20;
import '../types/pallet_ai_predictions/prediction_token_stake.dart' as _i15;
import '../types/pallet_ai_predictions/settlement_economics_settings.dart'
    as _i19;
import '../types/pallet_ai_predictions/settlement_outcome.dart' as _i31;
import '../types/pallet_ai_predictions/settlement_settings.dart' as _i16;
import '../types/pallet_ai_predictions/staking_settings.dart' as _i14;
import '../types/pallet_ai_predictions/tokenization_settings.dart' as _i13;
import '../types/sp_core/crypto/account_id32.dart' as _i5;
import '../types/tuples.dart' as _i3;
import '../types/tuples_3.dart' as _i4;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageMap<BigInt, List<int>> _evaluationBindings =
      const _i1.StorageMap<BigInt, List<int>>(
        prefix: 'AiPredictions',
        storage: 'EvaluationBindings',
        valueCodec: _i2.U8ArrayCodec(32),
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, _i3.Tuple2<BigInt, BigInt>> _evaluationTiming =
      const _i1.StorageMap<BigInt, _i3.Tuple2<BigInt, BigInt>>(
        prefix: 'AiPredictions',
        storage: 'EvaluationTiming',
        valueCodec: _i3.Tuple2Codec<BigInt, BigInt>(
          _i2.U64Codec.codec,
          _i2.U64Codec.codec,
        ),
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageDoubleMap<BigInt, List<int>, BigInt> _evaluationRequests =
      const _i1.StorageDoubleMap<BigInt, List<int>, BigInt>(
        prefix: 'AiPredictions',
        storage: 'EvaluationRequests',
        valueCodec: _i2.U64Codec.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(_i2.U8ArrayCodec(32)),
      );

  final _i1.StorageMap<BigInt, int> _evaluationRevisionCount =
      const _i1.StorageMap<BigInt, int>(
        prefix: 'AiPredictions',
        storage: 'EvaluationRevisionCount',
        valueCodec: _i2.U32Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageDoubleMap<
    BigInt,
    int,
    _i4.Tuple4<_i5.AccountId32, List<int>, _i6.PredictionOutcome, int>
  >
  _evaluationEvidence =
      const _i1.StorageDoubleMap<
        BigInt,
        int,
        _i4.Tuple4<_i5.AccountId32, List<int>, _i6.PredictionOutcome, int>
      >(
        prefix: 'AiPredictions',
        storage: 'EvaluationEvidence',
        valueCodec:
            _i4.Tuple4Codec<
              _i5.AccountId32,
              List<int>,
              _i6.PredictionOutcome,
              int
            >(
              _i5.AccountId32Codec(),
              _i2.U8ArrayCodec(32),
              _i6.PredictionOutcome.codec,
              _i2.U32Codec.codec,
            ),
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<BigInt> _nextModelId = const _i1.StorageValue<BigInt>(
    prefix: 'AiPredictions',
    storage: 'NextModelId',
    valueCodec: _i2.U64Codec.codec,
  );

  final _i1.StorageValue<BigInt> _nextPredictionId =
      const _i1.StorageValue<BigInt>(
        prefix: 'AiPredictions',
        storage: 'NextPredictionId',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageMap<BigInt, _i7.AiModel> _models =
      const _i1.StorageMap<BigInt, _i7.AiModel>(
        prefix: 'AiPredictions',
        storage: 'Models',
        valueCodec: _i7.AiModel.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, _i8.Prediction> _predictions =
      const _i1.StorageMap<BigInt, _i8.Prediction>(
        prefix: 'AiPredictions',
        storage: 'Predictions',
        valueCodec: _i8.Prediction.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, _i9.ModelStats> _modelStatsById =
      const _i1.StorageMap<BigInt, _i9.ModelStats>(
        prefix: 'AiPredictions',
        storage: 'ModelStatsById',
        valueCodec: _i9.ModelStats.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, _i10.ModelGovernance> _modelGovernanceById =
      const _i1.StorageMap<BigInt, _i10.ModelGovernance>(
        prefix: 'AiPredictions',
        storage: 'ModelGovernanceById',
        valueCodec: _i10.ModelGovernance.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageValue<_i11.ModelOnboardingSettings> _modelOnboardingConfig =
      const _i1.StorageValue<_i11.ModelOnboardingSettings>(
        prefix: 'AiPredictions',
        storage: 'ModelOnboardingConfig',
        valueCodec: _i11.ModelOnboardingSettings.codec,
      );

  final _i1.StorageMap<_i5.AccountId32, List<BigInt>> _modelIdsByOwner =
      const _i1.StorageMap<_i5.AccountId32, List<BigInt>>(
        prefix: 'AiPredictions',
        storage: 'ModelIdsByOwner',
        valueCodec: _i2.U64SequenceCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageMap<BigInt, List<BigInt>> _predictionIdsByModel =
      const _i1.StorageMap<BigInt, List<BigInt>>(
        prefix: 'AiPredictions',
        storage: 'PredictionIdsByModel',
        valueCodec: _i2.U64SequenceCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, int> _activePredictionCountByModel =
      const _i1.StorageMap<BigInt, int>(
        prefix: 'AiPredictions',
        storage: 'ActivePredictionCountByModel',
        valueCodec: _i2.U32Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<_i5.AccountId32, bool> _authorizedValidators =
      const _i1.StorageMap<_i5.AccountId32, bool>(
        prefix: 'AiPredictions',
        storage: 'AuthorizedValidators',
        valueCodec: _i2.BoolCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageValue<BigInt> _nextPredictionTokenId =
      const _i1.StorageValue<BigInt>(
        prefix: 'AiPredictions',
        storage: 'NextPredictionTokenId',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageMap<BigInt, _i12.PredictionToken> _predictionTokens =
      const _i1.StorageMap<BigInt, _i12.PredictionToken>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokens',
        valueCodec: _i12.PredictionToken.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, BigInt> _predictionTokenByPrediction =
      const _i1.StorageMap<BigInt, BigInt>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenByPrediction',
        valueCodec: _i2.U64Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, _i5.AccountId32> _predictionTokenApprovals =
      const _i1.StorageMap<BigInt, _i5.AccountId32>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenApprovals',
        valueCodec: _i5.AccountId32Codec(),
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageValue<_i13.TokenizationSettings> _tokenizationConfig =
      const _i1.StorageValue<_i13.TokenizationSettings>(
        prefix: 'AiPredictions',
        storage: 'TokenizationConfig',
        valueCodec: _i13.TokenizationSettings.codec,
      );

  final _i1.StorageValue<_i14.StakingSettings> _stakingConfig =
      const _i1.StorageValue<_i14.StakingSettings>(
        prefix: 'AiPredictions',
        storage: 'StakingConfig',
        valueCodec: _i14.StakingSettings.codec,
      );

  final _i1.StorageDoubleMap<BigInt, _i5.AccountId32, _i15.PredictionTokenStake>
  _predictionTokenStakes =
      const _i1.StorageDoubleMap<
        BigInt,
        _i5.AccountId32,
        _i15.PredictionTokenStake
      >(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenStakes',
        valueCodec: _i15.PredictionTokenStake.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageMap<BigInt, BigInt> _predictionTokenTotalStake =
      const _i1.StorageMap<BigInt, BigInt>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenTotalStake',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, bool> _predictionTokenStakeLocked =
      const _i1.StorageMap<BigInt, bool>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenStakeLocked',
        valueCodec: _i2.BoolCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageValue<_i16.SettlementSettings> _settlementConfig =
      const _i1.StorageValue<_i16.SettlementSettings>(
        prefix: 'AiPredictions',
        storage: 'SettlementConfig',
        valueCodec: _i16.SettlementSettings.codec,
      );

  final _i1.StorageMap<BigInt, _i17.PredictionTokenSettlement>
  _predictionTokenSettlements =
      const _i1.StorageMap<BigInt, _i17.PredictionTokenSettlement>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenSettlements',
        valueCodec: _i17.PredictionTokenSettlement.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageValue<BigInt> _nextDisputeId =
      const _i1.StorageValue<BigInt>(
        prefix: 'AiPredictions',
        storage: 'NextDisputeId',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageMap<BigInt, _i18.PredictionTokenDispute>
  _predictionTokenDisputes =
      const _i1.StorageMap<BigInt, _i18.PredictionTokenDispute>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenDisputes',
        valueCodec: _i18.PredictionTokenDispute.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageValue<_i19.SettlementEconomicsSettings>
  _settlementEconomicsConfig =
      const _i1.StorageValue<_i19.SettlementEconomicsSettings>(
        prefix: 'AiPredictions',
        storage: 'SettlementEconomicsConfig',
        valueCodec: _i19.SettlementEconomicsSettings.codec,
      );

  final _i1.StorageDoubleMap<
    BigInt,
    _i5.AccountId32,
    _i20.PredictionTokenSettlementClaim
  >
  _predictionTokenSettlementClaims =
      const _i1.StorageDoubleMap<
        BigInt,
        _i5.AccountId32,
        _i20.PredictionTokenSettlementClaim
      >(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenSettlementClaims',
        valueCodec: _i20.PredictionTokenSettlementClaim.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageValue<_i21.PredictionMarketEconomicsSettings>
  _predictionMarketEconomicsConfig =
      const _i1.StorageValue<_i21.PredictionMarketEconomicsSettings>(
        prefix: 'AiPredictions',
        storage: 'PredictionMarketEconomicsConfig',
        valueCodec: _i21.PredictionMarketEconomicsSettings.codec,
      );

  final _i1.StorageDoubleMap<BigInt, _i5.AccountId32, _i22.PredictionSideStake>
  _predictionTokenSideStakes =
      const _i1.StorageDoubleMap<
        BigInt,
        _i5.AccountId32,
        _i22.PredictionSideStake
      >(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenSideStakes',
        valueCodec: _i22.PredictionSideStake.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageDoubleMap<BigInt, _i23.PredictionOutcomeSide, BigInt>
  _predictionTokenSideTotals =
      const _i1.StorageDoubleMap<BigInt, _i23.PredictionOutcomeSide, BigInt>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenSideTotals',
        valueCodec: _i2.U128Codec.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(
          _i23.PredictionOutcomeSide.codec,
        ),
      );

  final _i1.StorageDoubleMap<
    BigInt,
    _i5.AccountId32,
    _i24.PredictionSidePayoutClaim
  >
  _predictionTokenSidePayoutClaims =
      const _i1.StorageDoubleMap<
        BigInt,
        _i5.AccountId32,
        _i24.PredictionSidePayoutClaim
      >(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenSidePayoutClaims',
        valueCodec: _i24.PredictionSidePayoutClaim.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(_i5.AccountId32Codec()),
      );

  final _i1.StorageMap<BigInt, bool> _predictionTokenMarketLocked =
      const _i1.StorageMap<BigInt, bool>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenMarketLocked',
        valueCodec: _i2.BoolCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  final _i1.StorageMap<BigInt, _i25.PredictionMarketAccounting>
  _predictionTokenMarketAccounting =
      const _i1.StorageMap<BigInt, _i25.PredictionMarketAccounting>(
        prefix: 'AiPredictions',
        storage: 'PredictionTokenMarketAccounting',
        valueCodec: _i25.PredictionMarketAccounting.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U64Codec.codec),
      );

  /// Immutable artifact commitment for an existing prediction ID. Payload hash commits
  /// canonical input/version/horizon/terms off-chain. No token or financial position.
  _i26.Future<List<int>?> evaluationBindings(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _evaluationBindings.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _evaluationBindings.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i3.Tuple2<BigInt, BigInt>?> evaluationTiming(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _evaluationTiming.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _evaluationTiming.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Stable business key survives process restart and delegation changes.
  _i26.Future<BigInt?> evaluationRequests(
    BigInt key1,
    List<int> key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _evaluationRequests.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _evaluationRequests.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<int> evaluationRevisionCount(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _evaluationRevisionCount.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _evaluationRevisionCount.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  /// Append-only evidence revisions, bounded to 32 per prediction. Original validation
  /// statistics are historical; clients must derive corrected scores from this log.
  _i26.Future<
    _i4.Tuple4<_i5.AccountId32, List<int>, _i6.PredictionOutcome, int>?
  >
  evaluationEvidence(BigInt key1, int key2, {_i1.BlockHash? at}) async {
    final hashedKey = _evaluationEvidence.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _evaluationEvidence.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<BigInt> nextModelId({_i1.BlockHash? at}) async {
    final hashedKey = _nextModelId.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextModelId.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i26.Future<BigInt> nextPredictionId({_i1.BlockHash? at}) async {
    final hashedKey = _nextPredictionId.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextPredictionId.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i26.Future<_i7.AiModel?> models(BigInt key1, {_i1.BlockHash? at}) async {
    final hashedKey = _models.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _models.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i8.Prediction?> predictions(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictions.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictions.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i9.ModelStats?> modelStatsById(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _modelStatsById.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _modelStatsById.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i10.ModelGovernance?> modelGovernanceById(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _modelGovernanceById.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _modelGovernanceById.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i11.ModelOnboardingSettings> modelOnboardingConfig({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _modelOnboardingConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _modelOnboardingConfig.decodeValue(bytes);
    }
    return _i11.ModelOnboardingSettings(
      modelRegistrationEnabled: true,
      predictionSubmissionEnabled: true,
      marketCreationEnabled: true,
      publicModelRegistrationEnabled: false,
      requireModelApproval: true,
      maxActivePredictionsPerModel: 32,
    ); /* Default */
  }

  _i26.Future<List<BigInt>> modelIdsByOwner(
    _i5.AccountId32 key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _modelIdsByOwner.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _modelIdsByOwner.decodeValue(bytes);
    }
    return List<BigInt>.filled(0, BigInt.zero, growable: true); /* Default */
  }

  _i26.Future<List<BigInt>> predictionIdsByModel(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionIdsByModel.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionIdsByModel.decodeValue(bytes);
    }
    return List<BigInt>.filled(0, BigInt.zero, growable: true); /* Default */
  }

  _i26.Future<int> activePredictionCountByModel(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _activePredictionCountByModel.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _activePredictionCountByModel.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i26.Future<bool> authorizedValidators(
    _i5.AccountId32 key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _authorizedValidators.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _authorizedValidators.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i26.Future<BigInt> nextPredictionTokenId({_i1.BlockHash? at}) async {
    final hashedKey = _nextPredictionTokenId.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextPredictionTokenId.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i26.Future<_i12.PredictionToken?> predictionTokens(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokens.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokens.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<BigInt?> predictionTokenByPrediction(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenByPrediction.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenByPrediction.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i5.AccountId32?> predictionTokenApprovals(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenApprovals.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenApprovals.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i13.TokenizationSettings> tokenizationConfig({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _tokenizationConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _tokenizationConfig.decodeValue(bytes);
    }
    return _i13.TokenizationSettings(
      tokenizationEnabled: false,
      transfersEnabled: false,
    ); /* Default */
  }

  _i26.Future<_i14.StakingSettings> stakingConfig({_i1.BlockHash? at}) async {
    final hashedKey = _stakingConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _stakingConfig.decodeValue(bytes);
    }
    return _i14.StakingSettings(
      stakingEnabled: false,
      minStake: BigInt.zero,
    ); /* Default */
  }

  _i26.Future<_i15.PredictionTokenStake?> predictionTokenStakes(
    BigInt key1,
    _i5.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenStakes.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenStakes.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<BigInt> predictionTokenTotalStake(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenTotalStake.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenTotalStake.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i26.Future<bool> predictionTokenStakeLocked(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenStakeLocked.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenStakeLocked.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i26.Future<_i16.SettlementSettings> settlementConfig({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _settlementConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _settlementConfig.decodeValue(bytes);
    }
    return _i16.SettlementSettings(
      settlementEnabled: false,
      disputeWindowBlocks: 0,
      minDisputeBond: BigInt.zero,
    ); /* Default */
  }

  _i26.Future<_i17.PredictionTokenSettlement?> predictionTokenSettlements(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenSettlements.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenSettlements.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<BigInt> nextDisputeId({_i1.BlockHash? at}) async {
    final hashedKey = _nextDisputeId.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextDisputeId.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i26.Future<_i18.PredictionTokenDispute?> predictionTokenDisputes(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenDisputes.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenDisputes.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i19.SettlementEconomicsSettings> settlementEconomicsConfig({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _settlementEconomicsConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _settlementEconomicsConfig.decodeValue(bytes);
    }
    return _i19.SettlementEconomicsSettings(
      economicsEnabled: false,
      slashIncorrect: false,
      slashFraudulent: false,
    ); /* Default */
  }

  _i26.Future<_i20.PredictionTokenSettlementClaim?>
  predictionTokenSettlementClaims(
    BigInt key1,
    _i5.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenSettlementClaims.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenSettlementClaims.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<_i21.PredictionMarketEconomicsSettings>
  predictionMarketEconomicsConfig({_i1.BlockHash? at}) async {
    final hashedKey = _predictionMarketEconomicsConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionMarketEconomicsConfig.decodeValue(bytes);
    }
    return _i21.PredictionMarketEconomicsSettings(
      marketEnabled: false,
      allowUnstakeBeforeSettlement: true,
      feesEnabled: false,
      feeBps: 0,
      treasuryEnabled: true,
    ); /* Default */
  }

  _i26.Future<_i22.PredictionSideStake?> predictionTokenSideStakes(
    BigInt key1,
    _i5.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenSideStakes.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenSideStakes.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<BigInt> predictionTokenSideTotals(
    BigInt key1,
    _i23.PredictionOutcomeSide key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenSideTotals.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenSideTotals.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i26.Future<_i24.PredictionSidePayoutClaim?> predictionTokenSidePayoutClaims(
    BigInt key1,
    _i5.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenSidePayoutClaims.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenSidePayoutClaims.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i26.Future<bool> predictionTokenMarketLocked(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenMarketLocked.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenMarketLocked.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i26.Future<_i25.PredictionMarketAccounting> predictionTokenMarketAccounting(
    BigInt key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _predictionTokenMarketAccounting.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _predictionTokenMarketAccounting.decodeValue(bytes);
    }
    return _i25.PredictionMarketAccounting(
      feesCollected: BigInt.zero,
      remaindersCollected: BigInt.zero,
      totalPaid: BigInt.zero,
      totalRefunded: BigInt.zero,
      totalSlashed: BigInt.zero,
    ); /* Default */
  }

  /// Immutable artifact commitment for an existing prediction ID. Payload hash commits
  /// canonical input/version/horizon/terms off-chain. No token or financial position.
  _i26.Future<List<List<int>?>> multiEvaluationBindings(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _evaluationBindings.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _evaluationBindings.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<_i3.Tuple2<BigInt, BigInt>?>> multiEvaluationTiming(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _evaluationTiming.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _evaluationTiming.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<int>> multiEvaluationRevisionCount(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _evaluationRevisionCount.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _evaluationRevisionCount.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => 0).toList() as List<int>); /* Default */
  }

  _i26.Future<List<_i7.AiModel?>> multiModels(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _models.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _models.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<_i8.Prediction?>> multiPredictions(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictions.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictions.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<_i9.ModelStats?>> multiModelStatsById(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _modelStatsById.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _modelStatsById.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<_i10.ModelGovernance?>> multiModelGovernanceById(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _modelGovernanceById.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _modelGovernanceById.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<List<BigInt>>> multiModelIdsByOwner(
    List<_i5.AccountId32> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _modelIdsByOwner.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _modelIdsByOwner.decodeValue(v.key))
          .toList();
    }
    return (keys
            .map((key) => List<BigInt>.filled(0, BigInt.zero, growable: true))
            .toList()
        as List<List<BigInt>>); /* Default */
  }

  _i26.Future<List<List<BigInt>>> multiPredictionIdsByModel(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionIdsByModel.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionIdsByModel.decodeValue(v.key))
          .toList();
    }
    return (keys
            .map((key) => List<BigInt>.filled(0, BigInt.zero, growable: true))
            .toList()
        as List<List<BigInt>>); /* Default */
  }

  _i26.Future<List<int>> multiActivePredictionCountByModel(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _activePredictionCountByModel.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _activePredictionCountByModel.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => 0).toList() as List<int>); /* Default */
  }

  _i26.Future<List<bool>> multiAuthorizedValidators(
    List<_i5.AccountId32> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _authorizedValidators.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _authorizedValidators.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => false).toList() as List<bool>); /* Default */
  }

  _i26.Future<List<_i12.PredictionToken?>> multiPredictionTokens(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokens.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokens.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<BigInt?>> multiPredictionTokenByPrediction(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenByPrediction.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenByPrediction.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<_i5.AccountId32?>> multiPredictionTokenApprovals(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenApprovals.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenApprovals.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<BigInt>> multiPredictionTokenTotalStake(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenTotalStake.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenTotalStake.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  _i26.Future<List<bool>> multiPredictionTokenStakeLocked(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenStakeLocked.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenStakeLocked.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => false).toList() as List<bool>); /* Default */
  }

  _i26.Future<List<_i17.PredictionTokenSettlement?>>
  multiPredictionTokenSettlements(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenSettlements.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenSettlements.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<_i18.PredictionTokenDispute?>> multiPredictionTokenDisputes(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenDisputes.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenDisputes.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i26.Future<List<bool>> multiPredictionTokenMarketLocked(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenMarketLocked.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenMarketLocked.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => false).toList() as List<bool>); /* Default */
  }

  _i26.Future<List<_i25.PredictionMarketAccounting>>
  multiPredictionTokenMarketAccounting(
    List<BigInt> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _predictionTokenMarketAccounting.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _predictionTokenMarketAccounting.decodeValue(v.key))
          .toList();
    }
    return (keys
            .map(
              (key) => _i25.PredictionMarketAccounting(
                feesCollected: BigInt.zero,
                remaindersCollected: BigInt.zero,
                totalPaid: BigInt.zero,
                totalRefunded: BigInt.zero,
                totalSlashed: BigInt.zero,
              ),
            )
            .toList()
        as List<_i25.PredictionMarketAccounting>); /* Default */
  }

  /// Returns the storage key for `evaluationBindings`.
  _i27.Uint8List evaluationBindingsKey(BigInt key1) {
    final hashedKey = _evaluationBindings.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `evaluationTiming`.
  _i27.Uint8List evaluationTimingKey(BigInt key1) {
    final hashedKey = _evaluationTiming.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `evaluationRequests`.
  _i27.Uint8List evaluationRequestsKey(BigInt key1, List<int> key2) {
    final hashedKey = _evaluationRequests.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `evaluationRevisionCount`.
  _i27.Uint8List evaluationRevisionCountKey(BigInt key1) {
    final hashedKey = _evaluationRevisionCount.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `evaluationEvidence`.
  _i27.Uint8List evaluationEvidenceKey(BigInt key1, int key2) {
    final hashedKey = _evaluationEvidence.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `nextModelId`.
  _i27.Uint8List nextModelIdKey() {
    final hashedKey = _nextModelId.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `nextPredictionId`.
  _i27.Uint8List nextPredictionIdKey() {
    final hashedKey = _nextPredictionId.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `models`.
  _i27.Uint8List modelsKey(BigInt key1) {
    final hashedKey = _models.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `predictions`.
  _i27.Uint8List predictionsKey(BigInt key1) {
    final hashedKey = _predictions.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `modelStatsById`.
  _i27.Uint8List modelStatsByIdKey(BigInt key1) {
    final hashedKey = _modelStatsById.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `modelGovernanceById`.
  _i27.Uint8List modelGovernanceByIdKey(BigInt key1) {
    final hashedKey = _modelGovernanceById.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `modelOnboardingConfig`.
  _i27.Uint8List modelOnboardingConfigKey() {
    final hashedKey = _modelOnboardingConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `modelIdsByOwner`.
  _i27.Uint8List modelIdsByOwnerKey(_i5.AccountId32 key1) {
    final hashedKey = _modelIdsByOwner.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `predictionIdsByModel`.
  _i27.Uint8List predictionIdsByModelKey(BigInt key1) {
    final hashedKey = _predictionIdsByModel.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `activePredictionCountByModel`.
  _i27.Uint8List activePredictionCountByModelKey(BigInt key1) {
    final hashedKey = _activePredictionCountByModel.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `authorizedValidators`.
  _i27.Uint8List authorizedValidatorsKey(_i5.AccountId32 key1) {
    final hashedKey = _authorizedValidators.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `nextPredictionTokenId`.
  _i27.Uint8List nextPredictionTokenIdKey() {
    final hashedKey = _nextPredictionTokenId.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokens`.
  _i27.Uint8List predictionTokensKey(BigInt key1) {
    final hashedKey = _predictionTokens.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenByPrediction`.
  _i27.Uint8List predictionTokenByPredictionKey(BigInt key1) {
    final hashedKey = _predictionTokenByPrediction.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenApprovals`.
  _i27.Uint8List predictionTokenApprovalsKey(BigInt key1) {
    final hashedKey = _predictionTokenApprovals.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `tokenizationConfig`.
  _i27.Uint8List tokenizationConfigKey() {
    final hashedKey = _tokenizationConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `stakingConfig`.
  _i27.Uint8List stakingConfigKey() {
    final hashedKey = _stakingConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenStakes`.
  _i27.Uint8List predictionTokenStakesKey(BigInt key1, _i5.AccountId32 key2) {
    final hashedKey = _predictionTokenStakes.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenTotalStake`.
  _i27.Uint8List predictionTokenTotalStakeKey(BigInt key1) {
    final hashedKey = _predictionTokenTotalStake.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenStakeLocked`.
  _i27.Uint8List predictionTokenStakeLockedKey(BigInt key1) {
    final hashedKey = _predictionTokenStakeLocked.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `settlementConfig`.
  _i27.Uint8List settlementConfigKey() {
    final hashedKey = _settlementConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenSettlements`.
  _i27.Uint8List predictionTokenSettlementsKey(BigInt key1) {
    final hashedKey = _predictionTokenSettlements.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `nextDisputeId`.
  _i27.Uint8List nextDisputeIdKey() {
    final hashedKey = _nextDisputeId.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenDisputes`.
  _i27.Uint8List predictionTokenDisputesKey(BigInt key1) {
    final hashedKey = _predictionTokenDisputes.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `settlementEconomicsConfig`.
  _i27.Uint8List settlementEconomicsConfigKey() {
    final hashedKey = _settlementEconomicsConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenSettlementClaims`.
  _i27.Uint8List predictionTokenSettlementClaimsKey(
    BigInt key1,
    _i5.AccountId32 key2,
  ) {
    final hashedKey = _predictionTokenSettlementClaims.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `predictionMarketEconomicsConfig`.
  _i27.Uint8List predictionMarketEconomicsConfigKey() {
    final hashedKey = _predictionMarketEconomicsConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenSideStakes`.
  _i27.Uint8List predictionTokenSideStakesKey(
    BigInt key1,
    _i5.AccountId32 key2,
  ) {
    final hashedKey = _predictionTokenSideStakes.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenSideTotals`.
  _i27.Uint8List predictionTokenSideTotalsKey(
    BigInt key1,
    _i23.PredictionOutcomeSide key2,
  ) {
    final hashedKey = _predictionTokenSideTotals.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenSidePayoutClaims`.
  _i27.Uint8List predictionTokenSidePayoutClaimsKey(
    BigInt key1,
    _i5.AccountId32 key2,
  ) {
    final hashedKey = _predictionTokenSidePayoutClaims.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenMarketLocked`.
  _i27.Uint8List predictionTokenMarketLockedKey(BigInt key1) {
    final hashedKey = _predictionTokenMarketLocked.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `predictionTokenMarketAccounting`.
  _i27.Uint8List predictionTokenMarketAccountingKey(BigInt key1) {
    final hashedKey = _predictionTokenMarketAccounting.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `evaluationBindings`.
  _i27.Uint8List evaluationBindingsMapPrefix() {
    final hashedKey = _evaluationBindings.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `evaluationTiming`.
  _i27.Uint8List evaluationTimingMapPrefix() {
    final hashedKey = _evaluationTiming.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `evaluationRequests`.
  _i27.Uint8List evaluationRequestsMapPrefix(BigInt key1) {
    final hashedKey = _evaluationRequests.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `evaluationRevisionCount`.
  _i27.Uint8List evaluationRevisionCountMapPrefix() {
    final hashedKey = _evaluationRevisionCount.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `evaluationEvidence`.
  _i27.Uint8List evaluationEvidenceMapPrefix(BigInt key1) {
    final hashedKey = _evaluationEvidence.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `models`.
  _i27.Uint8List modelsMapPrefix() {
    final hashedKey = _models.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictions`.
  _i27.Uint8List predictionsMapPrefix() {
    final hashedKey = _predictions.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `modelStatsById`.
  _i27.Uint8List modelStatsByIdMapPrefix() {
    final hashedKey = _modelStatsById.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `modelGovernanceById`.
  _i27.Uint8List modelGovernanceByIdMapPrefix() {
    final hashedKey = _modelGovernanceById.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `modelIdsByOwner`.
  _i27.Uint8List modelIdsByOwnerMapPrefix() {
    final hashedKey = _modelIdsByOwner.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionIdsByModel`.
  _i27.Uint8List predictionIdsByModelMapPrefix() {
    final hashedKey = _predictionIdsByModel.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `activePredictionCountByModel`.
  _i27.Uint8List activePredictionCountByModelMapPrefix() {
    final hashedKey = _activePredictionCountByModel.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `authorizedValidators`.
  _i27.Uint8List authorizedValidatorsMapPrefix() {
    final hashedKey = _authorizedValidators.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokens`.
  _i27.Uint8List predictionTokensMapPrefix() {
    final hashedKey = _predictionTokens.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenByPrediction`.
  _i27.Uint8List predictionTokenByPredictionMapPrefix() {
    final hashedKey = _predictionTokenByPrediction.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenApprovals`.
  _i27.Uint8List predictionTokenApprovalsMapPrefix() {
    final hashedKey = _predictionTokenApprovals.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenStakes`.
  _i27.Uint8List predictionTokenStakesMapPrefix(BigInt key1) {
    final hashedKey = _predictionTokenStakes.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenTotalStake`.
  _i27.Uint8List predictionTokenTotalStakeMapPrefix() {
    final hashedKey = _predictionTokenTotalStake.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenStakeLocked`.
  _i27.Uint8List predictionTokenStakeLockedMapPrefix() {
    final hashedKey = _predictionTokenStakeLocked.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenSettlements`.
  _i27.Uint8List predictionTokenSettlementsMapPrefix() {
    final hashedKey = _predictionTokenSettlements.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenDisputes`.
  _i27.Uint8List predictionTokenDisputesMapPrefix() {
    final hashedKey = _predictionTokenDisputes.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenSettlementClaims`.
  _i27.Uint8List predictionTokenSettlementClaimsMapPrefix(BigInt key1) {
    final hashedKey = _predictionTokenSettlementClaims.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenSideStakes`.
  _i27.Uint8List predictionTokenSideStakesMapPrefix(BigInt key1) {
    final hashedKey = _predictionTokenSideStakes.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenSideTotals`.
  _i27.Uint8List predictionTokenSideTotalsMapPrefix(BigInt key1) {
    final hashedKey = _predictionTokenSideTotals.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenSidePayoutClaims`.
  _i27.Uint8List predictionTokenSidePayoutClaimsMapPrefix(BigInt key1) {
    final hashedKey = _predictionTokenSidePayoutClaims.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenMarketLocked`.
  _i27.Uint8List predictionTokenMarketLockedMapPrefix() {
    final hashedKey = _predictionTokenMarketLocked.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `predictionTokenMarketAccounting`.
  _i27.Uint8List predictionTokenMarketAccountingMapPrefix() {
    final hashedKey = _predictionTokenMarketAccounting.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  _i28.AiPredictions registerModel({
    required List<int> modelHash,
    required List<int> metadataUri,
  }) {
    return _i28.AiPredictions(
      _i29.RegisterModel(modelHash: modelHash, metadataUri: metadataUri),
    );
  }

  _i28.AiPredictions updateModel({
    required BigInt modelId,
    required List<int> modelHash,
    required List<int> metadataUri,
  }) {
    return _i28.AiPredictions(
      _i29.UpdateModel(
        modelId: modelId,
        modelHash: modelHash,
        metadataUri: metadataUri,
      ),
    );
  }

  _i28.AiPredictions submitPrediction({
    required BigInt modelId,
    required _i30.PredictionDomain domain,
    required List<int> categoryCode,
    required List<int> predictionHash,
    required List<int> metadataUri,
    required int confidence,
    required int expiresAt,
  }) {
    return _i28.AiPredictions(
      _i29.SubmitPrediction(
        modelId: modelId,
        domain: domain,
        categoryCode: categoryCode,
        predictionHash: predictionHash,
        metadataUri: metadataUri,
        confidence: confidence,
        expiresAt: expiresAt,
      ),
    );
  }

  _i28.AiPredictions validatePrediction({
    required BigInt predictionId,
    required _i6.PredictionOutcome outcome,
  }) {
    return _i28.AiPredictions(
      _i29.ValidatePrediction(predictionId: predictionId, outcome: outcome),
    );
  }

  _i28.AiPredictions closePrediction({required BigInt predictionId}) {
    return _i28.AiPredictions(_i29.ClosePrediction(predictionId: predictionId));
  }

  _i28.AiPredictions authorizeValidator({required _i5.AccountId32 account}) {
    return _i28.AiPredictions(_i29.AuthorizeValidator(account: account));
  }

  _i28.AiPredictions removeValidator({required _i5.AccountId32 account}) {
    return _i28.AiPredictions(_i29.RemoveValidator(account: account));
  }

  _i28.AiPredictions setTokenizationConfig({
    required bool tokenizationEnabled,
    required bool transfersEnabled,
  }) {
    return _i28.AiPredictions(
      _i29.SetTokenizationConfig(
        tokenizationEnabled: tokenizationEnabled,
        transfersEnabled: transfersEnabled,
      ),
    );
  }

  _i28.AiPredictions tokenizePrediction({
    required BigInt predictionId,
    required List<int> metadataUri,
    required bool transferable,
  }) {
    return _i28.AiPredictions(
      _i29.TokenizePrediction(
        predictionId: predictionId,
        metadataUri: metadataUri,
        transferable: transferable,
      ),
    );
  }

  _i28.AiPredictions approvePredictionTokenTransfer({
    required BigInt tokenId,
    required _i5.AccountId32 approved,
  }) {
    return _i28.AiPredictions(
      _i29.ApprovePredictionTokenTransfer(tokenId: tokenId, approved: approved),
    );
  }

  _i28.AiPredictions revokePredictionTokenApproval({required BigInt tokenId}) {
    return _i28.AiPredictions(
      _i29.RevokePredictionTokenApproval(tokenId: tokenId),
    );
  }

  _i28.AiPredictions transferPredictionToken({
    required BigInt tokenId,
    required _i5.AccountId32 to,
  }) {
    return _i28.AiPredictions(
      _i29.TransferPredictionToken(tokenId: tokenId, to: to),
    );
  }

  _i28.AiPredictions freezePredictionToken({required BigInt tokenId}) {
    return _i28.AiPredictions(_i29.FreezePredictionToken(tokenId: tokenId));
  }

  _i28.AiPredictions unfreezePredictionToken({required BigInt tokenId}) {
    return _i28.AiPredictions(_i29.UnfreezePredictionToken(tokenId: tokenId));
  }

  _i28.AiPredictions burnPredictionToken({required BigInt tokenId}) {
    return _i28.AiPredictions(_i29.BurnPredictionToken(tokenId: tokenId));
  }

  _i28.AiPredictions updatePredictionTokenMetadata({
    required BigInt tokenId,
    required List<int> metadataUri,
  }) {
    return _i28.AiPredictions(
      _i29.UpdatePredictionTokenMetadata(
        tokenId: tokenId,
        metadataUri: metadataUri,
      ),
    );
  }

  _i28.AiPredictions setStakingConfig({
    required bool stakingEnabled,
    required BigInt minStake,
  }) {
    return _i28.AiPredictions(
      _i29.SetStakingConfig(stakingEnabled: stakingEnabled, minStake: minStake),
    );
  }

  _i28.AiPredictions stakeOnPredictionToken({
    required BigInt tokenId,
    required BigInt amount,
  }) {
    return _i28.AiPredictions(
      _i29.StakeOnPredictionToken(tokenId: tokenId, amount: amount),
    );
  }

  _i28.AiPredictions unstakePredictionToken({
    required BigInt tokenId,
    required BigInt amount,
  }) {
    return _i28.AiPredictions(
      _i29.UnstakePredictionToken(tokenId: tokenId, amount: amount),
    );
  }

  _i28.AiPredictions lockPredictionTokenStake({required BigInt tokenId}) {
    return _i28.AiPredictions(_i29.LockPredictionTokenStake(tokenId: tokenId));
  }

  _i28.AiPredictions releasePredictionTokenStake({required BigInt tokenId}) {
    return _i28.AiPredictions(
      _i29.ReleasePredictionTokenStake(tokenId: tokenId),
    );
  }

  _i28.AiPredictions setSettlementConfig({
    required bool settlementEnabled,
    required int disputeWindowBlocks,
    required BigInt minDisputeBond,
  }) {
    return _i28.AiPredictions(
      _i29.SetSettlementConfig(
        settlementEnabled: settlementEnabled,
        disputeWindowBlocks: disputeWindowBlocks,
        minDisputeBond: minDisputeBond,
      ),
    );
  }

  _i28.AiPredictions proposePredictionOutcome({
    required BigInt tokenId,
    required _i31.SettlementOutcome proposedOutcome,
    required List<int> evidenceUri,
  }) {
    return _i28.AiPredictions(
      _i29.ProposePredictionOutcome(
        tokenId: tokenId,
        proposedOutcome: proposedOutcome,
        evidenceUri: evidenceUri,
      ),
    );
  }

  _i28.AiPredictions disputePredictionOutcome({
    required BigInt tokenId,
    required _i32.DisputeReason reason,
    required List<int> evidenceUri,
    required BigInt bond,
  }) {
    return _i28.AiPredictions(
      _i29.DisputePredictionOutcome(
        tokenId: tokenId,
        reason: reason,
        evidenceUri: evidenceUri,
        bond: bond,
      ),
    );
  }

  _i28.AiPredictions adminFinalizePredictionOutcome({
    required BigInt tokenId,
    required _i31.SettlementOutcome finalOutcome,
    required List<int> evidenceUri,
  }) {
    return _i28.AiPredictions(
      _i29.AdminFinalizePredictionOutcome(
        tokenId: tokenId,
        finalOutcome: finalOutcome,
        evidenceUri: evidenceUri,
      ),
    );
  }

  _i28.AiPredictions finalizePredictionOutcomeAfterDisputeWindow({
    required BigInt tokenId,
  }) {
    return _i28.AiPredictions(
      _i29.FinalizePredictionOutcomeAfterDisputeWindow(tokenId: tokenId),
    );
  }

  _i28.AiPredictions cancelPredictionSettlement({
    required BigInt tokenId,
    required List<int> evidenceUri,
  }) {
    return _i28.AiPredictions(
      _i29.CancelPredictionSettlement(
        tokenId: tokenId,
        evidenceUri: evidenceUri,
      ),
    );
  }

  _i28.AiPredictions setSettlementEconomicsConfig({
    required bool economicsEnabled,
    required bool slashIncorrect,
    required bool slashFraudulent,
  }) {
    return _i28.AiPredictions(
      _i29.SetSettlementEconomicsConfig(
        economicsEnabled: economicsEnabled,
        slashIncorrect: slashIncorrect,
        slashFraudulent: slashFraudulent,
      ),
    );
  }

  _i28.AiPredictions claimPredictionTokenSettlement({required BigInt tokenId}) {
    return _i28.AiPredictions(
      _i29.ClaimPredictionTokenSettlement(tokenId: tokenId),
    );
  }

  _i28.AiPredictions resolvePredictionDisputeBond({
    required BigInt disputeId,
    required bool accepted,
  }) {
    return _i28.AiPredictions(
      _i29.ResolvePredictionDisputeBond(
        disputeId: disputeId,
        accepted: accepted,
      ),
    );
  }

  _i28.AiPredictions setMarketEconomicsConfig({
    required bool marketEnabled,
    required bool allowUnstakeBeforeSettlement,
  }) {
    return _i28.AiPredictions(
      _i29.SetMarketEconomicsConfig(
        marketEnabled: marketEnabled,
        allowUnstakeBeforeSettlement: allowUnstakeBeforeSettlement,
      ),
    );
  }

  _i28.AiPredictions stakeOnPredictionOutcomeSide({
    required BigInt tokenId,
    required _i23.PredictionOutcomeSide side,
    required BigInt amount,
  }) {
    return _i28.AiPredictions(
      _i29.StakeOnPredictionOutcomeSide(
        tokenId: tokenId,
        side: side,
        amount: amount,
      ),
    );
  }

  _i28.AiPredictions unstakeFromPredictionOutcomeSide({
    required BigInt tokenId,
    required _i23.PredictionOutcomeSide side,
    required BigInt amount,
  }) {
    return _i28.AiPredictions(
      _i29.UnstakeFromPredictionOutcomeSide(
        tokenId: tokenId,
        side: side,
        amount: amount,
      ),
    );
  }

  _i28.AiPredictions claimPredictionMarketPayout({required BigInt tokenId}) {
    return _i28.AiPredictions(
      _i29.ClaimPredictionMarketPayout(tokenId: tokenId),
    );
  }

  _i28.AiPredictions setMarketFeeConfig({
    required bool feesEnabled,
    required int feeBps,
    required bool treasuryEnabled,
  }) {
    return _i28.AiPredictions(
      _i29.SetMarketFeeConfig(
        feesEnabled: feesEnabled,
        feeBps: feeBps,
        treasuryEnabled: treasuryEnabled,
      ),
    );
  }

  _i28.AiPredictions setModelOnboardingConfig({
    required _i11.ModelOnboardingSettings config,
  }) {
    return _i28.AiPredictions(_i29.SetModelOnboardingConfig(config: config));
  }

  _i28.AiPredictions approveModel({required BigInt modelId}) {
    return _i28.AiPredictions(_i29.ApproveModel(modelId: modelId));
  }

  _i28.AiPredictions suspendModel({required BigInt modelId}) {
    return _i28.AiPredictions(_i29.SuspendModel(modelId: modelId));
  }

  _i28.AiPredictions rejectModel({required BigInt modelId}) {
    return _i28.AiPredictions(_i29.RejectModel(modelId: modelId));
  }

  _i28.AiPredictions setModelSubmitter({
    required BigInt modelId,
    _i5.AccountId32? submitter,
  }) {
    return _i28.AiPredictions(
      _i29.SetModelSubmitter(modelId: modelId, submitter: submitter),
    );
  }

  /// Explicit fraud finding; ordinary unsuccessful disputes are refunded by call29.
  _i28.AiPredictions adjudicatePredictionDisputeBond({
    required BigInt disputeId,
    required bool accepted,
    required bool fraudulent,
    required List<int> evidenceHash,
  }) {
    return _i28.AiPredictions(
      _i29.AdjudicatePredictionDisputeBond(
        disputeId: disputeId,
        accepted: accepted,
        fraudulent: fraudulent,
        evidenceHash: evidenceHash,
      ),
    );
  }

  /// The existing prediction hash commits canonical model/version/input/horizon/terms.
  /// A duplicate exact business request succeeds without a second prediction.
  _i28.AiPredictions submitEvaluation({
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
    return _i28.AiPredictions(
      _i29.SubmitEvaluation(
        modelId: modelId,
        requestId: requestId,
        artifact: artifact,
        predictionHash: predictionHash,
        metadataUri: metadataUri,
        confidence: confidence,
        expiresAt: expiresAt,
        cutoffUtc: cutoffUtc,
        evidenceAfterUtc: evidenceAfterUtc,
      ),
    );
  }

  /// Authorized independent account publishes evidence; corrections append, never erase.
  _i28.AiPredictions recordEvaluationEvidence({
    required BigInt predictionId,
    required int revision,
    required List<int> evidence,
    required _i6.PredictionOutcome outcome,
  }) {
    return _i28.AiPredictions(
      _i29.RecordEvaluationEvidence(
        predictionId: predictionId,
        revision: revision,
        evidence: evidence,
        outcome: outcome,
      ),
    );
  }
}

class Constants {
  Constants();

  final int maxHashLen = 128;

  final int maxMetadataUriLen = 256;

  final int maxCategoryCodeLen = 96;

  final int maxModelsPerOwner = 64;

  final int maxPredictionsPerModel = 1024;

  /// Compile-time policy. False rejects creation of financial obligations and tokens.
  final bool financialModesAllowed = false;
}
