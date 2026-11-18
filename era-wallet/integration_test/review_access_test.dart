// Run only on a newly created disposable iOS simulator, never a personal device.
import 'dart:io';
import 'package:era_wallet/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('review access guide on clean disposable simulator', (
    tester,
  ) async {
    app.main();
    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 180 && finder.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(finder, findsWidgets);
    }

    Future<void> capture(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      final screenshot = await binding.takeScreenshot(name);
      // Persist each safe frame inside the disposable simulator immediately.
      // Keeping every PNG inside the final VM-service JSON loses all images
      // when a later assertion fails or that large response is interrupted.
      final directory = Directory(
        '${Directory.systemTemp.path}/era-review-access-captures',
      );
      await directory.create(recursive: true);
      await File(
        '${directory.path}/$name.png',
      ).writeAsBytes(screenshot, flush: true);
      (binding.reportData?['screenshots'] as List?)?.clear();
      // Only names, never PINs, phrases, keys or raw screenshots, enter logs.
      debugPrint('REVIEW_SAFE_CAPTURE_SAVED: $name');
    }

    Future<void> tap(String label) async {
      final finder = find.text(label);
      await waitFor(finder);
      await tester.ensureVisible(finder.first);
      await tester.tap(finder.first);
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> section(String label) async {
      await tester.tap(find.widgetWithText(ChoiceChip, label));
      await tester.pump(const Duration(milliseconds: 600));
    }

    await waitFor(find.text('Explore synthetic demo — no funds'));
    await capture('01-first-launch-no-pin');
    await tap('Explore synthetic demo — no funds');
    await capture('02-demo-home');
    await section('Accounts');
    await capture('03-demo-accounts');
    await section('Send / QR');
    await tap('Estimate illustrative fee');
    await capture('04-demo-send-fee');
    await tap('Review synthetic transfer');
    await capture('05-demo-transfer-review');
    await tap('Simulate sign and finality');
    await section('Home');
    await capture('06-demo-transfer-outcome');
    await section('Staking');
    await tap('Simulate Bond & Nominate 1');
    await tap('Simulate Unbond 1');
    await capture('07-demo-staking-outcome');
    await section('Rewards');
    await tap('Inspect synthetic eligibility');
    await capture('08-demo-reward-eligibility');
    await tap('Review synthetic claim');
    await tap('Simulate claim');
    await capture('09-demo-reward-outcome');
    await section('NFT read');
    await tap('Read synthetic NFT');
    await capture('10-demo-nft-read');
    await section('Demo controls');
    await capture('11-demo-controls');
    await tap('Reset synthetic demo');
    await section('Demo controls');
    await tap('Exit demo to ordinary wallet');
    await capture('12-ordinary-pin-setup-empty');
    // Never capture entered PINs or the generated recovery phrase.
    await tester.enterText(find.widgetWithText(TextField, 'PIN'), '738291');
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm PIN'),
      '738291',
    );
    await tap('Create PIN');
    await waitFor(find.text('Account Name'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Account Name'),
      'App Review disposable',
    );
    await capture('13-ordinary-create-account');
    await tester.tap(find.text('Create Account').last);
    await waitFor(find.text('Mnemonic (save now, shown only once):'));
    // Leave Accounts to clear its one-time phrase reveal before any capture.
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Mnemonic (save now, shown only once):'), findsNothing);
    await capture('14-ordinary-home-unfunded');
    await tester.tap(find.byTooltip('Accounts'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Mnemonic (save now, shown only once):'), findsNothing);
    await capture('15-ordinary-accounts-phrase-hidden');
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byTooltip('Send Funds'));
    await tester.pump(const Duration(seconds: 2));
    await capture('16-ordinary-send-unfunded');
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byTooltip('Staking'));
    await tester.pump(const Duration(seconds: 2));
    await capture('17-ordinary-staking-unfunded');
  });
}
