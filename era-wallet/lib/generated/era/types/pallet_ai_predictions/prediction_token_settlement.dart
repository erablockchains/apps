// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i5;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../sp_core/crypto/account_id32.dart' as _i4;
import 'settlement_outcome.dart' as _i3;
import 'settlement_status.dart' as _i2;

class PredictionTokenSettlement {
  const PredictionTokenSettlement({
    required this.tokenId,
    required this.status,
    this.proposedOutcome,
    this.finalOutcome,
    this.proposedBy,
    this.finalizedBy,
    this.proposedAt,
    this.disputeUntil,
    this.finalizedAt,
    this.evidenceUri,
    required this.totalStakeAtFinalization,
    required this.disputeCount,
  });

  factory PredictionTokenSettlement.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u64
  final BigInt tokenId;

  /// SettlementStatus
  final _i2.SettlementStatus status;

  /// Option<SettlementOutcome>
  final _i3.SettlementOutcome? proposedOutcome;

  /// Option<SettlementOutcome>
  final _i3.SettlementOutcome? finalOutcome;

  /// Option<AccountId>
  final _i4.AccountId32? proposedBy;

  /// Option<AccountId>
  final _i4.AccountId32? finalizedBy;

  /// Option<BlockNumber>
  final int? proposedAt;

  /// Option<BlockNumber>
  final int? disputeUntil;

  /// Option<BlockNumber>
  final int? finalizedAt;

  /// Option<BoundedUri>
  final List<int>? evidenceUri;

  /// Balance
  final BigInt totalStakeAtFinalization;

  /// u32
  final int disputeCount;

  static const $PredictionTokenSettlementCodec codec =
      $PredictionTokenSettlementCodec();

  _i5.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'tokenId': tokenId,
    'status': status.toJson(),
    'proposedOutcome': proposedOutcome?.toJson(),
    'finalOutcome': finalOutcome?.toJson(),
    'proposedBy': proposedBy?.toList(),
    'finalizedBy': finalizedBy?.toList(),
    'proposedAt': proposedAt,
    'disputeUntil': disputeUntil,
    'finalizedAt': finalizedAt,
    'evidenceUri': evidenceUri,
    'totalStakeAtFinalization': totalStakeAtFinalization,
    'disputeCount': disputeCount,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTokenSettlement &&
          other.tokenId == tokenId &&
          other.status == status &&
          other.proposedOutcome == proposedOutcome &&
          other.finalOutcome == finalOutcome &&
          other.proposedBy == proposedBy &&
          other.finalizedBy == finalizedBy &&
          other.proposedAt == proposedAt &&
          other.disputeUntil == disputeUntil &&
          other.finalizedAt == finalizedAt &&
          other.evidenceUri == evidenceUri &&
          other.totalStakeAtFinalization == totalStakeAtFinalization &&
          other.disputeCount == disputeCount;

  @override
  int get hashCode => Object.hash(
    tokenId,
    status,
    proposedOutcome,
    finalOutcome,
    proposedBy,
    finalizedBy,
    proposedAt,
    disputeUntil,
    finalizedAt,
    evidenceUri,
    totalStakeAtFinalization,
    disputeCount,
  );
}

