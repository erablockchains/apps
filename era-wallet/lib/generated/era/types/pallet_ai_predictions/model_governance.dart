// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i4;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../sp_core/crypto/account_id32.dart' as _i3;
import 'model_status.dart' as _i2;

class ModelGovernance {
  const ModelGovernance({
    required this.status,
    this.authorizedSubmitter,
    required this.updatedAt,
  });

  factory ModelGovernance.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// ModelStatus
  final _i2.ModelStatus status;

  /// Option<AccountId>
  final _i3.AccountId32? authorizedSubmitter;

  /// BlockNumber
  final int updatedAt;

  static const $ModelGovernanceCodec codec = $ModelGovernanceCodec();

  _i4.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'status': status.toJson(),
    'authorizedSubmitter': authorizedSubmitter?.toList(),
    'updatedAt': updatedAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGovernance &&
          other.status == status &&
          other.authorizedSubmitter == authorizedSubmitter &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(status, authorizedSubmitter, updatedAt);
}

class $ModelGovernanceCodec with _i1.Codec<ModelGovernance> {
  const $ModelGovernanceCodec();

  @override
  void encodeTo(ModelGovernance obj, _i1.Output output) {
    _i2.ModelStatus.codec.encodeTo(obj.status, output);
    const _i1.OptionCodec<_i3.AccountId32>(
      _i3.AccountId32Codec(),
    ).encodeTo(obj.authorizedSubmitter, output);
    _i1.U32Codec.codec.encodeTo(obj.updatedAt, output);
  }

  @override
  ModelGovernance decode(_i1.Input input) {
    return ModelGovernance(
      status: _i2.ModelStatus.codec.decode(input),
      authorizedSubmitter: const _i1.OptionCodec<_i3.AccountId32>(
        _i3.AccountId32Codec(),
      ).decode(input),
      updatedAt: _i1.U32Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(ModelGovernance obj) {
    int size = 0;
    size = size + _i2.ModelStatus.codec.sizeHint(obj.status);
    size =
        size +
        const _i1.OptionCodec<_i3.AccountId32>(
          _i3.AccountId32Codec(),
        ).sizeHint(obj.authorizedSubmitter);
    size = size + _i1.U32Codec.codec.sizeHint(obj.updatedAt);
    return size;
  }
}
