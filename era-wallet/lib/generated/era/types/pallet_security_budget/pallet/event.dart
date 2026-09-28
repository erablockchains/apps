// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i9;

import '../../sp_core/crypto/account_id32.dart' as _i3;
import 'allocation_failure_reason.dart' as _i8;
import 'era_skip_reason.dart' as _i4;
import 'issuance_limit.dart' as _i5;
import 'tip_fallback_reason.dart' as _i6;
import 'treasury_source.dart' as _i7;

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

  MigrationCompleted migrationCompleted({
    required int at,
    required _i3.AccountId32 stakingPot,
    required BigInt minimumValidatorBond,
    required int activeValidatorCount,
    required BigInt legacyRewardLiability,
    required BigInt totalRewardBudget,
  }) {
    return MigrationCompleted(
      at: at,
      stakingPot: stakingPot,
      minimumValidatorBond: minimumValidatorBond,
      activeValidatorCount: activeValidatorCount,
      legacyRewardLiability: legacyRewardLiability,
      totalRewardBudget: totalRewardBudget,
    );
  }

  Activated activated({
    required int at,
    required int legacyCutoffEra,
    required int firstEligibleEra,
    required _i3.AccountId32 stakingPot,
    required _i3.AccountId32 treasury,
  }) {
    return Activated(
      at: at,
      legacyCutoffEra: legacyCutoffEra,
      firstEligibleEra: firstEligibleEra,
      stakingPot: stakingPot,
      treasury: treasury,
    );
  }

  EraSkipped eraSkipped({required int era, required _i4.EraSkipReason reason}) {
    return EraSkipped(era: era, reason: reason);
  }

  IssuanceTargetCalculated issuanceTargetCalculated({
    required int era,
    required BigInt stakingTarget,
    required BigInt grossTarget,
    required BigInt grossIssued,
    required _i5.IssuanceLimit limit,
  }) {
    return IssuanceTargetCalculated(
      era: era,
      stakingTarget: stakingTarget,
      grossTarget: grossTarget,
      grossIssued: grossIssued,
      limit: limit,
    );
  }

  EraBudgetReserved eraBudgetReserved({
    required int era,
    required BigInt grossIssuance,
    required BigInt stakingIssuance,
    required BigInt treasuryIssuance,
    required BigInt feeStaking,
    required BigInt failedAuthorTips,
    required BigInt retainedCarry,
    required BigInt total,
    required BigInt remainingAllowance,
  }) {
    return EraBudgetReserved(
      era: era,
      grossIssuance: grossIssuance,
      stakingIssuance: stakingIssuance,
      treasuryIssuance: treasuryIssuance,
      feeStaking: feeStaking,
      failedAuthorTips: failedAuthorTips,
      retainedCarry: retainedCarry,
      total: total,
      remainingAllowance: remainingAllowance,
    );
  }

  NormalFeeStaged normalFeeStaged({
    required BigInt amount,
    required BigInt staking,
    required BigInt treasury,
  }) {
    return NormalFeeStaged(
      amount: amount,
      staking: staking,
      treasury: treasury,
    );
  }

  NormalFeeRouted normalFeeRouted({
    required BigInt amount,
    required BigInt staking,
    required BigInt treasury,
  }) {
    return NormalFeeRouted(
      amount: amount,
      staking: staking,
      treasury: treasury,
    );
  }

  NormalFeeDeferred normalFeeDeferred({
    required BigInt staking,
    required BigInt treasury,
  }) {
    return NormalFeeDeferred(staking: staking, treasury: treasury);
  }

  TipStaged tipStaged({required BigInt amount, _i3.AccountId32? author}) {
    return TipStaged(amount: amount, author: author);
  }

  TipRouted tipRouted({
    required BigInt amount,
    required _i3.AccountId32 author,
    required BigInt authorShare,
    required BigInt treasury,
  }) {
    return TipRouted(
      amount: amount,
      author: author,
      authorShare: authorShare,
      treasury: treasury,
    );
  }

  TipFallback tipFallback({
    required BigInt amount,
    required BigInt staking,
    required BigInt treasury,
    required _i6.TipFallbackReason reason,
  }) {
    return TipFallback(
      amount: amount,
      staking: staking,
      treasury: treasury,
      reason: reason,
    );
  }

  TipDeferred tipDeferred({required BigInt amount, _i3.AccountId32? author}) {
    return TipDeferred(amount: amount, author: author);
  }

  TreasuryInflow treasuryInflow({
    required _i7.TreasurySource source,
    required BigInt amount,
    required BigInt sourceTotal,
  }) {
    return TreasuryInflow(
      source: source,
      amount: amount,
      sourceTotal: sourceTotal,
    );
  }

  ValidatorRewardPaid validatorRewardPaid({
    required int era,
    required _i3.AccountId32 validator,
    required int page,
    required BigInt amount,
    required BigInt commission,
  }) {
    return ValidatorRewardPaid(
      era: era,
      validator: validator,
      page: page,
      amount: amount,
      commission: commission,
    );
  }

  NominatorRewardPaid nominatorRewardPaid({
    required int era,
    required _i3.AccountId32 validator,
    required _i3.AccountId32 nominator,
    required int page,
    required BigInt amount,
  }) {
    return NominatorRewardPaid(
      era: era,
      validator: validator,
      nominator: nominator,
      page: page,
      amount: amount,
    );
  }

  RewardPagePaid rewardPagePaid({
    required int era,
    required _i3.AccountId32 validator,
    required int page,
    required BigInt amount,
  }) {
    return RewardPagePaid(
      era: era,
      validator: validator,
      page: page,
      amount: amount,
    );
  }

  LiabilityReleased liabilityReleased({
    required int era,
    required BigInt amount,
    required bool expired,
  }) {
    return LiabilityReleased(era: era, amount: amount, expired: expired);
  }

  AllocationPaused allocationPaused({
    required int era,
    required _i8.AllocationFailureReason reason,
  }) {
    return AllocationPaused(era: era, reason: reason);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return MigrationCompleted._decode(input);
      case 1:
        return Activated._decode(input);
      case 2:
        return EraSkipped._decode(input);
      case 3:
        return IssuanceTargetCalculated._decode(input);
      case 4:
        return EraBudgetReserved._decode(input);
      case 5:
        return NormalFeeStaged._decode(input);
      case 6:
        return NormalFeeRouted._decode(input);
      case 7:
        return NormalFeeDeferred._decode(input);
      case 8:
        return TipStaged._decode(input);
      case 9:
        return TipRouted._decode(input);
      case 10:
        return TipFallback._decode(input);
      case 11:
        return TipDeferred._decode(input);
      case 12:
        return TreasuryInflow._decode(input);
      case 13:
        return ValidatorRewardPaid._decode(input);
      case 14:
        return NominatorRewardPaid._decode(input);
      case 15:
        return RewardPagePaid._decode(input);
      case 16:
        return LiabilityReleased._decode(input);
      case 17:
        return AllocationPaused._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case MigrationCompleted:
        (value as MigrationCompleted).encodeTo(output);
        break;
      case Activated:
        (value as Activated).encodeTo(output);
        break;
      case EraSkipped:
        (value as EraSkipped).encodeTo(output);
        break;
      case IssuanceTargetCalculated:
        (value as IssuanceTargetCalculated).encodeTo(output);
        break;
      case EraBudgetReserved:
        (value as EraBudgetReserved).encodeTo(output);
        break;
      case NormalFeeStaged:
        (value as NormalFeeStaged).encodeTo(output);
        break;
      case NormalFeeRouted:
        (value as NormalFeeRouted).encodeTo(output);
        break;
      case NormalFeeDeferred:
        (value as NormalFeeDeferred).encodeTo(output);
        break;
      case TipStaged:
        (value as TipStaged).encodeTo(output);
        break;
      case TipRouted:
        (value as TipRouted).encodeTo(output);
        break;
      case TipFallback:
        (value as TipFallback).encodeTo(output);
        break;
      case TipDeferred:
        (value as TipDeferred).encodeTo(output);
        break;
      case TreasuryInflow:
        (value as TreasuryInflow).encodeTo(output);
        break;
      case ValidatorRewardPaid:
        (value as ValidatorRewardPaid).encodeTo(output);
        break;
      case NominatorRewardPaid:
        (value as NominatorRewardPaid).encodeTo(output);
        break;
      case RewardPagePaid:
        (value as RewardPagePaid).encodeTo(output);
        break;
      case LiabilityReleased:
        (value as LiabilityReleased).encodeTo(output);
        break;
      case AllocationPaused:
        (value as AllocationPaused).encodeTo(output);
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
      case MigrationCompleted:
        return (value as MigrationCompleted)._sizeHint();
      case Activated:
        return (value as Activated)._sizeHint();
      case EraSkipped:
        return (value as EraSkipped)._sizeHint();
      case IssuanceTargetCalculated:
        return (value as IssuanceTargetCalculated)._sizeHint();
      case EraBudgetReserved:
        return (value as EraBudgetReserved)._sizeHint();
      case NormalFeeStaged:
        return (value as NormalFeeStaged)._sizeHint();
      case NormalFeeRouted:
        return (value as NormalFeeRouted)._sizeHint();
      case NormalFeeDeferred:
        return (value as NormalFeeDeferred)._sizeHint();
      case TipStaged:
        return (value as TipStaged)._sizeHint();
      case TipRouted:
        return (value as TipRouted)._sizeHint();
      case TipFallback:
        return (value as TipFallback)._sizeHint();
      case TipDeferred:
        return (value as TipDeferred)._sizeHint();
      case TreasuryInflow:
        return (value as TreasuryInflow)._sizeHint();
      case ValidatorRewardPaid:
        return (value as ValidatorRewardPaid)._sizeHint();
      case NominatorRewardPaid:
        return (value as NominatorRewardPaid)._sizeHint();
      case RewardPagePaid:
        return (value as RewardPagePaid)._sizeHint();
      case LiabilityReleased:
        return (value as LiabilityReleased)._sizeHint();
      case AllocationPaused:
        return (value as AllocationPaused)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class MigrationCompleted extends Event {
  const MigrationCompleted({
    required this.at,
    required this.stakingPot,
    required this.minimumValidatorBond,
    required this.activeValidatorCount,
    required this.legacyRewardLiability,
    required this.totalRewardBudget,
  });

  factory MigrationCompleted._decode(_i1.Input input) {
    return MigrationCompleted(
      at: _i1.U32Codec.codec.decode(input),
      stakingPot: const _i1.U8ArrayCodec(32).decode(input),
      minimumValidatorBond: _i1.U128Codec.codec.decode(input),
      activeValidatorCount: _i1.U32Codec.codec.decode(input),
      legacyRewardLiability: _i1.U128Codec.codec.decode(input),
      totalRewardBudget: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BlockNumberFor<T>
  final int at;

  /// T::AccountId
  final _i3.AccountId32 stakingPot;

  /// u128
  final BigInt minimumValidatorBond;

  /// u32
  final int activeValidatorCount;

  /// u128
  final BigInt legacyRewardLiability;

  /// u128
  final BigInt totalRewardBudget;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'MigrationCompleted': {
      'at': at,
      'stakingPot': stakingPot.toList(),
      'minimumValidatorBond': minimumValidatorBond,
      'activeValidatorCount': activeValidatorCount,
      'legacyRewardLiability': legacyRewardLiability,
      'totalRewardBudget': totalRewardBudget,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(at);
    size = size + const _i3.AccountId32Codec().sizeHint(stakingPot);
    size = size + _i1.U128Codec.codec.sizeHint(minimumValidatorBond);
    size = size + _i1.U32Codec.codec.sizeHint(activeValidatorCount);
    size = size + _i1.U128Codec.codec.sizeHint(legacyRewardLiability);
    size = size + _i1.U128Codec.codec.sizeHint(totalRewardBudget);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U32Codec.codec.encodeTo(at, output);
    const _i1.U8ArrayCodec(32).encodeTo(stakingPot, output);
    _i1.U128Codec.codec.encodeTo(minimumValidatorBond, output);
    _i1.U32Codec.codec.encodeTo(activeValidatorCount, output);
    _i1.U128Codec.codec.encodeTo(legacyRewardLiability, output);
    _i1.U128Codec.codec.encodeTo(totalRewardBudget, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MigrationCompleted &&
          other.at == at &&
          _i9.listsEqual(other.stakingPot, stakingPot) &&
          other.minimumValidatorBond == minimumValidatorBond &&
          other.activeValidatorCount == activeValidatorCount &&
          other.legacyRewardLiability == legacyRewardLiability &&
          other.totalRewardBudget == totalRewardBudget;

  @override
  int get hashCode => Object.hash(
    at,
    stakingPot,
    minimumValidatorBond,
    activeValidatorCount,
    legacyRewardLiability,
    totalRewardBudget,
  );
}

class Activated extends Event {
  const Activated({
    required this.at,
    required this.legacyCutoffEra,
    required this.firstEligibleEra,
    required this.stakingPot,
    required this.treasury,
  });

  factory Activated._decode(_i1.Input input) {
    return Activated(
      at: _i1.U32Codec.codec.decode(input),
      legacyCutoffEra: _i1.U32Codec.codec.decode(input),
      firstEligibleEra: _i1.U32Codec.codec.decode(input),
      stakingPot: const _i1.U8ArrayCodec(32).decode(input),
      treasury: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// BlockNumberFor<T>
  final int at;

  /// EraIndex
  final int legacyCutoffEra;

  /// EraIndex
  final int firstEligibleEra;

  /// T::AccountId
  final _i3.AccountId32 stakingPot;

  /// T::AccountId
  final _i3.AccountId32 treasury;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'Activated': {
      'at': at,
      'legacyCutoffEra': legacyCutoffEra,
      'firstEligibleEra': firstEligibleEra,
      'stakingPot': stakingPot.toList(),
      'treasury': treasury.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(at);
    size = size + _i1.U32Codec.codec.sizeHint(legacyCutoffEra);
    size = size + _i1.U32Codec.codec.sizeHint(firstEligibleEra);
    size = size + const _i3.AccountId32Codec().sizeHint(stakingPot);
    size = size + const _i3.AccountId32Codec().sizeHint(treasury);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U32Codec.codec.encodeTo(at, output);
    _i1.U32Codec.codec.encodeTo(legacyCutoffEra, output);
    _i1.U32Codec.codec.encodeTo(firstEligibleEra, output);
    const _i1.U8ArrayCodec(32).encodeTo(stakingPot, output);
    const _i1.U8ArrayCodec(32).encodeTo(treasury, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activated &&
          other.at == at &&
          other.legacyCutoffEra == legacyCutoffEra &&
          other.firstEligibleEra == firstEligibleEra &&
          _i9.listsEqual(other.stakingPot, stakingPot) &&
          _i9.listsEqual(other.treasury, treasury);

  @override
  int get hashCode =>
      Object.hash(at, legacyCutoffEra, firstEligibleEra, stakingPot, treasury);
}

class EraSkipped extends Event {
  const EraSkipped({required this.era, required this.reason});

  factory EraSkipped._decode(_i1.Input input) {
    return EraSkipped(
      era: _i1.U32Codec.codec.decode(input),
      reason: _i4.EraSkipReason.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// EraSkipReason
  final _i4.EraSkipReason reason;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraSkipped': {'era': era, 'reason': reason.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i4.EraSkipReason.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i4.EraSkipReason.codec.encodeTo(reason, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraSkipped && other.era == era && other.reason == reason;

  @override
  int get hashCode => Object.hash(era, reason);
}

class IssuanceTargetCalculated extends Event {
  const IssuanceTargetCalculated({
    required this.era,
    required this.stakingTarget,
    required this.grossTarget,
    required this.grossIssued,
    required this.limit,
  });

  factory IssuanceTargetCalculated._decode(_i1.Input input) {
    return IssuanceTargetCalculated(
      era: _i1.U32Codec.codec.decode(input),
      stakingTarget: _i1.U128Codec.codec.decode(input),
      grossTarget: _i1.U128Codec.codec.decode(input),
      grossIssued: _i1.U128Codec.codec.decode(input),
      limit: _i5.IssuanceLimit.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// u128
  final BigInt stakingTarget;

  /// u128
  final BigInt grossTarget;

  /// u128
  final BigInt grossIssued;

  /// IssuanceLimit
  final _i5.IssuanceLimit limit;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'IssuanceTargetCalculated': {
      'era': era,
      'stakingTarget': stakingTarget,
      'grossTarget': grossTarget,
      'grossIssued': grossIssued,
      'limit': limit.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(stakingTarget);
    size = size + _i1.U128Codec.codec.sizeHint(grossTarget);
    size = size + _i1.U128Codec.codec.sizeHint(grossIssued);
    size = size + _i5.IssuanceLimit.codec.sizeHint(limit);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(stakingTarget, output);
    _i1.U128Codec.codec.encodeTo(grossTarget, output);
    _i1.U128Codec.codec.encodeTo(grossIssued, output);
    _i5.IssuanceLimit.codec.encodeTo(limit, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssuanceTargetCalculated &&
          other.era == era &&
          other.stakingTarget == stakingTarget &&
          other.grossTarget == grossTarget &&
          other.grossIssued == grossIssued &&
          other.limit == limit;

  @override
  int get hashCode =>
      Object.hash(era, stakingTarget, grossTarget, grossIssued, limit);
}

class EraBudgetReserved extends Event {
  const EraBudgetReserved({
    required this.era,
    required this.grossIssuance,
    required this.stakingIssuance,
    required this.treasuryIssuance,
    required this.feeStaking,
    required this.failedAuthorTips,
    required this.retainedCarry,
    required this.total,
    required this.remainingAllowance,
  });

  factory EraBudgetReserved._decode(_i1.Input input) {
    return EraBudgetReserved(
      era: _i1.U32Codec.codec.decode(input),
      grossIssuance: _i1.U128Codec.codec.decode(input),
      stakingIssuance: _i1.U128Codec.codec.decode(input),
      treasuryIssuance: _i1.U128Codec.codec.decode(input),
      feeStaking: _i1.U128Codec.codec.decode(input),
      failedAuthorTips: _i1.U128Codec.codec.decode(input),
      retainedCarry: _i1.U128Codec.codec.decode(input),
      total: _i1.U128Codec.codec.decode(input),
      remainingAllowance: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// u128
  final BigInt grossIssuance;

  /// u128
  final BigInt stakingIssuance;

  /// u128
  final BigInt treasuryIssuance;

  /// u128
  final BigInt feeStaking;

  /// u128
  final BigInt failedAuthorTips;

  /// u128
  final BigInt retainedCarry;

  /// u128
  final BigInt total;

  /// u128
  final BigInt remainingAllowance;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraBudgetReserved': {
      'era': era,
      'grossIssuance': grossIssuance,
      'stakingIssuance': stakingIssuance,
      'treasuryIssuance': treasuryIssuance,
      'feeStaking': feeStaking,
      'failedAuthorTips': failedAuthorTips,
      'retainedCarry': retainedCarry,
      'total': total,
      'remainingAllowance': remainingAllowance,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(grossIssuance);
    size = size + _i1.U128Codec.codec.sizeHint(stakingIssuance);
    size = size + _i1.U128Codec.codec.sizeHint(treasuryIssuance);
    size = size + _i1.U128Codec.codec.sizeHint(feeStaking);
    size = size + _i1.U128Codec.codec.sizeHint(failedAuthorTips);
    size = size + _i1.U128Codec.codec.sizeHint(retainedCarry);
    size = size + _i1.U128Codec.codec.sizeHint(total);
    size = size + _i1.U128Codec.codec.sizeHint(remainingAllowance);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(grossIssuance, output);
    _i1.U128Codec.codec.encodeTo(stakingIssuance, output);
    _i1.U128Codec.codec.encodeTo(treasuryIssuance, output);
    _i1.U128Codec.codec.encodeTo(feeStaking, output);
    _i1.U128Codec.codec.encodeTo(failedAuthorTips, output);
    _i1.U128Codec.codec.encodeTo(retainedCarry, output);
    _i1.U128Codec.codec.encodeTo(total, output);
    _i1.U128Codec.codec.encodeTo(remainingAllowance, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraBudgetReserved &&
          other.era == era &&
          other.grossIssuance == grossIssuance &&
          other.stakingIssuance == stakingIssuance &&
          other.treasuryIssuance == treasuryIssuance &&
          other.feeStaking == feeStaking &&
          other.failedAuthorTips == failedAuthorTips &&
          other.retainedCarry == retainedCarry &&
          other.total == total &&
          other.remainingAllowance == remainingAllowance;

  @override
  int get hashCode => Object.hash(
    era,
    grossIssuance,
    stakingIssuance,
    treasuryIssuance,
    feeStaking,
    failedAuthorTips,
    retainedCarry,
    total,
    remainingAllowance,
  );
}

class NormalFeeStaged extends Event {
  const NormalFeeStaged({
    required this.amount,
    required this.staking,
    required this.treasury,
  });

  factory NormalFeeStaged._decode(_i1.Input input) {
    return NormalFeeStaged(
      amount: _i1.U128Codec.codec.decode(input),
      staking: _i1.U128Codec.codec.decode(input),
      treasury: _i1.U128Codec.codec.decode(input),
    );
  }

  /// u128
  final BigInt amount;

  /// u128
  final BigInt staking;

  /// u128
  final BigInt treasury;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'NormalFeeStaged': {
      'amount': amount,
      'staking': staking,
      'treasury': treasury,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(staking);
    size = size + _i1.U128Codec.codec.sizeHint(treasury);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(staking, output);
    _i1.U128Codec.codec.encodeTo(treasury, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NormalFeeStaged &&
          other.amount == amount &&
          other.staking == staking &&
          other.treasury == treasury;

  @override
  int get hashCode => Object.hash(amount, staking, treasury);
}

class NormalFeeRouted extends Event {
  const NormalFeeRouted({
    required this.amount,
    required this.staking,
    required this.treasury,
  });

  factory NormalFeeRouted._decode(_i1.Input input) {
    return NormalFeeRouted(
      amount: _i1.U128Codec.codec.decode(input),
      staking: _i1.U128Codec.codec.decode(input),
      treasury: _i1.U128Codec.codec.decode(input),
    );
  }

  /// u128
  final BigInt amount;

  /// u128
  final BigInt staking;

  /// u128
  final BigInt treasury;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'NormalFeeRouted': {
      'amount': amount,
      'staking': staking,
      'treasury': treasury,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(staking);
    size = size + _i1.U128Codec.codec.sizeHint(treasury);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(staking, output);
    _i1.U128Codec.codec.encodeTo(treasury, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NormalFeeRouted &&
          other.amount == amount &&
          other.staking == staking &&
          other.treasury == treasury;

  @override
  int get hashCode => Object.hash(amount, staking, treasury);
}

class NormalFeeDeferred extends Event {
  const NormalFeeDeferred({required this.staking, required this.treasury});

  factory NormalFeeDeferred._decode(_i1.Input input) {
    return NormalFeeDeferred(
      staking: _i1.U128Codec.codec.decode(input),
      treasury: _i1.U128Codec.codec.decode(input),
    );
  }

  /// u128
  final BigInt staking;

  /// u128
  final BigInt treasury;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'NormalFeeDeferred': {'staking': staking, 'treasury': treasury},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(staking);
    size = size + _i1.U128Codec.codec.sizeHint(treasury);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(7, output);
    _i1.U128Codec.codec.encodeTo(staking, output);
    _i1.U128Codec.codec.encodeTo(treasury, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NormalFeeDeferred &&
          other.staking == staking &&
          other.treasury == treasury;

  @override
  int get hashCode => Object.hash(staking, treasury);
}

class TipStaged extends Event {
  const TipStaged({required this.amount, this.author});

  factory TipStaged._decode(_i1.Input input) {
    return TipStaged(
      amount: _i1.U128Codec.codec.decode(input),
      author: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// u128
  final BigInt amount;

  /// Option<T::AccountId>
  final _i3.AccountId32? author;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'TipStaged': {'amount': amount, 'author': author?.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(author);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(8, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(author, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipStaged && other.amount == amount && other.author == author;

  @override
  int get hashCode => Object.hash(amount, author);
}

class TipRouted extends Event {
  const TipRouted({
    required this.amount,
    required this.author,
    required this.authorShare,
    required this.treasury,
  });

  factory TipRouted._decode(_i1.Input input) {
    return TipRouted(
      amount: _i1.U128Codec.codec.decode(input),
      author: const _i1.U8ArrayCodec(32).decode(input),
      authorShare: _i1.U128Codec.codec.decode(input),
      treasury: _i1.U128Codec.codec.decode(input),
    );
  }

  /// u128
  final BigInt amount;

  /// T::AccountId
  final _i3.AccountId32 author;

  /// u128
  final BigInt authorShare;

  /// u128
  final BigInt treasury;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'TipRouted': {
      'amount': amount,
      'author': author.toList(),
      'authorShare': authorShare,
      'treasury': treasury,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + const _i3.AccountId32Codec().sizeHint(author);
    size = size + _i1.U128Codec.codec.sizeHint(authorShare);
    size = size + _i1.U128Codec.codec.sizeHint(treasury);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(9, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    const _i1.U8ArrayCodec(32).encodeTo(author, output);
    _i1.U128Codec.codec.encodeTo(authorShare, output);
    _i1.U128Codec.codec.encodeTo(treasury, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipRouted &&
          other.amount == amount &&
          _i9.listsEqual(other.author, author) &&
          other.authorShare == authorShare &&
          other.treasury == treasury;

  @override
  int get hashCode => Object.hash(amount, author, authorShare, treasury);
}

class TipFallback extends Event {
  const TipFallback({
    required this.amount,
    required this.staking,
    required this.treasury,
    required this.reason,
  });

  factory TipFallback._decode(_i1.Input input) {
    return TipFallback(
      amount: _i1.U128Codec.codec.decode(input),
      staking: _i1.U128Codec.codec.decode(input),
      treasury: _i1.U128Codec.codec.decode(input),
      reason: _i6.TipFallbackReason.codec.decode(input),
    );
  }

  /// u128
  final BigInt amount;

  /// u128
  final BigInt staking;

  /// u128
  final BigInt treasury;

  /// TipFallbackReason
  final _i6.TipFallbackReason reason;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'TipFallback': {
      'amount': amount,
      'staking': staking,
      'treasury': treasury,
      'reason': reason.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(staking);
    size = size + _i1.U128Codec.codec.sizeHint(treasury);
    size = size + _i6.TipFallbackReason.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(staking, output);
    _i1.U128Codec.codec.encodeTo(treasury, output);
    _i6.TipFallbackReason.codec.encodeTo(reason, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipFallback &&
          other.amount == amount &&
          other.staking == staking &&
          other.treasury == treasury &&
          other.reason == reason;

  @override
  int get hashCode => Object.hash(amount, staking, treasury, reason);
}

class TipDeferred extends Event {
  const TipDeferred({required this.amount, this.author});

  factory TipDeferred._decode(_i1.Input input) {
    return TipDeferred(
      amount: _i1.U128Codec.codec.decode(input),
      author: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// u128
  final BigInt amount;

  /// Option<T::AccountId>
  final _i3.AccountId32? author;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'TipDeferred': {'amount': amount, 'author': author?.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(author);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(author, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipDeferred && other.amount == amount && other.author == author;

  @override
  int get hashCode => Object.hash(amount, author);
}

class TreasuryInflow extends Event {
  const TreasuryInflow({
    required this.source,
    required this.amount,
    required this.sourceTotal,
  });

  factory TreasuryInflow._decode(_i1.Input input) {
    return TreasuryInflow(
      source: _i7.TreasurySource.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      sourceTotal: _i1.U128Codec.codec.decode(input),
    );
  }

  /// TreasurySource
  final _i7.TreasurySource source;

  /// u128
  final BigInt amount;

  /// u128
  final BigInt sourceTotal;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'TreasuryInflow': {
      'source': source.toJson(),
      'amount': amount,
      'sourceTotal': sourceTotal,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i7.TreasurySource.codec.sizeHint(source);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(sourceTotal);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(12, output);
    _i7.TreasurySource.codec.encodeTo(source, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(sourceTotal, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreasuryInflow &&
          other.source == source &&
          other.amount == amount &&
          other.sourceTotal == sourceTotal;

  @override
  int get hashCode => Object.hash(source, amount, sourceTotal);
}

class ValidatorRewardPaid extends Event {
  const ValidatorRewardPaid({
    required this.era,
    required this.validator,
    required this.page,
    required this.amount,
    required this.commission,
  });

  factory ValidatorRewardPaid._decode(_i1.Input input) {
    return ValidatorRewardPaid(
      era: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      page: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      commission: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// T::AccountId
  final _i3.AccountId32 validator;

  /// Page
  final int page;

  /// u128
  final BigInt amount;

  /// u128
  final BigInt commission;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ValidatorRewardPaid': {
      'era': era,
      'validator': validator.toList(),
      'page': page,
      'amount': amount,
      'commission': commission,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + const _i3.AccountId32Codec().sizeHint(validator);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(commission);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(13, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    _i1.U32Codec.codec.encodeTo(page, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(commission, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatorRewardPaid &&
          other.era == era &&
          _i9.listsEqual(other.validator, validator) &&
          other.page == page &&
          other.amount == amount &&
          other.commission == commission;

  @override
  int get hashCode => Object.hash(era, validator, page, amount, commission);
}

class NominatorRewardPaid extends Event {
  const NominatorRewardPaid({
    required this.era,
    required this.validator,
    required this.nominator,
    required this.page,
    required this.amount,
  });

  factory NominatorRewardPaid._decode(_i1.Input input) {
    return NominatorRewardPaid(
      era: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      nominator: const _i1.U8ArrayCodec(32).decode(input),
      page: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// T::AccountId
  final _i3.AccountId32 validator;

  /// T::AccountId
  final _i3.AccountId32 nominator;

  /// Page
  final int page;

  /// u128
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'NominatorRewardPaid': {
      'era': era,
      'validator': validator.toList(),
      'nominator': nominator.toList(),
      'page': page,
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + const _i3.AccountId32Codec().sizeHint(validator);
    size = size + const _i3.AccountId32Codec().sizeHint(nominator);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(14, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    const _i1.U8ArrayCodec(32).encodeTo(nominator, output);
    _i1.U32Codec.codec.encodeTo(page, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NominatorRewardPaid &&
          other.era == era &&
          _i9.listsEqual(other.validator, validator) &&
          _i9.listsEqual(other.nominator, nominator) &&
          other.page == page &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(era, validator, nominator, page, amount);
}

class RewardPagePaid extends Event {
  const RewardPagePaid({
    required this.era,
    required this.validator,
    required this.page,
    required this.amount,
  });

  factory RewardPagePaid._decode(_i1.Input input) {
    return RewardPagePaid(
      era: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      page: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// T::AccountId
  final _i3.AccountId32 validator;

  /// Page
  final int page;

  /// u128
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'RewardPagePaid': {
      'era': era,
      'validator': validator.toList(),
      'page': page,
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + const _i3.AccountId32Codec().sizeHint(validator);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(15, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    _i1.U32Codec.codec.encodeTo(page, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardPagePaid &&
          other.era == era &&
          _i9.listsEqual(other.validator, validator) &&
          other.page == page &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(era, validator, page, amount);
}

class LiabilityReleased extends Event {
  const LiabilityReleased({
    required this.era,
    required this.amount,
    required this.expired,
  });

  factory LiabilityReleased._decode(_i1.Input input) {
    return LiabilityReleased(
      era: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      expired: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// u128
  final BigInt amount;

  /// bool
  final bool expired;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'LiabilityReleased': {'era': era, 'amount': amount, 'expired': expired},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.BoolCodec.codec.sizeHint(expired);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(16, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.BoolCodec.codec.encodeTo(expired, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiabilityReleased &&
          other.era == era &&
          other.amount == amount &&
          other.expired == expired;

  @override
  int get hashCode => Object.hash(era, amount, expired);
}

class AllocationPaused extends Event {
  const AllocationPaused({required this.era, required this.reason});

  factory AllocationPaused._decode(_i1.Input input) {
    return AllocationPaused(
      era: _i1.U32Codec.codec.decode(input),
      reason: _i8.AllocationFailureReason.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// AllocationFailureReason
  final _i8.AllocationFailureReason reason;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'AllocationPaused': {'era': era, 'reason': reason.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i8.AllocationFailureReason.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(17, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i8.AllocationFailureReason.codec.encodeTo(reason, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllocationPaused && other.era == era && other.reason == reason;

  @override
  int get hashCode => Object.hash(era, reason);
}
