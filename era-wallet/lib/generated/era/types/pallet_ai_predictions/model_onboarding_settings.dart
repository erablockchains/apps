// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class ModelOnboardingSettings {
  const ModelOnboardingSettings({
    required this.modelRegistrationEnabled,
    required this.predictionSubmissionEnabled,
    required this.marketCreationEnabled,
    required this.publicModelRegistrationEnabled,
    required this.requireModelApproval,
    required this.maxActivePredictionsPerModel,
  });

  factory ModelOnboardingSettings.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// bool
  final bool modelRegistrationEnabled;

  /// bool
  final bool predictionSubmissionEnabled;

  /// bool
  final bool marketCreationEnabled;

  /// bool
  final bool publicModelRegistrationEnabled;

  /// bool
  final bool requireModelApproval;

  /// u32
  final int maxActivePredictionsPerModel;

  static const $ModelOnboardingSettingsCodec codec =
      $ModelOnboardingSettingsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'modelRegistrationEnabled': modelRegistrationEnabled,
    'predictionSubmissionEnabled': predictionSubmissionEnabled,
    'marketCreationEnabled': marketCreationEnabled,
    'publicModelRegistrationEnabled': publicModelRegistrationEnabled,
    'requireModelApproval': requireModelApproval,
    'maxActivePredictionsPerModel': maxActivePredictionsPerModel,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelOnboardingSettings &&
          other.modelRegistrationEnabled == modelRegistrationEnabled &&
          other.predictionSubmissionEnabled == predictionSubmissionEnabled &&
          other.marketCreationEnabled == marketCreationEnabled &&
          other.publicModelRegistrationEnabled ==
              publicModelRegistrationEnabled &&
          other.requireModelApproval == requireModelApproval &&
          other.maxActivePredictionsPerModel == maxActivePredictionsPerModel;

  @override
  int get hashCode => Object.hash(
    modelRegistrationEnabled,
    predictionSubmissionEnabled,
    marketCreationEnabled,
    publicModelRegistrationEnabled,
    requireModelApproval,
    maxActivePredictionsPerModel,
  );
}

class $ModelOnboardingSettingsCodec with _i1.Codec<ModelOnboardingSettings> {
  const $ModelOnboardingSettingsCodec();

  @override
  void encodeTo(ModelOnboardingSettings obj, _i1.Output output) {
    _i1.BoolCodec.codec.encodeTo(obj.modelRegistrationEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.predictionSubmissionEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.marketCreationEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.publicModelRegistrationEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.requireModelApproval, output);
    _i1.U32Codec.codec.encodeTo(obj.maxActivePredictionsPerModel, output);
  }

  @override
  ModelOnboardingSettings decode(_i1.Input input) {
    return ModelOnboardingSettings(
      modelRegistrationEnabled: _i1.BoolCodec.codec.decode(input),
      predictionSubmissionEnabled: _i1.BoolCodec.codec.decode(input),
      marketCreationEnabled: _i1.BoolCodec.codec.decode(input),
      publicModelRegistrationEnabled: _i1.BoolCodec.codec.decode(input),
      requireModelApproval: _i1.BoolCodec.codec.decode(input),
      maxActivePredictionsPerModel: _i1.U32Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(ModelOnboardingSettings obj) {
    int size = 0;
    size = size + _i1.BoolCodec.codec.sizeHint(obj.modelRegistrationEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.predictionSubmissionEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.marketCreationEnabled);
    size =
        size + _i1.BoolCodec.codec.sizeHint(obj.publicModelRegistrationEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.requireModelApproval);
    size = size + _i1.U32Codec.codec.sizeHint(obj.maxActivePredictionsPerModel);
    return size;
  }
}
