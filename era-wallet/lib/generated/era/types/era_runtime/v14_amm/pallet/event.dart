// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../../../era_v14_amm/v1/asset.dart' as _i4;
import '../../../era_v14_amm/v1/event_v1.dart' as _i3;

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

  Notice notice({required _i3.EventV1 event}) {
    return Notice(event: event);
  }

  PairApproved pairApproved({
    required _i4.Asset assetA,
    required _i4.Asset assetB,
    required int at,
  }) {
    return PairApproved(assetA: assetA, assetB: assetB, at: at);
  }

  Activated activated({required int at}) {
    return Activated(at: at);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return Notice._decode(input);
      case 1:
        return PairApproved._decode(input);
      case 2:
        return Activated._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case Notice:
        (value as Notice).encodeTo(output);
        break;
      case PairApproved:
        (value as PairApproved).encodeTo(output);
        break;
      case Activated:
        (value as Activated).encodeTo(output);
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
      case Notice:
        return (value as Notice)._sizeHint();
      case PairApproved:
        return (value as PairApproved)._sizeHint();
      case Activated:
        return (value as Activated)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class Notice extends Event {
  const Notice({required this.event});

  factory Notice._decode(_i1.Input input) {
    return Notice(event: _i3.EventV1.codec.decode(input));
  }

  /// contract::EventV1
  final _i3.EventV1 event;

  @override
  Map<String, Map<String, Map<String, Map<String, dynamic>>>> toJson() => {
    'Notice': {'event': event.toJson()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.EventV1.codec.sizeHint(event);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.EventV1.codec.encodeTo(event, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Notice && other.event == event;

  @override
  int get hashCode => event.hashCode;
}

class PairApproved extends Event {
  const PairApproved({
    required this.assetA,
    required this.assetB,
    required this.at,
  });

  factory PairApproved._decode(_i1.Input input) {
    return PairApproved(
      assetA: _i4.Asset.codec.decode(input),
      assetB: _i4.Asset.codec.decode(input),
      at: _i1.U32Codec.codec.decode(input),
    );
  }

  /// contract::Asset
  final _i4.Asset assetA;

  /// contract::Asset
  final _i4.Asset assetB;

  /// BlockNumberFor<T>
  final int at;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PairApproved': {
      'assetA': assetA.toJson(),
      'assetB': assetB.toJson(),
      'at': at,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i4.Asset.codec.sizeHint(assetA);
    size = size + _i4.Asset.codec.sizeHint(assetB);
    size = size + _i1.U32Codec.codec.sizeHint(at);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i4.Asset.codec.encodeTo(assetA, output);
    _i4.Asset.codec.encodeTo(assetB, output);
    _i1.U32Codec.codec.encodeTo(at, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairApproved &&
          other.assetA == assetA &&
          other.assetB == assetB &&
          other.at == at;

  @override
  int get hashCode => Object.hash(assetA, assetB, at);
}

class Activated extends Event {
  const Activated({required this.at});

  factory Activated._decode(_i1.Input input) {
    return Activated(at: _i1.U32Codec.codec.decode(input));
  }

  /// BlockNumberFor<T>
  final int at;

  @override
  Map<String, Map<String, int>> toJson() => {
    'Activated': {'at': at},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(at);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U32Codec.codec.encodeTo(at, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Activated && other.at == at;

  @override
  int get hashCode => at.hashCode;
}
