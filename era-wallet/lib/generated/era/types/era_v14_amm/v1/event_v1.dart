// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import 'asset.dart' as _i4;
import 'pool_id.dart' as _i3;

abstract class EventV1 {
  const EventV1();

  factory EventV1.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $EventV1Codec codec = $EventV1Codec();

  static const $EventV1 values = $EventV1();

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

class $EventV1 {
  const $EventV1();

  PoolCreated poolCreated({
    required _i3.PoolId pool,
    required List<int> creator,
    required List<int> custodyAccount,
  }) {
    return PoolCreated(
      pool: pool,
      creator: creator,
      custodyAccount: custodyAccount,
    );
  }

  LiquidityAdded liquidityAdded({
    required _i3.PoolId pool,
    required List<int> provider,
    required BigInt amount0,
    required BigInt amount1,
    required BigInt lpMinted,
  }) {
    return LiquidityAdded(
      pool: pool,
      provider: provider,
      amount0: amount0,
      amount1: amount1,
      lpMinted: lpMinted,
    );
  }

  LiquidityRemoved liquidityRemoved({
    required _i3.PoolId pool,
    required List<int> provider,
    required List<int> recipient,
    required BigInt amount0,
    required BigInt amount1,
    required BigInt lpBurned,
  }) {
    return LiquidityRemoved(
      pool: pool,
      provider: provider,
      recipient: recipient,
      amount0: amount0,
      amount1: amount1,
      lpBurned: lpBurned,
    );
  }

  SwapExecuted swapExecuted({
    required _i3.PoolId pool,
    required List<int> trader,
    required List<int> recipient,
    required _i4.Asset assetIn,
    required _i4.Asset assetOut,
    required BigInt amountIn,
    required BigInt amountOut,
    required BigInt totalFee,
    required BigInt protocolFee,
    required bool exactOutput,
  }) {
    return SwapExecuted(
      pool: pool,
      trader: trader,
      recipient: recipient,
      assetIn: assetIn,
      assetOut: assetOut,
      amountIn: amountIn,
      amountOut: amountOut,
      totalFee: totalFee,
      protocolFee: protocolFee,
      exactOutput: exactOutput,
    );
  }
}

class $EventV1Codec with _i1.Codec<EventV1> {
  const $EventV1Codec();

