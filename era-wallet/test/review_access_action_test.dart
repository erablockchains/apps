import 'dart:async';
import '../integration_test/review_access_actions.dart';

import 'package:era_wallet/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _RecordingAccounts extends AccountManager {
  int creations = 0;
  final completion = Completer<WalletAccount>();

  @override
  Future<WalletAccount> addAccount({required String name, String? mnemonic}) {
    creations++;
    return completion.future;
  }
}

void main() {
  for (final size in [const Size(800, 600), const Size(834, 1194)]) {
    testWidgets('review create action invokes account creation at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final accounts = _RecordingAccounts();
      await tester.pumpWidget(
        ChangeNotifierProvider<AccountManager>.value(
          value: accounts,
          child: const MaterialApp(home: AddAccountScreen()),
        ),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Account Name'),
        'Disposable review',
      );
      expect(find.text('Create Account'), findsNWidgets(3));
      await tapCreateAccountAction(tester);
      await tester.pump();
      expect(
        accounts.creations,
        1,
        reason: 'The real action must run, not a heading tap.',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      accounts.completion.complete(
        WalletAccount(
          id: 'synthetic',
          name: 'Disposable',
          address: 'unfunded-test-fixture',
        ),
      );
      await tester.pump();
      accounts.dispose();
    });
  }
}