class $PredictionTokenSettlementCodec
    with _i1.Codec<PredictionTokenSettlement> {
  const $PredictionTokenSettlementCodec();

  @override
  void encodeTo(PredictionTokenSettlement obj, _i1.Output output) {
    _i1.U64Codec.codec.encodeTo(obj.tokenId, output);
    _i2.SettlementStatus.codec.encodeTo(obj.status, output);
    const _i1.OptionCodec<_i3.SettlementOutcome>(
      _i3.SettlementOutcome.codec,
    ).encodeTo(obj.proposedOutcome, output);
    const _i1.OptionCodec<_i3.SettlementOutcome>(
      _i3.SettlementOutcome.codec,
    ).encodeTo(obj.finalOutcome, output);
    const _i1.OptionCodec<_i4.AccountId32>(
      _i4.AccountId32Codec(),
    ).encodeTo(obj.proposedBy, output);
    const _i1.OptionCodec<_i4.AccountId32>(
      _i4.AccountId32Codec(),
    ).encodeTo(obj.finalizedBy, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.proposedAt, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.disputeUntil, output);
    const _i1.OptionCodec<int>(
      _i1.U32Codec.codec,
    ).encodeTo(obj.finalizedAt, output);
    const _i1.OptionCodec<List<int>>(
      _i1.U8SequenceCodec.codec,
    ).encodeTo(obj.evidenceUri, output);
    _i1.U128Codec.codec.encodeTo(obj.totalStakeAtFinalization, output);
    _i1.U32Codec.codec.encodeTo(obj.disputeCount, output);
  }

  @override
  PredictionTokenSettlement decode(_i1.Input input) {
    return PredictionTokenSettlement(
      tokenId: _i1.U64Codec.codec.decode(input),
      status: _i2.SettlementStatus.codec.decode(input),
      proposedOutcome: const _i1.OptionCodec<_i3.SettlementOutcome>(
        _i3.SettlementOutcome.codec,
      ).decode(input),
      finalOutcome: const _i1.OptionCodec<_i3.SettlementOutcome>(
        _i3.SettlementOutcome.codec,
      ).decode(input),
      proposedBy: const _i1.OptionCodec<_i4.AccountId32>(
        _i4.AccountId32Codec(),
      ).decode(input),
      finalizedBy: const _i1.OptionCodec<_i4.AccountId32>(
        _i4.AccountId32Codec(),
      ).decode(input),
      proposedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
      disputeUntil: const _i1.OptionCodec<int>(
        _i1.U32Codec.codec,
      ).decode(input),
      finalizedAt: const _i1.OptionCodec<int>(_i1.U32Codec.codec).decode(input),
      evidenceUri: const _i1.OptionCodec<List<int>>(
        _i1.U8SequenceCodec.codec,
      ).decode(input),
      totalStakeAtFinalization: _i1.U128Codec.codec.decode(input),
      disputeCount: _i1.U32Codec.codec.decode(input),
    );
  }

  @override
  int sizeHint(PredictionTokenSettlement obj) {
    int size = 0;
    size = size + _i1.U64Codec.codec.sizeHint(obj.tokenId);
    size = size + _i2.SettlementStatus.codec.sizeHint(obj.status);
    size =
        size +
        const _i1.OptionCodec<_i3.SettlementOutcome>(
          _i3.SettlementOutcome.codec,
        ).sizeHint(obj.proposedOutcome);
    size =
        size +
        const _i1.OptionCodec<_i3.SettlementOutcome>(
          _i3.SettlementOutcome.codec,
        ).sizeHint(obj.finalOutcome);
    size =
        size +
        const _i1.OptionCodec<_i4.AccountId32>(
          _i4.AccountId32Codec(),
        ).sizeHint(obj.proposedBy);
    size =
        size +
        const _i1.OptionCodec<_i4.AccountId32>(
          _i4.AccountId32Codec(),
        ).sizeHint(obj.finalizedBy);
    size =
        size +
        const _i1.OptionCodec<int>(_i1.U32Codec.codec).sizeHint(obj.proposedAt);
    size =
        size +
        const _i1.OptionCodec<int>(
          _i1.U32Codec.codec,
        ).sizeHint(obj.disputeUntil);
    size =
        size +
        const _i1.OptionCodec<int>(
          _i1.U32Codec.codec,
        ).sizeHint(obj.finalizedAt);
    size =
        size +
        const _i1.OptionCodec<List<int>>(
          _i1.U8SequenceCodec.codec,
        ).sizeHint(obj.evidenceUri);
    size = size + _i1.U128Codec.codec.sizeHint(obj.totalStakeAtFinalization);
    size = size + _i1.U32Codec.codec.sizeHint(obj.disputeCount);
    return size;
  }
}
