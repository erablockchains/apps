// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  /// The V13 baseline gate has not initialized the shared allowance.
  allowanceNotInitialized('AllowanceNotInitialized', 0),

  /// A zero-value request is not an issuance operation.
  zeroIssuance('ZeroIssuance', 1),

  /// The request exceeds the burn-independent remaining lifetime allowance.
  allowanceExceeded('AllowanceExceeded', 2),

  /// Stored allowance is outside the single approved initialization range.
  invalidStoredAllowance('InvalidStoredAllowance', 3),

  /// Native issuance is already above the approved lifetime ceiling.
  issuanceAboveLifetimeCeiling('IssuanceAboveLifetimeCeiling', 4),

  /// The requested issuance would exceed the approved lifetime ceiling.
  lifetimeCeilingExceeded('LifetimeCeilingExceeded', 5),

  /// Base-unit arithmetic overflowed.
  arithmeticOverflow('ArithmeticOverflow', 6),

  /// The native currency rejected the mint after allowance validation.
  downstreamMintFailed('DownstreamMintFailed', 7),

  /// The currency reported an amount or total-issuance delta other than the exact request.
  unexpectedIssuanceDelta('UnexpectedIssuanceDelta', 8),

  /// Both issuance shares must have distinct protocol destinations.
  destinationCollision('DestinationCollision', 9),

  /// The supplied split carry is outside the fixed 0..9 domain.
  invalidSplitCarry('InvalidSplitCarry', 10),

  /// The two shares and carry transition do not encode the approved persistent 90/10 split.
  invalidSplitEvidence('InvalidSplitEvidence', 11);

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
        return Error.allowanceNotInitialized;
      case 1:
        return Error.zeroIssuance;
      case 2:
        return Error.allowanceExceeded;
      case 3:
        return Error.invalidStoredAllowance;
      case 4:
        return Error.issuanceAboveLifetimeCeiling;
      case 5:
        return Error.lifetimeCeilingExceeded;
      case 6:
        return Error.arithmeticOverflow;
      case 7:
        return Error.downstreamMintFailed;
      case 8:
        return Error.unexpectedIssuanceDelta;
      case 9:
        return Error.destinationCollision;
      case 10:
        return Error.invalidSplitCarry;
      case 11:
        return Error.invalidSplitEvidence;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
