// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

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

  Map<String, Map<String, int>> toJson();
}

class $Event {
  const $Event();

  RootStored rootStored({required int index}) {
    return RootStored(index: index);
  }

  RootsPruned rootsPruned({required int upTo}) {
    return RootsPruned(upTo: upTo);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RootStored._decode(input);
      case 1:
        return RootsPruned._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case RootStored:
        (value as RootStored).encodeTo(output);
        break;
      case RootsPruned:
        (value as RootsPruned).encodeTo(output);
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
      case RootStored:
        return (value as RootStored)._sizeHint();
      case RootsPruned:
        return (value as RootsPruned)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

/// The merkle root of the validators of the said session were stored
class RootStored extends Event {
  const RootStored({required this.index});

  factory RootStored._decode(_i1.Input input) {
    return RootStored(index: _i1.U32Codec.codec.decode(input));
  }

  /// SessionIndex
  final int index;

  @override
  Map<String, Map<String, int>> toJson() => {
    'RootStored': {'index': index},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(index);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U32Codec.codec.encodeTo(index, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RootStored && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// The merkle roots of up to this session index were pruned
class RootsPruned extends Event {
  const RootsPruned({required this.upTo});

  factory RootsPruned._decode(_i1.Input input) {
    return RootsPruned(upTo: _i1.U32Codec.codec.decode(input));
  }

  /// SessionIndex
  final int upTo;

  @override
  Map<String, Map<String, int>> toJson() => {
    'RootsPruned': {'upTo': upTo},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(upTo);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U32Codec.codec.encodeTo(upTo, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RootsPruned && other.upTo == upTo;

  @override
  int get hashCode => upTo.hashCode;
}
