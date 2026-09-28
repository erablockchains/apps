import 'package:flutter_test/flutter_test.dart';

import 'package:era_wallet/phase6b/chain_reconciliation.dart';
import 'package:era_wallet/phase6b/phase6b_data.dart';

void main() {
  test('scans finalized blocks and preserves Timestamp pallet time', () async {
    final source = _FakeSource(head: 10);
    final result = await Phase6bChainReconciler(
      source,
    ).reconcile(blockLookback: 3);

    expect(result.requestedFrom, 8);
    expect(result.requestedThrough, 10);
    expect(result.historyComplete, isTrue);
    expect(result.events, hasLength(3));
    expect(
      result.events.first.timestamp,
      DateTime.fromMillisecondsSinceEpoch(10000, isUtc: true),
    );
    expect(
      result.events.first.provenance,
      Phase6bDataProvenance.finalizedEvent,
    );
  });

  test('marks pruned history incomplete instead of fabricating it', () async {
    final source = _FakeSource(head: 10, unavailable: {9});
    final result = await Phase6bChainReconciler(
      source,
    ).reconcile(blockLookback: 3);

    expect(result.unavailableBlocks, [9]);
    expect(result.historyComplete, isFalse);
    expect(result.completenessLabel, contains('incomplete'));
    expect(result.warnings.join(' '), contains('pruned'));
  });

  test('marks an event-limit-truncated window incomplete', () async {
    final result = await Phase6bChainReconciler(
      _FakeSource(head: 10),
    ).reconcile(blockLookback: 3, eventLimit: 1);

    expect(result.events, hasLength(1));
    expect(result.truncatedByEventLimit, isTrue);
    expect(result.historyComplete, isFalse);
    expect(
      result.incompleteReasons,
      contains(Phase6bReconciliationIncompleteReason.eventLimitTruncated),
    );
    expect(result.incompletenessReason, contains('event limit'));
    expect(result.completenessLabel, contains('event limit'));
    expect(result.warnings.join(' '), contains('truncated'));
  });

  test('does not call an exact final-block event cap truncation', () async {
    final result = await Phase6bChainReconciler(
      _FakeSource(head: 10),
    ).reconcile(blockLookback: 1, eventLimit: 1);

    expect(result.events, hasLength(1));
    expect(result.truncatedByEventLimit, isFalse);
    expect(result.incompleteReasons, isEmpty);
    expect(result.historyComplete, isTrue);
    expect(result.warnings, isEmpty);
  });

  test('canonical storage wins over events and local evidence', () {
    const canonical = Phase6bEvidence(
      value: 'chain storage',
      provenance: Phase6bDataProvenance.canonicalStorage,
      complete: true,
    );
    const event = Phase6bEvidence(
      value: 'event',
      provenance: Phase6bDataProvenance.finalizedEvent,
      complete: true,
    );
    const local = Phase6bEvidence(
      value: 'local',
      provenance: Phase6bDataProvenance.localSupplementary,
      complete: false,
    );

    expect(
      Phase6bEvidenceReconciler.preferCanonical(
        canonical: canonical,
        finalizedEvent: event,
        local: local,
      )?.value,
      'chain storage',
    );
    expect(
      Phase6bEvidenceReconciler.preferCanonical(
        finalizedEvent: event,
        local: local,
      )?.value,
      'event',
    );
  });

  test('rejects an unbounded scan', () async {
    expect(
      () => Phase6bChainReconciler(
        _FakeSource(head: 10),
      ).reconcile(blockLookback: Phase6bChainReconciler.maximumLookback + 1),
      throwsArgumentError,
    );
  });
}

class _FakeSource implements Phase6bFinalizedChainSource {
  final int head;
  final Set<int> unavailable;

  _FakeSource({required this.head, this.unavailable = const {}});

  @override
  Future<FinalizedBlockReference> latestFinalized() async =>
      FinalizedBlockReference(number: head, hash: '0x$head');

  @override
  Future<Phase6bBlockEvents> eventsAt(int blockNumber) async {
    if (unavailable.contains(blockNumber)) {
      throw StateError('pruned state');
    }
    final block = FinalizedBlockReference(
      number: blockNumber,
      hash: '0x$blockNumber',
    );
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      blockNumber * 1000,
      isUtc: true,
    );
    return Phase6bBlockEvents(
      block: block,
      timestamp: timestamp,
      events: [
        Phase6bFinalizedEvent(
          blockNumber: blockNumber,
          blockHash: block.hash,
          timestamp: timestamp,
          extrinsicIndex: 1,
          eventIndex: 2,
          pallet: 'AiPredictions',
          event: 'ModelRegistered',
          fields: {'modelId': '$blockNumber'},
        ),
      ],
    );
  }
}
