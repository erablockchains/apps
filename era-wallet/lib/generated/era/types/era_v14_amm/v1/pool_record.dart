// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

class PoolRecord {
  const PoolRecord({
    required this.custody,
    required this.creator,
    required this.deposit,
    required this.reserve0,
    required this.reserve1,
    required this.totalLp,
    required this.lockedLp,
    required this.userLp,
  });

  factory PoolRecord.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// AccountId
  final List<int> custody;

  /// AccountId
  final List<int> creator;

  /// u128
  final BigInt deposit;

  /// u128
  final BigInt reserve0;

  /// u128
  final BigInt reserve1;

  /// u128
  final BigInt totalLp;

  /// u128
  final BigInt lockedLp;

  /// u128
  final BigInt userLp;

  static const $PoolRecordCodec codec = $PoolRecordCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'custody': custody.toList(),
    'creator': creator.toList(),
    'deposit': deposit,
    'reserve0': reserve0,
    'reserve1': reserve1,
    'totalLp': totalLp,
    'lockedLp': lockedLp,
    'userLp': userLp,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoolRecord &&
          _i3.listsEqual(other.custody, custody) &&
          _i3.listsEqual(other.creator, creator) &&
          other.deposit == deposit &&
          other.reserve0 == reserve0 &&
          other.reserve1 == reserve1 &&
          other.totalLp == totalLp &&
          other.lockedLp == lockedLp &&
          other.userLp == userLp;

  @override
  int get hashCode => Object.hash(
    custody,
    creator,
    deposit,
    reserve0,
    reserve1,
    totalLp,
    lockedLp,
    userLp,
  );
}

class $PoolRecordCodec with _i1.Codec<PoolRecord> {
  const $PoolRecordCodec();

  @override
  void encodeTo(PoolRecord obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.custody, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.creator, output);
    _i1.U128Codec.codec.encodeTo(obj.deposit, output);
    _i1.U128Codec.codec.encodeTo(obj.reserve0, output);
    _i1.U128Codec.codec.encodeTo(obj.reserve1, output);
    _i1.U128Codec.codec.encodeTo(obj.totalLp, output);
    _i1.U128Codec.codec.encodeTo(obj.lockedLp, output);
    _i1.U128Codec.codec.encodeTo(obj.userLp, output);
  }

  @override
  PoolRecord decode(_i1.Input input) {
    return PoolRecord(
      custody: const _i1.U8ArrayCodec(32).decode(input),
      creator: const _i1.U8ArrayCodec(32).decode(input),
      deposit: _i1.U128Codec.codec.decode(input),
      reserve0: _i1.U128Codec.codec.decode(input),
      reserve1: _i1.U128Codec.codec.decode(input),
      totalLp: _i1.U128Codec.codec.decode(input),
      lockedLp: _i1.U128Codec.codec.decode(input),
      userLp: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PoolRecord obj) {
    int size = 0;
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.custody);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.creator);
    size = size + _i1.U128Codec.codec.sizeHint(obj.deposit);
    size = size + _i1.U128Codec.codec.sizeHint(obj.reserve0);
    size = size + _i1.U128Codec.codec.sizeHint(obj.reserve1);
    size = size + _i1.U128Codec.codec.sizeHint(obj.totalLp);
    size = size + _i1.U128Codec.codec.sizeHint(obj.lockedLp);
    size = size + _i1.U128Codec.codec.sizeHint(obj.userLp);
    return size;
  }
}