  @override
  EventV1 decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PoolCreated._decode(input);
      case 1:
        return LiquidityAdded._decode(input);
      case 2:
        return LiquidityRemoved._decode(input);
      case 3:
        return SwapExecuted._decode(input);
      default:
        throw Exception('EventV1: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(EventV1 value, _i1.Output output) {
    switch (value.runtimeType) {
      case PoolCreated:
        (value as PoolCreated).encodeTo(output);
        break;
      case LiquidityAdded:
        (value as LiquidityAdded).encodeTo(output);
        break;
      case LiquidityRemoved:
        (value as LiquidityRemoved).encodeTo(output);
        break;
      case SwapExecuted:
        (value as SwapExecuted).encodeTo(output);
        break;
      default:
        throw Exception(
          'EventV1: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(EventV1 value) {
    switch (value.runtimeType) {
      case PoolCreated:
        return (value as PoolCreated)._sizeHint();
      case LiquidityAdded:
        return (value as LiquidityAdded)._sizeHint();
      case LiquidityRemoved:
        return (value as LiquidityRemoved)._sizeHint();
      case SwapExecuted:
        return (value as SwapExecuted)._sizeHint();
      default:
        throw Exception(
          'EventV1: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class PoolCreated extends EventV1 {
  const PoolCreated({
    required this.pool,
    required this.creator,
    required this.custodyAccount,
  });

  factory PoolCreated._decode(_i1.Input input) {
    return PoolCreated(
      pool: _i3.PoolId.codec.decode(input),
      creator: const _i1.U8ArrayCodec(32).decode(input),
      custodyAccount: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// PoolId
  final _i3.PoolId pool;

  /// AccountId
  final List<int> creator;

  /// AccountId
  final List<int> custodyAccount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PoolCreated': {
      'pool': pool.toJson(),
      'creator': creator.toList(),
      'custodyAccount': custodyAccount.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.PoolId.codec.sizeHint(pool);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(creator);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(custodyAccount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.PoolId.codec.encodeTo(pool, output);
    const _i1.U8ArrayCodec(32).encodeTo(creator, output);
    const _i1.U8ArrayCodec(32).encodeTo(custodyAccount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoolCreated &&
          other.pool == pool &&
          _i5.listsEqual(other.creator, creator) &&
          _i5.listsEqual(other.custodyAccount, custodyAccount);

  @override
  int get hashCode => Object.hash(pool, creator, custodyAccount);
}

class LiquidityAdded extends EventV1 {
  const LiquidityAdded({
    required this.pool,
    required this.provider,
    required this.amount0,
    required this.amount1,
    required this.lpMinted,
  });

  factory LiquidityAdded._decode(_i1.Input input) {
    return LiquidityAdded(
      pool: _i3.PoolId.codec.decode(input),
      provider: const _i1.U8ArrayCodec(32).decode(input),
      amount0: _i1.U128Codec.codec.decode(input),
      amount1: _i1.U128Codec.codec.decode(input),
      lpMinted: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PoolId
  final _i3.PoolId pool;

  /// AccountId
  final List<int> provider;

  /// u128
  final BigInt amount0;

  /// u128
  final BigInt amount1;

  /// u128
  final BigInt lpMinted;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'LiquidityAdded': {
      'pool': pool.toJson(),
      'provider': provider.toList(),
      'amount0': amount0,
      'amount1': amount1,
      'lpMinted': lpMinted,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.PoolId.codec.sizeHint(pool);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(provider);
    size = size + _i1.U128Codec.codec.sizeHint(amount0);
    size = size + _i1.U128Codec.codec.sizeHint(amount1);
    size = size + _i1.U128Codec.codec.sizeHint(lpMinted);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i3.PoolId.codec.encodeTo(pool, output);
    const _i1.U8ArrayCodec(32).encodeTo(provider, output);
    _i1.U128Codec.codec.encodeTo(amount0, output);
    _i1.U128Codec.codec.encodeTo(amount1, output);
    _i1.U128Codec.codec.encodeTo(lpMinted, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidityAdded &&
          other.pool == pool &&
          _i5.listsEqual(other.provider, provider) &&
          other.amount0 == amount0 &&
          other.amount1 == amount1 &&
          other.lpMinted == lpMinted;

  @override
  int get hashCode => Object.hash(pool, provider, amount0, amount1, lpMinted);
}

class LiquidityRemoved extends EventV1 {
  const LiquidityRemoved({
    required this.pool,
    required this.provider,
    required this.recipient,
    required this.amount0,
    required this.amount1,
    required this.lpBurned,
  });

  factory LiquidityRemoved._decode(_i1.Input input) {
    return LiquidityRemoved(
      pool: _i3.PoolId.codec.decode(input),
      provider: const _i1.U8ArrayCodec(32).decode(input),
      recipient: const _i1.U8ArrayCodec(32).decode(input),
      amount0: _i1.U128Codec.codec.decode(input),
      amount1: _i1.U128Codec.codec.decode(input),
      lpBurned: _i1.U128Codec.codec.decode(input),
    );
  }

  /// PoolId
  final _i3.PoolId pool;

  /// AccountId
  final List<int> provider;

  /// AccountId
  final List<int> recipient;

  /// u128
  final BigInt amount0;

  /// u128
  final BigInt amount1;

  /// u128
  final BigInt lpBurned;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'LiquidityRemoved': {
      'pool': pool.toJson(),
      'provider': provider.toList(),
      'recipient': recipient.toList(),
      'amount0': amount0,
      'amount1': amount1,
      'lpBurned': lpBurned,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.PoolId.codec.sizeHint(pool);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(provider);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(recipient);
    size = size + _i1.U128Codec.codec.sizeHint(amount0);
    size = size + _i1.U128Codec.codec.sizeHint(amount1);
    size = size + _i1.U128Codec.codec.sizeHint(lpBurned);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i3.PoolId.codec.encodeTo(pool, output);
    const _i1.U8ArrayCodec(32).encodeTo(provider, output);
    const _i1.U8ArrayCodec(32).encodeTo(recipient, output);
    _i1.U128Codec.codec.encodeTo(amount0, output);
    _i1.U128Codec.codec.encodeTo(amount1, output);
    _i1.U128Codec.codec.encodeTo(lpBurned, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidityRemoved &&
          other.pool == pool &&
          _i5.listsEqual(other.provider, provider) &&
          _i5.listsEqual(other.recipient, recipient) &&
          other.amount0 == amount0 &&
          other.amount1 == amount1 &&
          other.lpBurned == lpBurned;

  @override
  int get hashCode =>
      Object.hash(pool, provider, recipient, amount0, amount1, lpBurned);
}

class SwapExecuted extends EventV1 {
  const SwapExecuted({
    required this.pool,
    required this.trader,
    required this.recipient,
    required this.assetIn,
    required this.assetOut,
    required this.amountIn,
    required this.amountOut,
    required this.totalFee,
    required this.protocolFee,
    required this.exactOutput,
  });

  factory SwapExecuted._decode(_i1.Input input) {
    return SwapExecuted(
      pool: _i3.PoolId.codec.decode(input),
      trader: const _i1.U8ArrayCodec(32).decode(input),
      recipient: const _i1.U8ArrayCodec(32).decode(input),
      assetIn: _i4.Asset.codec.decode(input),
      assetOut: _i4.Asset.codec.decode(input),
      amountIn: _i1.U128Codec.codec.decode(input),
      amountOut: _i1.U128Codec.codec.decode(input),
      totalFee: _i1.U128Codec.codec.decode(input),
      protocolFee: _i1.U128Codec.codec.decode(input),
      exactOutput: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// PoolId
  final _i3.PoolId pool;

  /// AccountId
  final List<int> trader;

  /// AccountId
  final List<int> recipient;

  /// Asset
  final _i4.Asset assetIn;

  /// Asset
  final _i4.Asset assetOut;

  /// u128
  final BigInt amountIn;

  /// u128
  final BigInt amountOut;

  /// u128
  final BigInt totalFee;

  /// u128
  final BigInt protocolFee;

  /// bool
  final bool exactOutput;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'SwapExecuted': {
      'pool': pool.toJson(),
      'trader': trader.toList(),
      'recipient': recipient.toList(),
      'assetIn': assetIn.toJson(),
      'assetOut': assetOut.toJson(),
      'amountIn': amountIn,
      'amountOut': amountOut,
      'totalFee': totalFee,
      'protocolFee': protocolFee,
      'exactOutput': exactOutput,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.PoolId.codec.sizeHint(pool);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(trader);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(recipient);
    size = size + _i4.Asset.codec.sizeHint(assetIn);
    size = size + _i4.Asset.codec.sizeHint(assetOut);
    size = size + _i1.U128Codec.codec.sizeHint(amountIn);
    size = size + _i1.U128Codec.codec.sizeHint(amountOut);
    size = size + _i1.U128Codec.codec.sizeHint(totalFee);
    size = size + _i1.U128Codec.codec.sizeHint(protocolFee);
    size = size + _i1.BoolCodec.codec.sizeHint(exactOutput);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i3.PoolId.codec.encodeTo(pool, output);
    const _i1.U8ArrayCodec(32).encodeTo(trader, output);
    const _i1.U8ArrayCodec(32).encodeTo(recipient, output);
    _i4.Asset.codec.encodeTo(assetIn, output);
    _i4.Asset.codec.encodeTo(assetOut, output);
    _i1.U128Codec.codec.encodeTo(amountIn, output);
    _i1.U128Codec.codec.encodeTo(amountOut, output);
    _i1.U128Codec.codec.encodeTo(totalFee, output);
    _i1.U128Codec.codec.encodeTo(protocolFee, output);
    _i1.BoolCodec.codec.encodeTo(exactOutput, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwapExecuted &&
          other.pool == pool &&
          _i5.listsEqual(other.trader, trader) &&
          _i5.listsEqual(other.recipient, recipient) &&
          other.assetIn == assetIn &&
          other.assetOut == assetOut &&
          other.amountIn == amountIn &&
          other.amountOut == amountOut &&
          other.totalFee == totalFee &&
          other.protocolFee == protocolFee &&
          other.exactOutput == exactOutput;

  @override
  int get hashCode => Object.hash(
    pool,
    trader,
    recipient,
    assetIn,
    assetOut,
    amountIn,
    amountOut,
    totalFee,
    protocolFee,
    exactOutput,
  );
}
