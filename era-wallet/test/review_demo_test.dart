import 'package:era_wallet/review_demo/demo_session.dart';
import 'package:era_wallet/review_demo/review_demo_screen.dart';
import 'package:era_wallet/main.dart' show KeyStore, PinSetupScreen;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  test(
    'synthetic state is disposable and rejects unfunded/offline actions',
    () {
      final demo = DemoSession();
      demo.createAccount();
      demo.importFixture();
      expect(demo.accounts.length, 3);
      demo.connected = false;
      expect(
        demo.send(to: DemoSession.recipient, amount: 1),
        contains('offline'),
      );
      expect(demo.available, 12);
      demo.connected = true;
      expect(
        demo.send(to: DemoSession.recipient, amount: 13),
        contains('Insufficient'),
      );
      expect(demo.send(to: DemoSession.recipient, amount: 1), isNull);
      expect(demo.available, closeTo(10.99, 0.000001));
      expect(demo.bond(1), isNull);
      expect(demo.bonded, 4);
      expect(demo.unbond(1), isNull);
      expect(demo.bonded, 3);
      expect(demo.pendingUnbond, 1);
      expect(demo.claimReward(), isNull);
      expect(demo.claimReward(), contains('already claimed'));
      final reopened = DemoSession();
      expect(reopened.available, 12);
      expect(reopened.accounts, ['Demo Reviewer']);
      expect(reopened.activity, isEmpty);
    },
  );

  for (final size in [const Size(834, 1194), const Size(1194, 834)]) {
    testWidgets('all demo sections fit 11-inch iPad $size viewport', (
      tester,
    ) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(const MaterialApp(home: ReviewDemoScreen()));
      expect(find.textContaining('SYNTHETIC DEMO'), findsOneWidget);
      for (final section in [
        'Home',
        'Accounts',
        'Send / QR',
        'Staking',
        'NFT read',
        'Rewards',
        'Demo controls',
      ]) {
        await tester.tap(find.widgetWithText(ChoiceChip, section));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Reset synthetic demo'), findsOneWidget);
    });
  }

  testWidgets('first-launch demo opens without setting a PIN or wallet', (
    tester,
  ) async {
    final keyStore = KeyStore();
    await tester.pumpWidget(
      ChangeNotifierProvider<KeyStore>.value(
        value: keyStore,
        child: const MaterialApp(home: PinSetupScreen()),
      ),
    );
    expect(find.text('Create PIN'), findsOneWidget);
    await tester.tap(find.text('Explore synthetic demo — no funds'));
    await tester.pumpAndSettle();
    expect(find.textContaining('SYNTHETIC DEMO'), findsOneWidget);
    expect(keyStore.hasWallet, isFalse);
    expect(keyStore.unlocked, isFalse);
  });

  testWidgets('reviewer can inspect synthetic funded flows without a wallet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(834, 1194) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const MaterialApp(home: ReviewDemoScreen()));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Send / QR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review synthetic transfer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('broadcasts no transaction'), findsOneWidget);
    await tester.tap(find.text('Simulate sign and finality'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Staking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate Bond & Nominate 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate Unbond 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pending unbond: 1.00'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'NFT read'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read synthetic NFT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ERA synthetic review item'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Rewards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inspect synthetic eligibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review synthetic claim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate claim'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Claimed: yes'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Home'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Synthetic available: 10.49'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Demo controls'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset synthetic demo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Synthetic available: 12.00'), findsOneWidget);
    expect(find.text('No demo action yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
