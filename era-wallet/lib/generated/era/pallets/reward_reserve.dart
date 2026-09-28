// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:typed_data' as _i8;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/era_runtime/runtime_call.dart' as _i9;
import '../types/frame_support/pallet_id.dart' as _i11;
import '../types/pallet_reward_reserve/fee_routing_configuration.dart' as _i6;
import '../types/pallet_reward_reserve/pallet/call.dart' as _i10;
import '../types/pallet_reward_reserve/reward_era_skip_reason.dart' as _i5;
import '../types/sp_arithmetic/per_things/perbill.dart' as _i12;
import '../types/sp_core/crypto/account_id32.dart' as _i4;
import '../types/tuples.dart' as _i3;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<bool> _rewardSystemActive =
      const _i1.StorageValue<bool>(
        prefix: 'RewardReserve',
        storage: 'RewardSystemActive',
        valueCodec: _i2.BoolCodec.codec,
      );

  final _i1.StorageValue<bool> _feeRoutingActive = const _i1.StorageValue<bool>(
    prefix: 'RewardReserve',
    storage: 'FeeRoutingActive',
    valueCodec: _i2.BoolCodec.codec,
  );

  final _i1.StorageValue<int> _activationBlock = const _i1.StorageValue<int>(
    prefix: 'RewardReserve',
    storage: 'ActivationBlock',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<int> _activationEra = const _i1.StorageValue<int>(
    prefix: 'RewardReserve',
    storage: 'ActivationEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<int> _firstEligibleEra = const _i1.StorageValue<int>(
    prefix: 'RewardReserve',
    storage: 'FirstEligibleEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<int> _pointSourceOperationalEra =
      const _i1.StorageValue<int>(
        prefix: 'RewardReserve',
        storage: 'PointSourceOperationalEra',
        valueCodec: _i2.U32Codec.codec,
      );

  final _i1.StorageValue<_i3.Tuple2<int, int>> _legacyZeroPointEraRange =
      const _i1.StorageValue<_i3.Tuple2<int, int>>(
        prefix: 'RewardReserve',
        storage: 'LegacyZeroPointEraRange',
        valueCodec: _i3.Tuple2Codec<int, int>(
          _i2.U32Codec.codec,
          _i2.U32Codec.codec,
        ),
      );

  final _i1.StorageValue<BigInt> _legacyLiabilityBudgetPeriodStartMillis =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'LegacyLiabilityBudgetPeriodStartMillis',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageValue<int> _lastObservedEra = const _i1.StorageValue<int>(
    prefix: 'RewardReserve',
    storage: 'LastObservedEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<BigInt> _lastObservedEraStartMillis =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'LastObservedEraStartMillis',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageValue<_i3.Tuple2<int, BigInt>> _pendingCompletedEra =
      const _i1.StorageValue<_i3.Tuple2<int, BigInt>>(
        prefix: 'RewardReserve',
        storage: 'PendingCompletedEra',
        valueCodec: _i3.Tuple2Codec<int, BigInt>(
          _i2.U32Codec.codec,
          _i2.U64Codec.codec,
        ),
      );

  final _i1.StorageMap<int, BigInt> _eraRewardBudgets =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'RewardReserve',
        storage: 'EraRewardBudgets',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageMap<int, BigInt> _eraRewardPaid =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'RewardReserve',
        storage: 'EraRewardPaid',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageMap<int, BigInt> _eraRewardLiabilities =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'RewardReserve',
        storage: 'EraRewardLiabilities',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageDoubleMap<int, _i3.Tuple2<_i4.AccountId32, int>, dynamic>
  _claimedRewardPages =
      const _i1.StorageDoubleMap<
        int,
        _i3.Tuple2<_i4.AccountId32, int>,
        dynamic
      >(
        prefix: 'RewardReserve',
        storage: 'ClaimedRewardPages',
        valueCodec: _i2.NullCodec.codec,
        hasher1: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
        hasher2: _i1.StorageHasher.blake2b128Concat(
          _i3.Tuple2Codec<_i4.AccountId32, int>(
            _i4.AccountId32Codec(),
            _i2.U32Codec.codec,
          ),
        ),
      );

  final _i1.StorageMap<int, dynamic> _expiredEras =
      const _i1.StorageMap<int, dynamic>(
        prefix: 'RewardReserve',
        storage: 'ExpiredEras',
        valueCodec: _i2.NullCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageMap<int, _i5.RewardEraSkipReason> _skippedRewardEras =
      const _i1.StorageMap<int, _i5.RewardEraSkipReason>(
        prefix: 'RewardReserve',
        storage: 'SkippedRewardEras',
        valueCodec: _i5.RewardEraSkipReason.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageMap<int, BigInt> _cancelledZeroPointLiabilities =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'RewardReserve',
        storage: 'CancelledZeroPointLiabilities',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<BigInt> _committedLiabilities =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'CommittedLiabilities',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _budgetPeriodStartMillis =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'BudgetPeriodStartMillis',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageValue<BigInt> _annualBudgetUsed =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'AnnualBudgetUsed',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<int> _nextExpiryEra = const _i1.StorageValue<int>(
    prefix: 'RewardReserve',
    storage: 'NextExpiryEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<BigInt> _lastPotBalance =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'LastPotBalance',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _lastTreasuryBalance =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'LastTreasuryBalance',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<_i6.FeeRoutingConfiguration> _feeRoutingConfig =
      const _i1.StorageValue<_i6.FeeRoutingConfiguration>(
        prefix: 'RewardReserve',
        storage: 'FeeRoutingConfig',
        valueCodec: _i6.FeeRoutingConfiguration.codec,
      );

  final _i1.StorageValue<BigInt> _pendingRewardFee =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'PendingRewardFee',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _pendingTreasuryFee =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'PendingTreasuryFee',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _pendingTipTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'PendingTipTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageMap<_i4.AccountId32, BigInt> _pendingAuthorTips =
      const _i1.StorageMap<_i4.AccountId32, BigInt>(
        prefix: 'RewardReserve',
        storage: 'PendingAuthorTips',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i4.AccountId32Codec()),
      );

  final _i1.StorageValue<BigInt> _pendingUnassignedTip =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'PendingUnassignedTip',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _reserveFundingTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'ReserveFundingTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _feeContributionTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'FeeContributionTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _ecosystemTreasuryFeeTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'EcosystemTreasuryFeeTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _normalFeeRoutedTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'NormalFeeRoutedTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _authorTipTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'RewardReserve',
        storage: 'AuthorTipTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<bool> _allocationPaused = const _i1.StorageValue<bool>(
    prefix: 'RewardReserve',
    storage: 'AllocationPaused',
    valueCodec: _i2.BoolCodec.codec,
  );

  final _i1.StorageValue<bool> _legacyClaimOnly = const _i1.StorageValue<bool>(
    prefix: 'RewardReserve',
    storage: 'LegacyClaimOnly',
    valueCodec: _i2.BoolCodec.codec,
  );

  final _i1.StorageValue<int> _v14LegacyCutoffEra = const _i1.StorageValue<int>(
    prefix: 'RewardReserve',
    storage: 'V14LegacyCutoffEra',
    valueCodec: _i2.U32Codec.codec,
  );

  /// Explicit activation flag. Migration always leaves this false.
  _i7.Future<bool> rewardSystemActive({_i1.BlockHash? at}) async {
    final hashedKey = _rewardSystemActive.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _rewardSystemActive.decodeValue(bytes);
    }
    return false; /* Default */
  }

  /// Corrected 70/30 routing is operational only after the same atomic activation.
  _i7.Future<bool> feeRoutingActive({_i1.BlockHash? at}) async {
    final hashedKey = _feeRoutingActive.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _feeRoutingActive.decodeValue(bytes);
    }
    return false; /* Default */
  }

  /// Block at which Root completed the activation gate.
  _i7.Future<int?> activationBlock({_i1.BlockHash? at}) async {
    final hashedKey = _activationBlock.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _activationBlock.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Era active when Root explicitly activates the reward system.
  _i7.Future<int?> activationEra({_i1.BlockHash? at}) async {
    final hashedKey = _activationEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _activationEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// First complete era after the point source became operational.
  _i7.Future<int?> firstEligibleEra({_i1.BlockHash? at}) async {
    final hashedKey = _firstEligibleEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _firstEligibleEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Era during which the production reward-point source became operational.
  _i7.Future<int?> pointSourceOperationalEra({_i1.BlockHash? at}) async {
    final hashedKey = _pointSourceOperationalEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pointSourceOperationalEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Inclusive range of pre-Spec12 eras eligible for guarded zero-point cancellation.
  _i7.Future<_i3.Tuple2<int, int>?> legacyZeroPointEraRange({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _legacyZeroPointEraRange.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _legacyZeroPointEraRange.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Budget period captured with the legacy zero-point range.
  _i7.Future<BigInt?> legacyLiabilityBudgetPeriodStartMillis({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _legacyLiabilityBudgetPeriodStartMillis.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _legacyLiabilityBudgetPeriodStartMillis.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Last active era observed by the pallet.
  _i7.Future<int?> lastObservedEra({_i1.BlockHash? at}) async {
    final hashedKey = _lastObservedEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _lastObservedEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Start timestamp recorded by staking for the last observed era.
  _i7.Future<BigInt?> lastObservedEraStartMillis({_i1.BlockHash? at}) async {
    final hashedKey = _lastObservedEraStartMillis.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _lastObservedEraStartMillis.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Completed era waiting for the next era's staking start timestamp.
  _i7.Future<_i3.Tuple2<int, BigInt>?> pendingCompletedEra({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _pendingCompletedEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingCompletedEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Finalized maximum liability for each eligible era.
  _i7.Future<BigInt?> eraRewardBudgets(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraRewardBudgets.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraRewardBudgets.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Amount actually transferred for each era.
  _i7.Future<BigInt> eraRewardPaid(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraRewardPaid.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraRewardPaid.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Funded but unpaid liability remaining for each era.
  _i7.Future<BigInt> eraRewardLiabilities(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraRewardLiabilities.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraRewardLiabilities.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Exact custom reward pages already claimed.
  _i7.Future<dynamic> claimedRewardPages(
    int key1,
    _i3.Tuple2<_i4.AccountId32, int> key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _claimedRewardPages.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _claimedRewardPages.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Eras whose claim window has closed and whose unclaimed liability was released.
  _i7.Future<dynamic> expiredEras(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _expiredEras.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _expiredEras.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Eras deliberately skipped before any liability or annual-budget consumption.
  _i7.Future<_i5.RewardEraSkipReason?> skippedRewardEras(
    int key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _skippedRewardEras.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _skippedRewardEras.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Proven pre-Spec12 zero-point liabilities released by a separately authorized Root call.
  _i7.Future<BigInt?> cancelledZeroPointLiabilities(
    int key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _cancelledZeroPointLiabilities.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _cancelledZeroPointLiabilities.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Aggregate funded liabilities across all claimable eras.
  _i7.Future<BigInt> committedLiabilities({_i1.BlockHash? at}) async {
    final hashedKey = _committedLiabilities.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _committedLiabilities.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Start of the current annual budget window.
  _i7.Future<BigInt?> budgetPeriodStartMillis({_i1.BlockHash? at}) async {
    final hashedKey = _budgetPeriodStartMillis.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _budgetPeriodStartMillis.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Budget allocated in the current annual window.
  _i7.Future<BigInt> annualBudgetUsed({_i1.BlockHash? at}) async {
    final hashedKey = _annualBudgetUsed.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _annualBudgetUsed.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Cursor used to release at most one expired era per block.
  _i7.Future<int?> nextExpiryEra({_i1.BlockHash? at}) async {
    final hashedKey = _nextExpiryEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextExpiryEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Last observed total pot balance, used only for public funding-source accounting.
  _i7.Future<BigInt?> lastPotBalance({_i1.BlockHash? at}) async {
    final hashedKey = _lastPotBalance.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _lastPotBalance.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Last observed treasury balance, preventing duplicate fee accounting.
  _i7.Future<BigInt?> lastTreasuryBalance({_i1.BlockHash? at}) async {
    final hashedKey = _lastTreasuryBalance.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _lastTreasuryBalance.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Intended normal-fee and tip routing configuration; dormant until activation.
  _i7.Future<_i6.FeeRoutingConfiguration?> feeRoutingConfig({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _feeRoutingConfig.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _feeRoutingConfig.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Reward share collected but not yet transferred from the Fee Collection Pot.
  _i7.Future<BigInt> pendingRewardFee({_i1.BlockHash? at}) async {
    final hashedKey = _pendingRewardFee.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingRewardFee.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Treasury share collected but not yet transferred from the Fee Collection Pot.
  _i7.Future<BigInt> pendingTreasuryFee({_i1.BlockHash? at}) async {
    final hashedKey = _pendingTreasuryFee.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingTreasuryFee.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Aggregate author tips retained in the Fee Collection Pot pending delivery.
  _i7.Future<BigInt> pendingTipTotal({_i1.BlockHash? at}) async {
    final hashedKey = _pendingTipTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingTipTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Deferred tips keyed by the block author to whom they remain owed.
  _i7.Future<BigInt> pendingAuthorTips(
    _i4.AccountId32 key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _pendingAuthorTips.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingAuthorTips.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Tips collected from a block with no determinable author; held, never burned.
  _i7.Future<BigInt> pendingUnassignedTip({_i1.BlockHash? at}) async {
    final hashedKey = _pendingUnassignedTip.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingUnassignedTip.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Existing-balance contributions observed from reserve transfers.
  _i7.Future<BigInt> reserveFundingTotal({_i1.BlockHash? at}) async {
    final hashedKey = _reserveFundingTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _reserveFundingTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Corrected normal-fee contributions resolved into the reward pot.
  _i7.Future<BigInt> feeContributionTotal({_i1.BlockHash? at}) async {
    final hashedKey = _feeContributionTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _feeContributionTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Normal fees routed to the deterministic Ecosystem Treasury pot.
  _i7.Future<BigInt> ecosystemTreasuryFeeTotal({_i1.BlockHash? at}) async {
    final hashedKey = _ecosystemTreasuryFeeTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _ecosystemTreasuryFeeTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Total corrected normal fees routed without burning.
  _i7.Future<BigInt> normalFeeRoutedTotal({_i1.BlockHash? at}) async {
    final hashedKey = _normalFeeRoutedTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _normalFeeRoutedTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Tips successfully resolved to block authors.
  _i7.Future<BigInt> authorTipTotal({_i1.BlockHash? at}) async {
    final hashedKey = _authorTipTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _authorTipTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Whether new era allocations are currently paused for reserve insufficiency.
  _i7.Future<bool> allocationPaused({_i1.BlockHash? at}) async {
    final hashedKey = _allocationPaused.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _allocationPaused.decodeValue(bytes);
    }
    return false; /* Default */
  }

  /// V14 permanently stops new legacy budgets and fee inflows while preserving valid claims.
  _i7.Future<bool> legacyClaimOnly({_i1.BlockHash? at}) async {
    final hashedKey = _legacyClaimOnly.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _legacyClaimOnly.decodeValue(bytes);
    }
    return false; /* Default */
  }

  /// Last era that may contain a legacy reward budget.
  _i7.Future<int?> v14LegacyCutoffEra({_i1.BlockHash? at}) async {
    final hashedKey = _v14LegacyCutoffEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _v14LegacyCutoffEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Finalized maximum liability for each eligible era.
  _i7.Future<List<BigInt?>> multiEraRewardBudgets(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _eraRewardBudgets.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraRewardBudgets.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Amount actually transferred for each era.
  _i7.Future<List<BigInt>> multiEraRewardPaid(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _eraRewardPaid.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraRewardPaid.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  /// Funded but unpaid liability remaining for each era.
  _i7.Future<List<BigInt>> multiEraRewardLiabilities(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _eraRewardLiabilities.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraRewardLiabilities.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  /// Eras whose claim window has closed and whose unclaimed liability was released.
  _i7.Future<List<dynamic>> multiExpiredEras(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _expiredEras.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _expiredEras.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Eras deliberately skipped before any liability or annual-budget consumption.
  _i7.Future<List<_i5.RewardEraSkipReason?>> multiSkippedRewardEras(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _skippedRewardEras.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _skippedRewardEras.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Proven pre-Spec12 zero-point liabilities released by a separately authorized Root call.
  _i7.Future<List<BigInt?>> multiCancelledZeroPointLiabilities(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _cancelledZeroPointLiabilities.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _cancelledZeroPointLiabilities.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Deferred tips keyed by the block author to whom they remain owed.
  _i7.Future<List<BigInt>> multiPendingAuthorTips(
    List<_i4.AccountId32> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _pendingAuthorTips.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _pendingAuthorTips.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  /// Returns the storage key for `rewardSystemActive`.
  _i8.Uint8List rewardSystemActiveKey() {
    final hashedKey = _rewardSystemActive.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `feeRoutingActive`.
  _i8.Uint8List feeRoutingActiveKey() {
    final hashedKey = _feeRoutingActive.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `activationBlock`.
  _i8.Uint8List activationBlockKey() {
    final hashedKey = _activationBlock.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `activationEra`.
  _i8.Uint8List activationEraKey() {
    final hashedKey = _activationEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `firstEligibleEra`.
  _i8.Uint8List firstEligibleEraKey() {
    final hashedKey = _firstEligibleEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pointSourceOperationalEra`.
  _i8.Uint8List pointSourceOperationalEraKey() {
    final hashedKey = _pointSourceOperationalEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `legacyZeroPointEraRange`.
  _i8.Uint8List legacyZeroPointEraRangeKey() {
    final hashedKey = _legacyZeroPointEraRange.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `legacyLiabilityBudgetPeriodStartMillis`.
  _i8.Uint8List legacyLiabilityBudgetPeriodStartMillisKey() {
    final hashedKey = _legacyLiabilityBudgetPeriodStartMillis.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `lastObservedEra`.
  _i8.Uint8List lastObservedEraKey() {
    final hashedKey = _lastObservedEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `lastObservedEraStartMillis`.
  _i8.Uint8List lastObservedEraStartMillisKey() {
    final hashedKey = _lastObservedEraStartMillis.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingCompletedEra`.
  _i8.Uint8List pendingCompletedEraKey() {
    final hashedKey = _pendingCompletedEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `eraRewardBudgets`.
  _i8.Uint8List eraRewardBudgetsKey(int key1) {
    final hashedKey = _eraRewardBudgets.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `eraRewardPaid`.
  _i8.Uint8List eraRewardPaidKey(int key1) {
    final hashedKey = _eraRewardPaid.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `eraRewardLiabilities`.
  _i8.Uint8List eraRewardLiabilitiesKey(int key1) {
    final hashedKey = _eraRewardLiabilities.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `claimedRewardPages`.
  _i8.Uint8List claimedRewardPagesKey(
    int key1,
    _i3.Tuple2<_i4.AccountId32, int> key2,
  ) {
    final hashedKey = _claimedRewardPages.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `expiredEras`.
  _i8.Uint8List expiredErasKey(int key1) {
    final hashedKey = _expiredEras.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `skippedRewardEras`.
  _i8.Uint8List skippedRewardErasKey(int key1) {
    final hashedKey = _skippedRewardEras.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `cancelledZeroPointLiabilities`.
  _i8.Uint8List cancelledZeroPointLiabilitiesKey(int key1) {
    final hashedKey = _cancelledZeroPointLiabilities.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `committedLiabilities`.
  _i8.Uint8List committedLiabilitiesKey() {
    final hashedKey = _committedLiabilities.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `budgetPeriodStartMillis`.
  _i8.Uint8List budgetPeriodStartMillisKey() {
    final hashedKey = _budgetPeriodStartMillis.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `annualBudgetUsed`.
  _i8.Uint8List annualBudgetUsedKey() {
    final hashedKey = _annualBudgetUsed.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `nextExpiryEra`.
  _i8.Uint8List nextExpiryEraKey() {
    final hashedKey = _nextExpiryEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `lastPotBalance`.
  _i8.Uint8List lastPotBalanceKey() {
    final hashedKey = _lastPotBalance.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `lastTreasuryBalance`.
  _i8.Uint8List lastTreasuryBalanceKey() {
    final hashedKey = _lastTreasuryBalance.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `feeRoutingConfig`.
  _i8.Uint8List feeRoutingConfigKey() {
    final hashedKey = _feeRoutingConfig.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingRewardFee`.
  _i8.Uint8List pendingRewardFeeKey() {
    final hashedKey = _pendingRewardFee.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingTreasuryFee`.
  _i8.Uint8List pendingTreasuryFeeKey() {
    final hashedKey = _pendingTreasuryFee.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingTipTotal`.
  _i8.Uint8List pendingTipTotalKey() {
    final hashedKey = _pendingTipTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingAuthorTips`.
  _i8.Uint8List pendingAuthorTipsKey(_i4.AccountId32 key1) {
    final hashedKey = _pendingAuthorTips.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `pendingUnassignedTip`.
  _i8.Uint8List pendingUnassignedTipKey() {
    final hashedKey = _pendingUnassignedTip.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `reserveFundingTotal`.
  _i8.Uint8List reserveFundingTotalKey() {
    final hashedKey = _reserveFundingTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `feeContributionTotal`.
  _i8.Uint8List feeContributionTotalKey() {
    final hashedKey = _feeContributionTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `ecosystemTreasuryFeeTotal`.
  _i8.Uint8List ecosystemTreasuryFeeTotalKey() {
    final hashedKey = _ecosystemTreasuryFeeTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `normalFeeRoutedTotal`.
  _i8.Uint8List normalFeeRoutedTotalKey() {
    final hashedKey = _normalFeeRoutedTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `authorTipTotal`.
  _i8.Uint8List authorTipTotalKey() {
    final hashedKey = _authorTipTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `allocationPaused`.
  _i8.Uint8List allocationPausedKey() {
    final hashedKey = _allocationPaused.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `legacyClaimOnly`.
  _i8.Uint8List legacyClaimOnlyKey() {
    final hashedKey = _legacyClaimOnly.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `v14LegacyCutoffEra`.
  _i8.Uint8List v14LegacyCutoffEraKey() {
    final hashedKey = _v14LegacyCutoffEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraRewardBudgets`.
  _i8.Uint8List eraRewardBudgetsMapPrefix() {
    final hashedKey = _eraRewardBudgets.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraRewardPaid`.
  _i8.Uint8List eraRewardPaidMapPrefix() {
    final hashedKey = _eraRewardPaid.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraRewardLiabilities`.
  _i8.Uint8List eraRewardLiabilitiesMapPrefix() {
    final hashedKey = _eraRewardLiabilities.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `claimedRewardPages`.
  _i8.Uint8List claimedRewardPagesMapPrefix(int key1) {
    final hashedKey = _claimedRewardPages.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `expiredEras`.
  _i8.Uint8List expiredErasMapPrefix() {
    final hashedKey = _expiredEras.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `skippedRewardEras`.
  _i8.Uint8List skippedRewardErasMapPrefix() {
    final hashedKey = _skippedRewardEras.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `cancelledZeroPointLiabilities`.
  _i8.Uint8List cancelledZeroPointLiabilitiesMapPrefix() {
    final hashedKey = _cancelledZeroPointLiabilities.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `pendingAuthorTips`.
  _i8.Uint8List pendingAuthorTipsMapPrefix() {
    final hashedKey = _pendingAuthorTips.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  /// Claim one finalized reward page. Any signed account may trigger the public payout.
  _i9.RewardReserve claimRewardPage({
    required int era,
    required _i4.AccountId32 validator,
    required int page,
  }) {
    return _i9.RewardReserve(
      _i10.ClaimRewardPage(era: era, validator: validator, page: page),
    );
  }

  /// Reconcile a same-block, separately authorized transfer into the reward pot.
  /// This call records public accounting only and never moves funds.
  _i9.RewardReserve syncRewardPot() {
    return _i9.RewardReserve(_i10.SyncRewardPot());
  }

  /// Update fee routing within the approved compile-time bounds.
  _i9.RewardReserve setFeeRoutingConfiguration({
    required _i6.FeeRoutingConfiguration new_,
  }) {
    return _i9.RewardReserve(_i10.SetFeeRoutingConfiguration(new_: new_));
  }

  /// Spend only from the isolated Ecosystem Treasury pot under the configured authority.
  _i9.RewardReserve spendEcosystemTreasury({
    required _i4.AccountId32 beneficiary,
    required BigInt amount,
  }) {
    return _i9.RewardReserve(
      _i10.SpendEcosystemTreasury(beneficiary: beneficiary, amount: amount),
    );
  }

  /// Atomically activate rewards and corrected-fee routing after every floor and reserve gate.
  _i9.RewardReserve activateRewardsAndFeeRouting() {
    return _i9.RewardReserve(_i10.ActivateRewardsAndFeeRouting());
  }

  /// Retry all staged normal-fee obligations. Any signed account may trigger safe settlement.
  _i9.RewardReserve retryDeferredFeeRouting() {
    return _i9.RewardReserve(_i10.RetryDeferredFeeRouting());
  }

  /// Retry a staged tip owed to a specific block author.
  _i9.RewardReserve retryDeferredAuthorTip({required _i4.AccountId32 author}) {
    return _i9.RewardReserve(_i10.RetryDeferredAuthorTip(author: author));
  }

  /// Release one proven pre-Spec12 zero-point liability without moving funds.
  _i9.RewardReserve cancelLegacyZeroPointLiability({required int era}) {
    return _i9.RewardReserve(_i10.CancelLegacyZeroPointLiability(era: era));
  }
}

class Constants {
  Constants();

  /// Deterministic keyless reward-pot identifier.
  final _i11.PalletId rewardPalletId = const <int>[
    101,
    114,
    97,
    47,
    114,
    119,
    100,
    115,
  ];

  /// Maximum reward liability allocated during one budget year.
  final BigInt annualRewardCap = BigInt.parse(
    '5000000000000000000000000',
    radix: 10,
  );

  /// Milliseconds in the deterministic budget year.
  final BigInt millisecondsPerYear = BigInt.from(31556952000);

  /// Validator commission ceiling applied by this reward system.
  final _i12.Perbill maxValidatorCommission = 100000000;

  /// Low-reserve warning threshold measured as uncommitted spendable balance.
  final BigInt lowReserveThreshold = BigInt.parse(
    '5000000000000000000000000',
    radix: 10,
  );

  /// Deterministic keyless protocol treasury identifier.
  final _i11.PalletId ecosystemTreasuryPalletId = const <int>[
    101,
    114,
    97,
    47,
    116,
    114,
    101,
    97,
  ];

  /// Deterministic keyless staging account for corrected fees and deferred tips.
  final _i11.PalletId feeCollectionPalletId = const <int>[
    101,
    114,
    97,
    47,
    102,
    101,
    101,
    115,
  ];

  /// Available Reward Pot balance required before explicit activation.
  final BigInt initialRewardReserve = BigInt.zero;

  /// Reward Pot floor, inclusive of the existential-deposit requirement.
  final BigInt rewardPotSafetyFloor = BigInt.from(100000000000000);

  /// Treasury Pot floor, inclusive of the existential-deposit requirement.
  final BigInt treasuryPotSafetyFloor = BigInt.from(100000000000000);

  final int initialRewardPotFeeShare = 70;

  final int initialEcosystemTreasuryFeeShare = 30;

  final int initialBurnFeeShare = 0;

  final int initialTipToAuthorShare = 100;

  final int maxRewardPotFeeShare = 70;

  final int maxEcosystemTreasuryFeeShare = 30;

  final int maxBurnFeeShare = 0;

  /// Maximum nominators this reward pallet will transfer to in one page.
  final int maxRewardNominatorsPerPage = 64;
}
