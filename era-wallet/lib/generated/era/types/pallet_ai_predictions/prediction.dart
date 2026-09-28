// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i6;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i7;

import '../sp_core/crypto/account_id32.dart' as _i2;
import 'prediction_domain.dart' as _i3;
import 'prediction_outcome.dart' as _i5;
import 'prediction_status.dart' as _i4;

class Prediction {
  const Prediction({
    required this.modelId,
    required this.submitter,
    required this.domain,
    required this.categoryCode,
    required this.predictionHash,
    required this.metadataUri,
    required this.confidence,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.outcome,
    this.validator,
    this.validatedAt,
  });

  factory Prediction.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u64
  final BigInt modelId;

  /// AccountId
  final _i2.AccountId32 submitter;

  /// PredictionDomain
  final _i3.PredictionDomain domain;

  /// BoundedCategoryCode
  final List<int> categoryCode;

  /// BoundedHash
  final List<int> predictionHash;

  /// BoundedUri
  final List<int> metadataUri;

  /// u8
  final int confidence;

  /// BlockNumber
  final int createdAt;

  /// BlockNumber
  final int expiresAt;

  /// PredictionStatus
  final _i4.PredictionStatus status;

  /// Option<PredictionOutcome>
  final _i5.PredictionOutcome? outcome;

  /// Option<AccountId>
  final _i2.AccountId32? validator;

  /// Option<BlockNumber>
  final int? validatedAt;

  static const $PredictionCodec codec = $PredictionCodec();

  _i6.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'modelId': modelId,
    'submitter': submitter.toList(),
    'domain': domain.toJson(),
    'categoryCode': categoryCode,
    'predictionHash': predictionHash,
    'metadataUri': metadataUri,
    'confidence': confidence,
    'createdAt': createdAt,
    'expiresAt': expiresAt,
    'status': status.toJson(),
    'outcome': outcome?.toJson(),
    'validator': validator?.toList(),
    'validatedAt': validatedAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prediction &&
          other.modelId == modelId &&
          _i7.listsEqual(other.submitter, submitter) &&
          other.domain == domain &&
          _i7.listsEqual(other.categoryCode, categoryCode) &&
          _i7.listsEqual(other.predictionHash, predictionHash) &&
          _i7.listsEqual(other.metadataUri, metadataUri) &&
          other.confidence == confidence &&
          other.createdAt == createdAt &&
          other.expiresAt == expiresAt &&
          other.status == status &&
          other.outcome == outcome &&
          other.validator == validator &&
          other.validatedAt == validatedAt;

  @override
  int get hashCode => Object.hash(
    modelId,
    submitter,
    domain,
    categoryCode,
    predictionHash,
    metadataUri,
    confidence,
    createdAt,
    expiresAt,
    status,
    outcome,
    validator,
    validatedAt,
  );
}

class $PredictionCodec with _i1.Codec<Prediction> {
  const $PredictionCodec();

  @override
  void encodeTo(Prediction obj, _i1.Output output) {
    _i1.U64Codec.codec.encodeTo(obj.modelId, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.submitter, output);
    _i3.PredictionDomain.codec.encodeTo(obj.domain, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.categoryCode, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.predictionHash, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.metadataUri, output);
    _i1.U8Codec.codec.encodeTo(obj.confidence, output);
    _i1.U32Codec.codec.encodeTo(obj.createdAt, output);
    _i1.U32Codec.codec.encodeTo(obj.expiresAt, output);
    _i4.PredictionStatus.codec.encodeTo(obj.status, output);
    const _i1.OptionCodec<_i5.PredictionOutcome>(
      _i5.PredictionOutcome.codec,
    ).encodeTo(obj.outcome, output);
    const _i1.OptionCodec<_i2.AccountId32>(
      _i2.AccountId32Codec(),
    ).encodeTo(obj.validator, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.validatedAt, output);
  }

  @override
  Prediction decode(_i1.Input input) {
    return Prediction(
      modelId: _i1.U64Codec.codec.decode(input),
      submitter: const _i1.U8ArrayCodec(32).decode(input),
      domain: _i3.PredictionDomain.codec.decode(input),
      categoryCode: _i1.U8SequenceCodec.codec.decode(input),
      predictionHash: _i1.U8SequenceCodec.codec.decode(input),
      metadataUri: _i1.U8SequenceCodec.codec.decode(input),
      confidence: _i1.U8Codec.codec.decode(input),
      createdAt: _i1.U32Codec.codec.decode(input),
      expiresAt: _i1.U32Codec.codec.decode(input),
      status: _i4.PredictionStatus.codec.decode(input),
      outcome: const _i1.OptionCodec<_i5.PredictionOutcome>(
        _i5.PredictionOutcome.codec,
      ).decode(input),
      validator: const _i1.OptionCodec<_i2.AccountId32>(
        _i2.AccountId32Codec(),
      ).decode(input),
      validatedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
    );
  }

  @override
  int sizeHint(Prediction obj) {
    int size = 0;
    size = size + _i1.U64Codec.codec.sizeHint(obj.modelId);
    size = size + const _i2.AccountId32Codec().sizeHint(obj.submitter);
    size = size + _i3.PredictionDomain.codec.sizeHint(obj.domain);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.categoryCode);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.predictionHash);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.metadataUri);
    size = size + _i1.U8Codec.codec.sizeHint(obj.confidence);
    size = size + _i1.U32Codec.codec.sizeHint(obj.createdAt);
    size = size + _i1.U32Codec.codec.sizeHint(obj.expiresAt);
    size = size + _i4.PredictionStatus.codec.sizeHint(obj.status);
    size =
        size +
        const _i1.OptionCodec<_i5.PredictionOutcome>(
          _i5.PredictionOutcome.codec,
        ).sizeHint(obj.outcome);
    size =
        size +
        const _i1.OptionCodec<_i2.AccountId32>(
          _i2.AccountId32Codec(),
        ).sizeHint(obj.validator);
    size =
        size +
        const _i1.OptionCodec<int>(
          _i1.U32Codec.codec,
        ).sizeHint(obj.validatedAt);
    return size;
  }
}
