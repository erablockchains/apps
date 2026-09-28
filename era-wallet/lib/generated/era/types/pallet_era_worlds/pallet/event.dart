// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../sp_core/crypto/account_id32.dart' as _i3;

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

  Map<String, dynamic> toJson();
}

class $Event {
  const $Event();

  WorldRegistered worldRegistered({
    required List<int> worldId,
    required _i3.AccountId32 owner,
    required List<int> commitment,
  }) {
    return WorldRegistered(
      worldId: worldId,
      owner: owner,
      commitment: commitment,
    );
  }

  CommitmentUpdated commitmentUpdated({
    required List<int> worldId,
    required _i3.AccountId32 owner,
    required List<int> commitment,
  }) {
    return CommitmentUpdated(
      worldId: worldId,
      owner: owner,
      commitment: commitment,
    );
  }

  WorldRemoved worldRemoved({
    required List<int> worldId,
    required _i3.AccountId32 owner,
    required bool byAdmin,
  }) {
    return WorldRemoved(worldId: worldId, owner: owner, byAdmin: byAdmin);
  }

  Paused paused() {
    return Paused();
  }

  Unpaused unpaused() {
    return Unpaused();
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return WorldRegistered._decode(input);
      case 1:
        return CommitmentUpdated._decode(input);
      case 2:
        return WorldRemoved._decode(input);
      case 3:
        return const Paused();
      case 4:
        return const Unpaused();
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case WorldRegistered:
        (value as WorldRegistered).encodeTo(output);
        break;
      case CommitmentUpdated:
        (value as CommitmentUpdated).encodeTo(output);
        break;
      case WorldRemoved:
        (value as WorldRemoved).encodeTo(output);
        break;
      case Paused:
        (value as Paused).encodeTo(output);
        break;
      case Unpaused:
        (value as Unpaused).encodeTo(output);
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
      case WorldRegistered:
        return (value as WorldRegistered)._sizeHint();
      case CommitmentUpdated:
        return (value as CommitmentUpdated)._sizeHint();
      case WorldRemoved:
        return (value as WorldRemoved)._sizeHint();
      case Paused:
        return 1;
      case Unpaused:
        return 1;
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class WorldRegistered extends Event {
  const WorldRegistered({
    required this.worldId,
    required this.owner,
    required this.commitment,
  });

  factory WorldRegistered._decode(_i1.Input input) {
    return WorldRegistered(
      worldId: _i1.U8SequenceCodec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
      commitment: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  /// [u8; 32]
  final List<int> commitment;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'WorldRegistered': {
      'worldId': worldId,
      'owner': owner.toList(),
      'commitment': commitment.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(commitment);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
    const _i1.U8ArrayCodec(32).encodeTo(commitment, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldRegistered &&
          _i4.listsEqual(other.worldId, worldId) &&
          _i4.listsEqual(other.owner, owner) &&
          _i4.listsEqual(other.commitment, commitment);

  @override
  int get hashCode => Object.hash(worldId, owner, commitment);
}

class CommitmentUpdated extends Event {
  const CommitmentUpdated({
    required this.worldId,
    required this.owner,
    required this.commitment,
  });

  factory CommitmentUpdated._decode(_i1.Input input) {
    return CommitmentUpdated(
      worldId: _i1.U8SequenceCodec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
      commitment: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  /// [u8; 32]
  final List<int> commitment;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'CommitmentUpdated': {
      'worldId': worldId,
      'owner': owner.toList(),
      'commitment': commitment.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(commitment);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
    const _i1.U8ArrayCodec(32).encodeTo(commitment, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommitmentUpdated &&
          _i4.listsEqual(other.worldId, worldId) &&
          _i4.listsEqual(other.owner, owner) &&
          _i4.listsEqual(other.commitment, commitment);

  @override
  int get hashCode => Object.hash(worldId, owner, commitment);
}

class WorldRemoved extends Event {
  const WorldRemoved({
    required this.worldId,
    required this.owner,
    required this.byAdmin,
  });

  factory WorldRemoved._decode(_i1.Input input) {
    return WorldRemoved(
      worldId: _i1.U8SequenceCodec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
      byAdmin: _i1.BoolCodec.codec.decode(input),
    );
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  /// T::AccountId
  final _i3.AccountId32 owner;

  /// bool
  final bool byAdmin;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'WorldRemoved': {
      'worldId': worldId,
      'owner': owner.toList(),
      'byAdmin': byAdmin,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    size = size + const _i3.AccountId32Codec().sizeHint(owner);
    size = size + _i1.BoolCodec.codec.sizeHint(byAdmin);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
    const _i1.U8ArrayCodec(32).encodeTo(owner, output);
    _i1.BoolCodec.codec.encodeTo(byAdmin, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldRemoved &&
          _i4.listsEqual(other.worldId, worldId) &&
          _i4.listsEqual(other.owner, owner) &&
          other.byAdmin == byAdmin;

  @override
  int get hashCode => Object.hash(worldId, owner, byAdmin);
}

class Paused extends Event {
  const Paused();

  @override
  Map<String, dynamic> toJson() => {'Paused': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
  }

  @override
  bool operator ==(Object other) => other is Paused;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Unpaused extends Event {
  const Unpaused();

  @override
  Map<String, dynamic> toJson() => {'Unpaused': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
  }

  @override
  bool operator ==(Object other) => other is Unpaused;

  @override
  int get hashCode => runtimeType.hashCode;
}
