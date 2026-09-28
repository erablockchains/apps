import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../era_scaffold.dart';
import 'transaction_lifecycle.dart';

class FinalizedTransactionReceiptScreen extends StatelessWidget {
  final TransactionLifecycleRecord record;
  final Uri? explorerUri;

  const FinalizedTransactionReceiptScreen({
    super.key,
    required this.record,
    this.explorerUri,
  });

  @override
  Widget build(BuildContext context) {
    final uncertain =
        record.state == TransactionLifecycleState.unknownNeedsVerification;
    final failed = record.state == TransactionLifecycleState.failed;
    final color = uncertain
        ? Colors.orange
        : failed
        ? Colors.red
        : Colors.green;
    return EraScaffold(
      appBar: AppBar(
        title: const Text('Transaction Receipt'),
        actions: [
          IconButton(
            tooltip: 'Copy receipt',
            icon: const Icon(Icons.copy_all),
            onPressed: () => _copy(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            color: color.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    uncertain
                        ? Icons.help_outline
                        : failed
                        ? Icons.error_outline
                        : Icons.verified,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _stateLabel(record.state),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (uncertain)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Do not resubmit until this transaction is verified against '
                  'the chain. An ambiguous timeout does not prove failure.',
                ),
              ),
            ),
          _ReceiptCard(
            title: 'Call',
            rows: {
              'Exact path': '${record.pallet}.${record.call}',
              'Signer': record.signer,
              'Nonce': record.nonce?.toString() ?? 'Not assigned',
              'Arguments': const JsonEncoder.withIndent(
                '  ',
              ).convert(record.argumentsSummary),
            },
          ),
          _ReceiptCard(
            title: 'Chain evidence',
            rows: {
              'Transaction hash': record.txHash ?? 'Unavailable',
              'Submitted': record.submittedAt?.toIso8601String() ?? 'No',
              'Inclusion block': _block(record.inclusionBlock),
              'Finalized block': _block(record.finalityBlock),
              'Dispatch': record.dispatchResult?.status.name ?? 'Unknown',
              'Module error':
                  record.decodedModuleError?.qualifiedName ?? 'None',
              'Post-state': record.postStateVerification.status.name,
              if (explorerUri != null) 'Explorer': explorerUri.toString(),
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Relevant events',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (record.relevantEvents.isEmpty)
                    const Text('No decoded events are available.')
                  else
                    for (final event in record.relevantEvents)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${event.pallet}.${event.event}'),
                        subtitle: Text(jsonEncode(event.fields)),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: const JsonEncoder.withIndent('  ').convert(record.toJson()),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Redacted receipt copied.')));
  }
}

class _ReceiptCard extends StatelessWidget {
  final String title;
  final Map<String, String> rows;

  const _ReceiptCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final entry in rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    SelectableText(entry.value),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _block(BlockReference? block) =>
    block == null ? 'Unavailable' : '${block.number} (${block.hash})';

String _stateLabel(TransactionLifecycleState state) => switch (state) {
  TransactionLifecycleState.preparing => 'Preparing',
  TransactionLifecycleState.awaitingAuthentication => 'Awaiting authentication',
  TransactionLifecycleState.signing => 'Signing',
  TransactionLifecycleState.submitting => 'Submitting',
  TransactionLifecycleState.submitted => 'Submitted',
  TransactionLifecycleState.inBlock => 'In block',
  TransactionLifecycleState.finalized => 'Finalized',
  TransactionLifecycleState.succeeded => 'Succeeded and finalized',
  TransactionLifecycleState.failed => 'Failed',
  TransactionLifecycleState.unknownNeedsVerification =>
    'Unknown — needs verification',
};
