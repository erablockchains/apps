// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i9;

import '../../sp_core/crypto/account_id32.dart' as _i7;
import '../activation_rejection.dart' as _i3;
import '../fee_routing_configuration.dart' as _i4;
import '../fee_routing_failure.dart' as _i8;
import '../funding_source.dart' as _i5;
import '../liability_cancellation_reason.dart' as _i6;

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

  RewardSystemActivated rewardSystemActivated({
    required int block,
    required int activationEra,
    required int firstEligibleEra,
    required BigInt rewardPotBalance,
  }) {
    return RewardSystemActivated(
      block: block,
      activationEra: activationEra,
      firstEligibleEra: firstEligibleEra,
      rewardPotBalance: rewardPotBalance,
    );
  }

  RewardActivationRejected rewardActivationRejected({
    required _i3.ActivationRejection reason,
  }) {
    return RewardActivationRejected(reason: reason);
  }

  FeeRoutingActivated feeRoutingActivated({
    required int block,
    required _i4.FeeRoutingConfiguration configuration,
  }) {
    return FeeRoutingActivated(block: block, configuration: configuration);
  }

  RewardPotFundingRecorded rewardPotFundingRecorded({
    required _i5.FundingSource source,
    required BigInt amount,
    required BigInt total,
  }) {
    return RewardPotFundingRecorded(
      source: source,
      amount: amount,
      total: total,
    );
  }

  EraRewardBudgetFinalized eraRewardBudgetFinalized({
    required int era,
    required BigInt durationMillis,
    required BigInt target,
    required BigInt budget,
    required BigInt annualBudgetUsed,
  }) {
    return EraRewardBudgetFinalized(
      era: era,
      durationMillis: durationMillis,
      target: target,
      budget: budget,
      annualBudgetUsed: annualBudgetUsed,
    );
  }

  EraRewardLiabilityReserved eraRewardLiabilityReserved({
    required int era,
    required BigInt amount,
    required BigInt committedLiabilities,
  }) {
    return EraRewardLiabilityReserved(
      era: era,
      amount: amount,
      committedLiabilities: committedLiabilities,
    );
  }

  EraRewardSkippedNoPoints eraRewardSkippedNoPoints({
    required int era,
    required BigInt calculatedBudget,
  }) {
    return EraRewardSkippedNoPoints(
      era: era,
      calculatedBudget: calculatedBudget,
    );
  }

  EraRewardSkippedPartialPointSource eraRewardSkippedPartialPointSource({
    required int era,
  }) {
    return EraRewardSkippedPartialPointSource(era: era);
  }

  EraRewardSkippedAllocationPaused eraRewardSkippedAllocationPaused({
    required int era,
    required BigInt calculatedBudget,
  }) {
    return EraRewardSkippedAllocationPaused(
      era: era,
      calculatedBudget: calculatedBudget,
    );
  }

  EraRewardLiabilityCancelled eraRewardLiabilityCancelled({
    required int era,
    required BigInt amount,
    required _i6.LiabilityCancellationReason reason,
  }) {
    return EraRewardLiabilityCancelled(
      era: era,
      amount: amount,
      reason: reason,
    );
  }

  ValidatorRewardClaimed validatorRewardClaimed({
    required int era,
    required int page,
    required _i7.AccountId32 validator,
    required BigInt amount,
    required BigInt commission,
  }) {
    return ValidatorRewardClaimed(
      era: era,
      page: page,
      validator: validator,
      amount: amount,
      commission: commission,
    );
  }

  NominatorRewardClaimed nominatorRewardClaimed({
    required int era,
    required int page,
    required _i7.AccountId32 validator,
    required _i7.AccountId32 nominator,
    required BigInt amount,
  }) {
    return NominatorRewardClaimed(
      era: era,
      page: page,
      validator: validator,
      nominator: nominator,
      amount: amount,
    );
  }

  EraRewardPagePaid eraRewardPagePaid({
    required int era,
    required int page,
    required _i7.AccountId32 validator,
    required _i7.AccountId32 caller,
    required BigInt amount,
    required BigInt remainingLiability,
  }) {
    return EraRewardPagePaid(
      era: era,
      page: page,
      validator: validator,
      caller: caller,
      amount: amount,
      remainingLiability: remainingLiability,
    );
  }

  FeeContributionReceived feeContributionReceived({
    required BigInt amount,
    required BigInt total,
  }) {
    return FeeContributionReceived(amount: amount, total: total);
  }

  TransactionFeeRouted transactionFeeRouted({
    required BigInt normalFee,
    required BigInt rewardPotContribution,
    required BigInt ecosystemTreasuryContribution,
    required BigInt burned,
    required BigInt tip,
    _i7.AccountId32? author,
  }) {
    return TransactionFeeRouted(
      normalFee: normalFee,
      rewardPotContribution: rewardPotContribution,
      ecosystemTreasuryContribution: ecosystemTreasuryContribution,
      burned: burned,
      tip: tip,
      author: author,
    );
  }

  RewardPotFeeContribution rewardPotFeeContribution({
    required BigInt amount,
    required BigInt total,
  }) {
    return RewardPotFeeContribution(amount: amount, total: total);
  }

  EcosystemTreasuryFeeContribution ecosystemTreasuryFeeContribution({
    required BigInt amount,
    required BigInt total,
  }) {
    return EcosystemTreasuryFeeContribution(amount: amount, total: total);
  }

  FeeRoutingConfigurationChanged feeRoutingConfigurationChanged({
    required _i4.FeeRoutingConfiguration old,
    required _i4.FeeRoutingConfiguration new_,
  }) {
    return FeeRoutingConfigurationChanged(old: old, new_: new_);
  }

  FeeRoutingDeferred feeRoutingDeferred({
    required BigInt normalFee,
    required BigInt pendingReward,
    required BigInt pendingTreasury,
  }) {
    return FeeRoutingDeferred(
      normalFee: normalFee,
      pendingReward: pendingReward,
      pendingTreasury: pendingTreasury,
    );
  }

  FeeRoutingCompleted feeRoutingCompleted({
    required BigInt normalFee,
    required BigInt rewardPotContribution,
    required BigInt ecosystemTreasuryContribution,
  }) {
    return FeeRoutingCompleted(
      normalFee: normalFee,
      rewardPotContribution: rewardPotContribution,
      ecosystemTreasuryContribution: ecosystemTreasuryContribution,
    );
  }

  FeeRoutingFailed feeRoutingFailed({
    required BigInt normalFee,
    required BigInt tip,
    required _i8.FeeRoutingFailure reason,
  }) {
    return FeeRoutingFailed(normalFee: normalFee, tip: tip, reason: reason);
  }

  AuthorTipDeferred authorTipDeferred({
    _i7.AccountId32? author,
    required BigInt amount,
  }) {
    return AuthorTipDeferred(author: author, amount: amount);
  }

  AuthorTipCompleted authorTipCompleted({
    required _i7.AccountId32 author,
    required BigInt amount,
  }) {
    return AuthorTipCompleted(author: author, amount: amount);
  }

  EcosystemTreasurySpent ecosystemTreasurySpent({
    required _i7.AccountId32 beneficiary,
    required BigInt amount,
  }) {
    return EcosystemTreasurySpent(beneficiary: beneficiary, amount: amount);
  }

  RewardReserveLow rewardReserveLow({
    required BigInt available,
    required BigInt committedLiabilities,
  }) {
    return RewardReserveLow(
      available: available,
      committedLiabilities: committedLiabilities,
    );
  }

  RewardPotBelowMinimum rewardPotBelowMinimum({
    required BigInt balance,
    required BigInt required,
  }) {
    return RewardPotBelowMinimum(balance: balance, required: required);
  }

  TreasuryPotBelowMinimum treasuryPotBelowMinimum({
    required BigInt balance,
    required BigInt required,
  }) {
    return TreasuryPotBelowMinimum(balance: balance, required: required);
  }

  RewardAllocationPaused rewardAllocationPaused({
    required int era,
    required BigInt available,
  }) {
    return RewardAllocationPaused(era: era, available: available);
  }

  RewardAllocationResumed rewardAllocationResumed({
    required int era,
    required BigInt available,
  }) {
    return RewardAllocationResumed(era: era, available: available);
  }

  ClaimExpired claimExpired({
    required int era,
    required BigInt releasedLiability,
  }) {
    return ClaimExpired(era: era, releasedLiability: releasedLiability);
  }

  EraRoundingRemainderReleased eraRoundingRemainderReleased({
    required int era,
    required BigInt amount,
  }) {
    return EraRoundingRemainderReleased(era: era, amount: amount);
  }

  LegacyClaimOnlyEntered legacyClaimOnlyEntered({required int cutoffEra}) {
    return LegacyClaimOnlyEntered(cutoffEra: cutoffEra);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RewardSystemActivated._decode(input);
      case 1:
        return RewardActivationRejected._decode(input);
      case 2:
        return FeeRoutingActivated._decode(input);
      case 3:
        return RewardPotFundingRecorded._decode(input);
      case 4:
        return EraRewardBudgetFinalized._decode(input);
      case 5:
        return EraRewardLiabilityReserved._decode(input);
      case 6:
        return EraRewardSkippedNoPoints._decode(input);
      case 7:
        return EraRewardSkippedPartialPointSource._decode(input);
      case 8:
        return EraRewardSkippedAllocationPaused._decode(input);
      case 9:
        return EraRewardLiabilityCancelled._decode(input);
      case 10:
        return ValidatorRewardClaimed._decode(input);
      case 11:
        return NominatorRewardClaimed._decode(input);
      case 12:
        return EraRewardPagePaid._decode(input);
      case 13:
        return FeeContributionReceived._decode(input);
      case 14:
        return TransactionFeeRouted._decode(input);
      case 15:
        return RewardPotFeeContribution._decode(input);
      case 16:
        return EcosystemTreasuryFeeContribution._decode(input);
      case 17:
        return FeeRoutingConfigurationChanged._decode(input);
      case 18:
        return FeeRoutingDeferred._decode(input);
      case 19:
        return FeeRoutingCompleted._decode(input);
      case 20:
        return FeeRoutingFailed._decode(input);
      case 21:
        return AuthorTipDeferred._decode(input);
      case 22:
        return AuthorTipCompleted._decode(input);
      case 23:
        return EcosystemTreasurySpent._decode(input);
      case 24:
        return RewardReserveLow._decode(input);
      case 25:
        return RewardPotBelowMinimum._decode(input);
      case 26:
        return TreasuryPotBelowMinimum._decode(input);
      case 27:
        return RewardAllocationPaused._decode(input);
      case 28:
        return RewardAllocationResumed._decode(input);
      case 29:
        return ClaimExpired._decode(input);
      case 30:
        return EraRoundingRemainderReleased._decode(input);
      case 31:
        return LegacyClaimOnlyEntered._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case RewardSystemActivated:
        (value as RewardSystemActivated).encodeTo(output);
        break;
      case RewardActivationRejected:
        (value as RewardActivationRejected).encodeTo(output);
        break;
      case FeeRoutingActivated:
        (value as FeeRoutingActivated).encodeTo(output);
        break;
      case RewardPotFundingRecorded:
        (value as RewardPotFundingRecorded).encodeTo(output);
        break;
      case EraRewardBudgetFinalized:
        (value as EraRewardBudgetFinalized).encodeTo(output);
        break;
      case EraRewardLiabilityReserved:
        (value as EraRewardLiabilityReserved).encodeTo(output);
        break;
      case EraRewardSkippedNoPoints:
        (value as EraRewardSkippedNoPoints).encodeTo(output);
        break;
      case EraRewardSkippedPartialPointSource:
        (value as EraRewardSkippedPartialPointSource).encodeTo(output);
        break;
      case EraRewardSkippedAllocationPaused:
        (value as EraRewardSkippedAllocationPaused).encodeTo(output);
        break;
      case EraRewardLiabilityCancelled:
        (value as EraRewardLiabilityCancelled).encodeTo(output);
        break;
      case ValidatorRewardClaimed:
        (value as ValidatorRewardClaimed).encodeTo(output);
        break;
      case NominatorRewardClaimed:
        (value as NominatorRewardClaimed).encodeTo(output);
        break;
      case EraRewardPagePaid:
        (value as EraRewardPagePaid).encodeTo(output);
        break;
      case FeeContributionReceived:
        (value as FeeContributionReceived).encodeTo(output);
        break;
      case TransactionFeeRouted:
        (value as TransactionFeeRouted).encodeTo(output);
        break;
      case RewardPotFeeContribution:
        (value as RewardPotFeeContribution).encodeTo(output);
        break;
      case EcosystemTreasuryFeeContribution:
        (value as EcosystemTreasuryFeeContribution).encodeTo(output);
        break;
      case FeeRoutingConfigurationChanged:
        (value as FeeRoutingConfigurationChanged).encodeTo(output);
        break;
      case FeeRoutingDeferred:
        (value as FeeRoutingDeferred).encodeTo(output);
        break;
      case FeeRoutingCompleted:
        (value as FeeRoutingCompleted).encodeTo(output);
        break;
      case FeeRoutingFailed:
        (value as FeeRoutingFailed).encodeTo(output);
        break;
      case AuthorTipDeferred:
        (value as AuthorTipDeferred).encodeTo(output);
        break;
      case AuthorTipCompleted:
        (value as AuthorTipCompleted).encodeTo(output);
        break;
      case EcosystemTreasurySpent:
        (value as EcosystemTreasurySpent).encodeTo(output);
        break;
      case RewardReserveLow:
        (value as RewardReserveLow).encodeTo(output);
        break;
      case RewardPotBelowMinimum:
        (value as RewardPotBelowMinimum).encodeTo(output);
        break;
      case TreasuryPotBelowMinimum:
        (value as TreasuryPotBelowMinimum).encodeTo(output);
        break;
      case RewardAllocationPaused:
        (value as RewardAllocationPaused).encodeTo(output);
        break;
      case RewardAllocationResumed:
        (value as RewardAllocationResumed).encodeTo(output);
        break;
      case ClaimExpired:
        (value as ClaimExpired).encodeTo(output);
        break;
      case EraRoundingRemainderReleased:
        (value as EraRoundingRemainderReleased).encodeTo(output);
        break;
      case LegacyClaimOnlyEntered:
        (value as LegacyClaimOnlyEntered).encodeTo(output);
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
      case RewardSystemActivated:
        return (value as RewardSystemActivated)._sizeHint();
      case RewardActivationRejected:
        return (value as RewardActivationRejected)._sizeHint();
      case FeeRoutingActivated:
        return (value as FeeRoutingActivated)._sizeHint();
      case RewardPotFundingRecorded:
        return (value as RewardPotFundingRecorded)._sizeHint();
      case EraRewardBudgetFinalized:
        return (value as EraRewardBudgetFinalized)._sizeHint();
      case EraRewardLiabilityReserved:
        return (value as EraRewardLiabilityReserved)._sizeHint();
      case EraRewardSkippedNoPoints:
        return (value as EraRewardSkippedNoPoints)._sizeHint();
      case EraRewardSkippedPartialPointSource:
        return (value as EraRewardSkippedPartialPointSource)._sizeHint();
      case EraRewardSkippedAllocationPaused:
        return (value as EraRewardSkippedAllocationPaused)._sizeHint();
      case EraRewardLiabilityCancelled:
        return (value as EraRewardLiabilityCancelled)._sizeHint();
      case ValidatorRewardClaimed:
        return (value as ValidatorRewardClaimed)._sizeHint();
      case NominatorRewardClaimed:
        return (value as NominatorRewardClaimed)._sizeHint();
      case EraRewardPagePaid:
        return (value as EraRewardPagePaid)._sizeHint();
      case FeeContributionReceived:
        return (value as FeeContributionReceived)._sizeHint();
      case TransactionFeeRouted:
        return (value as TransactionFeeRouted)._sizeHint();
      case RewardPotFeeContribution:
        return (value as RewardPotFeeContribution)._sizeHint();
      case EcosystemTreasuryFeeContribution:
        return (value as EcosystemTreasuryFeeContribution)._sizeHint();
      case FeeRoutingConfigurationChanged:
        return (value as FeeRoutingConfigurationChanged)._sizeHint();
      case FeeRoutingDeferred:
        return (value as FeeRoutingDeferred)._sizeHint();
      case FeeRoutingCompleted:
        return (value as FeeRoutingCompleted)._sizeHint();
      case FeeRoutingFailed:
        return (value as FeeRoutingFailed)._sizeHint();
      case AuthorTipDeferred:
        return (value as AuthorTipDeferred)._sizeHint();
      case AuthorTipCompleted:
        return (value as AuthorTipCompleted)._sizeHint();
      case EcosystemTreasurySpent:
        return (value as EcosystemTreasurySpent)._sizeHint();
      case RewardReserveLow:
        return (value as RewardReserveLow)._sizeHint();
      case RewardPotBelowMinimum:
        return (value as RewardPotBelowMinimum)._sizeHint();
      case TreasuryPotBelowMinimum:
        return (value as TreasuryPotBelowMinimum)._sizeHint();
      case RewardAllocationPaused:
        return (value as RewardAllocationPaused)._sizeHint();
      case RewardAllocationResumed:
        return (value as RewardAllocationResumed)._sizeHint();
      case ClaimExpired:
        return (value as ClaimExpired)._sizeHint();
      case EraRoundingRemainderReleased:
        return (value as EraRoundingRemainderReleased)._sizeHint();
      case LegacyClaimOnlyEntered:
        return (value as LegacyClaimOnlyEntered)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class RewardSystemActivated extends Event {
  const RewardSystemActivated({
    required this.block,
    required this.activationEra,
    required this.firstEligibleEra,
    required this.rewardPotBalance,
  });

  factory RewardSystemActivated._decode(_i1.Input input) {
    return RewardSystemActivated(
      block: _i1.U32Codec.codec.decode(input),
      activationEra: _i1.U32Codec.codec.decode(input),
      firstEligibleEra: _i1.U32Codec.codec.decode(input),
      rewardPotBalance: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BlockNumberFor<T>
  final int block;

  /// EraIndex
  final int activationEra;

  /// EraIndex
  final int firstEligibleEra;

  /// BalanceOf<T>
  final BigInt rewardPotBalance;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'RewardSystemActivated': {
      'block': block,
      'activationEra': activationEra,
      'firstEligibleEra': firstEligibleEra,
      'rewardPotBalance': rewardPotBalance,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(block);
    size = size + _i1.U32Codec.codec.sizeHint(activationEra);
    size = size + _i1.U32Codec.codec.sizeHint(firstEligibleEra);
    size = size + _i1.U128Codec.codec.sizeHint(rewardPotBalance);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U32Codec.codec.encodeTo(block, output);
    _i1.U32Codec.codec.encodeTo(activationEra, output);
    _i1.U32Codec.codec.encodeTo(firstEligibleEra, output);
    _i1.U128Codec.codec.encodeTo(rewardPotBalance, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardSystemActivated &&
          other.block == block &&
          other.activationEra == activationEra &&
          other.firstEligibleEra == firstEligibleEra &&
          other.rewardPotBalance == rewardPotBalance;

  @override
  int get hashCode =>
      Object.hash(block, activationEra, firstEligibleEra, rewardPotBalance);
}

class RewardActivationRejected extends Event {
  const RewardActivationRejected({required this.reason});

  factory RewardActivationRejected._decode(_i1.Input input) {
    return RewardActivationRejected(
      reason: _i3.ActivationRejection.codec.decode(input),
    );
  }

  /// ActivationRejection
  final _i3.ActivationRejection reason;

  @override
  Map<String, Map<String, String>> toJson() => {
    'RewardActivationRejected': {'reason': reason.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.ActivationRejection.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i3.ActivationRejection.codec.encodeTo(reason, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardActivationRejected && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;
}

class FeeRoutingActivated extends Event {
  const FeeRoutingActivated({required this.block, required this.configuration});

  factory FeeRoutingActivated._decode(_i1.Input input) {
    return FeeRoutingActivated(
      block: _i1.U32Codec.codec.decode(input),
      configuration: _i4.FeeRoutingConfiguration.codec.decode(input),
    );
  }

  /// BlockNumberFor<T>
  final int block;

  /// FeeRoutingConfiguration
  final _i4.FeeRoutingConfiguration configuration;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'FeeRoutingActivated': {
      'block': block,
      'configuration': configuration.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(block);
    size = size + _i4.FeeRoutingConfiguration.codec.sizeHint(configuration);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U32Codec.codec.encodeTo(block, output);
    _i4.FeeRoutingConfiguration.codec.encodeTo(configuration, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRoutingActivated &&
          other.block == block &&
          other.configuration == configuration;

  @override
  int get hashCode => Object.hash(block, configuration);
}

class RewardPotFundingRecorded extends Event {
  const RewardPotFundingRecorded({
    required this.source,
    required this.amount,
    required this.total,
  });

  factory RewardPotFundingRecorded._decode(_i1.Input input) {
    return RewardPotFundingRecorded(
      source: _i5.FundingSource.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      total: _i1.U128Codec.codec.decode(input),
    );
  }

  /// FundingSource
  final _i5.FundingSource source;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt total;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'RewardPotFundingRecorded': {
      'source': source.toJson(),
      'amount': amount,
      'total': total,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i5.FundingSource.codec.sizeHint(source);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(total);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i5.FundingSource.codec.encodeTo(source, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(total, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardPotFundingRecorded &&
          other.source == source &&
          other.amount == amount &&
          other.total == total;

  @override
  int get hashCode => Object.hash(source, amount, total);
}

class EraRewardBudgetFinalized extends Event {
  const EraRewardBudgetFinalized({
    required this.era,
    required this.durationMillis,
    required this.target,
    required this.budget,
    required this.annualBudgetUsed,
  });

  factory EraRewardBudgetFinalized._decode(_i1.Input input) {
    return EraRewardBudgetFinalized(
      era: _i1.U32Codec.codec.decode(input),
      durationMillis: _i1.U64Codec.codec.decode(input),
      target: _i1.U128Codec.codec.decode(input),
      budget: _i1.U128Codec.codec.decode(input),
      annualBudgetUsed: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// u64
  final BigInt durationMillis;

  /// BalanceOf<T>
  final BigInt target;

  /// BalanceOf<T>
  final BigInt budget;

  /// BalanceOf<T>
  final BigInt annualBudgetUsed;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRewardBudgetFinalized': {
      'era': era,
      'durationMillis': durationMillis,
      'target': target,
      'budget': budget,
      'annualBudgetUsed': annualBudgetUsed,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U64Codec.codec.sizeHint(durationMillis);
    size = size + _i1.U128Codec.codec.sizeHint(target);
    size = size + _i1.U128Codec.codec.sizeHint(budget);
    size = size + _i1.U128Codec.codec.sizeHint(annualBudgetUsed);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U64Codec.codec.encodeTo(durationMillis, output);
    _i1.U128Codec.codec.encodeTo(target, output);
    _i1.U128Codec.codec.encodeTo(budget, output);
    _i1.U128Codec.codec.encodeTo(annualBudgetUsed, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardBudgetFinalized &&
          other.era == era &&
          other.durationMillis == durationMillis &&
          other.target == target &&
          other.budget == budget &&
          other.annualBudgetUsed == annualBudgetUsed;

  @override
  int get hashCode =>
      Object.hash(era, durationMillis, target, budget, annualBudgetUsed);
}

class EraRewardLiabilityReserved extends Event {
  const EraRewardLiabilityReserved({
    required this.era,
    required this.amount,
    required this.committedLiabilities,
  });

  factory EraRewardLiabilityReserved._decode(_i1.Input input) {
    return EraRewardLiabilityReserved(
      era: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      committedLiabilities: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt committedLiabilities;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRewardLiabilityReserved': {
      'era': era,
      'amount': amount,
      'committedLiabilities': committedLiabilities,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(committedLiabilities);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(committedLiabilities, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardLiabilityReserved &&
          other.era == era &&
          other.amount == amount &&
          other.committedLiabilities == committedLiabilities;

  @override
  int get hashCode => Object.hash(era, amount, committedLiabilities);
}

class EraRewardSkippedNoPoints extends Event {
  const EraRewardSkippedNoPoints({
    required this.era,
    required this.calculatedBudget,
  });

  factory EraRewardSkippedNoPoints._decode(_i1.Input input) {
    return EraRewardSkippedNoPoints(
      era: _i1.U32Codec.codec.decode(input),
      calculatedBudget: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt calculatedBudget;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRewardSkippedNoPoints': {
      'era': era,
      'calculatedBudget': calculatedBudget,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(calculatedBudget);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(calculatedBudget, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardSkippedNoPoints &&
          other.era == era &&
          other.calculatedBudget == calculatedBudget;

  @override
  int get hashCode => Object.hash(era, calculatedBudget);
}

class EraRewardSkippedPartialPointSource extends Event {
  const EraRewardSkippedPartialPointSource({required this.era});

  factory EraRewardSkippedPartialPointSource._decode(_i1.Input input) {
    return EraRewardSkippedPartialPointSource(
      era: _i1.U32Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  @override
  Map<String, Map<String, int>> toJson() => {
    'EraRewardSkippedPartialPointSource': {'era': era},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(7, output);
    _i1.U32Codec.codec.encodeTo(era, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardSkippedPartialPointSource && other.era == era;

  @override
  int get hashCode => era.hashCode;
}

class EraRewardSkippedAllocationPaused extends Event {
  const EraRewardSkippedAllocationPaused({
    required this.era,
    required this.calculatedBudget,
  });

  factory EraRewardSkippedAllocationPaused._decode(_i1.Input input) {
    return EraRewardSkippedAllocationPaused(
      era: _i1.U32Codec.codec.decode(input),
      calculatedBudget: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt calculatedBudget;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRewardSkippedAllocationPaused': {
      'era': era,
      'calculatedBudget': calculatedBudget,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(calculatedBudget);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(8, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(calculatedBudget, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardSkippedAllocationPaused &&
          other.era == era &&
          other.calculatedBudget == calculatedBudget;

  @override
  int get hashCode => Object.hash(era, calculatedBudget);
}

class EraRewardLiabilityCancelled extends Event {
  const EraRewardLiabilityCancelled({
    required this.era,
    required this.amount,
    required this.reason,
  });

  factory EraRewardLiabilityCancelled._decode(_i1.Input input) {
    return EraRewardLiabilityCancelled(
      era: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      reason: _i6.LiabilityCancellationReason.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt amount;

  /// LiabilityCancellationReason
  final _i6.LiabilityCancellationReason reason;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRewardLiabilityCancelled': {
      'era': era,
      'amount': amount,
      'reason': reason.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i6.LiabilityCancellationReason.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(9, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i6.LiabilityCancellationReason.codec.encodeTo(reason, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardLiabilityCancelled &&
          other.era == era &&
          other.amount == amount &&
          other.reason == reason;

  @override
  int get hashCode => Object.hash(era, amount, reason);
}

class ValidatorRewardClaimed extends Event {
  const ValidatorRewardClaimed({
    required this.era,
    required this.page,
    required this.validator,
    required this.amount,
    required this.commission,
  });

  factory ValidatorRewardClaimed._decode(_i1.Input input) {
    return ValidatorRewardClaimed(
      era: _i1.U32Codec.codec.decode(input),
      page: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      commission: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// Page
  final int page;

  /// T::AccountId
  final _i7.AccountId32 validator;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt commission;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ValidatorRewardClaimed': {
      'era': era,
      'page': page,
      'validator': validator.toList(),
      'amount': amount,
      'commission': commission,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    size = size + const _i7.AccountId32Codec().sizeHint(validator);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(commission);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U32Codec.codec.encodeTo(page, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(commission, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatorRewardClaimed &&
          other.era == era &&
          other.page == page &&
          _i9.listsEqual(other.validator, validator) &&
          other.amount == amount &&
          other.commission == commission;

  @override
  int get hashCode => Object.hash(era, page, validator, amount, commission);
}

class NominatorRewardClaimed extends Event {
  const NominatorRewardClaimed({
    required this.era,
    required this.page,
    required this.validator,
    required this.nominator,
    required this.amount,
  });

  factory NominatorRewardClaimed._decode(_i1.Input input) {
    return NominatorRewardClaimed(
      era: _i1.U32Codec.codec.decode(input),
      page: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      nominator: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// Page
  final int page;

  /// T::AccountId
  final _i7.AccountId32 validator;

  /// T::AccountId
  final _i7.AccountId32 nominator;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'NominatorRewardClaimed': {
      'era': era,
      'page': page,
      'validator': validator.toList(),
      'nominator': nominator.toList(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    size = size + const _i7.AccountId32Codec().sizeHint(validator);
    size = size + const _i7.AccountId32Codec().sizeHint(nominator);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U32Codec.codec.encodeTo(page, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    const _i1.U8ArrayCodec(32).encodeTo(nominator, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NominatorRewardClaimed &&
          other.era == era &&
          other.page == page &&
          _i9.listsEqual(other.validator, validator) &&
          _i9.listsEqual(other.nominator, nominator) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(era, page, validator, nominator, amount);
}

class EraRewardPagePaid extends Event {
  const EraRewardPagePaid({
    required this.era,
    required this.page,
    required this.validator,
    required this.caller,
    required this.amount,
    required this.remainingLiability,
  });

  factory EraRewardPagePaid._decode(_i1.Input input) {
    return EraRewardPagePaid(
      era: _i1.U32Codec.codec.decode(input),
      page: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      caller: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
      remainingLiability: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// Page
  final int page;

  /// T::AccountId
  final _i7.AccountId32 validator;

  /// T::AccountId
  final _i7.AccountId32 caller;

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt remainingLiability;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRewardPagePaid': {
      'era': era,
      'page': page,
      'validator': validator.toList(),
      'caller': caller.toList(),
      'amount': amount,
      'remainingLiability': remainingLiability,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    size = size + const _i7.AccountId32Codec().sizeHint(validator);
    size = size + const _i7.AccountId32Codec().sizeHint(caller);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(remainingLiability);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(12, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U32Codec.codec.encodeTo(page, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    const _i1.U8ArrayCodec(32).encodeTo(caller, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(remainingLiability, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRewardPagePaid &&
          other.era == era &&
          other.page == page &&
          _i9.listsEqual(other.validator, validator) &&
          _i9.listsEqual(other.caller, caller) &&
          other.amount == amount &&
          other.remainingLiability == remainingLiability;

  @override
  int get hashCode =>
      Object.hash(era, page, validator, caller, amount, remainingLiability);
}

class FeeContributionReceived extends Event {
  const FeeContributionReceived({required this.amount, required this.total});

  factory FeeContributionReceived._decode(_i1.Input input) {
    return FeeContributionReceived(
      amount: _i1.U128Codec.codec.decode(input),
      total: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt total;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'FeeContributionReceived': {'amount': amount, 'total': total},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(total);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(13, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(total, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeContributionReceived &&
          other.amount == amount &&
          other.total == total;

  @override
  int get hashCode => Object.hash(amount, total);
}

class TransactionFeeRouted extends Event {
  const TransactionFeeRouted({
    required this.normalFee,
    required this.rewardPotContribution,
    required this.ecosystemTreasuryContribution,
    required this.burned,
    required this.tip,
    this.author,
  });

  factory TransactionFeeRouted._decode(_i1.Input input) {
    return TransactionFeeRouted(
      normalFee: _i1.U128Codec.codec.decode(input),
      rewardPotContribution: _i1.U128Codec.codec.decode(input),
      ecosystemTreasuryContribution: _i1.U128Codec.codec.decode(input),
      burned: _i1.U128Codec.codec.decode(input),
      tip: _i1.U128Codec.codec.decode(input),
      author: const _i1.OptionCodec<_i7.AccountId32>(
        _i7.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt normalFee;

  /// BalanceOf<T>
  final BigInt rewardPotContribution;

  /// BalanceOf<T>
  final BigInt ecosystemTreasuryContribution;

  /// BalanceOf<T>
  final BigInt burned;

  /// BalanceOf<T>
  final BigInt tip;

  /// Option<T::AccountId>
  final _i7.AccountId32? author;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'TransactionFeeRouted': {
      'normalFee': normalFee,
      'rewardPotContribution': rewardPotContribution,
      'ecosystemTreasuryContribution': ecosystemTreasuryContribution,
      'burned': burned,
      'tip': tip,
      'author': author?.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(normalFee);
    size = size + _i1.U128Codec.codec.sizeHint(rewardPotContribution);
    size = size + _i1.U128Codec.codec.sizeHint(ecosystemTreasuryContribution);
    size = size + _i1.U128Codec.codec.sizeHint(burned);
    size = size + _i1.U128Codec.codec.sizeHint(tip);
    size =
        size +
        const _i1.OptionCodec<_i7.AccountId32>(
          _i7.AccountId32Codec(),
        ).sizeHint(author);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(14, output);
    _i1.U128Codec.codec.encodeTo(normalFee, output);
    _i1.U128Codec.codec.encodeTo(rewardPotContribution, output);
    _i1.U128Codec.codec.encodeTo(ecosystemTreasuryContribution, output);
    _i1.U128Codec.codec.encodeTo(burned, output);
    _i1.U128Codec.codec.encodeTo(tip, output);
    const _i1.OptionCodec<_i7.AccountId32>(
      _i7.AccountId32Codec(),
    ).encodeTo(author, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFeeRouted &&
          other.normalFee == normalFee &&
          other.rewardPotContribution == rewardPotContribution &&
          other.ecosystemTreasuryContribution ==
              ecosystemTreasuryContribution &&
          other.burned == burned &&
          other.tip == tip &&
          other.author == author;

  @override
  int get hashCode => Object.hash(
    normalFee,
    rewardPotContribution,
    ecosystemTreasuryContribution,
    burned,
    tip,
    author,
  );
}

class RewardPotFeeContribution extends Event {
  const RewardPotFeeContribution({required this.amount, required this.total});

  factory RewardPotFeeContribution._decode(_i1.Input input) {
    return RewardPotFeeContribution(
      amount: _i1.U128Codec.codec.decode(input),
      total: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt total;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'RewardPotFeeContribution': {'amount': amount, 'total': total},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(total);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(15, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(total, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardPotFeeContribution &&
          other.amount == amount &&
          other.total == total;

  @override
  int get hashCode => Object.hash(amount, total);
}

class EcosystemTreasuryFeeContribution extends Event {
  const EcosystemTreasuryFeeContribution({
    required this.amount,
    required this.total,
  });

  factory EcosystemTreasuryFeeContribution._decode(_i1.Input input) {
    return EcosystemTreasuryFeeContribution(
      amount: _i1.U128Codec.codec.decode(input),
      total: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt amount;

  /// BalanceOf<T>
  final BigInt total;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'EcosystemTreasuryFeeContribution': {'amount': amount, 'total': total},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    size = size + _i1.U128Codec.codec.sizeHint(total);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(16, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
    _i1.U128Codec.codec.encodeTo(total, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EcosystemTreasuryFeeContribution &&
          other.amount == amount &&
          other.total == total;

  @override
  int get hashCode => Object.hash(amount, total);
}

class FeeRoutingConfigurationChanged extends Event {
  const FeeRoutingConfigurationChanged({required this.old, required this.new_});

  factory FeeRoutingConfigurationChanged._decode(_i1.Input input) {
    return FeeRoutingConfigurationChanged(
      old: _i4.FeeRoutingConfiguration.codec.decode(input),
      new_: _i4.FeeRoutingConfiguration.codec.decode(input),
    );
  }

  /// FeeRoutingConfiguration
  final _i4.FeeRoutingConfiguration old;

  /// FeeRoutingConfiguration
  final _i4.FeeRoutingConfiguration new_;

  @override
  Map<String, Map<String, Map<String, int>>> toJson() => {
    'FeeRoutingConfigurationChanged': {
      'old': old.toJson(),
      'new': new_.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i4.FeeRoutingConfiguration.codec.sizeHint(old);
    size = size + _i4.FeeRoutingConfiguration.codec.sizeHint(new_);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(17, output);
    _i4.FeeRoutingConfiguration.codec.encodeTo(old, output);
    _i4.FeeRoutingConfiguration.codec.encodeTo(new_, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRoutingConfigurationChanged &&
          other.old == old &&
          other.new_ == new_;

  @override
  int get hashCode => Object.hash(old, new_);
}

class FeeRoutingDeferred extends Event {
  const FeeRoutingDeferred({
    required this.normalFee,
    required this.pendingReward,
    required this.pendingTreasury,
  });

  factory FeeRoutingDeferred._decode(_i1.Input input) {
    return FeeRoutingDeferred(
      normalFee: _i1.U128Codec.codec.decode(input),
      pendingReward: _i1.U128Codec.codec.decode(input),
      pendingTreasury: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt normalFee;

  /// BalanceOf<T>
  final BigInt pendingReward;

  /// BalanceOf<T>
  final BigInt pendingTreasury;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'FeeRoutingDeferred': {
      'normalFee': normalFee,
      'pendingReward': pendingReward,
      'pendingTreasury': pendingTreasury,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(normalFee);
    size = size + _i1.U128Codec.codec.sizeHint(pendingReward);
    size = size + _i1.U128Codec.codec.sizeHint(pendingTreasury);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(18, output);
    _i1.U128Codec.codec.encodeTo(normalFee, output);
    _i1.U128Codec.codec.encodeTo(pendingReward, output);
    _i1.U128Codec.codec.encodeTo(pendingTreasury, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRoutingDeferred &&
          other.normalFee == normalFee &&
          other.pendingReward == pendingReward &&
          other.pendingTreasury == pendingTreasury;

  @override
  int get hashCode => Object.hash(normalFee, pendingReward, pendingTreasury);
}

class FeeRoutingCompleted extends Event {
  const FeeRoutingCompleted({
    required this.normalFee,
    required this.rewardPotContribution,
    required this.ecosystemTreasuryContribution,
  });

  factory FeeRoutingCompleted._decode(_i1.Input input) {
    return FeeRoutingCompleted(
      normalFee: _i1.U128Codec.codec.decode(input),
      rewardPotContribution: _i1.U128Codec.codec.decode(input),
      ecosystemTreasuryContribution: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt normalFee;

  /// BalanceOf<T>
  final BigInt rewardPotContribution;

  /// BalanceOf<T>
  final BigInt ecosystemTreasuryContribution;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'FeeRoutingCompleted': {
      'normalFee': normalFee,
      'rewardPotContribution': rewardPotContribution,
      'ecosystemTreasuryContribution': ecosystemTreasuryContribution,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(normalFee);
    size = size + _i1.U128Codec.codec.sizeHint(rewardPotContribution);
    size = size + _i1.U128Codec.codec.sizeHint(ecosystemTreasuryContribution);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(19, output);
    _i1.U128Codec.codec.encodeTo(normalFee, output);
    _i1.U128Codec.codec.encodeTo(rewardPotContribution, output);
    _i1.U128Codec.codec.encodeTo(ecosystemTreasuryContribution, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRoutingCompleted &&
          other.normalFee == normalFee &&
          other.rewardPotContribution == rewardPotContribution &&
          other.ecosystemTreasuryContribution == ecosystemTreasuryContribution;

  @override
  int get hashCode => Object.hash(
    normalFee,
    rewardPotContribution,
    ecosystemTreasuryContribution,
  );
}

class FeeRoutingFailed extends Event {
  const FeeRoutingFailed({
    required this.normalFee,
    required this.tip,
    required this.reason,
  });

  factory FeeRoutingFailed._decode(_i1.Input input) {
    return FeeRoutingFailed(
      normalFee: _i1.U128Codec.codec.decode(input),
      tip: _i1.U128Codec.codec.decode(input),
      reason: _i8.FeeRoutingFailure.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt normalFee;

  /// BalanceOf<T>
  final BigInt tip;

  /// FeeRoutingFailure
  final _i8.FeeRoutingFailure reason;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'FeeRoutingFailed': {
      'normalFee': normalFee,
      'tip': tip,
      'reason': reason.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(normalFee);
    size = size + _i1.U128Codec.codec.sizeHint(tip);
    size = size + _i8.FeeRoutingFailure.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(20, output);
    _i1.U128Codec.codec.encodeTo(normalFee, output);
    _i1.U128Codec.codec.encodeTo(tip, output);
    _i8.FeeRoutingFailure.codec.encodeTo(reason, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRoutingFailed &&
          other.normalFee == normalFee &&
          other.tip == tip &&
          other.reason == reason;

  @override
  int get hashCode => Object.hash(normalFee, tip, reason);
}

class AuthorTipDeferred extends Event {
  const AuthorTipDeferred({this.author, required this.amount});

  factory AuthorTipDeferred._decode(_i1.Input input) {
    return AuthorTipDeferred(
      author: const _i1.OptionCodec<_i7.AccountId32>(
        _i7.AccountId32Codec(),
      ).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// Option<T::AccountId>
  final _i7.AccountId32? author;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'AuthorTipDeferred': {'author': author?.toList(), 'amount': amount},
  };

  int _sizeHint() {
    int size = 1;
    size =
        size +
        const _i1.OptionCodec<_i7.AccountId32>(
          _i7.AccountId32Codec(),
        ).sizeHint(author);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(21, output);
    const _i1.OptionCodec<_i7.AccountId32>(
      _i7.AccountId32Codec(),
    ).encodeTo(author, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorTipDeferred &&
          other.author == author &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(author, amount);
}

class AuthorTipCompleted extends Event {
  const AuthorTipCompleted({required this.author, required this.amount});

  factory AuthorTipCompleted._decode(_i1.Input input) {
    return AuthorTipCompleted(
      author: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// T::AccountId
  final _i7.AccountId32 author;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'AuthorTipCompleted': {'author': author.toList(), 'amount': amount},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i7.AccountId32Codec().sizeHint(author);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(22, output);
    const _i1.U8ArrayCodec(32).encodeTo(author, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorTipCompleted &&
          _i9.listsEqual(other.author, author) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(author, amount);
}

class EcosystemTreasurySpent extends Event {
  const EcosystemTreasurySpent({
    required this.beneficiary,
    required this.amount,
  });

  factory EcosystemTreasurySpent._decode(_i1.Input input) {
    return EcosystemTreasurySpent(
      beneficiary: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// T::AccountId
  final _i7.AccountId32 beneficiary;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EcosystemTreasurySpent': {
      'beneficiary': beneficiary.toList(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i7.AccountId32Codec().sizeHint(beneficiary);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(23, output);
    const _i1.U8ArrayCodec(32).encodeTo(beneficiary, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EcosystemTreasurySpent &&
          _i9.listsEqual(other.beneficiary, beneficiary) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(beneficiary, amount);
}

class RewardReserveLow extends Event {
  const RewardReserveLow({
    required this.available,
    required this.committedLiabilities,
  });

  factory RewardReserveLow._decode(_i1.Input input) {
    return RewardReserveLow(
      available: _i1.U128Codec.codec.decode(input),
      committedLiabilities: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt available;

  /// BalanceOf<T>
  final BigInt committedLiabilities;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'RewardReserveLow': {
      'available': available,
      'committedLiabilities': committedLiabilities,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(available);
    size = size + _i1.U128Codec.codec.sizeHint(committedLiabilities);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(24, output);
    _i1.U128Codec.codec.encodeTo(available, output);
    _i1.U128Codec.codec.encodeTo(committedLiabilities, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardReserveLow &&
          other.available == available &&
          other.committedLiabilities == committedLiabilities;

  @override
  int get hashCode => Object.hash(available, committedLiabilities);
}

class RewardPotBelowMinimum extends Event {
  const RewardPotBelowMinimum({required this.balance, required this.required});

  factory RewardPotBelowMinimum._decode(_i1.Input input) {
    return RewardPotBelowMinimum(
      balance: _i1.U128Codec.codec.decode(input),
      required: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt balance;

  /// BalanceOf<T>
  final BigInt required;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'RewardPotBelowMinimum': {'balance': balance, 'required': required},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(balance);
    size = size + _i1.U128Codec.codec.sizeHint(required);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(25, output);
    _i1.U128Codec.codec.encodeTo(balance, output);
    _i1.U128Codec.codec.encodeTo(required, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardPotBelowMinimum &&
          other.balance == balance &&
          other.required == required;

  @override
  int get hashCode => Object.hash(balance, required);
}

class TreasuryPotBelowMinimum extends Event {
  const TreasuryPotBelowMinimum({
    required this.balance,
    required this.required,
  });

  factory TreasuryPotBelowMinimum._decode(_i1.Input input) {
    return TreasuryPotBelowMinimum(
      balance: _i1.U128Codec.codec.decode(input),
      required: _i1.U128Codec.codec.decode(input),
    );
  }

  /// BalanceOf<T>
  final BigInt balance;

  /// BalanceOf<T>
  final BigInt required;

  @override
  Map<String, Map<String, BigInt>> toJson() => {
    'TreasuryPotBelowMinimum': {'balance': balance, 'required': required},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U128Codec.codec.sizeHint(balance);
    size = size + _i1.U128Codec.codec.sizeHint(required);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(26, output);
    _i1.U128Codec.codec.encodeTo(balance, output);
    _i1.U128Codec.codec.encodeTo(required, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreasuryPotBelowMinimum &&
          other.balance == balance &&
          other.required == required;

  @override
  int get hashCode => Object.hash(balance, required);
}

class RewardAllocationPaused extends Event {
  const RewardAllocationPaused({required this.era, required this.available});

  factory RewardAllocationPaused._decode(_i1.Input input) {
    return RewardAllocationPaused(
      era: _i1.U32Codec.codec.decode(input),
      available: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt available;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'RewardAllocationPaused': {'era': era, 'available': available},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(available);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(27, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(available, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardAllocationPaused &&
          other.era == era &&
          other.available == available;

  @override
  int get hashCode => Object.hash(era, available);
}

class RewardAllocationResumed extends Event {
  const RewardAllocationResumed({required this.era, required this.available});

  factory RewardAllocationResumed._decode(_i1.Input input) {
    return RewardAllocationResumed(
      era: _i1.U32Codec.codec.decode(input),
      available: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt available;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'RewardAllocationResumed': {'era': era, 'available': available},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(available);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(28, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(available, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardAllocationResumed &&
          other.era == era &&
          other.available == available;

  @override
  int get hashCode => Object.hash(era, available);
}

class ClaimExpired extends Event {
  const ClaimExpired({required this.era, required this.releasedLiability});

  factory ClaimExpired._decode(_i1.Input input) {
    return ClaimExpired(
      era: _i1.U32Codec.codec.decode(input),
      releasedLiability: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt releasedLiability;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ClaimExpired': {'era': era, 'releasedLiability': releasedLiability},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(releasedLiability);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(29, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(releasedLiability, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimExpired &&
          other.era == era &&
          other.releasedLiability == releasedLiability;

  @override
  int get hashCode => Object.hash(era, releasedLiability);
}

class EraRoundingRemainderReleased extends Event {
  const EraRoundingRemainderReleased({required this.era, required this.amount});

  factory EraRoundingRemainderReleased._decode(_i1.Input input) {
    return EraRoundingRemainderReleased(
      era: _i1.U32Codec.codec.decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'EraRoundingRemainderReleased': {'era': era, 'amount': amount},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(30, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraRoundingRemainderReleased &&
          other.era == era &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(era, amount);
}

class LegacyClaimOnlyEntered extends Event {
  const LegacyClaimOnlyEntered({required this.cutoffEra});

  factory LegacyClaimOnlyEntered._decode(_i1.Input input) {
    return LegacyClaimOnlyEntered(cutoffEra: _i1.U32Codec.codec.decode(input));
  }

  /// EraIndex
  final int cutoffEra;

  @override
  Map<String, Map<String, int>> toJson() => {
    'LegacyClaimOnlyEntered': {'cutoffEra': cutoffEra},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(cutoffEra);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(31, output);
    _i1.U32Codec.codec.encodeTo(cutoffEra, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyClaimOnlyEntered && other.cutoffEra == cutoffEra;

  @override
  int get hashCode => cutoffEra.hashCode;
}
