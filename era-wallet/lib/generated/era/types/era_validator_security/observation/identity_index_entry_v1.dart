// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

class IdentityIndexEntryV1 {
  const IdentityIndexEntryV1({
    required this.observationKey,
    required this.ringIndex,
  });

  factory IdentityIndexEntryV1.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// [u8; 32]
  final List<int> observationKey;

  /// u32
  final int ringIndex;

  static const $IdentityIndexEntryV1Codec codec = $IdentityIndexEntryV1Codec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'observationKey': observationKey.toList(),
    'ringIndex': ringIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityIndexEntryV1 &&
          _i3.listsEqual(other.observationKey, observationKey) &&
          other.ringIndex == ringIndex;

  @override
  int get hashCode => Object.hash(observationKey, ringIndex);
}

class $IdentityIndexEntryV1Codec with _i1.Codec<IdentityIndexEntryV1> {
  const $IdentityIndexEntryV1Codec();

  @override
  void encodeTo(IdentityIndexEntryV1 obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.observationKey, output);
    _i1.U32Codec.codec.encodeTo(obj.ringIndex, output);
  }

  @override
  IdentityIndexEntryV1 decode(_i1.Input input) {
    return IdentityIndexEntryV1(
      observationKey: const _i1.U8ArrayCodec(32).decode(input),
      ringIndex: _i1.U32Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(IdentityIndexEntryV1 obj) {
    int size = 0;
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.observationKey);
    size = size + _i1.U32Codec.codec.sizeHint(obj.ringIndex);
    return size;
  }
}
