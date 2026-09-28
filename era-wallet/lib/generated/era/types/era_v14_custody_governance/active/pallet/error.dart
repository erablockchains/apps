// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  invalidSignerConfiguration('InvalidSignerConfiguration', 0),
  unauthorizedSigner('UnauthorizedSigner', 1),
  requestIdMismatch('RequestIdMismatch', 2),
  zeroAmount('ZeroAmount', 3),
  invalidDestination('InvalidDestination', 4),
  proposalMismatch('ProposalMismatch', 5),
  duplicateApproval('DuplicateApproval', 6),
  malformedPendingRequest('MalformedPendingRequest', 7),
  insufficientCustodyBalance('InsufficientCustodyBalance', 8),
  requestIdOverflow('RequestIdOverflow', 9),
  transferFailed('TransferFailed', 10);

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
        return Error.invalidSignerConfiguration;
      case 1:
        return Error.unauthorizedSigner;
      case 2:
        return Error.requestIdMismatch;
      case 3:
        return Error.zeroAmount;
      case 4:
        return Error.invalidDestination;
      case 5:
        return Error.proposalMismatch;
      case 6:
        return Error.duplicateApproval;
      case 7:
        return Error.malformedPendingRequest;
      case 8:
        return Error.insufficientCustodyBalance;
      case 9:
        return Error.requestIdOverflow;
      case 10:
        return Error.transferFailed;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Error value, _i1.Output output) {
    _i1.U8Codec.codec.encodeTo(value.codecIndex, output);
  }
}
