// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:typed_data' as _i7;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i2;

import '../types/era_runtime/runtime_call.dart' as _i8;
import '../types/era_runtime/v14_allocator/asset_permit.dart' as _i3;
import '../types/era_runtime/v14_allocator/pallet/call.dart' as _i9;
import '../types/sp_core/crypto/account_id32.dart' as _i4;
import '../types/tuples.dart' as _i5;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageValue<int> _legacyCreationClosedAt =
      const _i1.StorageValue<int>(
        prefix: 'EraV14AssetAllocator',
        storage: 'LegacyCreationClosedAt',
        valueCodec: _i2.U32Codec.codec,
      );

  final _i1.StorageValue<int> _schemaVersion = const _i1.StorageValue<int>(
    prefix: 'EraV14AssetAllocator',
    storage: 'SchemaVersion',
    valueCodec: _i2.U16Codec.codec,
  );

  final _i1.StorageValue<int?> _nextAssetId = const _i1.StorageValue<int?>(
    prefix: 'EraV14AssetAllocator',
    storage: 'NextAssetId',
    valueCodec: _i2.OptionCodec<int>(_i2.U32Codec.codec),
  );

  final _i1.StorageValue<int?> _nextCollectionId = const _i1.StorageValue<int?>(
    prefix: 'EraV14AssetAllocator',
    storage: 'NextCollectionId',
    valueCodec: _i2.OptionCodec<int>(_i2.U32Codec.codec),
  );

  final _i1.StorageMap<int, int?> _nextItemId = const _i1.StorageMap<int, int?>(
    prefix: 'EraV14AssetAllocator',
    storage: 'NextItemId',
    valueCodec: _i2.OptionCodec<int>(_i2.U32Codec.codec),
    hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
  );

  final _i1.StorageValue<List<int>> _initializationEvidence =
      const _i1.StorageValue<List<int>>(
        prefix: 'EraV14AssetAllocator',
        storage: 'InitializationEvidence',
        valueCodec: _i2.U8ArrayCodec(32),
      );

  final _i1.StorageMap<int, List<int>> _itemInitializationEvidence =
      const _i1.StorageMap<int, List<int>>(
        prefix: 'EraV14AssetAllocator',
        storage: 'ItemInitializationEvidence',
        valueCodec: _i2.U8ArrayCodec(32),
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<_i3.AssetPermit> _nextAssetPermit =
      const _i1.StorageValue<_i3.AssetPermit>(
        prefix: 'EraV14AssetAllocator',
        storage: 'NextAssetPermit',
        valueCodec: _i3.AssetPermit.codec,
      );

  final _i1.StorageValue<_i4.AccountId32> _nextCollectionCreator =
      const _i1.StorageValue<_i4.AccountId32>(
        prefix: 'EraV14AssetAllocator',
        storage: 'NextCollectionCreator',
        valueCodec: _i4.AccountId32Codec(),
      );

  final _i1.StorageMap<int, BigInt> _admittedAssets =
      const _i1.StorageMap<int, BigInt>(
        prefix: 'EraV14AssetAllocator',
        storage: 'AdmittedAssets',
        valueCodec: _i2.U128Codec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageMap<int, dynamic> _admittedCollections =
      const _i1.StorageMap<int, dynamic>(
        prefix: 'EraV14AssetAllocator',
        storage: 'AdmittedCollections',
        valueCodec: _i2.NullCodec.codec,
        hasher: _i1.StorageHasher.blake2b128Concat(_i2.U32Codec.codec),
      );

  final _i1.StorageValue<_i5.Tuple2<int, int>> _creationGuard =
      const _i1.StorageValue<_i5.Tuple2<int, int>>(
        prefix: 'EraV14AssetAllocator',
        storage: 'CreationGuard',
        valueCodec: _i5.Tuple2Codec<int, int>(
          _i2.U8Codec.codec,
          _i2.U32Codec.codec,
        ),
      );

  final _i1.StorageValue<_i5.Tuple2<int, int>> _mintGuard =
      const _i1.StorageValue<_i5.Tuple2<int, int>>(
        prefix: 'EraV14AssetAllocator',
        storage: 'MintGuard',
        valueCodec: _i5.Tuple2Codec<int, int>(
          _i2.U32Codec.codec,
          _i2.U32Codec.codec,
        ),
      );

  _i6.Future<int?> legacyCreationClosedAt({_i1.BlockHash? at}) async {
    final hashedKey = _legacyCreationClosedAt.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _legacyCreationClosedAt.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> schemaVersion({_i1.BlockHash? at}) async {
    final hashedKey = _schemaVersion.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _schemaVersion.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> nextAssetId({_i1.BlockHash? at}) async {
    final hashedKey = _nextAssetId.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextAssetId.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> nextCollectionId({_i1.BlockHash? at}) async {
    final hashedKey = _nextCollectionId.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextCollectionId.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<int?> nextItemId(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _nextItemId.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextItemId.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<List<int>?> initializationEvidence({_i1.BlockHash? at}) async {
    final hashedKey = _initializationEvidence.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _initializationEvidence.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<List<int>?> itemInitializationEvidence(
    int key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _itemInitializationEvidence.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _itemInitializationEvidence.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<_i3.AssetPermit?> nextAssetPermit({_i1.BlockHash? at}) async {
    final hashedKey = _nextAssetPermit.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextAssetPermit.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<_i4.AccountId32?> nextCollectionCreator({
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _nextCollectionCreator.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _nextCollectionCreator.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<BigInt?> admittedAssets(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _admittedAssets.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _admittedAssets.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<dynamic> admittedCollections(int key1, {_i1.BlockHash? at}) async {
    final hashedKey = _admittedCollections.hashedKeyFor(key1);
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _admittedCollections.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<_i5.Tuple2<int, int>?> creationGuard({_i1.BlockHash? at}) async {
    final hashedKey = _creationGuard.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _creationGuard.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<_i5.Tuple2<int, int>?> mintGuard({_i1.BlockHash? at}) async {
    final hashedKey = _mintGuard.hashedKey();
    final bytes = await __api.getStorage(hashedKey, at: at);
    if (bytes != null) {
      return _mintGuard.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  _i6.Future<List<int?>> multiNextItemId(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _nextItemId.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _nextItemId.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i6.Future<List<List<int>?>> multiItemInitializationEvidence(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _itemInitializationEvidence.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _itemInitializationEvidence.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i6.Future<List<BigInt?>> multiAdmittedAssets(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _admittedAssets.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _admittedAssets.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  _i6.Future<List<dynamic>> multiAdmittedCollections(
    List<int> keys, {
    _i1.BlockHash? at,
  }) async {
    final hashedKeys = keys
        .map((key) => _admittedCollections.hashedKeyFor(key))
        .toList();
    final bytes = await __api.queryStorageAt(hashedKeys, at: at);
    if (bytes.isNotEmpty) {
      return bytes.first.changes
          .map((v) => _admittedCollections.decodeValue(v.key))
          .toList();
    }
    return []; /* Nullable */
  }

  /// Returns the storage key for `legacyCreationClosedAt`.
  _i7.Uint8List legacyCreationClosedAtKey() {
    final hashedKey = _legacyCreationClosedAt.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `schemaVersion`.
  _i7.Uint8List schemaVersionKey() {
    final hashedKey = _schemaVersion.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `nextAssetId`.
  _i7.Uint8List nextAssetIdKey() {
    final hashedKey = _nextAssetId.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `nextCollectionId`.
  _i7.Uint8List nextCollectionIdKey() {
    final hashedKey = _nextCollectionId.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `nextItemId`.
  _i7.Uint8List nextItemIdKey(int key1) {
    final hashedKey = _nextItemId.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `initializationEvidence`.
  _i7.Uint8List initializationEvidenceKey() {
    final hashedKey = _initializationEvidence.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `itemInitializationEvidence`.
  _i7.Uint8List itemInitializationEvidenceKey(int key1) {
    final hashedKey = _itemInitializationEvidence.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `nextAssetPermit`.
  _i7.Uint8List nextAssetPermitKey() {
    final hashedKey = _nextAssetPermit.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `nextCollectionCreator`.
  _i7.Uint8List nextCollectionCreatorKey() {
    final hashedKey = _nextCollectionCreator.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `admittedAssets`.
  _i7.Uint8List admittedAssetsKey(int key1) {
    final hashedKey = _admittedAssets.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `admittedCollections`.
  _i7.Uint8List admittedCollectionsKey(int key1) {
    final hashedKey = _admittedCollections.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage key for `creationGuard`.
  _i7.Uint8List creationGuardKey() {
    final hashedKey = _creationGuard.hashedKey();
    return hashedKey;
  }

  /// Returns the storage key for `mintGuard`.
  _i7.Uint8List mintGuardKey() {
    final hashedKey = _mintGuard.hashedKey();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `nextItemId`.
  _i7.Uint8List nextItemIdMapPrefix() {
    final hashedKey = _nextItemId.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `itemInitializationEvidence`.
  _i7.Uint8List itemInitializationEvidenceMapPrefix() {
    final hashedKey = _itemInitializationEvidence.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `admittedAssets`.
  _i7.Uint8List admittedAssetsMapPrefix() {
    final hashedKey = _admittedAssets.mapPrefix();
    return hashedKey;
  }

  /// Returns the storage map key prefix for `admittedCollections`.
  _i7.Uint8List admittedCollectionsMapPrefix() {
    final hashedKey = _admittedCollections.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  /// Cursors must come from owner-approved historical high-water evidence. No scan or reset.
  _i8.EraV14AssetAllocator initialize({
    int? nextAsset,
    int? nextCollection,
    required List<int> evidence,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.Initialize(
        nextAsset: nextAsset,
        nextCollection: nextCollection,
        evidence: evidence,
      ),
    );
  }

  _i8.EraV14AssetAllocator permitAsset({
    required _i4.AccountId32 creator,
    required BigInt minimum,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.PermitAsset(creator: creator, minimum: minimum),
    );
  }

  _i8.EraV14AssetAllocator permitCollection({
    required _i4.AccountId32 creator,
  }) {
    return _i8.EraV14AssetAllocator(_i9.PermitCollection(creator: creator));
  }

  _i8.EraV14AssetAllocator createAsset({
    required _i4.AccountId32 issuer,
    required _i4.AccountId32 admin,
    required _i4.AccountId32 freezer,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.CreateAsset(issuer: issuer, admin: admin, freezer: freezer),
    );
  }

  _i8.EraV14AssetAllocator createCollection({
    required _i4.AccountId32 issuer,
    required _i4.AccountId32 admin,
    required _i4.AccountId32 freezer,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.CreateCollection(issuer: issuer, admin: admin, freezer: freezer),
    );
  }

  _i8.EraV14AssetAllocator mintItem({
    required int collection,
    required _i4.AccountId32 recipient,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.MintItem(collection: collection, recipient: recipient),
    );
  }

  _i8.EraV14AssetAllocator admitExistingAsset({
    required int id,
    required BigInt minimum,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.AdmitExistingAsset(id: id, minimum: minimum),
    );
  }

  _i8.EraV14AssetAllocator admitExistingCollection({
    required int id,
    int? nextItem,
    required List<int> evidence,
  }) {
    return _i8.EraV14AssetAllocator(
      _i9.AdmitExistingCollection(
        id: id,
        nextItem: nextItem,
        evidence: evidence,
      ),
    );
  }
}
