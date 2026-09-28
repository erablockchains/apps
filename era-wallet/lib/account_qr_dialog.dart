import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'recipient_qr_scanner.dart';

Future<void> showAccountQrDialog({
  required BuildContext context,
  required String accountName,
  required String address,
}) {
  final publicAddress = validatedPublicAccountAddress(address);
  if (publicAddress == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This account does not contain a valid public address.'),
      ),
    );
    return Future.value();
  }
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(accountName),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AccountQrCode(publicAddress: publicAddress),
            ),
            const SizedBox(height: 16),
            SelectableText(
              publicAddress,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy address'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: publicAddress));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Address copied: $accountName')),
            );
          },
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class AccountQrCode extends StatelessWidget {
  final String publicAddress;

  const AccountQrCode({super.key, required this.publicAddress});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: publicAddress,
      version: QrVersions.auto,
      size: 220,
      backgroundColor: Colors.white,
    );
  }
}

class AccountQrButton extends StatelessWidget {
  final String accountName;
  final String address;
  final double iconSize;

  const AccountQrButton({
    super.key,
    required this.accountName,
    required this.address,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.qr_code_2, size: iconSize),
      tooltip: 'Show address QR code',
      onPressed: () => showAccountQrDialog(
        context: context,
        accountName: accountName,
        address: address,
      ),
    );
  }
}
