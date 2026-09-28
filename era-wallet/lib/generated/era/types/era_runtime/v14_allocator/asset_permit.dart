// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../sp_core/crypto/account_id32.dart' as _i2;

class AssetPermit {
  const AssetPermit({required this.creator, required this.minimum});

  factory AssetPermit.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// AccountId
  final _i2.AccountId32 creator;

  /// u128
  final BigInt minimum;

  static const $AssetPermitCodec codec = $AssetPermitCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'creator': creator.toList(),
    'minimum': minimum,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetPermit &&
          _i4.listsEqual(other.creator, creator) &&
          other.minimum == minimum;

  @override
  int get hashCode => Object.hash(creator, minimum);
}

class $AssetPermitCodec with _i1.Codec<AssetPermit> {
  const $AssetPermitCodec();

  @override
  void encodeTo(AssetPermit obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.creator, output);
    _i1.U128Codec.codec.encodeTo(obj.minimum, output);
  }

  @override
  AssetPermit decode(_i1.Input input) {
    return AssetPermit(
      creator: const _i1.U8ArrayCodec(32).decode(input),
      minimum: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(AssetPermit obj) {
    int size = 0;
    size = size + const _i2.AccountId32Codec().sizeHint(obj.creator);
    size = size + _i1.U128Codec.codec.sizeHint(obj.minimum);
    return size;
  }
}
