// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../sp_core/crypto/account_id32.dart' as _i3;

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

  Activate activate() {
    return Activate();
  }

  ClaimRewardPage claimRewardPage({
    required int era,
    required _i3.AccountId32 validator,
    required int page,
  }) {
    return ClaimRewardPage(era: era, validator: validator, page: page);
  }

  RetryNormalFee retryNormalFee() {
    return RetryNormalFee();
  }

  RetryTip retryTip({_i3.AccountId32? author}) {
    return RetryTip(author: author);
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return const Activate();
      case 1:
        return ClaimRewardPage._decode(input);
      case 2:
        return const RetryNormalFee();
      case 3:
        return RetryTip._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case Activate:
        (value as Activate).encodeTo(output);
        break;
      case ClaimRewardPage:
        (value as ClaimRewardPage).encodeTo(output);
        break;
      case RetryNormalFee:
        (value as RetryNormalFee).encodeTo(output);
        break;
      case RetryTip:
        (value as RetryTip).encodeTo(output);
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
      case Activate:
        return 1;
      case ClaimRewardPage:
        return (value as ClaimRewardPage)._sizeHint();
      case RetryNormalFee:
        return 1;
      case RetryTip:
        return (value as RetryTip)._sizeHint();
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class Activate extends Call {
  const Activate();

  @override
  Map<String, dynamic> toJson() => {'activate': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
  }

  @override
  bool operator ==(Object other) => other is Activate;

  @override
  int get hashCode => runtimeType.hashCode;
}

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
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U32Codec.codec.encodeTo(era, output);
    const _i1.U8ArrayCodec(32).encodeTo(validator, output);
    _i1.U32Codec.codec.encodeTo(page, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimRewardPage &&
          other.era == era &&
          _i4.listsEqual(other.validator, validator) &&
          other.page == page;

  @override
  int get hashCode => Object.hash(era, validator, page);
}

class RetryNormalFee extends Call {
  const RetryNormalFee();

  @override
  Map<String, dynamic> toJson() => {'retry_normal_fee': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
  }

  @override
  bool operator ==(Object other) => other is RetryNormalFee;

  @override
  int get hashCode => runtimeType.hashCode;
}

class RetryTip extends Call {
  const RetryTip({this.author});

  factory RetryTip._decode(_i1.Input input) {
    return RetryTip(
      author: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
    );
  }

  /// Option<T::AccountId>
  final _i3.AccountId32? author;

  @override
  Map<String, Map<String, List<int>?>> toJson() => {
    'retry_tip': {'author': author?.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(author);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(author, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RetryTip && other.author == author;

  @override
  int get hashCode => author.hashCode;
}
