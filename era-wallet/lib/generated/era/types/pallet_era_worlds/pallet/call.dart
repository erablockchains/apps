// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

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

  RegisterWorld registerWorld({
    required List<int> worldId,
    required List<int> commitment,
  }) {
    return RegisterWorld(worldId: worldId, commitment: commitment);
  }

  UpdateCommitment updateCommitment({
    required List<int> worldId,
    required List<int> commitment,
  }) {
    return UpdateCommitment(worldId: worldId, commitment: commitment);
  }

  DeregisterWorld deregisterWorld({required List<int> worldId}) {
    return DeregisterWorld(worldId: worldId);
  }

  AdminRemoveWorld adminRemoveWorld({required List<int> worldId}) {
    return AdminRemoveWorld(worldId: worldId);
  }

  Pause pause() {
    return Pause();
  }

  Unpause unpause() {
    return Unpause();
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RegisterWorld._decode(input);
      case 1:
        return UpdateCommitment._decode(input);
      case 2:
        return DeregisterWorld._decode(input);
      case 3:
        return AdminRemoveWorld._decode(input);
      case 4:
        return const Pause();
      case 5:
        return const Unpause();
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case RegisterWorld:
        (value as RegisterWorld).encodeTo(output);
        break;
      case UpdateCommitment:
        (value as UpdateCommitment).encodeTo(output);
        break;
      case DeregisterWorld:
        (value as DeregisterWorld).encodeTo(output);
        break;
      case AdminRemoveWorld:
        (value as AdminRemoveWorld).encodeTo(output);
        break;
      case Pause:
        (value as Pause).encodeTo(output);
        break;
      case Unpause:
        (value as Unpause).encodeTo(output);
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
      case RegisterWorld:
        return (value as RegisterWorld)._sizeHint();
      case UpdateCommitment:
        return (value as UpdateCommitment)._sizeHint();
      case DeregisterWorld:
        return (value as DeregisterWorld)._sizeHint();
      case AdminRemoveWorld:
        return (value as AdminRemoveWorld)._sizeHint();
      case Pause:
        return 1;
      case Unpause:
        return 1;
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class RegisterWorld extends Call {
  const RegisterWorld({required this.worldId, required this.commitment});

  factory RegisterWorld._decode(_i1.Input input) {
    return RegisterWorld(
      worldId: _i1.U8SequenceCodec.codec.decode(input),
      commitment: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  /// [u8; 32]
  final List<int> commitment;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'register_world': {'worldId': worldId, 'commitment': commitment.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(commitment);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
    const _i1.U8ArrayCodec(32).encodeTo(commitment, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterWorld &&
          _i3.listsEqual(other.worldId, worldId) &&
          _i3.listsEqual(other.commitment, commitment);

  @override
  int get hashCode => Object.hash(worldId, commitment);
}

class UpdateCommitment extends Call {
  const UpdateCommitment({required this.worldId, required this.commitment});

  factory UpdateCommitment._decode(_i1.Input input) {
    return UpdateCommitment(
      worldId: _i1.U8SequenceCodec.codec.decode(input),
      commitment: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  /// [u8; 32]
  final List<int> commitment;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'update_commitment': {
      'worldId': worldId,
      'commitment': commitment.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(commitment);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
    const _i1.U8ArrayCodec(32).encodeTo(commitment, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCommitment &&
          _i3.listsEqual(other.worldId, worldId) &&
          _i3.listsEqual(other.commitment, commitment);

  @override
  int get hashCode => Object.hash(worldId, commitment);
}

class DeregisterWorld extends Call {
  const DeregisterWorld({required this.worldId});

  factory DeregisterWorld._decode(_i1.Input input) {
    return DeregisterWorld(worldId: _i1.U8SequenceCodec.codec.decode(input));
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'deregister_world': {'worldId': worldId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeregisterWorld && _i3.listsEqual(other.worldId, worldId);

  @override
  int get hashCode => worldId.hashCode;
}

class AdminRemoveWorld extends Call {
  const AdminRemoveWorld({required this.worldId});

  factory AdminRemoveWorld._decode(_i1.Input input) {
    return AdminRemoveWorld(worldId: _i1.U8SequenceCodec.codec.decode(input));
  }

  /// WorldIdOf<T>
  final List<int> worldId;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'admin_remove_world': {'worldId': worldId},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(worldId);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i1.U8SequenceCodec.codec.encodeTo(worldId, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminRemoveWorld && _i3.listsEqual(other.worldId, worldId);

  @override
  int get hashCode => worldId.hashCode;
}

class Pause extends Call {
  const Pause();

  @override
  Map<String, dynamic> toJson() => {'pause': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
  }

  @override
  bool operator ==(Object other) => other is Pause;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Unpause extends Call {
  const Unpause();

  @override
  Map<String, dynamic> toJson() => {'unpause': null};

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
  }

  @override
  bool operator ==(Object other) => other is Unpause;

  @override
  int get hashCode => runtimeType.hashCode;
}
