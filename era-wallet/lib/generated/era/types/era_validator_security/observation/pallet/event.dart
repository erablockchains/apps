// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../offence_observation_v1.dart' as _i3;

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

  ObservationStored observationStored({
    required List<int> identityKey,
    required List<int> observationKey,
    required _i3.OffenceObservationV1 record,
  }) {
    return ObservationStored(
      identityKey: identityKey,
      observationKey: observationKey,
      record: record,
    );
  }

  ExpiredObservationsPruned expiredObservationsPruned({
    required int count,
    required int newHead,
    required int remaining,
  }) {
    return ExpiredObservationsPruned(
      count: count,
      newHead: newHead,
      remaining: remaining,
    );
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ObservationStored._decode(input);
      case 1:
        return ExpiredObservationsPruned._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case ObservationStored:
        (value as ObservationStored).encodeTo(output);
        break;
      case ExpiredObservationsPruned:
        (value as ExpiredObservationsPruned).encodeTo(output);
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
      case ObservationStored:
        return (value as ObservationStored)._sizeHint();
      case ExpiredObservationsPruned:
        return (value as ExpiredObservationsPruned)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class ObservationStored extends Event {
  const ObservationStored({
    required this.identityKey,
    required this.observationKey,
    required this.record,
  });

  factory ObservationStored._decode(_i1.Input input) {
    return ObservationStored(
      identityKey: const _i1.U8ArrayCodec(32).decode(input),
      observationKey: const _i1.U8ArrayCodec(32).decode(input),
      record: _i3.OffenceObservationV1.codec.decode(input),
    );
  }

  /// [u8; 32]
  final List<int> identityKey;

  /// [u8; 32]
  final List<int> observationKey;

  /// OffenceObservationV1<T::AccountId>
  final _i3.OffenceObservationV1 record;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ObservationStored': {
      'identityKey': identityKey.toList(),
      'observationKey': observationKey.toList(),
      'record': record.toJson(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i1.U8ArrayCodec(32).sizeHint(identityKey);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(observationKey);
    size = size + _i3.OffenceObservationV1.codec.sizeHint(record);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    const _i1.U8ArrayCodec(32).encodeTo(identityKey, output);
    const _i1.U8ArrayCodec(32).encodeTo(observationKey, output);
    _i3.OffenceObservationV1.codec.encodeTo(record, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservationStored &&
          _i4.listsEqual(other.identityKey, identityKey) &&
          _i4.listsEqual(other.observationKey, observationKey) &&
          other.record == record;

  @override
  int get hashCode => Object.hash(identityKey, observationKey, record);
}

class ExpiredObservationsPruned extends Event {
  const ExpiredObservationsPruned({
    required this.count,
    required this.newHead,
    required this.remaining,
  });

  factory ExpiredObservationsPruned._decode(_i1.Input input) {
    return ExpiredObservationsPruned(
      count: _i1.U32Codec.codec.decode(input),
      newHead: _i1.U32Codec.codec.decode(input),
      remaining: _i1.U32Codec.codec.decode(input),
    );
  }

  /// u32
  final int count;

  /// u32
  final int newHead;

  /// u32
  final int remaining;

  @override
  Map<String, Map<String, int>> toJson() => {
    'ExpiredObservationsPruned': {
      'count': count,
      'newHead': newHead,
      'remaining': remaining,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(count);
    size = size + _i1.U32Codec.codec.sizeHint(newHead);
    size = size + _i1.U32Codec.codec.sizeHint(remaining);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U32Codec.codec.encodeTo(count, output);
    _i1.U32Codec.codec.encodeTo(newHead, output);
    _i1.U32Codec.codec.encodeTo(remaining, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpiredObservationsPruned &&
          other.count == count &&
          other.newHead == newHead &&
          other.remaining == remaining;

  @override
  int get hashCode => Object.hash(count, newHead, remaining);
}
