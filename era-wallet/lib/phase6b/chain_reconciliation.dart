import 'dart:typed_data';

import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show decodeHex, encodeHex;

import '../generated/era/era.dart' as era_api;
import '../generated/era/types/era_runtime/runtime_event.dart' as era_event;
import '../generated/era/types/frame_system/phase.dart' as era_phase;
import 'phase6b_data.dart' show Phase6bDataProvenance;

class FinalizedBlockReference {
  final int number;
  final String hash;

  const FinalizedBlockReference({required this.number, required this.hash});
}

class Phase6bFinalizedEvent {
  final int blockNumber;
  final String blockHash;
  final DateTime timestamp;
  final int? extrinsicIndex;
  final int eventIndex;
  final String pallet;
  final String event;
  final Map<String, Object?> fields;

  const Phase6bFinalizedEvent({
    required this.blockNumber,
    required this.blockHash,
    required this.timestamp,
    required this.extrinsicIndex,
    required this.eventIndex,
    required this.pallet,
    required this.event,
    required this.fields,
  });

  Phase6bDataProvenance get provenance => Phase6bDataProvenance.finalizedEvent;

  String get stableId =>
      '$blockHash:${extrinsicIndex ?? 'none'}:$eventIndex:$pallet.$event';

  Map<String, Object?> toJson() => {
    'blockNumber': blockNumber,
    'blockHash': blockHash,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'extrinsicIndex': extrinsicIndex,
    'eventIndex': eventIndex,
    'pallet': pallet,
    'event': event,
    'fields': fields,
    'provenance': provenance.name,
  };
}

class Phase6bBlockEvents {
  final FinalizedBlockReference block;
  final DateTime timestamp;
  final List<Phase6bFinalizedEvent> events;

  const Phase6bBlockEvents({
    required this.block,
    required this.timestamp,
    required this.events,
  });
}

abstract interface class Phase6bFinalizedChainSource {
  Future<FinalizedBlockReference> latestFinalized();

  Future<Phase6bBlockEvents> eventsAt(int blockNumber);
}

enum Phase6bReconciliationIncompleteReason {
  unavailableBlocks,
  eventLimitTruncated,
}

extension Phase6bReconciliationIncompleteReasonLabel
    on Phase6bReconciliationIncompleteReason {
  String get label => switch (this) {
    Phase6bReconciliationIncompleteReason.unavailableBlocks =>
      'RPC pruning or gaps',
    Phase6bReconciliationIncompleteReason.eventLimitTruncated =>
      'event limit truncated the requested window',
  };
}

class Phase6bReconciliationResult {
  final List<Phase6bFinalizedEvent> events;
  final int requestedFrom;
  final int requestedThrough;
  final List<int> unavailableBlocks;
  final bool truncatedByEventLimit;
  final List<String> warnings;

  const Phase6bReconciliationResult({
    required this.events,
    required this.requestedFrom,
    required this.requestedThrough,
    required this.unavailableBlocks,
    this.truncatedByEventLimit = false,
    required this.warnings,
  });

  List<Phase6bReconciliationIncompleteReason> get incompleteReasons =>
      List.unmodifiable([
        if (unavailableBlocks.isNotEmpty)
          Phase6bReconciliationIncompleteReason.unavailableBlocks,
        if (truncatedByEventLimit)
          Phase6bReconciliationIncompleteReason.eventLimitTruncated,
      ]);

  bool get historyComplete => incompleteReasons.isEmpty;

  String? get incompletenessReason => historyComplete
      ? null
      : incompleteReasons.map((reason) => reason.label).join('; ');

  String get completenessLabel => historyComplete
      ? 'Finalized on-chain history (bounded window complete)'
      : 'Finalized on-chain history (incomplete: $incompletenessReason)';
}

class Phase6bChainReconciler {
  static const int maximumLookback = 512;

  final Phase6bFinalizedChainSource source;

  const Phase6bChainReconciler(this.source);

  Future<Phase6bReconciliationResult> reconcile({
    int blockLookback = 120,
    int eventLimit = 500,
    bool Function(Phase6bFinalizedEvent event)? include,
  }) async {
    if (blockLookback < 1 || blockLookback > maximumLookback) {
      throw ArgumentError.value(
        blockLookback,
        'blockLookback',
        'Use a bounded finalized window from 1 to $maximumLookback blocks.',
      );
    }
    if (eventLimit < 1) {
      throw ArgumentError.value(eventLimit, 'eventLimit');
    }

    final head = await source.latestFinalized();
    final first = (head.number - blockLookback + 1).clamp(0, head.number);
    final events = <Phase6bFinalizedEvent>[];
    final unavailable = <int>[];
    final warnings = <String>[];
    var truncatedByEventLimit = false;

    for (var number = head.number; number >= first; number--) {
      try {
        final block = await source.eventsAt(number);
        for (
          var eventIndex = 0;
          eventIndex < block.events.length;
          eventIndex++
        ) {
          final event = block.events[eventIndex];
          if (include != null && !include(event)) continue;
          events.add(event);
          if (events.length >= eventLimit) {
            final hasMoreIncludedEvents = block.events
                .skip(eventIndex + 1)
                .any((candidate) => include == null || include(candidate));
            truncatedByEventLimit = number > first || hasMoreIncludedEvents;
            break;
          }
        }
      } catch (error) {
        unavailable.add(number);
        warnings.add('Block $number unavailable: ${_safeError(error)}');
      }
      if (truncatedByEventLimit) {
        warnings.add(
          'Result truncated at the visible $eventLimit-event bound before '
          'the requested finalized window was completely scanned. '
          'Increase the bound or use an indexer for more history.',
        );
        break;
      }
    }

    if (unavailable.isNotEmpty) {
      warnings.add(
        'The connected RPC could not provide every requested finalized '
        'block. This commonly occurs on a pruned node; history is marked '
        'incomplete and local records are not presented as canonical.',
      );
    }
    return Phase6bReconciliationResult(
      events: events,
      requestedFrom: first,
      requestedThrough: head.number,
      unavailableBlocks: unavailable,
      truncatedByEventLimit: truncatedByEventLimit,
      warnings: warnings,
    );
  }
}

