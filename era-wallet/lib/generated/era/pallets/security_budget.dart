// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:typed_data' as _i7;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/era_runtime/runtime_call.dart' as _i8;
import '../types/frame_support/pallet_id.dart' as _i10;
import '../types/pallet_security_budget/pallet/call.dart' as _i9;
import '../types/pallet_security_budget/pallet/era_budget.dart' as _i4;
import '../types/sp_arithmetic/per_things/perbill.dart' as _i11;
import '../types/sp_core/crypto/account_id32.dart' as _i3;
import '../types/tuples.dart' as _i5;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<bool> _active = const _i1.StorageValue<bool>(
    prefix: 'SecurityBudget',
    storage: 'Active',
    valueCodec: _i2.BoolCodec.codec,
  );

  final _i1.StorageValue<int> _activatedAt = const _i1.StorageValue<int>(
    prefix: 'SecurityBudget',
    storage: 'ActivatedAt',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<int> _migrationCompletedAt =
      const _i1.StorageValue<int>(
        prefix: 'SecurityBudget',
        storage: 'MigrationCompletedAt',
        valueCodec: _i2.U32Codec.codec,
      );

  final _i1.StorageValue<BigInt> _legacyRewardLiability =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'LegacyRewardLiability',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<int> _firstEligibleEra = const _i1.StorageValue<int>(
    prefix: 'SecurityBudget',
    storage: 'FirstEligibleEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<int> _legacyCutoffEra = const _i1.StorageValue<int>(
    prefix: 'SecurityBudget',
    storage: 'LegacyCutoffEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<int> _lastObservedEra = const _i1.StorageValue<int>(
    prefix: 'SecurityBudget',
    storage: 'LastObservedEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<BigInt> _lastObservedEraStart =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'LastObservedEraStart',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageValue<BigInt> _emissionPeriodStart =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'EmissionPeriodStart',
        valueCodec: _i2.U64Codec.codec,
      );

  final _i1.StorageValue<BigInt> _grossIssuedInPeriod =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'GrossIssuedInPeriod',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _targetRemainder =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'TargetRemainder',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<int> _issuanceSplitCarry = const _i1.StorageValue<int>(
    prefix: 'SecurityBudget',
    storage: 'IssuanceSplitCarry',
    valueCodec: _i2.U8Codec.codec,
  );

  final _i1.StorageValue<BigInt> _unallocatedFeeStaking =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'UnallocatedFeeStaking',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _unallocatedTipFallback =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'UnallocatedTipFallback',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _unallocatedStakingCarry =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'UnallocatedStakingCarry',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _unallocatedPrincipal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'UnallocatedPrincipal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _principalReservedTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'PrincipalReservedTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageMap<int, BigInt> _eraPrincipal =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'SecurityBudget',
        storage: 'EraPrincipal',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<BigInt> _pendingStakingFee =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'PendingStakingFee',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _pendingTreasuryFee =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'PendingTreasuryFee',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageMap<_i3.AccountId32, BigInt> _pendingAuthorTips =
      const _i1.StorageMap<_i3.AccountId32, BigInt>(
        prefix: 'SecurityBudget',
        storage: 'PendingAuthorTips',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i3.AccountId32Codec()),
      );

  final _i1.StorageValue<BigInt> _pendingMissingAuthorTips =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'PendingMissingAuthorTips',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _pendingTipTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'PendingTipTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageMap<int, _i4.EraBudget> _eraBudgets =
      const _i1.StorageMap<int, _i4.EraBudget>(
        prefix: 'SecurityBudget',
        storage: 'EraBudgets',
        valueCodec: _i4.EraBudget.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageDoubleMap<int, _i3.AccountId32, int>
  _eligibleValidatorPoints =
      const _i1.StorageDoubleMap<int, _i3.AccountId32, int>(
        prefix: 'SecurityBudget',
        storage: 'EligibleValidatorPoints',
        valueCodec: _i2.U32Codec.codec,
        hasher1: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
        hasher2: _i1.StorageHasher.twoxx64Concat(_i3.AccountId32Codec()),
      );

  final _i1.StorageMap<int, BigInt> _eraPaid =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'SecurityBudget',
        storage: 'EraPaid',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageDoubleMap<int, _i3.AccountId32, BigInt> _validatorPaid =
      const _i1.StorageDoubleMap<int, _i3.AccountId32, BigInt>(
        prefix: 'SecurityBudget',
        storage: 'ValidatorPaid',
        valueCodec: _i2.U128Codec.codec,
        hasher1: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
        hasher2: _i1.StorageHasher.twoxx64Concat(_i3.AccountId32Codec()),
      );

  final _i1.StorageMap<int, BigInt> _eraLiability =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'SecurityBudget',
        storage: 'EraLiability',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<BigInt> _committedLiabilities =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'CommittedLiabilities',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageDoubleMap<int, _i5.Tuple2<_i3.AccountId32, int>, dynamic>
  _claimedPages =
      const _i1.StorageDoubleMap<
        int,
        _i5.Tuple2<_i3.AccountId32, int>,
        dynamic
      >(
        prefix: 'SecurityBudget',
        storage: 'ClaimedPages',
        valueCodec: _i2.NullCodec.codec,
        hasher1: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
        hasher2: _i1.StorageHasher.twoxx64Concat(
          _i5.Tuple2Codec<_i3.AccountId32, int>(
            _i3.AccountId32Codec(),
            _i2.U32Codec.codec,
          ),
        ),
      );

  final _i1.StorageMap<int, dynamic> _expiredEras =
      const _i1.StorageMap<int, dynamic>(
        prefix: 'SecurityBudget',
        storage: 'ExpiredEras',
        valueCodec: _i2.NullCodec.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<int> _nextExpiryEra = const _i1.StorageValue<int>(
    prefix: 'SecurityBudget',
    storage: 'NextExpiryEra',
    valueCodec: _i2.U32Codec.codec,
  );

  final _i1.StorageValue<BigInt> _stakingFundingTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'StakingFundingTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _stakingPaidTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'StakingPaidTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _treasuryIssuanceTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'TreasuryIssuanceTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _treasuryNormalFeeTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'TreasuryNormalFeeTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _treasuryTipTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'TreasuryTipTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _normalFeeRoutedTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'NormalFeeRoutedTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _authorTipPaidTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'AuthorTipPaidTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<BigInt> _failedAuthorTipTotal =
      const _i1.StorageValue<BigInt>(
        prefix: 'SecurityBudget',
        storage: 'FailedAuthorTipTotal',
        valueCodec: _i2.U128Codec.codec,
      );

  final _i1.StorageValue<bool> _allocationPaused = const _i1.StorageValue<bool>(
    prefix: 'SecurityBudget',
    storage: 'AllocationPaused',
    valueCodec: _i2.BoolCodec.codec,
  );

  _i6.Future<bool> active({_i1.BlockHash? at}) async {
    final hashedKey = _active.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _active.decodeValue(bytes);
    }
    return false; /* Default */
  }

  _i6.Future<int?> activatedAt({_i1.BlockHash? at}) async {
    final hashedKey = _activatedAt.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _activatedAt.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> migrationCompletedAt({_i1.BlockHash? at}) async {
    final hashedKey = _migrationCompletedAt.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _migrationCompletedAt.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Legacy earned liability captured exactly once by the coordinated V14 migration.
  _i6.Future<BigInt> legacyRewardLiability({_i1.BlockHash? at}) async {
    final hashedKey = _legacyRewardLiability.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _legacyRewardLiability.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<int?> firstEligibleEra({_i1.BlockHash? at}) async {
    final hashedKey = _firstEligibleEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _firstEligibleEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> legacyCutoffEra({_i1.BlockHash? at}) async {
    final hashedKey = _legacyCutoffEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _legacyCutoffEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> lastObservedEra({_i1.BlockHash? at}) async {
    final hashedKey = _lastObservedEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _lastObservedEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<BigInt?> lastObservedEraStart({_i1.BlockHash? at}) async {
    final hashedKey = _lastObservedEraStart.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _lastObservedEraStart.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<BigInt?> emissionPeriodStart({_i1.BlockHash? at}) async {
    final hashedKey = _emissionPeriodStart.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _emissionPeriodStart.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<BigInt> grossIssuedInPeriod({_i1.BlockHash? at}) async {
    final hashedKey = _grossIssuedInPeriod.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _grossIssuedInPeriod.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> targetRemainder({_i1.BlockHash? at}) async {
    final hashedKey = _targetRemainder.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _targetRemainder.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<int> issuanceSplitCarry({_i1.BlockHash? at}) async {
    final hashedKey = _issuanceSplitCarry.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _issuanceSplitCarry.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i6.Future<BigInt> unallocatedFeeStaking({_i1.BlockHash? at}) async {
    final hashedKey = _unallocatedFeeStaking.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _unallocatedFeeStaking.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> unallocatedTipFallback({_i1.BlockHash? at}) async {
    final hashedKey = _unallocatedTipFallback.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _unallocatedTipFallback.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> unallocatedStakingCarry({_i1.BlockHash? at}) async {
    final hashedKey = _unallocatedStakingCarry.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _unallocatedStakingCarry.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Fresh-genesis principal is a funding source, not earned debt or mint allowance.
  /// Absent on historical/migration state: the old allocator behavior remains unchanged.
  _i6.Future<BigInt> unallocatedPrincipal({_i1.BlockHash? at}) async {
    final hashedKey = _unallocatedPrincipal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _unallocatedPrincipal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> principalReservedTotal({_i1.BlockHash? at}) async {
    final hashedKey = _principalReservedTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _principalReservedTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  /// Kept separate to retain the existing EraBudget SCALE layout.
  _i6.Future<BigInt> eraPrincipal(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraPrincipal.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraPrincipal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> pendingStakingFee({_i1.BlockHash? at}) async {
    final hashedKey = _pendingStakingFee.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingStakingFee.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> pendingTreasuryFee({_i1.BlockHash? at}) async {
    final hashedKey = _pendingTreasuryFee.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingTreasuryFee.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> pendingAuthorTips(
    _i3.AccountId32 key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _pendingAuthorTips.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingAuthorTips.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> pendingMissingAuthorTips({_i1.BlockHash? at}) async {
    final hashedKey = _pendingMissingAuthorTips.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingMissingAuthorTips.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> pendingTipTotal({_i1.BlockHash? at}) async {
    final hashedKey = _pendingTipTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingTipTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<_i4.EraBudget?> eraBudgets(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraBudgets.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraBudgets.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> eligibleValidatorPoints(
    int key1,
    _i3.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _eligibleValidatorPoints.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eligibleValidatorPoints.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<BigInt> eraPaid(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraPaid.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraPaid.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> validatorPaid(
    int key1,
    _i3.AccountId32 key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _validatorPaid.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _validatorPaid.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> eraLiability(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _eraLiability.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _eraLiability.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> committedLiabilities({_i1.BlockHash? at}) async {
    final hashedKey = _committedLiabilities.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _committedLiabilities.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<dynamic> claimedPages(
    int key1,
    _i5.Tuple2<_i3.AccountId32, int> key2, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _claimedPages.hashedKeyFor(key1, key2);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _claimedPages.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<dynamic> expiredEras(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _expiredEras.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _expiredEras.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> nextExpiryEra({_i1.BlockHash? at}) async {
    final hashedKey = _nextExpiryEra.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextExpiryEra.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<BigInt> stakingFundingTotal({_i1.BlockHash? at}) async {
    final hashedKey = _stakingFundingTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _stakingFundingTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> stakingPaidTotal({_i1.BlockHash? at}) async {
    final hashedKey = _stakingPaidTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _stakingPaidTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> treasuryIssuanceTotal({_i1.BlockHash? at}) async {
    final hashedKey = _treasuryIssuanceTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _treasuryIssuanceTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> treasuryNormalFeeTotal({_i1.BlockHash? at}) async {
    final hashedKey = _treasuryNormalFeeTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _treasuryNormalFeeTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> treasuryTipTotal({_i1.BlockHash? at}) async {
    final hashedKey = _treasuryTipTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _treasuryTipTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> normalFeeRoutedTotal({_i1.BlockHash? at}) async {
    final hashedKey = _normalFeeRoutedTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _normalFeeRoutedTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> authorTipPaidTotal({_i1.BlockHash? at}) async {
    final hashedKey = _authorTipPaidTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _authorTipPaidTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<BigInt> failedAuthorTipTotal({_i1.BlockHash? at}) async {
    final hashedKey = _failedAuthorTipTotal.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _failedAuthorTipTotal.decodeValue(bytes);
    }
    return BigInt.zero; /* Default */
  }

  _i6.Future<bool> allocationPaused({_i1.BlockHash? at}) async {
    final hashedKey = _allocationPaused.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _allocationPaused.decodeValue(bytes);
    }
    return false; /* Default */
  }

  /// Kept separate to retain the existing EraBudget SCALE layout.
  _i6.Future<List<BigInt>> multiEraPrincipal(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _eraPrincipal.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraPrincipal.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  _i6.Future<List<BigInt>> multiPendingAuthorTips(
    List<_i3.AccountId32> keys, {
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

  _i6.Future<List<_i4.EraBudget?>> multiEraBudgets(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _eraBudgets.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraBudgets.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i6.Future<List<BigInt>> multiEraPaid(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys.map((key) => _eraPaid.hashedKeyFor(key)).toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraPaid.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  _i6.Future<List<BigInt>> multiEraLiability(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _eraLiability.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _eraLiability.decodeValue(v.key))
          .toList();
    }
    return (keys.map((key) => BigInt.zero).toList()
        as List<BigInt>); /* Default */
  }

  _i6.Future<List<dynamic>> multiExpiredEras(
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

  /// Returns the storage key for `active`.
  _i7.Uint8List activeKey() {
    final hashedKey = _active.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `activatedAt`.
  _i7.Uint8List activatedAtKey() {
    final hashedKey = _activatedAt.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `migrationCompletedAt`.
  _i7.Uint8List migrationCompletedAtKey() {
    final hashedKey = _migrationCompletedAt.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `legacyRewardLiability`.
  _i7.Uint8List legacyRewardLiabilityKey() {
    final hashedKey = _legacyRewardLiability.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `firstEligibleEra`.
  _i7.Uint8List firstEligibleEraKey() {
    final hashedKey = _firstEligibleEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `legacyCutoffEra`.
  _i7.Uint8List legacyCutoffEraKey() {
    final hashedKey = _legacyCutoffEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `lastObservedEra`.
  _i7.Uint8List lastObservedEraKey() {
    final hashedKey = _lastObservedEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `lastObservedEraStart`.
  _i7.Uint8List lastObservedEraStartKey() {
    final hashedKey = _lastObservedEraStart.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `emissionPeriodStart`.
  _i7.Uint8List emissionPeriodStartKey() {
    final hashedKey = _emissionPeriodStart.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `grossIssuedInPeriod`.
  _i7.Uint8List grossIssuedInPeriodKey() {
    final hashedKey = _grossIssuedInPeriod.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `targetRemainder`.
  _i7.Uint8List targetRemainderKey() {
    final hashedKey = _targetRemainder.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `issuanceSplitCarry`.
  _i7.Uint8List issuanceSplitCarryKey() {
    final hashedKey = _issuanceSplitCarry.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `unallocatedFeeStaking`.
  _i7.Uint8List unallocatedFeeStakingKey() {
    final hashedKey = _unallocatedFeeStaking.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `unallocatedTipFallback`.
  _i7.Uint8List unallocatedTipFallbackKey() {
    final hashedKey = _unallocatedTipFallback.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `unallocatedStakingCarry`.
  _i7.Uint8List unallocatedStakingCarryKey() {
    final hashedKey = _unallocatedStakingCarry.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `unallocatedPrincipal`.
  _i7.Uint8List unallocatedPrincipalKey() {
    final hashedKey = _unallocatedPrincipal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `principalReservedTotal`.
  _i7.Uint8List principalReservedTotalKey() {
    final hashedKey = _principalReservedTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `eraPrincipal`.
  _i7.Uint8List eraPrincipalKey(int key1) {
    final hashedKey = _eraPrincipal.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `pendingStakingFee`.
  _i7.Uint8List pendingStakingFeeKey() {
    final hashedKey = _pendingStakingFee.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingTreasuryFee`.
  _i7.Uint8List pendingTreasuryFeeKey() {
    final hashedKey = _pendingTreasuryFee.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingAuthorTips`.
  _i7.Uint8List pendingAuthorTipsKey(_i3.AccountId32 key1) {
    final hashedKey = _pendingAuthorTips.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `pendingMissingAuthorTips`.
  _i7.Uint8List pendingMissingAuthorTipsKey() {
    final hashedKey = _pendingMissingAuthorTips.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingTipTotal`.
  _i7.Uint8List pendingTipTotalKey() {
    final hashedKey = _pendingTipTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `eraBudgets`.
  _i7.Uint8List eraBudgetsKey(int key1) {
    final hashedKey = _eraBudgets.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `eligibleValidatorPoints`.
  _i7.Uint8List eligibleValidatorPointsKey(int key1, _i3.AccountId32 key2) {
    final hashedKey = _eligibleValidatorPoints.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `eraPaid`.
  _i7.Uint8List eraPaidKey(int key1) {
    final hashedKey = _eraPaid.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `validatorPaid`.
  _i7.Uint8List validatorPaidKey(int key1, _i3.AccountId32 key2) {
    final hashedKey = _validatorPaid.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `eraLiability`.
  _i7.Uint8List eraLiabilityKey(int key1) {
    final hashedKey = _eraLiability.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `committedLiabilities`.
  _i7.Uint8List committedLiabilitiesKey() {
    final hashedKey = _committedLiabilities.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `claimedPages`.
  _i7.Uint8List claimedPagesKey(
    int key1,
    _i5.Tuple2<_i3.AccountId32, int> key2,
  ) {
    final hashedKey = _claimedPages.hashedKeyFor(key1, key2);
    return hashedKey;
  }

  /// Returns the storage key for `expiredEras`.
  _i7.Uint8List expiredErasKey(int key1) {
    final hashedKey = _expiredEras.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `nextExpiryEra`.
  _i7.Uint8List nextExpiryEraKey() {
    final hashedKey = _nextExpiryEra.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `stakingFundingTotal`.
  _i7.Uint8List stakingFundingTotalKey() {
    final hashedKey = _stakingFundingTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `stakingPaidTotal`.
  _i7.Uint8List stakingPaidTotalKey() {
    final hashedKey = _stakingPaidTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `treasuryIssuanceTotal`.
  _i7.Uint8List treasuryIssuanceTotalKey() {
    final hashedKey = _treasuryIssuanceTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `treasuryNormalFeeTotal`.
  _i7.Uint8List treasuryNormalFeeTotalKey() {
    final hashedKey = _treasuryNormalFeeTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `treasuryTipTotal`.
  _i7.Uint8List treasuryTipTotalKey() {
    final hashedKey = _treasuryTipTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `normalFeeRoutedTotal`.
  _i7.Uint8List normalFeeRoutedTotalKey() {
    final hashedKey = _normalFeeRoutedTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `authorTipPaidTotal`.
  _i7.Uint8List authorTipPaidTotalKey() {
    final hashedKey = _authorTipPaidTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `failedAuthorTipTotal`.
  _i7.Uint8List failedAuthorTipTotalKey() {
    final hashedKey = _failedAuthorTipTotal.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `allocationPaused`.
  _i7.Uint8List allocationPausedKey() {
    final hashedKey = _allocationPaused.hashedKey();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraPrincipal`.
  _i7.Uint8List eraPrincipalMapPrefix() {
    final hashedKey = _eraPrincipal.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `pendingAuthorTips`.
  _i7.Uint8List pendingAuthorTipsMapPrefix() {
    final hashedKey = _pendingAuthorTips.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraBudgets`.
  _i7.Uint8List eraBudgetsMapPrefix() {
    final hashedKey = _eraBudgets.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eligibleValidatorPoints`.
  _i7.Uint8List eligibleValidatorPointsMapPrefix(int key1) {
    final hashedKey = _eligibleValidatorPoints.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraPaid`.
  _i7.Uint8List eraPaidMapPrefix() {
    final hashedKey = _eraPaid.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `validatorPaid`.
  _i7.Uint8List validatorPaidMapPrefix(int key1) {
    final hashedKey = _validatorPaid.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `eraLiability`.
  _i7.Uint8List eraLiabilityMapPrefix() {
    final hashedKey = _eraLiability.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `claimedPages`.
  _i7.Uint8List claimedPagesMapPrefix(int key1) {
    final hashedKey = _claimedPages.mapPrefix(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `expiredEras`.
  _i7.Uint8List expiredErasMapPrefix() {
    final hashedKey = _expiredEras.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  _i8.SecurityBudget activate() {
    return _i8.SecurityBudget(_i9.Activate());
  }

  _i8.SecurityBudget claimRewardPage({
    required int era,
    required _i3.AccountId32 validator,
    required int page,
  }) {
    return _i8.SecurityBudget(
      _i9.ClaimRewardPage(era: era, validator: validator, page: page),
    );
  }

  _i8.SecurityBudget retryNormalFee() {
    return _i8.SecurityBudget(_i9.RetryNormalFee());
  }

  _i8.SecurityBudget retryTip({_i3.AccountId32? author}) {
    return _i8.SecurityBudget(_i9.RetryTip(author: author));
  }
}

class Constants {
  Constants();

  final _i10.PalletId stakingPotPalletId = const <int>[
    101,
    114,
    97,
    47,
    118,
    49,
    52,
    115,
  ];

  final _i10.PalletId treasuryPalletId = const <int>[
    101,
    114,
    97,
    47,
    116,
    114,
    101,
    97,
  ];

  final _i10.PalletId v14FeeCollectionPalletId = const <int>[
    101,
    114,
    97,
    47,
    102,
    101,
    101,
    115,
  ];

  final BigInt minimumValidatorBond = BigInt.parse(
    '10000000000000000000000',
    radix: 10,
  );

  final _i11.Perbill maximumValidatorCommission = 200000000;

  final _i11.Perbill targetStakingApr = 100000000;

  final BigInt grossAnnualIssuanceCeiling = BigInt.parse(
    '6000000000000000000000000',
    radix: 10,
  );

  /// Lifetime validator/nominator reward budget, including the migrated legacy liability.
  final BigInt totalStakingRewardBudget = BigInt.parse(
    '20000000000000000000000000',
    radix: 10,
  );

  /// Separate protected allocation that this pallet must never spend.
  final BigInt protectedCommunityOnboardingBudget = BigInt.parse(
    '10000000000000000000000000',
    radix: 10,
  );

  /// The retired legacy allocator has no post-V14 reward target.
  final BigInt retiredLegacyRewardReserveTarget = BigInt.zero;

  final BigInt securityMillisecondsPerYear = BigInt.from(31556952000);

  final int runtimeTechnicalMaxValidators = 16;

  final int activationValidatorCount = 4;

  final int v14MaxRewardNominatorsPerPage = 64;

  final int maxExposurePages = 1;
}
