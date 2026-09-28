// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class PredictionMarketAccounting {
  const PredictionMarketAccounting({
    required this.feesCollected,
    required this.remaindersCollected,
    required this.totalPaid,
    required this.totalRefunded,
    required this.totalSlashed,
  });

  factory PredictionMarketAccounting.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// Balance
  final BigInt feesCollected;

  /// Balance
  final BigInt remaindersCollected;

  /// Balance
  final BigInt totalPaid;

  /// Balance
  final BigInt totalRefunded;

  /// Balance
  final BigInt totalSlashed;

  static const $PredictionMarketAccountingCodec codec =
      $PredictionMarketAccountingCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, BigInt> toJson() => {
    'feesCollected': feesCollected,
    'remaindersCollected': remaindersCollected,
    'totalPaid': totalPaid,
    'totalRefunded': totalRefunded,
    'totalSlashed': totalSlashed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionMarketAccounting &&
          other.feesCollected == feesCollected &&
          other.remaindersCollected == remaindersCollected &&
          other.totalPaid == totalPaid &&
          other.totalRefunded == totalRefunded &&
          other.totalSlashed == totalSlashed;

  @override
  int get hashCode => Object.hash(
    feesCollected,
    remaindersCollected,
    totalPaid,
    totalRefunded,
    totalSlashed,
  );
}

class $PredictionMarketAccountingCodec
    with _i1.Codec<PredictionMarketAccounting> {
  const $PredictionMarketAccountingCodec();

  @override
  void encodeTo(PredictionMarketAccounting obj, _i1.Output output) {
    _i1.U128Codec.codec.encodeTo(obj.feesCollected, output);
    _i1.U128Codec.codec.encodeTo(obj.remaindersCollected, output);
    _i1.U128Codec.codec.encodeTo(obj.totalPaid, output);
    _i1.U128Codec.codec.encodeTo(obj.totalRefunded, output);
    _i1.U128Codec.codec.encodeTo(obj.totalSlashed, output);
  }

  @override
  PredictionMarketAccounting decode(_i1.Input input) {
    return PredictionMarketAccounting(
      feesCollected: _i1.U128Codec.codec.decode(input),
      remaindersCollected: _i1.U128Codec.codec.decode(input),
      totalPaid: _i1.U128Codec.codec.decode(input),
      totalRefunded: _i1.U128Codec.codec.decode(input),
      totalSlashed: _i1.U128Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PredictionMarketAccounting obj) {
    int size = 0;
    size = size + _i1.U128Codec.codec.sizeHint(obj.feesCollected);
    size = size + _i1.U128Codec.codec.sizeHint(obj.remaindersCollected);
    size = size + _i1.U128Codec.codec.sizeHint(obj.totalPaid);
    size = size + _i1.U128Codec.codec.sizeHint(obj.totalRefunded);
    size = size + _i1.U128Codec.codec.sizeHint(obj.totalSlashed);
    return size;
  }
}
