import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';

import 'era_scaffold.dart';

const _eraIconPath = 'assets/images/era_icon.png';

String? validatedPublicAccountAddress(String? value) {
  final candidate = value?.trim();
  if (candidate == null ||
      candidate.isEmpty ||
      candidate.contains(RegExp(r'\s'))) {
    return null;
  }
  try {
    final accountId = Keyring().decodeAddress(candidate);
    return accountId.length == 32 ? candidate : null;
  } catch (_) {
    return null;
  }
}

String? normalizeRecipientQrPayload(String? rawValue) {
  final value = rawValue?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri != null) {
    for (final key in const ['address', 'to', 'recipient']) {
      final address = validatedPublicAccountAddress(uri.queryParameters[key]);
      if (address != null) return address;
    }

    if (uri.scheme.isNotEmpty) {
      final pathAddress = validatedPublicAccountAddress(
        uri.path.replaceFirst(RegExp(r'^/+'), ''),
      );
      if (pathAddress != null) return pathAddress;

      final hostAddress = validatedPublicAccountAddress(uri.host);
      if (hostAddress != null) return hostAddress;
    }
  }

  return validatedPublicAccountAddress(value);
}

bool recipientQrScannerSupported({TargetPlatform? platform, bool? web}) {
  if (web ?? kIsWeb) return true;
  return switch (platform ?? defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

String recipientQrScannerErrorMessage(MobileScannerErrorCode code) {
  if (code == MobileScannerErrorCode.permissionDenied) {
    return 'Camera permission was denied. Allow camera access in system settings and reopen the scanner.';
  }
  return 'The camera scanner is unavailable (${code.name}). You can go back and paste the recipient address.';
}

Future<String?> showRecipientQrScanner(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => const RecipientQrScannerScreen()),
  );
}

class RecipientQrScannerScreen extends StatefulWidget {
  const RecipientQrScannerScreen({super.key});

  @override
  State<RecipientQrScannerScreen> createState() =>
      _RecipientQrScannerScreenState();
}

class _RecipientQrScannerScreenState extends State<RecipientQrScannerScreen> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handledScan = false;
  String? _validationError;

  void _handleDetection(BarcodeCapture capture) {
    if (_handledScan) return;

    for (final barcode in capture.barcodes) {
      final address = normalizeRecipientQrPayload(barcode.rawValue);
      if (address == null) continue;
      _handledScan = true;
      Navigator.of(context).pop(address);
      return;
    }

    if (mounted && _validationError == null) {
      setState(() {
        _validationError =
            'This QR code does not contain a valid public account address.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            Image.asset(_eraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Scan Address QR'),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  recipientQrScannerErrorMessage(error.errorCode),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Center(
            child: IgnorePointer(
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
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _validationError ??
                      'Point the camera at a public recipient address QR code.',
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
