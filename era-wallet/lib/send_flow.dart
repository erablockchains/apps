import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:provider/provider.dart' as flutter_provider;

import 'accounts_flow.dart';
import 'auth_flow.dart';
import 'era_chain.dart';
import 'era_scaffold.dart';
import 'transfer_history.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  BigInt? _estimatedFee;
  bool _estimating = false;
  bool _sending = false;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _estimateFee() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final am = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      final acc = am.active;

      if (acc == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
        return;
      }

      final amount = parseEraToUnits(_amountController.text.trim());
      if (amount == null || amount <= BigInt.zero) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Invalid amount')),
        );
        return;
      }

      final connected = await chain.ensureConnected();
      if (!connected || chain.provider == null || chain.api == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
        return;
      }

      if (!mounted) return;
      final auth = await authenticateWalletForSensitiveAction(
        context,
        reason: 'Authenticate to estimate fee for this transfer',
      );
      if (!context.mounted || !auth.success) {
        return;
      }

      String? accountMnemonic = await am.loadMnemonicForAccount(acc.id);

      if (accountMnemonic == null) {
        debugPrint('FEE: no per-account mnemonic, trying legacy migration...');
        final legacy = await _tryLoadLegacyMnemonicForAccount(
          pin: auth.pin,
          accountAddress: acc.address,
        );
        if (legacy != null) {
          await am.storeMnemonicForAccount(acc.id, legacy, revealOnce: false);
          accountMnemonic = legacy;
        }
      }

      if (accountMnemonic == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'No mnemonic stored for this account on this device.\n'
              'Please remove and re-add this account (with its seed phrase) to enable fee estimation and sending.',
            ),
          ),
        );
        return;
      }

      final trimmedMnemonic = accountMnemonic.trim();
      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Stored seed phrase for this account is not a valid BIP39 mnemonic.\n'
              'Please remove this account and re-import it with the correct phrase.',
            ),
          ),
        );
        return;
      }

      final keyring = Keyring();
      final signerWallet = await keyring.fromMnemonic(trimmedMnemonic);
      if (signerWallet.address != acc.address) {
        if (!context.mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Stored mnemonic for this account does not match its address.\n'
              'Please remove and re-add the account with the correct seed.',
            ),
          ),
        );
        return;
      }

      setState(() => _estimating = true);
      try {
        final txService = TxService(chain.provider!, chain.api!);
        final fee = await txService.estimateFee(
          fromMnemonic: trimmedMnemonic,
          toAddress: _toController.text.trim(),
          amount: amount,
        );

        if (!mounted) return;

        if (fee == null) {
          _estimatedFee = null;
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Fee estimation not available (node did not return partialFee).',
              ),
            ),
          );
        } else {
          setState(() => _estimatedFee = fee);
        }
      } finally {
        if (mounted) setState(() => _estimating = false);
      }
    } catch (e, st) {
      debugPrint('FEE: unexpected error: $e');
      debugPrint('FEE: stack: $st');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Unexpected fee estimation error: $e')),
      );
    }
  }

  String _normalizeScannedAddress(String rawValue) {
    final value = rawValue.trim();
    final uri = Uri.tryParse(value);

    if (uri != null) {
      for (final key in const ['address', 'to', 'recipient']) {
        final address = uri.queryParameters[key]?.trim();
        if (address != null && address.isNotEmpty) {
          return address;
        }
      }

      if (uri.scheme.isNotEmpty && uri.path.trim().isNotEmpty) {
        return uri.path.trim();
      }
    }

    return value.split(RegExp(r'\s+')).first.trim();
  }

  Future<void> _scanRecipientAddress() async {
    final scannedValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const RecipientQrScannerScreen()),
    );
    if (!mounted || scannedValue == null) return;

    final address = _normalizeScannedAddress(scannedValue);
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No address found in QR code')),
      );
      return;
    }

    setState(() {
      _toController.text = address;
      _toController.selection = TextSelection.collapsed(
        offset: _toController.text.length,
      );
      _estimatedFee = null;
    });
  }

  Future<void> _pasteRecipientAddress() async {
    final messenger = ScaffoldMessenger.of(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;

    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Clipboard does not contain an address')),
      );
      return;
    }

    final address = _normalizeScannedAddress(text);
    if (address.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No address found on clipboard')),
      );
      return;
    }

    setState(() {
      _toController.text = address;
      _toController.selection = TextSelection.collapsed(
        offset: _toController.text.length,
      );
      _estimatedFee = null;
    });
  }

  Future<void> _copyRecipientAddress() async {
    final messenger = ScaffoldMessenger.of(context);
    final address = _toController.text.trim();
    if (address.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Recipient address is empty')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Recipient address copied')),
    );
  }

  Future<String?> _tryLoadLegacyMnemonicForAccount({
    required String? pin,
    required String accountAddress,
  }) async {
    if (pin == null || pin.isEmpty) {
      return null;
    }

    try {
      final saltB64 = await secureStorage.read(key: StorageKeys.pinSalt);
      final blob = await secureStorage.read(key: StorageKeys.mnemonicBlob);
      final nonce = await secureStorage.read(key: StorageKeys.mnemonicNonce);

      if (saltB64 == null || blob == null || nonce == null) {
        debugPrint('SEND: no legacy mnemonic blob/nonce found.');
        return null;
      }

      final salt = base64Decode(saltB64);
      final key = await PinCrypto.deriveKeyFromPin(pin, salt);
      final mnemonic = await PinCrypto.decryptLegacyMnemonic(blob, nonce, key);
      final trimmed = mnemonic.trim();

      if (!bip39.validateMnemonic(trimmed)) {
        debugPrint('SEND: legacy mnemonic failed BIP39 validation.');
        return null;
      }

      final keyring = Keyring();
      final wallet = await keyring.fromMnemonic(trimmed);

      debugPrint('SEND: legacy mnemonic address: ${wallet.address}');

      if (wallet.address != accountAddress) {
        debugPrint(
          'SEND: legacy mnemonic address does not match active account.',
        );
        return null;
      }

      debugPrint('SEND: legacy mnemonic MATCHES active account, migrating.');
      return trimmed;
    } catch (e) {
      debugPrint('SEND: legacy mnemonic decrypt/match failed: $e');
      return null;
    }
  }

  Future<void> _send() async {
    debugPrint('SEND: tapped');

    try {
      final messenger = ScaffoldMessenger.of(context);
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final am = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      final history = flutter_provider.Provider.of<TransferHistoryStore>(
        context,
        listen: false,
      );
      final acc = am.active;

      if (acc == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
        return;
      }

      final amount = parseEraToUnits(_amountController.text.trim());
      if (amount == null || amount <= BigInt.zero) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Invalid amount')),
        );
        return;
      }

      debugPrint('SEND: ensuring connection...');
      final connected = await chain.ensureConnected();
      if (!connected || chain.provider == null || chain.api == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
        return;
      }

      debugPrint('SEND: authenticating...');
      if (!mounted) return;
      final auth = await authenticateWalletForSensitiveAction(
        context,
        reason: 'Authenticate to send $kTokenSymbol',
      );
      if (!context.mounted || !auth.success) {
        debugPrint('SEND: auth failed/cancelled');
        return;
      }

      String? accountMnemonic = await am.loadMnemonicForAccount(acc.id);
      if (accountMnemonic == null) {
        debugPrint('SEND: no per-account mnemonic, trying legacy migration...');
        final legacy = await _tryLoadLegacyMnemonicForAccount(
          pin: auth.pin,
          accountAddress: acc.address,
        );
        if (legacy != null) {
          await am.storeMnemonicForAccount(acc.id, legacy, revealOnce: false);
          accountMnemonic = legacy;
        }
      }

      if (accountMnemonic == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'No mnemonic stored for this account on this device.\n'
              'Please remove and re-add this account (with its seed phrase) to enable sending.',
            ),
          ),
        );
        return;
      }

      final trimmedMnemonic = accountMnemonic.trim();
      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Stored seed phrase for this account is not a valid BIP39 mnemonic.\n'
              'Please remove this account and re-import it with the correct phrase.',
            ),
          ),
        );
        debugPrint(
          'SEND: invalid BIP39 mnemonic for active account, aborting send.',
        );
        return;
      }

      final keyring = Keyring();
      final signerWallet = await keyring.fromMnemonic(trimmedMnemonic);

      debugPrint('SEND: UI active address: ${acc.address}');
      debugPrint('SEND: signer address:    ${signerWallet.address}');

      if (signerWallet.address != acc.address) {
        if (!context.mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Stored mnemonic for this account does not match its address.\n'
              'Please remove and re-add the account with the correct seed.',
            ),
          ),
        );
        return;
      }

      setState(() => _sending = true);
      try {
        debugPrint('SEND: building and submitting extrinsic...');
        final txService = TxService(chain.provider!, chain.api!);
        final hash = await txService.sendTransfer(
          fromMnemonic: trimmedMnemonic,
          toAddress: _toController.text.trim(),
          amount: amount,
        );
        if (!mounted) return;

        final recipientAddress = _toController.text.trim();
        await history.recordSubmittedSend(
          fromAddress: acc.address,
          toAddress: recipientAddress,
          amount: amount,
          txHash: hash,
        );

        for (final account in am.accounts) {
          if (account.address == recipientAddress &&
              account.address != acc.address) {
            await history.recordSubmittedReceive(
              accountAddress: account.address,
              fromAddress: acc.address,
              amount: amount,
              txHash: hash,
            );
            break;
          }
        }

        final msg = 'Transaction submitted: $hash';
        debugPrint('SEND: $msg');

        messenger.showSnackBar(SnackBar(content: Text(msg)));
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        debugPrint('SEND: sendTransfer threw: $e');
        messenger.showSnackBar(
          SnackBar(content: Text('Send failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _sending = false);
      }
    } catch (e, st) {
      debugPrint('SEND: unexpected error: $e');
      debugPrint('SEND: stack: $st');
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Unexpected send error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Send Funds'),
          ],
        ),
      ),
      body: ListView(
        children: [
          TextField(
            controller: _toController,
            decoration: InputDecoration(
              labelText: 'Recipient Address',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Scan QR code',
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanRecipientAddress,
                  ),
                  IconButton(
                    tooltip: 'Paste address',
                    icon: const Icon(Icons.content_paste),
                    onPressed: _pasteRecipientAddress,
                  ),
                  IconButton(
                    tooltip: 'Copy address',
                    icon: const Icon(Icons.copy),
                    onPressed: _copyRecipientAddress,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (ETKN)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (_estimatedFee != null)
            Text(
              'Estimated Fee: ${formatEra(_estimatedFee)} $kTokenSymbol',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _estimating ? null : _estimateFee,
                  child: Text(_estimating ? 'Estimating...' : 'Estimate Fee'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _sending ? null : _send,
                  child: Text(_sending ? 'Sending...' : 'Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecipientQrScannerScreen extends StatefulWidget {
  const RecipientQrScannerScreen({super.key});

  @override
  State<RecipientQrScannerScreen> createState() =>
      _RecipientQrScannerScreenState();
}

class _RecipientQrScannerScreenState extends State<RecipientQrScannerScreen> {
  bool _handledScan = false;

  void _handleDetection(BarcodeCapture capture) {
    if (_handledScan) return;

    final value = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .firstOrNull;

    if (value == null) return;

    _handledScan = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Scan Address QR'),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: MobileScannerController(
              formats: const [BarcodeFormat.qrCode],
            ),
            onDetect: _handleDetection,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Point the camera at the recipient address QR code.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
