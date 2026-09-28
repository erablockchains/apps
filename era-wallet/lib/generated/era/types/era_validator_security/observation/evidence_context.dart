// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import 'observation_kind.dart' as _i2;

class EvidenceContext {
  const EvidenceContext({required this.kind, required this.proofHash});

  factory EvidenceContext.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// ObservationKind
  final _i2.ObservationKind kind;

  /// [u8; 32]
  final List<int> proofHash;

  static const $EvidenceContextCodec codec = $EvidenceContextCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'kind': kind.toJson(),
    'proofHash': proofHash.toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvidenceContext &&
          other.kind == kind &&
          _i4.listsEqual(other.proofHash, proofHash);

  @override
  int get hashCode => Object.hash(kind, proofHash);
}

class $EvidenceContextCodec with _i1.Codec<EvidenceContext> {
  const $EvidenceContextCodec();

  @override
  void encodeTo(EvidenceContext obj, _i1.Output output) {
    _i2.ObservationKind.codec.encodeTo(obj.kind, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.proofHash, output);
  }

  @override
  EvidenceContext decode(_i1.Input input) {
    return EvidenceContext(
      kind: _i2.ObservationKind.codec.decode(input),
      proofHash: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  @override
  int sizeHint(EvidenceContext obj) {
    int size = 0;
    size = size + _i2.ObservationKind.codec.sizeHint(obj.kind);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.proofHash);
    return size;
  }
}
