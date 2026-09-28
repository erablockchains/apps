// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import '../../sp_core/crypto/account_id32.dart' as _i3;
import '../fee_routing_configuration.dart' as _i4;

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

  Map<String, dynamic> toJson();
}

class $Call {
  const $Call();

  ClaimRewardPage claimRewardPage({
    required int era,
    required _i3.AccountId32 validator,
    required int page,
  }) {
    return ClaimRewardPage(era: era, validator: validator, page: page);
  }

  SyncRewardPot syncRewardPot() {
    return SyncRewardPot();
  }

  SetFeeRoutingConfiguration setFeeRoutingConfiguration({
    required _i4.FeeRoutingConfiguration new_,
  }) {
    return SetFeeRoutingConfiguration(new_: new_);
  }

  SpendEcosystemTreasury spendEcosystemTreasury({
    required _i3.AccountId32 beneficiary,
    required BigInt amount,
  }) {
    return SpendEcosystemTreasury(beneficiary: beneficiary, amount: amount);
  }

  ActivateRewardsAndFeeRouting activateRewardsAndFeeRouting() {
    return ActivateRewardsAndFeeRouting();
  }

  RetryDeferredFeeRouting retryDeferredFeeRouting() {
    return RetryDeferredFeeRouting();
  }

  RetryDeferredAuthorTip retryDeferredAuthorTip({
    required _i3.AccountId32 author,
  }) {
    return RetryDeferredAuthorTip(author: author);
  }

