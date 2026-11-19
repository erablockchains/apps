import 'package:era_wallet/account_qr_dialog.dart';
import 'package:era_wallet/review_demo/review_demo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  const publicAddress = '5Gzp5Kcgkg42WQ1LoWfrV9icX6HE7ZssCRT1eB4GESa1cy9X';
  for (final size in [
    const Size(834, 1194),
    const Size(1194, 834),
    const Size(390, 844),
  ]) {
    void configure(WidgetTester tester) {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('synthetic QR dialog opens and closes at $size', (
      tester,
    ) async {
      configure(tester);
      await tester.pumpWidget(const MaterialApp(home: ReviewDemoScreen()));
      await tester.tap(find.text('Show synthetic address QR'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Synthetic address QR'), findsOneWidget);
      expect(tester.getSize(find.byType(QrImageView)), const Size(200, 200));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ordinary QR dialog opens and closes at $size', (tester) async {
      configure(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAccountQrDialog(
                  context: context,
                  accountName: 'Disposable public test address',
                  address: publicAddress,
                ),
                child: const Text('Open ordinary QR'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open ordinary QR'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Disposable public test address'), findsOneWidget);
      expect(tester.getSize(find.byType(QrImageView)), const Size(220, 220));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
