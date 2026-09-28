// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i4;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import '../sp_core/crypto/account_id32.dart' as _i2;
import 'dispute_reason.dart' as _i3;

class PredictionTokenDispute {
  const PredictionTokenDispute({
    required this.disputeId,
    required this.tokenId,
    required this.disputedBy,
    required this.reason,
    required this.evidenceUri,
    required this.bond,
    required this.submittedAt,
    required this.resolved,
    this.accepted,
  });

  factory PredictionTokenDispute.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u64
  final BigInt disputeId;

  /// u64
  final BigInt tokenId;

  /// AccountId
  final _i2.AccountId32 disputedBy;

  /// DisputeReason
  final _i3.DisputeReason reason;

  /// BoundedUri
  final List<int> evidenceUri;

  /// Balance
  final BigInt bond;

  /// BlockNumber
  final int submittedAt;

  /// bool
  final bool resolved;

  /// Option<bool>
  final bool? accepted;

  static const $PredictionTokenDisputeCodec codec =
      $PredictionTokenDisputeCodec();

  _i4.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'disputeId': disputeId,
    'tokenId': tokenId,
    'disputedBy': disputedBy.toList(),
    'reason': reason.toJson(),
    'evidenceUri': evidenceUri,
    'bond': bond,
    'submittedAt': submittedAt,
    'resolved': resolved,
    'accepted': accepted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenDispute &&
          other.disputeId == disputeId &&
          other.tokenId == tokenId &&
          _i5.listsEqual(other.disputedBy, disputedBy) &&
          other.reason == reason &&
          _i5.listsEqual(other.evidenceUri, evidenceUri) &&
          other.bond == bond &&
          other.submittedAt == submittedAt &&
          other.resolved == resolved &&
          other.accepted == accepted;

  @override
  int get hashCode => Object.hash(
    disputeId,
    tokenId,
    disputedBy,
    reason,
    evidenceUri,
    bond,
    submittedAt,
    resolved,
    accepted,
  );
}

class $PredictionTokenDisputeCodec with _i1.Codec<PredictionTokenDispute> {
  const $PredictionTokenDisputeCodec();

  @override
  void encodeTo(PredictionTokenDispute obj, _i1.Output output) {
    _i1.U64Codec.codec.encodeTo(obj.disputeId, output);
    _i1.U64Codec.codec.encodeTo(obj.tokenId, output);
    const _i1.U8ArrayCodec(32).encodeTo(obj.disputedBy, output);
    _i3.DisputeReason.codec.encodeTo(obj.reason, output);
    _i1.U8SequenceCodec.codec.encodeTo(obj.evidenceUri, output);
    _i1.U128Codec.codec.encodeTo(obj.bond, output);
    _i1.U32Codec.codec.encodeTo(obj.submittedAt, output);
    _i1.BoolCodec.codec.encodeTo(obj.resolved, output);
    const _i1.OptionCodec<bool>(
      _i1.BoolCodec.codec,
    ).encodeTo(obj.accepted, output);
  }

  @override
  PredictionTokenDispute decode(_i1.Input input) {
    return PredictionTokenDispute(
      disputeId: _i1.U64Codec.codec.decode(input),
      tokenId: _i1.U64Codec.codec.decode(input),
      disputedBy: const _i1.U8ArrayCodec(32).decode(input),
      reason: _i3.DisputeReason.codec.decode(input),
      evidenceUri: _i1.U8SequenceCodec.codec.decode(input),
      bond: _i1.U128Codec.codec.decode(input),
      submittedAt: _i1.U32Codec.codec.decode(input),
      resolved: _i1.BoolCodec.codec.decode(input),
      accepted: const _i1.OptionCodec<bool>(_i1.BoolCodec.codec).decode(input),
    );
  }

  @override
  int sizeHint(PredictionTokenDispute obj) {
    int size = 0;
    size = size + _i1.U64Codec.codec.sizeHint(obj.disputeId);
    size = size + _i1.U64Codec.codec.sizeHint(obj.tokenId);
    size = size + const _i2.AccountId32Codec().sizeHint(obj.disputedBy);
    size = size + _i3.DisputeReason.codec.sizeHint(obj.reason);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.evidenceUri);
    size = size + _i1.U128Codec.codec.sizeHint(obj.bond);
    size = size + _i1.U32Codec.codec.sizeHint(obj.submittedAt);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.resolved);
    size =
        size +
        const _i1.OptionCodec<bool>(_i1.BoolCodec.codec).sizeHint(obj.accepted);
    return size;
  }
}
