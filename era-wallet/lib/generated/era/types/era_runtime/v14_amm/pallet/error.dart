// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  notFound('NotFound', 0),
  invalidLimit('InvalidLimit', 1),
  invalidCursor('InvalidCursor', 2),
  unsupportedAsset('UnsupportedAsset', 3),
  unconfigured('Unconfigured', 4),
  arithmetic('Arithmetic', 5),
  backendInvariant('BackendInvariant', 6),
  identicalAssets('IdenticalAssets', 7),
  unauthorized('Unauthorized', 8),
  poolAlreadyExists('PoolAlreadyExists', 9),
  custodyCollision('CustodyCollision', 10),
  custodyNotEmpty('CustodyNotEmpty', 11),
  custodyMismatch('CustodyMismatch', 12),
  custodyNotLive('CustodyNotLive', 13),
  deadlineExpired('DeadlineExpired', 14),
  boundExceeded('BoundExceeded', 15),
  zeroAmount('ZeroAmount', 16),
  insufficientInitialLiquidity('InsufficientInitialLiquidity', 17),
  insufficientLiquidity('InsufficientLiquidity', 18),
  insufficientLp('InsufficientLp', 19),
  slippageExceeded('SlippageExceeded', 20),
  invalidConfiguration('InvalidConfiguration', 21),
  belowMinimum('BelowMinimum', 22),
  insufficientBalance('InsufficientBalance', 23),
  frozen('Frozen', 24),
  depositFailure('DepositFailure', 25),
  backendRejected('BackendRejected', 26),
  reentrant('Reentrant', 27),
  transactionLimit('TransactionLimit', 28),
  corruptState('CorruptState', 29),
  badPair('BadPair', 30),
  bound('Bound', 31),
  alreadyActive('AlreadyActive', 32);

  const Error(this.variantName, this.codecIndex);

  factory Error.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ErrorCodec codec = $ErrorCodec();

  String toJson() => variantName;

  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ErrorCodec with _i1.Codec<Error> {
  const $ErrorCodec();

  @override
  Error decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return Error.notFound;
      case 1:
        return Error.invalidLimit;
      case 2:
        return Error.invalidCursor;
      case 3:
        return Error.unsupportedAsset;
      case 4:
        return Error.unconfigured;
      case 5:
        return Error.arithmetic;
      case 6:
        return Error.backendInvariant;
      case 7:
        return Error.identicalAssets;
      case 8:
        return Error.unauthorized;
      case 9:
        return Error.poolAlreadyExists;
      case 10:
        return Error.custodyCollision;
      case 11:
        return Error.custodyNotEmpty;
      case 12:
        return Error.custodyMismatch;
      case 13:
        return Error.custodyNotLive;
      case 14:
        return Error.deadlineExpired;
      case 15:
        return Error.boundExceeded;
      case 16:
        return Error.zeroAmount;
      case 17:
        return Error.insufficientInitialLiquidity;
      case 18:
        return Error.insufficientLiquidity;
      case 19:
        return Error.insufficientLp;
      case 20:
        return Error.slippageExceeded;
      case 21:
        return Error.invalidConfiguration;
      case 22:
        return Error.belowMinimum;
      case 23:
        return Error.insufficientBalance;
      case 24:
        return Error.frozen;
      case 25:
        return Error.depositFailure;
      case 26:
        return Error.backendRejected;
      case 27:
        return Error.reentrant;
      case 28:
        return Error.transactionLimit;
      case 29:
        return Error.corruptState;
      case 30:
        return Error.badPair;
      case 31:
        return Error.bound;
      case 32:
        return Error.alreadyActive;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
