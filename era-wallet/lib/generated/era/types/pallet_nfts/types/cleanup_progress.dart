// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class CleanupProgress {
  const CleanupProgress({required this.version, required this.phase});

  factory CleanupProgress.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u8
  final int version;

  /// u8
  final int phase;

  static const $CleanupProgressCodec codec = $CleanupProgressCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, int> toJson() => {'version': version, 'phase': phase};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CleanupProgress &&
          other.version == version &&
          other.phase == phase;

  @override
  int get hashCode => Object.hash(version, phase);
}

class $CleanupProgressCodec with _i1.Codec<CleanupProgress> {
  const $CleanupProgressCodec();

  @override
  void encodeTo(CleanupProgress obj, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(obj.version, output);
    _i1.U8Codec.codec.encodeTo(obj.phase, output);
  }

  @override
  CleanupProgress decode(_i1.Input input) {
    return CleanupProgress(
      version: _i1.U8Codec.codec.decode(input),
      phase: _i1.U8Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(CleanupProgress obj) {
    int size = 0;
    size = size + _i1.U8Codec.codec.sizeHint(obj.version);
    size = size + _i1.U8Codec.codec.sizeHint(obj.phase);
    return size;
  }
}
