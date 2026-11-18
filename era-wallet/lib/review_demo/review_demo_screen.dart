import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../recipient_qr_scanner.dart';
import 'demo_session.dart';

/// An optional review aid. It never reads a wallet, key, RPC or chain state.
/// Every example resets when this screen is closed.
class ReviewDemoScreen extends StatefulWidget {
  const ReviewDemoScreen({super.key});

  @override
  State<ReviewDemoScreen> createState() => _ReviewDemoScreenState();
}

class _ReviewDemoScreenState extends State<ReviewDemoScreen> {
  static const _sections = [
    'Home',
    'Accounts',
    'Send / QR',
    'Staking',
    'NFT read',
    'Rewards',
    'Demo controls',
  ];

  DemoSession _demo = DemoSession();
  final _recipient = TextEditingController(text: DemoSession.recipient);
  final _amount = TextEditingController(text: '1');
  final _collection = TextEditingController(text: '9001');
  final _item = TextEditingController(text: '1');
  int _section = 0;
  bool _feeEstimated = false;
  bool _nftLoaded = false;
  bool _rewardInspected = false;

  @override
  void dispose() {
    _recipient.dispose();
    _amount.dispose();
    _collection.dispose();
    _item.dispose();
    super.dispose();
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDemoQr() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Synthetic address QR'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: DemoSession.address,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'DEMO ONLY — this is not a valid destination for real funds.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQr() async {
    if (!recipientQrScannerSupported()) {
      _notice('Camera scanning is unavailable on this device.');
      return;
    }
    final result = await showRecipientQrScanner(context);
    if (!mounted || result == null) return;
    setState(() => _recipient.text = result);
    _notice('Scanned address is held only in this demonstration.');
  }

  Future<void> _reviewSend() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0 || !amount.isFinite) {
      _notice('Enter a positive synthetic amount.');
      return;
    }
    final to = _recipient.text.trim();
    if (to.isEmpty) {
      _notice('Enter a demo recipient.');
      return;
    }
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review synthetic transfer'),
        content: Text(
          'Recipient: $to\nAmount: ${amount.toStringAsFixed(2)} demo ETKN\n'
          'Illustrative fee: ${DemoSession.fee.toStringAsFixed(2)} demo ETKN\n\n'
          'This simulates signing and finality. It creates no signature and '
          'broadcasts no transaction.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simulate sign and finality'),
          ),
        ],
      ),
    );
    if (!mounted || approved != true) return;
    final error = _demo.send(to: to, amount: amount);
    setState(() {});
    _notice(error ?? 'Synthetic transfer finalized locally. No broadcast.');
  }

  Future<void> _reviewReward() async {
    if (!_rewardInspected) {
      _notice('Inspect the synthetic eligibility page first.');
      return;
    }
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review synthetic reward claim'),
        content: const Text(
          'Simulate a 0.50 demo ETKN reward claim for completed demo era 42. '
          'No key, signature, network fee or chain transaction is used.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simulate claim'),
          ),
        ],
      ),
    );
    if (!mounted || approved != true) return;
    final error = _demo.claimReward();
    setState(() {});
    _notice(error ?? 'Synthetic claim finalized locally. No broadcast.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('ERA Wallet demonstration'),
        actions: [
          IconButton(
            tooltip: 'Leave demonstration',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFFE4A8),
              padding: const EdgeInsets.all(12),
              child: const Text(
                'SYNTHETIC DEMO · No real wallet, funds, keys, signatures or '
                'chain transactions. Closing this screen discards demo state.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < _sections.length; i++)
                    ChoiceChip(
                      label: Text(_sections[i]),
                      selected: _section == i,
                      onSelected: (_) => setState(() => _section = i),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: IndexedStack(
                    index: _section,
                    children: [
                      _home(),
                      _accounts(),
                      _send(),
                      _staking(),
                      _nft(),
                      _rewards(),
                      _controls(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _home() => ListView(
    key: const Key('demo-home'),
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Wallet Home — synthetic example',
        style: TextStyle(fontSize: 22),
      ),
      const SizedBox(height: 12),
      Text(
        _demo.connected
            ? 'Demo RPC: connected (simulated)'
            : 'Demo RPC: offline',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          OutlinedButton(
            onPressed: () => setState(() => _demo.connected = !_demo.connected),
            child: Text(
              _demo.connected ? 'Simulate disconnect' : 'Simulate reconnect',
            ),
          ),
          TextButton(
            onPressed: () => setState(() {}),
            child: const Text('Refresh demo balance'),
          ),
        ],
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _demo.activeAccount,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SelectableText(DemoSession.address),
              Text(
                'Synthetic available: ${_demo.available.toStringAsFixed(2)} demo ETKN',
              ),
              TextButton.icon(
                onPressed: _showDemoQr,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Show synthetic address QR'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Synthetic activity',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (_demo.activity.isEmpty) const Text('No demo action yet.'),
      for (final entry in _demo.activity) Text(entry),
    ],
  );

  Widget _controls() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('Demonstration controls', style: TextStyle(fontSize: 22)),
      const Text(
        'Version 1.2.1 / prototype build 12. All examples are synthetic. '
        'This page controls only the demo; it changes no real wallet settings.',
      ),
      FilledButton(
        onPressed: () => setState(() {
          _demo = DemoSession();
          _recipient.text = DemoSession.recipient;
          _amount.text = '1';
          _collection.text = '9001';
          _item.text = '1';
          _feeEstimated = false;
          _nftLoaded = false;
          _rewardInspected = false;
          _section = 0;
        }),
        child: const Text('Reset synthetic demo'),
      ),
      OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Exit demo to ordinary wallet'),
      ),
      const Text(
        'The ordinary wallet uses the local PIN and device authentication. '
        'No PIN or recovery phrase is needed or accepted in this demo.',
      ),
    ],
  );

  Widget _accounts() => ListView(
    key: const Key('demo-accounts'),
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Accounts — synthetic examples',
        style: TextStyle(fontSize: 22),
      ),
      const SizedBox(height: 8),
      const Text(
        'The real first-run flow creates a local PIN and a new BIP39 account; '
        'the real import flow validates a phrase. This demo never asks for, '
        'generates or stores a phrase or PIN. Use Back to test real local setup.',
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () => setState(() {
              _demo.createAccount();
            }),
            child: const Text('Create synthetic account'),
          ),
          OutlinedButton(
            onPressed: () => setState(() {
              _demo.importFixture();
            }),
            child: const Text('Simulate import from fixture'),
          ),
        ],
      ),
      for (final name in _demo.accounts)
        ListTile(
          title: Text(name),
          subtitle: const Text(DemoSession.address),
          selected: name == _demo.activeAccount,
          trailing: name == _demo.activeAccount
              ? const Icon(Icons.check_circle)
              : null,
          onTap: () => setState(() => _demo.activeAccount = name),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Return to real PIN / wallet flow'),
      ),
    ],
  );

  Widget _send() => ListView(
    key: const Key('demo-send'),
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Send Funds — synthetic example',
        style: TextStyle(fontSize: 22),
      ),
      const SizedBox(height: 8),
      const Text('No entered recipient or amount leaves this screen.'),
      const SizedBox(height: 12),
      TextField(
        controller: _recipient,
        decoration: const InputDecoration(
          labelText: 'Demo recipient',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Amount (demo ETKN)',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: _scanQr,
            child: const Text('Open QR scanner (camera)'),
          ),
          TextButton(
            onPressed: () =>
                setState(() => _recipient.text = DemoSession.recipient),
            child: const Text('Use synthetic recipient'),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () => setState(() => _feeEstimated = true),
            child: const Text('Estimate illustrative fee'),
          ),
          FilledButton(
            onPressed: _reviewSend,
            child: const Text('Review synthetic transfer'),
          ),
        ],
      ),
      if (_feeEstimated)
        const Text(
          'Illustrative fee: 0.01 demo ETKN. Not a live ERA estimate.',
        ),
    ],
  );

  Widget _staking() => ListView(
    key: const Key('demo-staking'),
    padding: const EdgeInsets.all(16),
    children: [
      const Text('Staking — synthetic example', style: TextStyle(fontSize: 22)),
      const SizedBox(height: 8),
      Text('Bonded: ${_demo.bonded.toStringAsFixed(2)} demo ETKN'),
      Text(
        'Pending unbond: ${_demo.pendingUnbond.toStringAsFixed(2)} demo ETKN',
      ),
      const Text('Nominated validator: DEMO-VALIDATOR-NOT-ON-CHAIN'),
      const Text(
        'Real unbonding follows chain rules; this demo does not release funds.',
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () {
              final error = _demo.bond(1);
              setState(() {});
              _notice(
                error ?? 'Synthetic bond and nomination recorded locally.',
              );
            },
            child: const Text('Simulate Bond & Nominate 1'),
          ),
          OutlinedButton(
            onPressed: () {
              final error = _demo.unbond(1);
              setState(() {});
              _notice(error ?? 'Synthetic unbond queued locally.');
            },
            child: const Text('Simulate Unbond 1'),
          ),
        ],
      ),
    ],
  );

  Widget _nft() => ListView(
    key: const Key('demo-nft'),
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'NFT read — synthetic example',
        style: TextStyle(fontSize: 22),
      ),
      const SizedBox(height: 8),
      const Text(
        'iOS build 11 offers NFT read only; it has no NFT trading controls.',
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _collection,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Demo collection',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _item,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Demo item',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: () {
          final matches =
              _collection.text.trim() == '9001' && _item.text.trim() == '1';
          setState(() => _nftLoaded = matches);
          if (!matches) {
            _notice('No synthetic item at those demo IDs. Try 9001 / 1.');
          }
        },
        child: const Text('Read synthetic NFT'),
      ),
      if (_nftLoaded) ...[
        const SizedBox(height: 12),
        const Text('Owner: Demo Reviewer (synthetic)'),
        const Text('Selected demo account owns it: true'),
        const Text('Metadata: ERA synthetic review item; text only.'),
        const Text(
          'No IPFS request, finalized block or on-chain ownership is claimed.',
        ),
      ],
    ],
  );

  Widget _rewards() => ListView(
    key: const Key('demo-rewards'),
    padding: const EdgeInsets.all(16),
    children: [
      const Text('Rewards — synthetic example', style: TextStyle(fontSize: 22)),
      const SizedBox(height: 8),
      const Text('Completed era: 42 (synthetic)'),
      const Text('Historical validator: DEMO-VALIDATOR-NOT-ON-CHAIN'),
      const Text('Exposure page: 0 (synthetic)'),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () => setState(() => _rewardInspected = true),
        child: const Text('Inspect synthetic eligibility'),
      ),
      if (_rewardInspected) ...[
        const Text('Eligibility: true (synthetic fixture)'),
        Text('Claimed: ${_demo.rewardClaimed ? 'yes' : 'no'} (synthetic)'),
      ],
      FilledButton(
        onPressed: _reviewReward,
        child: const Text('Review synthetic claim'),
      ),
      const Text(
        'The live wallet checks a finalized reward page before any real claim.',
      ),
    ],
  );
}