class PolkadartPhase6bFinalizedSource implements Phase6bFinalizedChainSource {
  final polkadart.Provider provider;
  final era_api.Era api;

  const PolkadartPhase6bFinalizedSource({
    required this.provider,
    required this.api,
  });

  @override
  Future<FinalizedBlockReference> latestFinalized() async {
    final finalized = await provider.send('chain_getFinalizedHead', const []);
    if (finalized.error != null || finalized.result is! String) {
      throw StateError('Unable to read the latest finalized block hash.');
    }
    final hash = finalized.result! as String;
    final header = await provider.send('chain_getHeader', [hash]);
    if (header.error != null || header.result is! Map) {
      throw StateError('Unable to read the latest finalized block header.');
    }
    final rawNumber = (header.result! as Map)['number']?.toString();
    if (rawNumber == null) {
      throw StateError('Finalized header omitted its block number.');
    }
    return FinalizedBlockReference(
      number: _parseRpcInteger(rawNumber),
      hash: hash,
    );
  }

  @override
  Future<Phase6bBlockEvents> eventsAt(int blockNumber) async {
    final rawHash = await api.query.system.blockHash(blockNumber);
    if (rawHash.isEmpty || rawHash.every((byte) => byte == 0)) {
      throw StateError('Block hash is unavailable.');
    }
    final hash = '0x${encodeHex(rawHash)}';
    final at = Uint8List.fromList(rawHash);
    final timestampMillis = await api.query.timestamp.now(at: at);
    if (timestampMillis.isNegative ||
        timestampMillis > BigInt.from(8640000000000000)) {
      throw StateError('Timestamp pallet returned an invalid value.');
    }
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      timestampMillis.toInt(),
      isUtc: true,
    );
    final records = await api.query.system.events(at: at);
    final events = <Phase6bFinalizedEvent>[];

    for (var eventIndex = 0; eventIndex < records.length; eventIndex++) {
      final record = records[eventIndex];
      final runtimeEvent = record.event;
      if (runtimeEvent is! era_event.AiPredictions) continue;
      final json = runtimeEvent.value0.toJson();
      final name = json.keys.single;
      final rawFields = json[name];
      events.add(
        Phase6bFinalizedEvent(
          blockNumber: blockNumber,
          blockHash: hash,
          timestamp: timestamp,
          extrinsicIndex: record.phase is era_phase.ApplyExtrinsic
              ? (record.phase as era_phase.ApplyExtrinsic).value0
              : null,
          eventIndex: eventIndex,
          pallet: 'AiPredictions',
          event: name,
          fields: _jsonMap(rawFields),
        ),
      );
    }
    return Phase6bBlockEvents(
      block: FinalizedBlockReference(number: blockNumber, hash: hash),
      timestamp: timestamp,
      events: events,
    );
  }

  static int _parseRpcInteger(String value) {
    final parsed = value.startsWith('0x')
        ? BigInt.parse(value.substring(2), radix: 16)
        : BigInt.parse(value);
    if (parsed.isNegative || parsed > BigInt.from(0x7fffffff)) {
      throw StateError('Block number is outside the wallet safe range.');
    }
    return parsed.toInt();
  }
}

class Phase6bEvidence<T> {
  final T value;
  final Phase6bDataProvenance provenance;
  final bool complete;

  const Phase6bEvidence({
    required this.value,
    required this.provenance,
    required this.complete,
  });
}

class Phase6bEvidenceReconciler {
  static Phase6bEvidence<T>? preferCanonical<T>({
    Phase6bEvidence<T>? canonical,
    Phase6bEvidence<T>? finalizedEvent,
    Phase6bEvidence<T>? local,
  }) {
    if (canonical != null) return canonical;
    if (finalizedEvent != null) return finalizedEvent;
    return local;
  }
}

Map<String, Object?> _jsonMap(Object? value) {
  if (value is! Map) return {'value': _jsonValue(value)};
  return {
    for (final entry in value.entries)
      entry.key.toString(): _jsonValue(entry.value),
  };
}

Object? _jsonValue(Object? value) {
  if (value == null || value is bool || value is String || value is num) {
    return value;
  }
  if (value is BigInt) return value.toString();
  if (value is Uint8List) return '0x${encodeHex(value)}';
  if (value is List) return value.map(_jsonValue).toList(growable: false);
  if (value is Map) return _jsonMap(value);
  return value.toString();
}

String _safeError(Object error) {
  final text = error.toString().replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  return text.length <= 240 ? text : '${text.substring(0, 240)}…';
}

Uint8List blockHashBytes(String hash) {
  final value = hash.startsWith('0x') ? hash.substring(2) : hash;
  return Uint8List.fromList(decodeHex(value));
}
