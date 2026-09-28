// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import '../../../era_v14_amm/v1/asset.dart' as _i3;
import '../../../sp_core/crypto/account_id32.dart' as _i4;

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

  CreatePool createPool({
    required _i3.Asset assetA,
    required _i3.Asset assetB,
    required int deadline,
  }) {
    return CreatePool(assetA: assetA, assetB: assetB, deadline: deadline);
  }

  AddLiquidity addLiquidity({
    required _i3.Asset assetA,
    required _i3.Asset assetB,
    required BigInt desiredA,
    required BigInt desiredB,
    required BigInt minA,
    required BigInt minB,
    required int deadline,
  }) {
    return AddLiquidity(
      assetA: assetA,
      assetB: assetB,
      desiredA: desiredA,
      desiredB: desiredB,
      minA: minA,
      minB: minB,
      deadline: deadline,
    );
  }

  RemoveLiquidity removeLiquidity({
    required _i3.Asset assetA,
    required _i3.Asset assetB,
    required BigInt lp,
    required BigInt minA,
    required BigInt minB,
    required _i4.AccountId32 recipient,
    required int deadline,
  }) {
    return RemoveLiquidity(
      assetA: assetA,
      assetB: assetB,
      lp: lp,
      minA: minA,
      minB: minB,
      recipient: recipient,
      deadline: deadline,
    );
  }

  SwapExactInput swapExactInput({
    required _i3.Asset assetIn,
    required _i3.Asset assetOut,
    required BigInt amountIn,
    required BigInt minOut,
    required _i4.AccountId32 recipient,
    required int deadline,
  }) {
    return SwapExactInput(
      assetIn: assetIn,
      assetOut: assetOut,
      amountIn: amountIn,
      minOut: minOut,
      recipient: recipient,
      deadline: deadline,
    );
  }

  SwapExactOutput swapExactOutput({
    required _i3.Asset assetIn,
    required _i3.Asset assetOut,
    required BigInt amountOut,
    required BigInt maxIn,
    required _i4.AccountId32 recipient,
    required int deadline,
  }) {
    return SwapExactOutput(
      assetIn: assetIn,
      assetOut: assetOut,
      amountOut: amountOut,
      maxIn: maxIn,
      recipient: recipient,
      deadline: deadline,
    );
  }

  ApprovePair approvePair({
    required _i3.Asset assetA,
    required _i3.Asset assetB,
  }) {
    return ApprovePair(assetA: assetA, assetB: assetB);
  }

  Activate activate() {
    return Activate();
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return CreatePool._decode(input);
      case 1:
        return AddLiquidity._decode(input);
      case 2:
        return RemoveLiquidity._decode(input);
      case 3:
        return SwapExactInput._decode(input);
      case 4:
        return SwapExactOutput._decode(input);
      case 10:
        return ApprovePair._decode(input);
      case 11:
        return const Activate();
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case CreatePool:
        (value as CreatePool).encodeTo(output);
        break;
      case AddLiquidity:
        (value as AddLiquidity).encodeTo(output);
        break;
      case RemoveLiquidity:
        (value as RemoveLiquidity).encodeTo(output);
        break;
      case SwapExactInput:
        (value as SwapExactInput).encodeTo(output);
        break;
      case SwapExactOutput:
        (value as SwapExactOutput).encodeTo(output);
        break;
      case ApprovePair:
        (value as ApprovePair).encodeTo(output);
        break;
      case Activate:
        (value as Activate).encodeTo(output);
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
      case CreatePool:
        return (value as CreatePool)._sizeHint();
      case AddLiquidity:
        return (value as AddLiquidity)._sizeHint();
      case RemoveLiquidity:
        return (value as RemoveLiquidity)._sizeHint();
      case SwapExactInput:
        return (value as SwapExactInput)._sizeHint();
      case SwapExactOutput:
        return (value as SwapExactOutput)._sizeHint();
      case ApprovePair:
        return (value as ApprovePair)._sizeHint();
      case Activate:
        return 1;
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class CreatePool extends Call {
  const CreatePool({
    required this.assetA,
    required this.assetB,
    required this.deadline,
  });

  factory CreatePool._decode(_i1.Input input) {
    return CreatePool(
      assetA: _i3.Asset.codec.decode(input),
      assetB: _i3.Asset.codec.decode(input),
      deadline: _i1.U32Codec.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i3.Asset assetA;

  /// contract::Asset
  final _i3.Asset assetB;

  /// u32
  final int deadline;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'create_pool': {
      'assetA': assetA.toJson(),
      'assetB': assetB.toJson(),
      'deadline': deadline,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Asset.codec.sizeHint(assetA);
    size = size + _i3.Asset.codec.sizeHint(assetB);
    size = size + _i1.U32Codec.codec.sizeHint(deadline);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.Asset.codec.encodeTo(assetA, output);
    _i3.Asset.codec.encodeTo(assetB, output);
    _i1.U32Codec.codec.encodeTo(deadline, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePool &&
          other.assetA == assetA &&
          other.assetB == assetB &&
          other.deadline == deadline;

  @override
  int get hashCode => Object.hash(assetA, assetB, deadline);
}

class AddLiquidity extends Call {
  const AddLiquidity({
    required this.assetA,
    required this.assetB,
    required this.desiredA,
    required this.desiredB,
    required this.minA,
    required this.minB,
    required this.deadline,
  });

  factory AddLiquidity._decode(_i1.Input input) {
    return AddLiquidity(
      assetA: _i3.Asset.codec.decode(input),
      assetB: _i3.Asset.codec.decode(input),
      desiredA: _i1.U128Codec.codec.decode(input),
      desiredB: _i1.U128Codec.codec.decode(input),
      minA: _i1.U128Codec.codec.decode(input),
      minB: _i1.U128Codec.codec.decode(input),
      deadline: _i1.U32Codec.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i3.Asset assetA;

  /// contract::Asset
  final _i3.Asset assetB;

  /// u128
  final BigInt desiredA;

  /// u128
  final BigInt desiredB;

  /// u128
  final BigInt minA;

  /// u128
  final BigInt minB;

  /// u32
  final int deadline;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'add_liquidity': {
      'assetA': assetA.toJson(),
      'assetB': assetB.toJson(),
      'desiredA': desiredA,
      'desiredB': desiredB,
      'minA': minA,
      'minB': minB,
      'deadline': deadline,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Asset.codec.sizeHint(assetA);
    size = size + _i3.Asset.codec.sizeHint(assetB);
    size = size + _i1.U128Codec.codec.sizeHint(desiredA);
    size = size + _i1.U128Codec.codec.sizeHint(desiredB);
    size = size + _i1.U128Codec.codec.sizeHint(minA);
    size = size + _i1.U128Codec.codec.sizeHint(minB);
    size = size + _i1.U32Codec.codec.sizeHint(deadline);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i3.Asset.codec.encodeTo(assetA, output);
    _i3.Asset.codec.encodeTo(assetB, output);
    _i1.U128Codec.codec.encodeTo(desiredA, output);
    _i1.U128Codec.codec.encodeTo(desiredB, output);
    _i1.U128Codec.codec.encodeTo(minA, output);
    _i1.U128Codec.codec.encodeTo(minB, output);
    _i1.U32Codec.codec.encodeTo(deadline, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddLiquidity &&
          other.assetA == assetA &&
          other.assetB == assetB &&
          other.desiredA == desiredA &&
          other.desiredB == desiredB &&
          other.minA == minA &&
          other.minB == minB &&
          other.deadline == deadline;

  @override
  int get hashCode =>
      Object.hash(assetA, assetB, desiredA, desiredB, minA, minB, deadline);
}

class RemoveLiquidity extends Call {
  const RemoveLiquidity({
    required this.assetA,
    required this.assetB,
    required this.lp,
    required this.minA,
    required this.minB,
    required this.recipient,
    required this.deadline,
  });

  factory RemoveLiquidity._decode(_i1.Input input) {
    return RemoveLiquidity(
      assetA: _i3.Asset.codec.decode(input),
      assetB: _i3.Asset.codec.decode(input),
      lp: _i1.U128Codec.codec.decode(input),
      minA: _i1.U128Codec.codec.decode(input),
      minB: _i1.U128Codec.codec.decode(input),
      recipient: const _i1.U8ArrayCodec(32).decode(input),
      deadline: _i1.U32Codec.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i3.Asset assetA;

  /// contract::Asset
  final _i3.Asset assetB;

  /// u128
  final BigInt lp;

  /// u128
  final BigInt minA;

  /// u128
  final BigInt minB;

  /// AccountId
  final _i4.AccountId32 recipient;

  /// u32
  final int deadline;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'remove_liquidity': {
      'assetA': assetA.toJson(),
      'assetB': assetB.toJson(),
      'lp': lp,
      'minA': minA,
      'minB': minB,
      'recipient': recipient.toList(),
      'deadline': deadline,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Asset.codec.sizeHint(assetA);
    size = size + _i3.Asset.codec.sizeHint(assetB);
    size = size + _i1.U128Codec.codec.sizeHint(lp);
    size = size + _i1.U128Codec.codec.sizeHint(minA);
    size = size + _i1.U128Codec.codec.sizeHint(minB);
    size = size + const _i4.AccountId32Codec().sizeHint(recipient);
    size = size + _i1.U32Codec.codec.sizeHint(deadline);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i3.Asset.codec.encodeTo(assetA, output);
    _i3.Asset.codec.encodeTo(assetB, output);
    _i1.U128Codec.codec.encodeTo(lp, output);
    _i1.U128Codec.codec.encodeTo(minA, output);
    _i1.U128Codec.codec.encodeTo(minB, output);
    const _i1.U8ArrayCodec(32).encodeTo(recipient, output);
    _i1.U32Codec.codec.encodeTo(deadline, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoveLiquidity &&
          other.assetA == assetA &&
          other.assetB == assetB &&
          other.lp == lp &&
          other.minA == minA &&
          other.minB == minB &&
          _i5.listsEqual(other.recipient, recipient) &&
          other.deadline == deadline;

  @override
  int get hashCode =>
      Object.hash(assetA, assetB, lp, minA, minB, recipient, deadline);
}

class SwapExactInput extends Call {
  const SwapExactInput({
    required this.assetIn,
    required this.assetOut,
    required this.amountIn,
    required this.minOut,
    required this.recipient,
    required this.deadline,
  });

  factory SwapExactInput._decode(_i1.Input input) {
    return SwapExactInput(
      assetIn: _i3.Asset.codec.decode(input),
      assetOut: _i3.Asset.codec.decode(input),
      amountIn: _i1.U128Codec.codec.decode(input),
      minOut: _i1.U128Codec.codec.decode(input),
      recipient: const _i1.U8ArrayCodec(32).decode(input),
      deadline: _i1.U32Codec.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i3.Asset assetIn;

  /// contract::Asset
  final _i3.Asset assetOut;

  /// u128
  final BigInt amountIn;

  /// u128
  final BigInt minOut;

  /// AccountId
  final _i4.AccountId32 recipient;

  /// u32
  final int deadline;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'swap_exact_input': {
      'assetIn': assetIn.toJson(),
      'assetOut': assetOut.toJson(),
      'amountIn': amountIn,
      'minOut': minOut,
      'recipient': recipient.toList(),
      'deadline': deadline,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Asset.codec.sizeHint(assetIn);
    size = size + _i3.Asset.codec.sizeHint(assetOut);
    size = size + _i1.U128Codec.codec.sizeHint(amountIn);
    size = size + _i1.U128Codec.codec.sizeHint(minOut);
    size = size + const _i4.AccountId32Codec().sizeHint(recipient);
    size = size + _i1.U32Codec.codec.sizeHint(deadline);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i3.Asset.codec.encodeTo(assetIn, output);
    _i3.Asset.codec.encodeTo(assetOut, output);
    _i1.U128Codec.codec.encodeTo(amountIn, output);
    _i1.U128Codec.codec.encodeTo(minOut, output);
    const _i1.U8ArrayCodec(32).encodeTo(recipient, output);
    _i1.U32Codec.codec.encodeTo(deadline, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwapExactInput &&
          other.assetIn == assetIn &&
          other.assetOut == assetOut &&
          other.amountIn == amountIn &&
          other.minOut == minOut &&
          _i5.listsEqual(other.recipient, recipient) &&
          other.deadline == deadline;

  @override
  int get hashCode =>
      Object.hash(assetIn, assetOut, amountIn, minOut, recipient, deadline);
}

class SwapExactOutput extends Call {
  const SwapExactOutput({
    required this.assetIn,
    required this.assetOut,
    required this.amountOut,
    required this.maxIn,
    required this.recipient,
    required this.deadline,
  });

  factory SwapExactOutput._decode(_i1.Input input) {
    return SwapExactOutput(
      assetIn: _i3.Asset.codec.decode(input),
      assetOut: _i3.Asset.codec.decode(input),
      amountOut: _i1.U128Codec.codec.decode(input),
      maxIn: _i1.U128Codec.codec.decode(input),
      recipient: const _i1.U8ArrayCodec(32).decode(input),
      deadline: _i1.U32Codec.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i3.Asset assetIn;

  /// contract::Asset
  final _i3.Asset assetOut;

  /// u128
  final BigInt amountOut;

  /// u128
  final BigInt maxIn;

  /// AccountId
  final _i4.AccountId32 recipient;

  /// u32
  final int deadline;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'swap_exact_output': {
      'assetIn': assetIn.toJson(),
      'assetOut': assetOut.toJson(),
      'amountOut': amountOut,
      'maxIn': maxIn,
      'recipient': recipient.toList(),
      'deadline': deadline,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Asset.codec.sizeHint(assetIn);
    size = size + _i3.Asset.codec.sizeHint(assetOut);
    size = size + _i1.U128Codec.codec.sizeHint(amountOut);
    size = size + _i1.U128Codec.codec.sizeHint(maxIn);
    size = size + const _i4.AccountId32Codec().sizeHint(recipient);
    size = size + _i1.U32Codec.codec.sizeHint(deadline);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i3.Asset.codec.encodeTo(assetIn, output);
    _i3.Asset.codec.encodeTo(assetOut, output);
    _i1.U128Codec.codec.encodeTo(amountOut, output);
    _i1.U128Codec.codec.encodeTo(maxIn, output);
    const _i1.U8ArrayCodec(32).encodeTo(recipient, output);
    _i1.U32Codec.codec.encodeTo(deadline, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwapExactOutput &&
          other.assetIn == assetIn &&
          other.assetOut == assetOut &&
          other.amountOut == amountOut &&
          other.maxIn == maxIn &&
          _i5.listsEqual(other.recipient, recipient) &&
          other.deadline == deadline;

  @override
  int get hashCode =>
      Object.hash(assetIn, assetOut, amountOut, maxIn, recipient, deadline);
}

class ApprovePair extends Call {
  const ApprovePair({required this.assetA, required this.assetB});

  factory ApprovePair._decode(_i1.Input input) {
    return ApprovePair(
      assetA: _i3.Asset.codec.decode(input),
      assetB: _i3.Asset.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i3.Asset assetA;

  /// contract::Asset
  final _i3.Asset assetB;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'approve_pair': {'assetA': assetA.toJson(), 'assetB': assetB.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Asset.codec.sizeHint(assetA);
    size = size + _i3.Asset.codec.sizeHint(assetB);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i3.Asset.codec.encodeTo(assetA, output);
    _i3.Asset.codec.encodeTo(assetB, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovePair && other.assetA == assetA && other.assetB == assetB;

  @override
  int get hashCode => Object.hash(assetA, assetB);
}

class Activate extends Call {
  const Activate();

  @override
  Map<String, dynamic> toJson() => {'activate': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
  }

  @override
  bool operator ==(Object other) => other is Activate;

  @override
  int get hashCode => runtimeType.hashCode;
}
