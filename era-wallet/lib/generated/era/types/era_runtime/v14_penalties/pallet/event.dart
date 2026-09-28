// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../../sp_core/crypto/account_id32.dart' as _i3;

/// The `Event` enum of this pallet
abstract class Event {
  const Event();

  factory Event.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $EventCodec codec = $EventCodec();

  static const $Event values = $Event();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, dynamic>> toJson();
}

class $Event {
  const $Event();

  PolicyPrepared policyPrepared({
    required int maximumFractionPpb,
    required int activationSession,
    required int at,
  }) {
    return PolicyPrepared(
      maximumFractionPpb: maximumFractionPpb,
      activationSession: activationSession,
      at: at,
    );
  }

  PenaltySubmitted penaltySubmitted({
    required _i3.AccountId32 offender,
    required int kind,
    required int offenceEra,
    required int enactmentEra,
    required int requestedPpb,
    required int priorMaximumPpb,
    required int newQueueEntries,
  }) {
    return PenaltySubmitted(
      offender: offender,
      kind: kind,
      offenceEra: offenceEra,
      enactmentEra: enactmentEra,
      requestedPpb: requestedPpb,
      priorMaximumPpb: priorMaximumPpb,
      newQueueEntries: newQueueEntries,
    );
  }

  SlashTransferred slashTransferred({
    required _i3.AccountId32 destination,
    required BigInt amount,
  }) {
    return SlashTransferred(destination: destination, amount: amount);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return PolicyPrepared._decode(input);
      case 1:
        return PenaltySubmitted._decode(input);
      case 2:
        return SlashTransferred._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(Event value, _i1.Output output) {
    switch (value.runtimeType) {
      case PolicyPrepared:
        (value as PolicyPrepared).encodeTo(output);
        break;
      case PenaltySubmitted:
        (value as PenaltySubmitted).encodeTo(output);
        break;
      case SlashTransferred:
        (value as SlashTransferred).encodeTo(output);
        break;
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(Event value) {
    switch (value.runtimeType) {
      case PolicyPrepared:
        return (value as PolicyPrepared)._sizeHint();
      case PenaltySubmitted:
        return (value as PenaltySubmitted)._sizeHint();
      case SlashTransferred:
        return (value as SlashTransferred)._sizeHint();
      default:
        throw Exception(
          'Event: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class PolicyPrepared extends Event {
  const PolicyPrepared({
    required this.maximumFractionPpb,
    required this.activationSession,
    required this.at,
  });

  factory PolicyPrepared._decode(_i1.Input input) {
    return PolicyPrepared(
      maximumFractionPpb: _i1.U32Codec.codec.decode(input),
      activationSession: _i1.U32Codec.codec.decode(input),
      at: _i1.U32Codec.codec.decode(input),
    );
  }

  /// u32
  final int maximumFractionPpb;

  /// u32
  final int activationSession;

  /// BlockNumberFor<T>
  final int at;

  @override
  Map<String, Map<String, int>> toJson() => {
    'PolicyPrepared': {
      'maximumFractionPpb': maximumFractionPpb,
      'activationSession': activationSession,
      'at': at,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U32Codec.codec.sizeHint(maximumFractionPpb);
    size = size + _i1.U32Codec.codec.sizeHint(activationSession);
    size = size + _i1.U32Codec.codec.sizeHint(at);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i1.U32Codec.codec.encodeTo(maximumFractionPpb, output);
    _i1.U32Codec.codec.encodeTo(activationSession, output);
    _i1.U32Codec.codec.encodeTo(at, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolicyPrepared &&
          other.maximumFractionPpb == maximumFractionPpb &&
          other.activationSession == activationSession &&
          other.at == at;

  @override
  int get hashCode => Object.hash(maximumFractionPpb, activationSession, at);
}

class PenaltySubmitted extends Event {
  const PenaltySubmitted({
    required this.offender,
    required this.kind,
    required this.offenceEra,
    required this.enactmentEra,
    required this.requestedPpb,
    required this.priorMaximumPpb,
    required this.newQueueEntries,
  });

  factory PenaltySubmitted._decode(_i1.Input input) {
    return PenaltySubmitted(
      offender: const _i1.U8ArrayCodec(32).decode(input),
      kind: _i1.U8Codec.codec.decode(input),
      offenceEra: _i1.U32Codec.codec.decode(input),
      enactmentEra: _i1.U32Codec.codec.decode(input),
      requestedPpb: _i1.U32Codec.codec.decode(input),
      priorMaximumPpb: _i1.U32Codec.codec.decode(input),
      newQueueEntries: _i1.U32Codec.codec.decode(input),
    );
  }

  /// AccountId
  final _i3.AccountId32 offender;

  /// u8
  final int kind;

  /// u32
  final int offenceEra;

  /// u32
  final int enactmentEra;

  /// u32
  final int requestedPpb;

  /// u32
  final int priorMaximumPpb;

  /// u32
  final int newQueueEntries;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'PenaltySubmitted': {
      'offender': offender.toList(),
      'kind': kind,
      'offenceEra': offenceEra,
      'enactmentEra': enactmentEra,
      'requestedPpb': requestedPpb,
      'priorMaximumPpb': priorMaximumPpb,
      'newQueueEntries': newQueueEntries,
    },
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(offender);
    size = size + _i1.U8Codec.codec.sizeHint(kind);
    size = size + _i1.U32Codec.codec.sizeHint(offenceEra);
    size = size + _i1.U32Codec.codec.sizeHint(enactmentEra);
    size = size + _i1.U32Codec.codec.sizeHint(requestedPpb);
    size = size + _i1.U32Codec.codec.sizeHint(priorMaximumPpb);
    size = size + _i1.U32Codec.codec.sizeHint(newQueueEntries);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    const _i1.U8ArrayCodec(32).encodeTo(offender, output);
    _i1.U8Codec.codec.encodeTo(kind, output);
    _i1.U32Codec.codec.encodeTo(offenceEra, output);
    _i1.U32Codec.codec.encodeTo(enactmentEra, output);
    _i1.U32Codec.codec.encodeTo(requestedPpb, output);
    _i1.U32Codec.codec.encodeTo(priorMaximumPpb, output);
    _i1.U32Codec.codec.encodeTo(newQueueEntries, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltySubmitted &&
          _i4.listsEqual(other.offender, offender) &&
          other.kind == kind &&
          other.offenceEra == offenceEra &&
          other.enactmentEra == enactmentEra &&
          other.requestedPpb == requestedPpb &&
          other.priorMaximumPpb == priorMaximumPpb &&
          other.newQueueEntries == newQueueEntries;

  @override
  int get hashCode => Object.hash(
    offender,
    kind,
    offenceEra,
    enactmentEra,
    requestedPpb,
    priorMaximumPpb,
    newQueueEntries,
  );
}

class SlashTransferred extends Event {
  const SlashTransferred({required this.destination, required this.amount});

  factory SlashTransferred._decode(_i1.Input input) {
    return SlashTransferred(
      destination: const _i1.U8ArrayCodec(32).decode(input),
      amount: _i1.U128Codec.codec.decode(input),
    );
  }

  /// AccountId
  final _i3.AccountId32 destination;

  /// u128
  final BigInt amount;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'SlashTransferred': {'destination': destination.toList(), 'amount': amount},
  };

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(destination);
    size = size + _i1.U128Codec.codec.sizeHint(amount);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    const _i1.U8ArrayCodec(32).encodeTo(destination, output);
    _i1.U128Codec.codec.encodeTo(amount, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlashTransferred &&
          _i4.listsEqual(other.destination, destination) &&
          other.amount == amount;

  @override
  int get hashCode => Object.hash(destination, amount);
}
