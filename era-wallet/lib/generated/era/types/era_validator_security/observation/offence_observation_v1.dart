// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i6;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i7;

import '../../sp_core/crypto/account_id32.dart' as _i3;
import '../../tuples.dart' as _i4;
import 'observation_kind.dart' as _i2;
import 'observation_source.dart' as _i5;

class OffenceObservationV1 {
  const OffenceObservationV1({
    required this.version,
    required this.kind,
    required this.offender,
    required this.sessionIndex,
    this.babeSlot,
    this.grandpaCoordinate,
    required this.proofHash,
    required this.observedAt,
    required this.source,
  });

  factory OffenceObservationV1.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u8
  final int version;

  /// ObservationKind
  final _i2.ObservationKind kind;

  /// AccountId
  final _i3.AccountId32 offender;

  /// u32
  final int sessionIndex;

  /// Option<u64>
  final BigInt? babeSlot;

  /// Option<(u64, u64)>
  final _i4.Tuple2<BigInt, BigInt>? grandpaCoordinate;

  /// [u8; 32]
  final List<int> proofHash;

  /// u32
  final int observedAt;

  /// ObservationSource
  final _i5.ObservationSource source;

  static const $OffenceObservationV1Codec codec = $OffenceObservationV1Codec();

  _i6.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'kind': kind.toJson(),
    'offender': offender.toList(),
    'sessionIndex': sessionIndex,
    'babeSlot': babeSlot,
    'grandpaCoordinate': [grandpaCoordinate?.value0, grandpaCoordinate?.value1],
    'proofHash': proofHash.toList(),
    'observedAt': observedAt,
    'source': source.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffenceObservationV1 &&
          other.version == version &&
          other.kind == kind &&
          _i7.listsEqual(other.offender, offender) &&
          other.sessionIndex == sessionIndex &&
          other.babeSlot == babeSlot &&
          other.grandpaCoordinate == grandpaCoordinate &&
          _i7.listsEqual(other.proofHash, proofHash) &&
          other.observedAt == observedAt &&
          other.source == source;

  @override
  int get hashCode => Object.hash(
    version,
    kind,
    offender,
    sessionIndex,
    babeSlot,
    grandpaCoordinate,
    proofHash,
    observedAt,
    source,
  );
}

class $OffenceObservationV1Codec with _i1.Codec<OffenceObservationV1> {
  const $OffenceObservationV1Codec();

  @override
  void encodeTo(OffenceObservationV1 obj, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(obj.version, output);
    _i2.ObservationKind.codec.encodeTo(obj.kind, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.offender, output);
    _i1.U32Codec.codec.encodeTo(obj.sessionIndex, output);
    const _i1.OptionCodec<BigInt>(
      _i1.U64Codec.codec,
    ).encodeTo(obj.babeSlot, output);
    const _i1.OptionCodec<_i4.Tuple2<BigInt, BigInt>>(
      _i4.Tuple2Codec<BigInt, BigInt>(_i1.U64Codec.codec, _i1.U64Codec.codec),
    ).encodeTo(obj.grandpaCoordinate, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.proofHash, output);
    _i1.U32Codec.codec.encodeTo(obj.observedAt, output);
    _i5.ObservationSource.codec.encodeTo(obj.source, output);
  }

  @override
  OffenceObservationV1 decode(_i1.Input input) {
    return OffenceObservationV1(
      version: _i1.U8Codec.codec.decode(input),
      kind: _i2.ObservationKind.codec.decode(input),
      offender: const _i1.U8ArrayCodec(32).decode(input),
      sessionIndex: _i1.U32Codec.codec.decode(input),
      babeSlot: const _i1.OptionCodec<BigInt>(_i1.U64Codec.codec).decode(input),
      grandpaCoordinate: const _i1.OptionCodec<_i4.Tuple2<BigInt, BigInt>>(
        _i4.Tuple2Codec<BigInt, BigInt>(_i1.U64Codec.codec, _i1.U64Codec.codec),
      ).decode(input),
      proofHash: const _i1.U8ArrayCodec(32).decode(input),
      observedAt: _i1.U32Codec.codec.decode(input),
      source: _i5.ObservationSource.codec.decode(input),
    );
  }

  @override
  int sizeHint(OffenceObservationV1 obj) {
    int size = 0;
    size = size + _i1.U8Codec.codec.sizeHint(obj.version);
    size = size + _i2.ObservationKind.codec.sizeHint(obj.kind);
    size = size + const _i3.AccountId32Codec().sizeHint(obj.offender);
    size = size + _i1.U32Codec.codec.sizeHint(obj.sessionIndex);
    size =
        size +
        const _i1.OptionCodec<BigInt>(
          _i1.U64Codec.codec,
        ).sizeHint(obj.babeSlot);
    size =
        size +
        const _i1.OptionCodec<_i4.Tuple2<BigInt, BigInt>>(
          _i4.Tuple2Codec<BigInt, BigInt>(
            _i1.U64Codec.codec,
            _i1.U64Codec.codec,
          ),
        ).sizeHint(obj.grandpaCoordinate);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.proofHash);
    size = size + _i1.U32Codec.codec.sizeHint(obj.observedAt);
    size = size + _i5.ObservationSource.codec.sizeHint(obj.source);
    return size;
  }
}
