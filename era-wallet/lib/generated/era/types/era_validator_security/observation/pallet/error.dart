// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  unsupportedStorageVersion('UnsupportedStorageVersion', 0),
  invalidCoordinateShape('InvalidCoordinateShape', 1),
  emptyObservationBatch('EmptyObservationBatch', 2),
  observationBatchTooLarge('ObservationBatchTooLarge', 3),
  tooManyNewObservationsThisBlock('TooManyNewObservationsThisBlock', 4),
  capacityFull('CapacityFull', 5),
  observationKeyPreimageMismatch('ObservationKeyPreimageMismatch', 6),
  identityKeyPreimageMismatch('IdentityKeyPreimageMismatch', 7),
  identityIndexInvariant('IdentityIndexInvariant', 8),
  blockNumberOverflow('BlockNumberOverflow', 9),
  expiryOverflow('ExpiryOverflow', 10),
  ringIndexOverflow('RingIndexOverflow', 11),
  ringInvariantViolation('RingInvariantViolation', 12),
  evidenceContextOccupied('EvidenceContextOccupied', 13),
  evidenceContextMissing('EvidenceContextMissing', 14),
  evidenceContextMismatch('EvidenceContextMismatch', 15),
  signedIntakeRejected('SignedIntakeRejected', 16),
  adapterFailure('AdapterFailure', 17);

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
        return Error.unsupportedStorageVersion;
      case 1:
        return Error.invalidCoordinateShape;
      case 2:
        return Error.emptyObservationBatch;
      case 3:
        return Error.observationBatchTooLarge;
      case 4:
        return Error.tooManyNewObservationsThisBlock;
      case 5:
        return Error.capacityFull;
      case 6:
        return Error.observationKeyPreimageMismatch;
      case 7:
        return Error.identityKeyPreimageMismatch;
      case 8:
        return Error.identityIndexInvariant;
      case 9:
        return Error.blockNumberOverflow;
      case 10:
        return Error.expiryOverflow;
      case 11:
        return Error.ringIndexOverflow;
      case 12:
        return Error.ringInvariantViolation;
      case 13:
        return Error.evidenceContextOccupied;
      case 14:
        return Error.evidenceContextMissing;
      case 15:
        return Error.evidenceContextMismatch;
      case 16:
        return Error.signedIntakeRejected;
      case 17:
        return Error.adapterFailure;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
