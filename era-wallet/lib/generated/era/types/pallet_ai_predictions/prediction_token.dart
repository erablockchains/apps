// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../sp_core/crypto/account_id32.dart' as _i2;

class PredictionToken {
  const PredictionToken({
    required this.predictionId,
    required this.owner,
    required this.metadataUri,
    required this.createdAt,
    this.updatedAt,
    required this.transferable,
    required this.frozen,
    required this.burned,
  });

  factory PredictionToken.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u64
  final BigInt predictionId;

  /// AccountId
  final _i2.AccountId32 owner;

  /// BoundedUri
  final List<int> metadataUri;

  /// BlockNumber
  final int createdAt;

  /// Option<BlockNumber>
  final int? updatedAt;

  /// bool
  final bool transferable;

  /// bool
  final bool frozen;

  /// bool
  final bool burned;

  static const $PredictionTokenCodec codec = $PredictionTokenCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'predictionId': predictionId,
    'owner': owner.toList(),
    'metadataUri': metadataUri,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'transferable': transferable,
    'frozen': frozen,
    'burned': burned,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionToken &&
          other.predictionId == predictionId &&
          _i4.listsEqual(other.owner, owner) &&
          _i4.listsEqual(other.metadataUri, metadataUri) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.transferable == transferable &&
          other.frozen == frozen &&
          other.burned == burned;

  @override
  int get hashCode => Object.hash(
    predictionId,
    owner,
    metadataUri,
    createdAt,
    updatedAt,
    transferable,
    frozen,
    burned,
  );
}

class $PredictionTokenCodec with _i1.Codec<PredictionToken> {
  const $PredictionTokenCodec();

  @override
  void encodeTo(PredictionToken obj, _i1.Output output) {
    _i1.U64Codec.codec.encodeTo(obj.predictionId, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.owner, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.metadataUri, output);
    _i1.U32Codec.codec.encodeTo(obj.createdAt, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.updatedAt, output);
    _i1.BoolCodec.codec.encodeTo(obj.transferable, output);
    _i1.BoolCodec.codec.encodeTo(obj.frozen, output);
    _i1.BoolCodec.codec.encodeTo(obj.burned, output);
  }

  @override
  PredictionToken decode(_i1.Input input) {
    return PredictionToken(
      predictionId: _i1.U64Codec.codec.decode(input),
      owner: const _i1.U8ArrayCodec(32).decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
      createdAt: _i1.U32Codec.codec.decode(input),
      updatedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
      transferable: _i1.BoolCodec.codec.decode(input),
      frozen: _i1.BoolCodec.codec.decode(input),
      burned: _i1.BoolCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PredictionToken obj) {
    int size = 0;
    size = size + _i1.U64Codec.codec.sizeHint(obj.predictionId);
    size = size + const _i2.AccountId32Codec().sizeHint(obj.owner);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.metadataUri);
    size = size + _i1.U32Codec.codec.sizeHint(obj.createdAt);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(obj.updatedAt);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.transferable);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.frozen);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.burned);
    return size;
  }
}
