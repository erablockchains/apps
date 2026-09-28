// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../../sp_core/crypto/account_id32.dart' as _i3;

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

  Map<String, Map<String, dynamic>> toJson();
}

class $Call {
  const $Call();

  Initialize initialize({
    int? nextAsset,
    int? nextCollection,
    required List<int> evidence,
  }) {
    return Initialize(
      nextAsset: nextAsset,
      nextCollection: nextCollection,
      evidence: evidence,
    );
  }

  PermitAsset permitAsset({
    required _i3.AccountId32 creator,
    required BigInt minimum,
  }) {
    return PermitAsset(creator: creator, minimum: minimum);
  }

  PermitCollection permitCollection({required _i3.AccountId32 creator}) {
    return PermitCollection(creator: creator);
  }

  CreateAsset createAsset({
    required _i3.AccountId32 issuer,
    required _i3.AccountId32 admin,
    required _i3.AccountId32 freezer,
  }) {
    return CreateAsset(issuer: issuer, admin: admin, freezer: freezer);
  }

  CreateCollection createCollection({
    required _i3.AccountId32 issuer,
    required _i3.AccountId32 admin,
    required _i3.AccountId32 freezer,
  }) {
    return CreateCollection(issuer: issuer, admin: admin, freezer: freezer);
  }

  MintItem mintItem({
    required int collection,
    required _i3.AccountId32 recipient,
  }) {
    return MintItem(collection: collection, recipient: recipient);
  }

  AdmitExistingAsset admitExistingAsset({
    required int id,
    required BigInt minimum,
  }) {
    return AdmitExistingAsset(id: id, minimum: minimum);
  }

