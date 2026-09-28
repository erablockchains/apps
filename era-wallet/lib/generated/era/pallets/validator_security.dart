// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;
import 'dart:typed_data' as _i9;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i3;

import '../types/era_validator_security/observation/evidence_context.dart'
    as _i7;
import '../types/era_validator_security/observation/identity_index_entry_v1.dart'
    as _i4;
import '../types/era_validator_security/observation/offence_observation_v1.dart'
    as _i2;
import '../types/era_validator_security/observation/ring_entry.dart' as _i5;
import '../types/tuples.dart' as _i6;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageMap<List<int>, _i2.OffenceObservationV1> _observations =
      const _i1.StorageMap<List<int>, _i2.OffenceObservationV1>(
        prefix: 'ValidatorSecurity',
        storage: 'Observations',
        valueCodec: _i2.OffenceObservationV1.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i3.U8ArrayCodec(32)),
      );

  final _i1.StorageMap<List<int>, _i4.IdentityIndexEntryV1>
  _offenceIdentityIndex =
      const _i1.StorageMap<List<int>, _i4.IdentityIndexEntryV1>(
        prefix: 'ValidatorSecurity',
        storage: 'OffenceIdentityIndex',
        valueCodec: _i4.IdentityIndexEntryV1.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i3.U8ArrayCodec(32)),
      );

  final _i1.StorageMap<int, _i5.RingEntry> _observationRing =
      const _i1.StorageMap<int, _i5.RingEntry>(
        prefix: 'ValidatorSecurity',
        storage: 'ObservationRing',
        valueCodec: _i5.RingEntry.codec,
        hasher: _i1.StorageHasher.twoxx64Concat(_i3.U32Codec.codec),
      );

  final _i1.StorageValue<int> _ringHead = const _i1.StorageValue<int>(
    prefix: 'ValidatorSecurity',
    storage: 'RingHead',
    valueCodec: _i3.U32Codec.codec,
  );

  final _i1.StorageValue<int> _ringTail = const _i1.StorageValue<int>(
    prefix: 'ValidatorSecurity',
    storage: 'RingTail',
    valueCodec: _i3.U32Codec.codec,
  );

  final _i1.StorageValue<int> _observationCount = const _i1.StorageValue<int>(
    prefix: 'ValidatorSecurity',
    storage: 'ObservationCount',
    valueCodec: _i3.U32Codec.codec,
  );

  final _i1.StorageValue<_i6.Tuple2<int, int>> _newObservationsInBlock =
      const _i1.StorageValue<_i6.Tuple2<int, int>>(
        prefix: 'ValidatorSecurity',
        storage: 'NewObservationsInBlock',
        valueCodec: _i6.Tuple2Codec<int, int>(
          _i3.U32Codec.codec,
          _i3.U32Codec.codec,
        ),
      );

  final _i1.StorageValue<_i7.EvidenceContext> _pendingEvidenceContext =
      const _i1.StorageValue<_i7.EvidenceContext>(
        prefix: 'ValidatorSecurity',
        storage: 'PendingEvidenceContext',
        valueCodec: _i7.EvidenceContext.codec,
      );

  final _i1.StorageValue<int> _pendingAdapterError =
      const _i1.StorageValue<int>(
        prefix: 'ValidatorSecurity',
        storage: 'PendingAdapterError',
        valueCodec: _i3.U8Codec.codec,
      );

  _i8.Future<_i2.OffenceObservationV1?> observations(
    List<int> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _observations.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _observations.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i8.Future<_i4.IdentityIndexEntryV1?> offenceIdentityIndex(
    List<int> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _offenceIdentityIndex.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _offenceIdentityIndex.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i8.Future<_i5.RingEntry?> observationRing(
    int key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _observationRing.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _observationRing.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i8.Future<int> ringHead({_i1.BlockHash? at}) async {
    final hashedKey = _ringHead.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _ringHead.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i8.Future<int> ringTail({_i1.BlockHash? at}) async {
    final hashedKey = _ringTail.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _ringTail.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i8.Future<int> observationCount({_i1.BlockHash? at}) async {
    final hashedKey = _observationCount.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _observationCount.decodeValue(bytes);
    }
    return 0; /* Default */
  }

  _i8.Future<_i6.Tuple2<int, int>?> newObservationsInBlock({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _newObservationsInBlock.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _newObservationsInBlock.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i8.Future<_i7.EvidenceContext?> pendingEvidenceContext({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _pendingEvidenceContext.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingEvidenceContext.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i8.Future<int?> pendingAdapterError({_i1.BlockHash? at}) async {
    final hashedKey = _pendingAdapterError.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _pendingAdapterError.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i8.Future<List<_i2.OffenceObservationV1?>> multiObservations(
    List<List<int>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _observations.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _observations.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i8.Future<List<_i4.IdentityIndexEntryV1?>> multiOffenceIdentityIndex(
    List<List<int>> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _offenceIdentityIndex.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _offenceIdentityIndex.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i8.Future<List<_i5.RingEntry?>> multiObservationRing(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _observationRing.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _observationRing.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Returns the storage key for `observations`.
  _i9.Uint8List observationsKey(List<int> key1) {
    final hashedKey = _observations.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `offenceIdentityIndex`.
  _i9.Uint8List offenceIdentityIndexKey(List<int> key1) {
    final hashedKey = _offenceIdentityIndex.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `observationRing`.
  _i9.Uint8List observationRingKey(int key1) {
    final hashedKey = _observationRing.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `ringHead`.
  _i9.Uint8List ringHeadKey() {
    final hashedKey = _ringHead.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `ringTail`.
  _i9.Uint8List ringTailKey() {
    final hashedKey = _ringTail.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `observationCount`.
  _i9.Uint8List observationCountKey() {
    final hashedKey = _observationCount.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `newObservationsInBlock`.
  _i9.Uint8List newObservationsInBlockKey() {
    final hashedKey = _newObservationsInBlock.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingEvidenceContext`.
  _i9.Uint8List pendingEvidenceContextKey() {
    final hashedKey = _pendingEvidenceContext.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `pendingAdapterError`.
  _i9.Uint8List pendingAdapterErrorKey() {
    final hashedKey = _pendingAdapterError.hashedKey();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `observations`.
  _i9.Uint8List observationsMapPrefix() {
    final hashedKey = _observations.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `offenceIdentityIndex`.
  _i9.Uint8List offenceIdentityIndexMapPrefix() {
    final hashedKey = _offenceIdentityIndex.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `observationRing`.
  _i9.Uint8List observationRingMapPrefix() {
    final hashedKey = _observationRing.mapPrefix();
    return hashedKey;
  }
}

class Constants {
  Constants();

  final int babeMaxAuthorities = 1000;

  final int grandpaMaxAuthorities = 1000;
}
