import 'dart:convert';

import 'package:era_wallet/account_qr_dialog.dart';
import 'package:era_wallet/main.dart' as wallet;
import 'package:era_wallet/recipient_qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const publicAddress = '5Gzp5Kcgkg42WQ1LoWfrV9icX6HE7ZssCRT1eB4GESa1cy9X';
  const secondPublicAddress =
      '5F9L8YfBtFCwh8EBicuuwxYyeCnUsKf7seEtjvoEmhC5wvZm';

  Future<wallet.AccountManager> loadTwoPublicAccounts() async {
    FlutterSecureStorage.setMockInitialValues({
      'accounts_list': jsonEncode([
        {'id': 'first', 'name': 'First', 'address': publicAddress},
        {'id': 'second', 'name': 'Second', 'address': secondPublicAddress},
      ]),
      'active_account_id': 'first',
    });
    final accounts = wallet.AccountManager();
    await accounts.loadAccounts();
    return accounts;
  }

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('QR payload accepts a public address and rejects non-address input', () {
    expect(validatedPublicAccountAddress(publicAddress), publicAddress);
    expect(
      validatedPublicAccountAddress('not public account material'),
      isNull,
    );
    expect(normalizeRecipientQrPayload(null), isNull);
    expect(normalizeRecipientQrPayload('cancelled'), isNull);
    expect(
      normalizeRecipientQrPayload('era://pay?address=$publicAddress'),
      publicAddress,
    );
  });

  test('scanner support and permission errors are explicit', () {
    expect(
      recipientQrScannerSupported(platform: TargetPlatform.android, web: false),
      isTrue,
    );
    expect(
      recipientQrScannerSupported(platform: TargetPlatform.windows, web: false),
      isFalse,
    );
    expect(
      recipientQrScannerErrorMessage(MobileScannerErrorCode.permissionDenied),
      contains('permission was denied'),
    );
  });

  testWidgets(
    'displayed QR follows the selected account and contains only its address',
    (tester) async {
      final accounts = await loadTwoPublicAccounts();
      final first = accounts.accounts[0];
      final second = accounts.accounts[1];

      await tester.pumpWidget(
        ChangeNotifierProvider<wallet.AccountManager>.value(
          value: accounts,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<wallet.AccountManager>(
                builder: (context, manager, child) {
                  final selected = manager.active!;
                  return AccountQrCode(publicAddress: selected.address);
                },
              ),
            ),
          ),
        ),
      );

      expect(
        tester.widget<AccountQrCode>(find.byType(AccountQrCode)).publicAddress,
        first.address,
      );

      await accounts.setActive(second.id);
      await tester.pump();
      expect(
        tester.widget<AccountQrCode>(find.byType(AccountQrCode)).publicAddress,
        second.address,
      );
    },
  );

  testWidgets('active Accounts screen restores one QR entry per account', (
    tester,
  ) async {
    final accounts = await loadTwoPublicAccounts();

    await tester.pumpWidget(
      ChangeNotifierProvider<wallet.AccountManager>.value(
        value: accounts,
        child: const MaterialApp(home: wallet.AccountsScreen()),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Show address QR code'), findsNWidgets(2));
  });

  testWidgets('active Send screen exposes a platform-safe scanner entry', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: wallet.SendScreen()));
    expect(find.byTooltip('Scan recipient QR code'), findsOneWidget);
  });
}
