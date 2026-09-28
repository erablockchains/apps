// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

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

  Map<String, Map<String, int>> toJson();
}

class $Call {
  const $Call();

  PreparePolicy preparePolicy({
    required int maximumFractionPpb,
    required int activationSession,
  }) {
    return PreparePolicy(
      maximumFractionPpb: maximumFractionPpb,
      activationSession: activationSession,
    );
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PreparePolicy._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case PreparePolicy:
        (value as PreparePolicy).encodeTo(output);
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
      case PreparePolicy:
        return (value as PreparePolicy)._sizeHint();
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class PreparePolicy extends Call {
  const PreparePolicy({
    required this.maximumFractionPpb,
    required this.activationSession,
  });

  factory PreparePolicy._decode(_i1.Input input) {
    return PreparePolicy(
      maximumFractionPpb: _i1.U32Codec.codec.decode(input),
      activationSession: _i1.U32Codec.codec.decode(input),
    );
  }

  /// u32
  final int maximumFractionPpb;

  /// u32
  final int activationSession;

  @override
  Map<String, Map<String, int>> toJson() => {
    'prepare_policy': {
      'maximumFractionPpb': maximumFractionPpb,
      'activationSession': activationSession,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(maximumFractionPpb);
    size = size + _i1.U32Codec.codec.sizeHint(activationSession);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U32Codec.codec.encodeTo(maximumFractionPpb, output);
    _i1.U32Codec.codec.encodeTo(activationSession, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreparePolicy &&
          other.maximumFractionPpb == maximumFractionPpb &&
          other.activationSession == activationSession;

  @override
  int get hashCode => Object.hash(maximumFractionPpb, activationSession);
}