  CancelLegacyZeroPointLiability cancelLegacyZeroPointLiability({
    required int era,
  }) {
    return CancelLegacyZeroPointLiability(era: era);
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ClaimRewardPage._decode(input);
      case 1:
        return const SyncRewardPot();
      case 2:
        return SetFeeRoutingConfiguration._decode(input);
      case 3:
        return SpendEcosystemTreasury._decode(input);
      case 4:
        return const ActivateRewardsAndFeeRouting();
      case 5:
        return const RetryDeferredFeeRouting();
      case 6:
        return RetryDeferredAuthorTip._decode(input);
      case 7:
        return CancelLegacyZeroPointLiability._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case ClaimRewardPage:
        (value as ClaimRewardPage).encodeTo(output);
        break;
      case SyncRewardPot:
        (value as SyncRewardPot).encodeTo(output);
        break;
      case SetFeeRoutingConfiguration:
        (value as SetFeeRoutingConfiguration).encodeTo(output);
        break;
      case SpendEcosystemTreasury:
        (value as SpendEcosystemTreasury).encodeTo(output);
        break;
      case ActivateRewardsAndFeeRouting:
        (value as ActivateRewardsAndFeeRouting).encodeTo(output);
        break;
      case RetryDeferredFeeRouting:
        (value as RetryDeferredFeeRouting).encodeTo(output);
        break;
      case RetryDeferredAuthorTip:
        (value as RetryDeferredAuthorTip).encodeTo(output);
        break;
      case CancelLegacyZeroPointLiability:
        (value as CancelLegacyZeroPointLiability).encodeTo(output);
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
      case ClaimRewardPage:
        return (value as ClaimRewardPage)._sizeHint();
      case SyncRewardPot:
        return 1;
      case SetFeeRoutingConfiguration:
        return (value as SetFeeRoutingConfiguration)._sizeHint();
      case SpendEcosystemTreasury:
        return (value as SpendEcosystemTreasury)._sizeHint();
      case ActivateRewardsAndFeeRouting:
        return 1;
      case RetryDeferredFeeRouting:
        return 1;
      case RetryDeferredAuthorTip:
        return (value as RetryDeferredAuthorTip)._sizeHint();
      case CancelLegacyZeroPointLiability:
        return (value as CancelLegacyZeroPointLiability)._sizeHint();
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

/// Claim one finalized reward page. Any signed account may trigger the public payout.
class ClaimRewardPage extends Call {
  const ClaimRewardPage({
    required this.era,
    required this.validator,
    required this.page,
  });

  factory ClaimRewardPage._decode(_i1.Input input) {
    return ClaimRewardPage(
      era: _i1.U32Codec.codec.decode(input),
      validator: const _i1.U8ArrayCodec(32).decode(input),
      page: _i1.U32Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  /// T::AccountId
  final _i3.AccountId32 validator;

  /// Page
  final int page;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'claim_reward_page': {
      'era': era,
      'validator': validator.toList(),
      'page': page,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(era);
    size = size + const _i3.AccountId32Codec().sizeHint(validator);
    size = size + _i1.U32Codec.codec.sizeHint(page);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    _i1.U32Codec.codec.encodeTo(page, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimRewardPage &&
          other.era == era &&
          _i5.listsEqual(other.validator, validator) &&
          other.page == page;

  @override
  int get hashCode => Object.hash(era, validator, page);
}

/// Reconcile a same-block, separately authorized transfer into the reward pot.
/// This call records public accounting only and never moves funds.
class SyncRewardPot extends Call {
  const SyncRewardPot();

  @override
  Map<String, dynamic> toJson() => {'sync_reward_pot': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
  }

  @override
  bool operator ==(Object other) => other is SyncRewardPot;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Update fee routing within the approved compile-time bounds.
class SetFeeRoutingConfiguration extends Call {
  const SetFeeRoutingConfiguration({required this.new_});

  factory SetFeeRoutingConfiguration._decode(_i1.Input input) {
    return SetFeeRoutingConfiguration(
      new_: _i4.FeeRoutingConfiguration.codec.decode(input),
    );
  }

  /// FeeRoutingConfiguration
  final _i4.FeeRoutingConfiguration new_;

  @override
  Map<String, Map<String, Map<String, int>>> toJson() => {
    'set_fee_routing_configuration': {'new': new_.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i4.FeeRoutingConfiguration.codec.sizeHint(new_);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i4.FeeRoutingConfiguration.codec.encodeTo(new_, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetFeeRoutingConfiguration && other.new_ == new_;

  @override
  int get hashCode => new_.hashCode;
}

/// Spend only from the isolated Ecosystem Treasury pot under the configured authority.
class SpendEcosystemTreasury extends Call {
  const SpendEcosystemTreasury({
    required this.beneficiary,
    required this.amount,
  });

  factory SpendEcosystemTreasury._decode(_i1.Input input) {
    return SpendEcosystemTreasury(
      beneficiary: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// T::AccountId
  final _i3.AccountId32 beneficiary;

  /// BalanceOf<T>
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'spend_ecosystem_treasury': {
      'beneficiary': beneficiary.toList(),
      'amount': amount,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(beneficiary);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    const _i1.U8ArrayCodec(32).encodeTo(beneficiary, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendEcosystemTreasury &&
          _i5.listsEqual(other.beneficiary, beneficiary) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(beneficiary, amount);
}

/// Atomically activate rewards and corrected-fee routing after every floor and reserve gate.
class ActivateRewardsAndFeeRouting extends Call {
  const ActivateRewardsAndFeeRouting();

  @override
  Map<String, dynamic> toJson() => {'activate_rewards_and_fee_routing': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
  }

  @override
  bool operator ==(Object other) => other is ActivateRewardsAndFeeRouting;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Retry all staged normal-fee obligations. Any signed account may trigger safe settlement.
class RetryDeferredFeeRouting extends Call {
  const RetryDeferredFeeRouting();

  @override
  Map<String, dynamic> toJson() => {'retry_deferred_fee_routing': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
  }

  @override
  bool operator ==(Object other) => other is RetryDeferredFeeRouting;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Retry a staged tip owed to a specific block author.
class RetryDeferredAuthorTip extends Call {
  const RetryDeferredAuthorTip({required this.author});

  factory RetryDeferredAuthorTip._decode(_i1.Input input) {
    return RetryDeferredAuthorTip(
      author: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// T::AccountId
  final _i3.AccountId32 author;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'retry_deferred_author_tip': {'author': author.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(author);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    const _i1.U8ArrayCodec(32).encodeTo(author, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryDeferredAuthorTip && _i5.listsEqual(other.author, author);

  @override
  int get hashCode => author.hashCode;
}

/// Release one proven pre-Spec12 zero-point liability without moving funds.
class CancelLegacyZeroPointLiability extends Call {
  const CancelLegacyZeroPointLiability({required this.era});

  factory CancelLegacyZeroPointLiability._decode(_i1.Input input) {
    return CancelLegacyZeroPointLiability(
      era: _i1.U32Codec.codec.decode(input),
    );
  }

  /// EraIndex
  final int era;

  @override
  Map<String, Map<String, int>> toJson() => {
    'cancel_legacy_zero_point_liability': {'era': era},
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
      other is CancelLegacyZeroPointLiability && other.era == era;

  @override
  int get hashCode => era.hashCode;
}
