// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../../sp_core/crypto/account_id32.dart' as _i3;

/// The `Event` enum of this pallet
abstract class Event {
  const Event();

  factory Event.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $EventCodec codec = $EventCodec();

  static const $Event values = $Event();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, dynamic>> toJson();
}

class $Event {
  const $Event();

  Initialized initialized({
    int? nextAsset,
    int? nextCollection,
    required List<int> evidence,
  }) {
    return Initialized(
      nextAsset: nextAsset,
      nextCollection: nextCollection,
      evidence: evidence,
    );
  }

  AssetPermitted assetPermitted({
    required _i3.AccountId32 creator,
    required BigInt minimum,
  }) {
    return AssetPermitted(creator: creator, minimum: minimum);
  }

  CollectionPermitted collectionPermitted({required _i3.AccountId32 creator}) {
    return CollectionPermitted(creator: creator);
  }

  AssetCreated assetCreated({
    required int id,
    required _i3.AccountId32 creator,
  }) {
    return AssetCreated(id: id, creator: creator);
  }

  CollectionCreated collectionCreated({
    required int id,
    required _i3.AccountId32 creator,
  }) {
    return CollectionCreated(id: id, creator: creator);
  }

  ItemCreated itemCreated({
    required int collection,
    required int item,
    required _i3.AccountId32 issuer,
  }) {
    return ItemCreated(collection: collection, item: item, issuer: issuer);
  }

  LegacyAssetAdmitted legacyAssetAdmitted({required int id}) {
    return LegacyAssetAdmitted(id: id);
  }

