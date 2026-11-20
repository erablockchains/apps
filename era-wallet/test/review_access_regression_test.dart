import 'package:era_wallet/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _MemoryKeyStore extends KeyStore {
  bool ready = false;
  bool open = true;
  @override
  bool get hasWallet => ready;
  @override
  bool get unlocked => open;
  @override
  void lock() => open = false;
}

void main() {
  testWidgets(
    'leaving Accounts clears reveal without a disposal notification error',
    (tester) async {
      final accounts = AccountManager();
      await tester.pumpWidget(
        ChangeNotifierProvider<AccountManager>.value(
          value: accounts,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AccountsScreen(),
                    ),
                  ),
                  child: const Text('Open accounts'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open accounts'));
      await tester.pumpAndSettle();
      accounts.markMnemonicForReveal(
        'synthetic',
        'Not a mnemonic or signing key.',
      );
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(accounts.getPendingRevealMnemonic('synthetic'), isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      accounts.dispose();
    },
  );

  testWidgets(
    'more than one minute in background locks after the full resume sequence',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({'has_seen_splash': 'true'});
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final keyStore = _MemoryKeyStore();
      await tester.pumpWidget(
        ChangeNotifierProvider<KeyStore>.value(
          value: keyStore,
          child: const EraWalletApp(),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(PinSetupScreen), findsOneWidget);
      keyStore.ready = true;
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 62)),
      );
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        keyStore.open,
        isFalse,
        reason: 'Resume transitions must preserve elapsed background time.',
      );
      expect(find.text('ERA Wallet — Unlock'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      keyStore.dispose();
    },
  );
}
