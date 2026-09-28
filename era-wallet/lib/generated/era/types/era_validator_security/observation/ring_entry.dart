// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

class RingEntry {
  const RingEntry({
    required this.identityKey,
    required this.observationKey,
    required this.expiresAt,
  });

  factory RingEntry.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// [u8; 32]
  final List<int> identityKey;

  /// [u8; 32]
  final List<int> observationKey;

  /// u32
  final int expiresAt;

  static const $RingEntryCodec codec = $RingEntryCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'identityKey': identityKey.toList(),
    'observationKey': observationKey.toList(),
    'expiresAt': expiresAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RingEntry &&
          _i3.listsEqual(other.identityKey, identityKey) &&
          _i3.listsEqual(other.observationKey, observationKey) &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(identityKey, observationKey, expiresAt);
}

class $RingEntryCodec with _i1.Codec<RingEntry> {
  const $RingEntryCodec();

  @override
  void encodeTo(RingEntry obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.identityKey, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.observationKey, output);
    _i1.U32Codec.codec.encodeTo(obj.expiresAt, output);
  }

  @override
  RingEntry decode(_i1.Input input) {
    return RingEntry(
      identityKey: const _i1.U8ArrayCodec(32).decode(input),
      observationKey: const _i1.U8ArrayCodec(32).decode(input),
      expiresAt: _i1.U32Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(RingEntry obj) {
    int size = 0;
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.identityKey);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.observationKey);
    size = size + _i1.U32Codec.codec.sizeHint(obj.expiresAt);
    return size;
  }
}
