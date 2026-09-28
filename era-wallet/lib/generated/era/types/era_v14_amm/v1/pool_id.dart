// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;

import 'asset.dart' as _i2;

class PoolId {
  const PoolId({required this.asset0, required this.asset1});

  factory PoolId.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// Asset
  final _i2.Asset asset0;

  /// Asset
  final _i2.Asset asset1;

  static const $PoolIdCodec codec = $PoolIdCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, Map<String, dynamic>> toJson() => {
    'asset0': asset0.toJson(),
    'asset1': asset1.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoolId && other.asset0 == asset0 && other.asset1 == asset1;

  @override
  int get hashCode => Object.hash(asset0, asset1);
}

class $PoolIdCodec with _i1.Codec<PoolId> {
  const $PoolIdCodec();

  @override
  void encodeTo(PoolId obj, _i1.Output output) {
    _i2.Asset.codec.encodeTo(obj.asset0, output);
    _i2.Asset.codec.encodeTo(obj.asset1, output);
  }

  @override
  PoolId decode(_i1.Input input) {
    return PoolId(
      asset0: _i2.Asset.codec.decode(input),
      asset1: _i2.Asset.codec.decode(input),
    );
  }

  @override
  int sizeHint(PoolId obj) {
    int size = 0;
    size = size + _i2.Asset.codec.sizeHint(obj.asset0);
    size = size + _i2.Asset.codec.sizeHint(obj.asset1);
    return size;
  }
}
