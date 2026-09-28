// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:typed_data' as _i4;

import 'package:polkadart/polkadart.dart' as _i1;

import '../types/era_runtime/runtime_call.dart' as _i5;
import '../types/era_runtime/v14_penalties/pallet/call.dart' as _i6;
import '../types/era_runtime/v14_penalties/policy_v1.dart' as _i2;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<_i2.PolicyV1> _policy =
      const _i1.StorageValue<_i2.PolicyV1>(
        prefix: 'EquivocationPenalties',
        storage: 'Policy',
        valueCodec: _i2.PolicyV1.codec,
      );

  _i3.Future<_i2.PolicyV1?> policy({_i1.BlockHash? at}) async {
    final hashedKey = _policy.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _policy.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Returns the storage key for `policy`.
  _i4.Uint8List policyKey() {
    final hashedKey = _policy.hashedKey();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  _i5.EquivocationPenalties preparePolicy({
    required int maximumFractionPpb,
    required int activationSession,
  }) {
    return _i5.EquivocationPenalties(
      _i6.PreparePolicy(
        maximumFractionPpb: maximumFractionPpb,
        activationSession: activationSession,
      ),
    );
  }
}
