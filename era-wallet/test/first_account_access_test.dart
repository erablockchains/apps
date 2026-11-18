import 'dart:async';

import 'package:era_wallet/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _PendingAccount extends AccountManager {
  final account = WalletAccount(
    id: 'offline-review-fixture',
    name: 'Offline review fixture',
    address: 'synthetic-unfunded-address',
  );
  bool pending = true;

  @override
  WalletAccount get active => account;

  @override
  List<WalletAccount> get accounts => [account];

  @override
  String? getPendingRevealMnemonic(String accountId) => pending
      ? 'Fixture text only; not a valid mnemonic or signing key.'
      : null;

  @override
  void clearAllPendingRevealMnemonics() {
    pending = false;
  }
}

class _StalledRpc extends EraWalletProvider {
  final connection = Completer<void>();

  @override
  Future<void> connect({String? wsEndpoint}) => connection.future;
}

void main() {
  testWidgets('first-account recovery access does not await RPC', (
    tester,
  ) async {
    final accounts = _PendingAccount();
    final rpc = _StalledRpc();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AccountManager>.value(value: accounts),
          ChangeNotifierProvider<EraWalletProvider>.value(value: rpc),
        ],
        child: const MaterialApp(home: WalletHomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(rpc.connection.isCompleted, isFalse);
    expect(find.byType(AccountsScreen), findsOneWidget);
    expect(accounts.pending, isTrue);
    expect(find.text('Mnemonic (save now, shown only once):'), findsOneWidget);
    expect(find.text('Offline review fixture'), findsOneWidget);

    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(accounts.pending, isFalse);
    expect(find.text('Mnemonic (save now, shown only once):'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    rpc.connection.complete();
    await tester.pump();
    accounts.dispose();
    rpc.dispose();
  });
}
