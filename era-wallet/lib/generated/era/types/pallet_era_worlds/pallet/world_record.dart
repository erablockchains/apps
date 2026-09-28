// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../sp_core/crypto/account_id32.dart' as _i2;

class WorldRecord {
  const WorldRecord({
    required this.owner,
    required this.commitment,
    required this.deposit,
  });

  factory WorldRecord.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// T::AccountId
  final _i2.AccountId32 owner;

  /// [u8; 32]
  final List<int> commitment;

  /// BalanceOf<T>
  final BigInt deposit;

  static const $WorldRecordCodec codec = $WorldRecordCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'owner': owner.toList(),
    'commitment': commitment.toList(),
    'deposit': deposit,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldRecord &&
          _i4.listsEqual(other.owner, owner) &&
          _i4.listsEqual(other.commitment, commitment) &&
          other.deposit == deposit;

  @override
  int get hashCode => Object.hash(owner, commitment, deposit);
}

class $WorldRecordCodec with _i1.Codec<WorldRecord> {
  const $WorldRecordCodec();

  @override
  void encodeTo(WorldRecord obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.owner, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.commitment, output);
    _i1.U128Codec.codec.encodeTo(obj.deposit, output);
  }

  @override
  WorldRecord decode(_i1.Input input) {
    return WorldRecord(
      owner: const _i1.U8ArrayCodec(32).decode(input),
      commitment: const _i1.U8ArrayCodec(32).decode(input),
      deposit: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(WorldRecord obj) {
    int size = 0;
    size = size + const _i2.AccountId32Codec().sizeHint(obj.owner);
    size = size + const _i1.U8ArrayCodec(32).sizeHint(obj.commitment);
    size = size + _i1.U128Codec.codec.sizeHint(obj.deposit);
    return size;
  }
}
