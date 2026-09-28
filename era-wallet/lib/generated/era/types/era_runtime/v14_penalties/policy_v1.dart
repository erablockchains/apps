// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class PolicyV1 {
  const PolicyV1({
    required this.maximumFractionPpb,
    required this.activationSession,
  });

  factory PolicyV1.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u32
  final int maximumFractionPpb;

  /// u32
  final int activationSession;

  static const $PolicyV1Codec codec = $PolicyV1Codec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, int> toJson() => {
    'maximumFractionPpb': maximumFractionPpb,
    'activationSession': activationSession,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolicyV1 &&
          other.maximumFractionPpb == maximumFractionPpb &&
          other.activationSession == activationSession;

  @override
  int get hashCode => Object.hash(maximumFractionPpb, activationSession);
}

class $PolicyV1Codec with _i1.Codec<PolicyV1> {
  const $PolicyV1Codec();

  @override
  void encodeTo(PolicyV1 obj, _i1.Output output) {
    _i1.U32Codec.codec.encodeTo(obj.maximumFractionPpb, output);
    _i1.U32Codec.codec.encodeTo(obj.activationSession, output);
  }

  @override
  PolicyV1 decode(_i1.Input input) {
    return PolicyV1(
      maximumFractionPpb: _i1.U32Codec.codec.decode(input),
      activationSession: _i1.U32Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PolicyV1 obj) {
    int size = 0;
    size = size + _i1.U32Codec.codec.sizeHint(obj.maximumFractionPpb);
    size = size + _i1.U32Codec.codec.sizeHint(obj.activationSession);
    return size;
  }
}