  AdmitExistingCollection admitExistingCollection({
    required int id,
    int? nextItem,
    required List<int> evidence,
  }) {
    return AdmitExistingCollection(
      id: id,
      nextItem: nextItem,
      evidence: evidence,
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
        return Initialize._decode(input);
      case 1:
        return PermitAsset._decode(input);
      case 2:
        return PermitCollection._decode(input);
      case 3:
        return CreateAsset._decode(input);
      case 4:
        return CreateCollection._decode(input);
      case 5:
        return MintItem._decode(input);
      case 6:
        return AdmitExistingAsset._decode(input);
      case 7:
        return AdmitExistingCollection._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Call value, _i1.Output output) {
    switch (value.runtimeType) {
      case Initialize:
        (value as Initialize).encodeTo(output);
        break;
      case PermitAsset:
        (value as PermitAsset).encodeTo(output);
        break;
      case PermitCollection:
        (value as PermitCollection).encodeTo(output);
        break;
      case CreateAsset:
        (value as CreateAsset).encodeTo(output);
        break;
      case CreateCollection:
        (value as CreateCollection).encodeTo(output);
        break;
      case MintItem:
        (value as MintItem).encodeTo(output);
        break;
      case AdmitExistingAsset:
        (value as AdmitExistingAsset).encodeTo(output);
        break;
      case AdmitExistingCollection:
        (value as AdmitExistingCollection).encodeTo(output);
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
      case Initialize:
        return (value as Initialize)._sizeHint();
      case PermitAsset:
        return (value as PermitAsset)._sizeHint();
      case PermitCollection:
        return (value as PermitCollection)._sizeHint();
      case CreateAsset:
        return (value as CreateAsset)._sizeHint();
      case CreateCollection:
        return (value as CreateCollection)._sizeHint();
      case MintItem:
        return (value as MintItem)._sizeHint();
      case AdmitExistingAsset:
        return (value as AdmitExistingAsset)._sizeHint();
      case AdmitExistingCollection:
        return (value as AdmitExistingCollection)._sizeHint();
      default:
        throw Exception(
          'Call: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

/// Cursors must come from owner-approved historical high-water evidence. No scan or reset.
class Initialize extends Call {
  const Initialize({
    this.nextAsset,
    this.nextCollection,
    required this.evidence,
  });

  factory Initialize._decode(_i1.Input input) {
    return Initialize(
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
    'initialize': {
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
      other is Initialize &&
          other.nextAsset == nextAsset &&
          other.nextCollection == nextCollection &&
          _i4.listsEqual(other.evidence, evidence);

  @override
  int get hashCode => Object.hash(nextAsset, nextCollection, evidence);
}

class PermitAsset extends Call {
  const PermitAsset({required this.creator, required this.minimum});

  factory PermitAsset._decode(_i1.Input input) {
    return PermitAsset(
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
    'permit_asset': {'creator': creator.toList(), 'minimum': minimum},
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
      other is PermitAsset &&
          _i4.listsEqual(other.creator, creator) &&
          other.minimum == minimum;

  @override
  int get hashCode => Object.hash(creator, minimum);
}

class PermitCollection extends Call {
  const PermitCollection({required this.creator});

  factory PermitCollection._decode(_i1.Input input) {
    return PermitCollection(creator: const _i1.U8ArrayCodec(32).decode(input));
  }

  /// AccountId
  final _i3.AccountId32 creator;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'permit_collection': {'creator': creator.toList()},
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
      other is PermitCollection && _i4.listsEqual(other.creator, creator);

  @override
  int get hashCode => creator.hashCode;
}

class CreateAsset extends Call {
  const CreateAsset({
    required this.issuer,
    required this.admin,
    required this.freezer,
  });

  factory CreateAsset._decode(_i1.Input input) {
    return CreateAsset(
      issuer: const _i1.U8ArrayCodec(32).decode(input),
      admin: const _i1.U8ArrayCodec(32).decode(input),
      freezer: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// AccountId
  final _i3.AccountId32 issuer;

  /// AccountId
  final _i3.AccountId32 admin;

  /// AccountId
  final _i3.AccountId32 freezer;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'create_asset': {
      'issuer': issuer.toList(),
      'admin': admin.toList(),
      'freezer': freezer.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(issuer);
    size = size + const _i3.AccountId32Codec().sizeHint(admin);
    size = size + const _i3.AccountId32Codec().sizeHint(freezer);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    const _i1.U8ArrayCodec(32).encodeTo(issuer, output);
    const _i1.U8ArrayCodec(32).encodeTo(admin, output);
    const _i1.U8ArrayCodec(32).encodeTo(freezer, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAsset &&
          _i4.listsEqual(other.issuer, issuer) &&
          _i4.listsEqual(other.admin, admin) &&
          _i4.listsEqual(other.freezer, freezer);

  @override
  int get hashCode => Object.hash(issuer, admin, freezer);
}

class CreateCollection extends Call {
  const CreateCollection({
    required this.issuer,
    required this.admin,
    required this.freezer,
  });

  factory CreateCollection._decode(_i1.Input input) {
    return CreateCollection(
      issuer: const _i1.U8ArrayCodec(32).decode(input),
      admin: const _i1.U8ArrayCodec(32).decode(input),
      freezer: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// AccountId
  final _i3.AccountId32 issuer;

  /// AccountId
  final _i3.AccountId32 admin;

  /// AccountId
  final _i3.AccountId32 freezer;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
    'create_collection': {
      'issuer': issuer.toList(),
      'admin': admin.toList(),
      'freezer': freezer.toList(),
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(issuer);
    size = size + const _i3.AccountId32Codec().sizeHint(admin);
    size = size + const _i3.AccountId32Codec().sizeHint(freezer);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    const _i1.U8ArrayCodec(32).encodeTo(issuer, output);
    const _i1.U8ArrayCodec(32).encodeTo(admin, output);
    const _i1.U8ArrayCodec(32).encodeTo(freezer, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCollection &&
          _i4.listsEqual(other.issuer, issuer) &&
          _i4.listsEqual(other.admin, admin) &&
          _i4.listsEqual(other.freezer, freezer);

  @override
  int get hashCode => Object.hash(issuer, admin, freezer);
}

class MintItem extends Call {
  const MintItem({required this.collection, required this.recipient});

  factory MintItem._decode(_i1.Input input) {
    return MintItem(
      collection: _i1.U32Codec.codec.decode(input),
      recipient: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  /// u32
  final int collection;

  /// AccountId
  final _i3.AccountId32 recipient;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'mint_item': {'collection': collection, 'recipient': recipient.toList()},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(collection);
    size = size + const _i3.AccountId32Codec().sizeHint(recipient);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i1.U32Codec.codec.encodeTo(collection, output);
    const _i1.U8ArrayCodec(32).encodeTo(recipient, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MintItem &&
          other.collection == collection &&
          _i4.listsEqual(other.recipient, recipient);

  @override
  int get hashCode => Object.hash(collection, recipient);
}

class AdmitExistingAsset extends Call {
  const AdmitExistingAsset({required this.id, required this.minimum});

  factory AdmitExistingAsset._decode(_i1.Input input) {
    return AdmitExistingAsset(
      id: _i1.U32Codec.codec.decode(input),
      minimum: _i1.U128Codec.codec.decode(input),
    );
  }

  /// u32
  final int id;

  /// u128
  final BigInt minimum;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'admit_existing_asset': {'id': id, 'minimum': minimum},
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(id);
    size = size + _i1.U128Codec.codec.sizeHint(minimum);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    _i1.U32Codec.codec.encodeTo(id, output);
    _i1.U128Codec.codec.encodeTo(minimum, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdmitExistingAsset && other.id == id && other.minimum == minimum;

  @override
  int get hashCode => Object.hash(id, minimum);
}

class AdmitExistingCollection extends Call {
  const AdmitExistingCollection({
    required this.id,
    this.nextItem,
    required this.evidence,
  });

  factory AdmitExistingCollection._decode(_i1.Input input) {
    return AdmitExistingCollection(
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
    'admit_existing_collection': {
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
      other is AdmitExistingCollection &&
          other.id == id &&
          other.nextItem == nextItem &&
          _i4.listsEqual(other.evidence, evidence);

  @override
  int get hashCode => Object.hash(id, nextItem, evidence);
}