  LegacyCollectionAdmitted legacyCollectionAdmitted({
    required int id,
    int? nextItem,
    required List<int> evidence,
  }) {
    return LegacyCollectionAdmitted(
      id: id,
      nextItem: nextItem,
      evidence: evidence,
    );
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return Initialized._decode(input);
      case 1:
        return AssetPermitted._decode(input);
      case 2:
        return CollectionPermitted._decode(input);
      case 3:
        return AssetCreated._decode(input);
      case 4:
        return CollectionCreated._decode(input);
      case 5:
        return ItemCreated._decode(input);
      case 6:
        return LegacyAssetAdmitted._decode(input);
      case 7:
        return LegacyCollectionAdmitted._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case Initialized:
        (value as Initialized).encodeTo(output);
        break;
      case AssetPermitted:
        (value as AssetPermitted).encodeTo(output);
        break;
      case CollectionPermitted:
        (value as CollectionPermitted).encodeTo(output);
        break;
      case AssetCreated:
        (value as AssetCreated).encodeTo(output);
        break;
      case CollectionCreated:
        (value as CollectionCreated).encodeTo(output);
        break;
      case ItemCreated:
        (value as ItemCreated).encodeTo(output);
        break;
      case LegacyAssetAdmitted:
        (value as LegacyAssetAdmitted).encodeTo(output);
        break;
      case LegacyCollectionAdmitted:
        (value as LegacyCollectionAdmitted).encodeTo(output);
        break;
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Event value) {
    switch (value.runtimeType) {
      case Initialized:
        return (value as Initialized)._sizeHint();
      case AssetPermitted:
        return (value as AssetPermitted)._sizeHint();
      case CollectionPermitted:
        return (value as CollectionPermitted)._sizeHint();
      case AssetCreated:
        return (value as AssetCreated)._sizeHint();
      case CollectionCreated:
        return (value as CollectionCreated)._sizeHint();
      case ItemCreated:
        return (value as ItemCreated)._sizeHint();
      case LegacyAssetAdmitted:
        return (value as LegacyAssetAdmitted)._sizeHint();
      case LegacyCollectionAdmitted:
        return (value as LegacyCollectionAdmitted)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class Initialized extends Event {
  const Initialized({
    this.nextAsset,
    this.nextCollection,
    required this.evidence,
  });

  factory Initialized._decode(_i1.Input input) {
    return Initialized(
      nextAsset: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
      nextCollection: const _i1.OptionCodec<int>(
        _i1.U32Codec.codec,
      ).decode(input),
      evidence: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// Option<u32>
  final int? nextAsset;

  /// Option<u32>
  final int? nextCollection;

  /// [u8; 32]
  final List<int> evidence;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'Initialized': {
      'nextAsset': nextAsset,
      'nextCollection': nextCollection,
      'evidence': evidence.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(nextAsset);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(nextCollection);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(evidence);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    const _i1.OptionCodec<int>(_i1.U32Codec.codec).encodeTo(nextAsset, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(nextCollection, output);
    const _i1.U8ArrayCodec(32).encodeTo(evidence, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Initialized &&
          other.nextAsset == nextAsset &&
          other.nextCollection == nextCollection &&
          _i4.listsEqual(other.evidence, evidence);

  @override
  int get hashCode => Object.hash(nextAsset, nextCollection, evidence);
}

class AssetPermitted extends Event {
  const AssetPermitted({required this.creator, required this.minimum});

  factory AssetPermitted._decode(_i1.Input input) {
    return AssetPermitted(
      creator: const _i1.U8ArrayCodec(32).decode(input),
      minimum: _i1.U128Codec.codec.decode(input),
    );
  }

  /// AccountId
  final _i3.AccountId32 creator;

  /// u128
  final BigInt minimum;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'AssetPermitted': {'creator': creator.toList(), 'minimum': minimum},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(creator);
    size = size + _i1.U128Codec.codec.sizeHint(minimum);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    const _i1.U8ArrayCodec(32).encodeTo(creator, output);
    _i1.U128Codec.codec.encodeTo(minimum, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetPermitted &&
          _i4.listsEqual(other.creator, creator) &&
          other.minimum == minimum;

  @override
  int get hashCode => Object.hash(creator, minimum);
}

class CollectionPermitted extends Event {
  const CollectionPermitted({required this.creator});

  factory CollectionPermitted._decode(_i1.Input input) {
    return CollectionPermitted(
      creator: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// AccountId
  final _i3.AccountId32 creator;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'CollectionPermitted': {'creator': creator.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(creator);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    const _i1.U8ArrayCodec(32).encodeTo(creator, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionPermitted && _i4.listsEqual(other.creator, creator);

  @override
  int get hashCode => creator.hashCode;
}

class AssetCreated extends Event {
  const AssetCreated({required this.id, required this.creator});

  factory AssetCreated._decode(_i1.Input input) {
    return AssetCreated(
      id: _i1.U32Codec.codec.decode(input),
      creator: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// u32
  final int id;

  /// AccountId
  final _i3.AccountId32 creator;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'AssetCreated': {'id': id, 'creator': creator.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(id);
    size = size + const _i3.AccountId32Codec().sizeHint(creator);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i1.U32Codec.codec.encodeTo(id, output);
    const _i1.U8ArrayCodec(32).encodeTo(creator, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetCreated &&
          other.id == id &&
          _i4.listsEqual(other.creator, creator);

  @override
  int get hashCode => Object.hash(id, creator);
}

class CollectionCreated extends Event {
  const CollectionCreated({required this.id, required this.creator});

  factory CollectionCreated._decode(_i1.Input input) {
    return CollectionCreated(
      id: _i1.U32Codec.codec.decode(input),
      creator: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// u32
  final int id;

  /// AccountId
  final _i3.AccountId32 creator;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'CollectionCreated': {'id': id, 'creator': creator.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(id);
    size = size + const _i3.AccountId32Codec().sizeHint(creator);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i1.U32Codec.codec.encodeTo(id, output);
    const _i1.U8ArrayCodec(32).encodeTo(creator, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionCreated &&
          other.id == id &&
          _i4.listsEqual(other.creator, creator);

  @override
  int get hashCode => Object.hash(id, creator);
}

class ItemCreated extends Event {
  const ItemCreated({
    required this.collection,
    required this.item,
    required this.issuer,
  });

  factory ItemCreated._decode(_i1.Input input) {
    return ItemCreated(
      collection: _i1.U32Codec.codec.decode(input),
      item: _i1.U32Codec.codec.decode(input),
      issuer: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// u32
  final int collection;

  /// u32
  final int item;

  /// AccountId
  final _i3.AccountId32 issuer;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'ItemCreated': {
      'collection': collection,
      'item': item,
      'issuer': issuer.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(collection);
    size = size + _i1.U32Codec.codec.sizeHint(item);
    size = size + const _i3.AccountId32Codec().sizeHint(issuer);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i1.U32Codec.codec.encodeTo(collection, output);
    _i1.U32Codec.codec.encodeTo(item, output);
    const _i1.U8ArrayCodec(32).encodeTo(issuer, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemCreated &&
          other.collection == collection &&
          other.item == item &&
          _i4.listsEqual(other.issuer, issuer);

  @override
  int get hashCode => Object.hash(collection, item, issuer);
}

class LegacyAssetAdmitted extends Event {
  const LegacyAssetAdmitted({required this.id});

  factory LegacyAssetAdmitted._decode(_i1.Input input) {
    return LegacyAssetAdmitted(id: _i1.U32Codec.codec.decode(input));
  }

  /// u32
  final int id;

  @override
  Map<String, Map<String, int>> toJson() => {
    'LegacyAssetAdmitted': {'id': id},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(id);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    _i1.U32Codec.codec.encodeTo(id, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LegacyAssetAdmitted && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class LegacyCollectionAdmitted extends Event {
  const LegacyCollectionAdmitted({
    required this.id,
    this.nextItem,
    required this.evidence,
  });

  factory LegacyCollectionAdmitted._decode(_i1.Input input) {
    return LegacyCollectionAdmitted(
      id: _i1.U32Codec.codec.decode(input),
      nextItem: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
      evidence: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// u32
  final int id;

  /// Option<u32>
  final int? nextItem;

  /// [u8; 32]
  final List<int> evidence;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'LegacyCollectionAdmitted': {
      'id': id,
      'nextItem': nextItem,
      'evidence': evidence.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(id);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(nextItem);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(evidence);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(7, output);
    _i1.U32Codec.codec.encodeTo(id, output);
    const _i1.OptionCodec<int>(_i1.U32Codec.codec).encodeTo(nextItem, output);
    const _i1.U8ArrayCodec(32).encodeTo(evidence, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyCollectionAdmitted &&
          other.id == id &&
          other.nextItem == nextItem &&
          _i4.listsEqual(other.evidence, evidence);

  @override
  int get hashCode => Object.hash(id, nextItem, evidence);
}
