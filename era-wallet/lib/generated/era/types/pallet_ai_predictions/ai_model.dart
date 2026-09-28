// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../sp_core/crypto/account_id32.dart' as _i2;

class AiModel {
  const AiModel({
    required this.owner,
    required this.modelHash,
    required this.metadataUri,
    required this.registeredAt,
    this.updatedAt,
    required this.active,
  });

  factory AiModel.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// AccountId
  final _i2.AccountId32 owner;

  /// BoundedHash
  final List<int> modelHash;

  /// BoundedUri
  final List<int> metadataUri;

  /// BlockNumber
  final int registeredAt;

  /// Option<BlockNumber>
  final int? updatedAt;

  /// bool
  final bool active;

  static const $AiModelCodec codec = $AiModelCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'owner': owner.toList(),
    'modelHash': modelHash,
    'metadataUri': metadataUri,
    'registeredAt': registeredAt,
    'updatedAt': updatedAt,
    'active': active,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiModel &&
          _i4.listsEqual(other.owner, owner) &&
          _i4.listsEqual(other.modelHash, modelHash) &&
          _i4.listsEqual(other.metadataUri, metadataUri) &&
          other.registeredAt == registeredAt &&
          other.updatedAt == updatedAt &&
          other.active == active;

  @override
  int get hashCode => Object.hash(
    owner,
    modelHash,
    metadataUri,
    registeredAt,
    updatedAt,
    active,
  );
}

class $AiModelCodec with _i1.Codec<AiModel> {
  const $AiModelCodec();

  @override
  void encodeTo(AiModel obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.owner, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.modelHash, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.metadataUri, output);
    _i1.U32Codec.codec.encodeTo(obj.registeredAt, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.updatedAt, output);
    _i1.BoolCodec.codec.encodeTo(obj.active, output);
  }

  @override
  AiModel decode(_i1.Input input) {
    return AiModel(
      owner: const _i1.U8ArrayCodec(32).decode(input),
      modelHash: _i1.U8SequenceCodec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
      registeredAt: _i1.U32Codec.codec.decode(input),
      updatedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
      active: _i1.BoolCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(AiModel obj) {
    int size = 0;
    size = size + const _i2.AccountId32Codec().sizeHint(obj.owner);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.modelHash);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.metadataUri);
    size = size + _i1.U32Codec.codec.sizeHint(obj.registeredAt);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(obj.updatedAt);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.active);
    return size;
  }
}
