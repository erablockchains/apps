// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

abstract class Asset {
  const Asset();

  factory Asset.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $AssetCodec codec = $AssetCodec();

  static const $Asset values = $Asset();

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

class $Asset {
  const $Asset();

  Native native() {
    return Native();
  }

  Registered registered(int value0) {
    return Registered(value0);
  }
}

class $AssetCodec with _i1.Codec<Asset> {
  const $AssetCodec();

  @override
  Asset decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return const Native();
      case 1:
        return Registered._decode(input);
      default:
        throw Exception('Asset: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Asset value, _i1.Output output) {
    switch (value.runtimeType) {
      case Native:
        (value as Native).encodeTo(output);
        break;
      case Registered:
        (value as Registered).encodeTo(output);
        break;
      default:
        throw Exception(
          'Asset: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Asset value) {
    switch (value.runtimeType) {
      case Native:
        return 1;
      case Registered:
        return (value as Registered)._sizeHint();
      default:
        throw Exception(
          'Asset: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class Native extends Asset {
  const Native();

  @override
  Map<String, dynamic> toJson() => {'Native': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
  }

  @override
  bool operator ==(Object other) => other is Native;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Registered extends Asset {
  const Registered(this.value0);

  factory Registered._decode(_i1.Input input) {
    return Registered(_i1.U32Codec.codec.decode(input));
  }

  /// u32
  final int value0;

  @override
  Map<String, int> toJson() => {'Registered': value0};

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U32Codec.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Registered && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}
