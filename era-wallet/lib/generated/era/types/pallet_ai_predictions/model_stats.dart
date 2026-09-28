// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class ModelStats {
  const ModelStats({
    required this.totalPredictions,
    required this.validatedPredictions,
    required this.successfulPredictions,
    required this.failedPredictions,
    required this.inconclusivePredictions,
  });

  factory ModelStats.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u64
  final BigInt totalPredictions;

  /// u64
  final BigInt validatedPredictions;

  /// u64
  final BigInt successfulPredictions;

  /// u64
  final BigInt failedPredictions;

  /// u64
  final BigInt inconclusivePredictions;

  static const $ModelStatsCodec codec = $ModelStatsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, BigInt> toJson() => {
    'totalPredictions': totalPredictions,
    'validatedPredictions': validatedPredictions,
    'successfulPredictions': successfulPredictions,
    'failedPredictions': failedPredictions,
    'inconclusivePredictions': inconclusivePredictions,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelStats &&
          other.totalPredictions == totalPredictions &&
          other.validatedPredictions == validatedPredictions &&
          other.successfulPredictions == successfulPredictions &&
          other.failedPredictions == failedPredictions &&
          other.inconclusivePredictions == inconclusivePredictions;

  @override
  int get hashCode => Object.hash(
    totalPredictions,
    validatedPredictions,
    successfulPredictions,
    failedPredictions,
    inconclusivePredictions,
  );
}

class $ModelStatsCodec with _i1.Codec<ModelStats> {
  const $ModelStatsCodec();

  @override
  void encodeTo(ModelStats obj, _i1.Output output) {
    _i1.U64Codec.codec.encodeTo(obj.totalPredictions, output);
    _i1.U64Codec.codec.encodeTo(obj.validatedPredictions, output);
    _i1.U64Codec.codec.encodeTo(obj.successfulPredictions, output);
    _i1.U64Codec.codec.encodeTo(obj.failedPredictions, output);
    _i1.U64Codec.codec.encodeTo(obj.inconclusivePredictions, output);
  }

  @override
  ModelStats decode(_i1.Input input) {
    return ModelStats(
      totalPredictions: _i1.U64Codec.codec.decode(input),
      validatedPredictions: _i1.U64Codec.codec.decode(input),
      successfulPredictions: _i1.U64Codec.codec.decode(input),
      failedPredictions: _i1.U64Codec.codec.decode(input),
      inconclusivePredictions: _i1.U64Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(ModelStats obj) {
    int size = 0;
    size = size + _i1.U64Codec.codec.sizeHint(obj.totalPredictions);
    size = size + _i1.U64Codec.codec.sizeHint(obj.validatedPredictions);
    size = size + _i1.U64Codec.codec.sizeHint(obj.successfulPredictions);
    size = size + _i1.U64Codec.codec.sizeHint(obj.failedPredictions);
    size = size + _i1.U64Codec.codec.sizeHint(obj.inconclusivePredictions);
    return size;
  }
}
