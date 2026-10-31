import 'dart:async';

import 'package:era_wallet/generated/era/era.dart' as era_api;
import 'package:era_wallet/v14/v14_operations_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart' as polkadart;

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('NFT trade controls on $platform', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      final provider = _NoopProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: V14OperationsScreen(
            provider: provider,
            api: era_api.Era(provider),
            selectedAccount: 'synthetic-account',
            authenticateAndLoadMnemonic: (_) async => 'synthetic-only',
          ),
        ),
      );

      expect(find.text('NFT read'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(
        find.text('NFT actions'),
        platform == TargetPlatform.iOS ? findsNothing : findsOneWidget,
      );
      if (platform == TargetPlatform.android) {
        await tester.tap(find.text('NFT actions'));
        await tester.pumpAndSettle();
        expect(find.text('Estimate, review and sign once'), findsOneWidget);
      }
      debugDefaultTargetPlatformOverride = null;
    });
  }
}

class _NoopProvider extends polkadart.Provider {
  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  bool isConnected() => true;

  @override
  Future<polkadart.RpcResponse> send(String method, List<dynamic> params) =>
      throw UnimplementedError();

  @override
  Future<polkadart.SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) => throw UnimplementedError();
}
