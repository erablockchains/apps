import 'dart:async';

import 'package:era_wallet/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart' as polkadart;

void main() {
  test(
    'does not expose a connected wallet before the ERA RPC is ready',
    () async {
      final readiness = Completer<polkadart.RpcResponse>();
      final provider = _FakeProvider(onSend: (_, _) => readiness.future);
      final wallet = EraWalletProvider(providerFactory: (_) => provider);

      final pending = wallet.connect();
      await Future<void>.delayed(Duration.zero);

      expect(wallet.connectionState, WalletConnectionState.connecting);
      expect(wallet.provider, isNull);
      expect(wallet.api, isNull);

      readiness.complete(polkadart.RpcResponse(id: 1, result: 'ERA'));
      await pending;

      expect(wallet.connectionState, WalletConnectionState.connected);
      expect(wallet.provider, same(provider));
      expect(wallet.api, isNotNull);
      expect(provider.methods, ['system_chain']);
    },
  );

  test('rejects a provider whose readiness stream ended empty', () async {
    final provider = _FakeProvider(
      onSend: (_, _) => Future.error(StateError('No element')),
    );
    final wallet = EraWalletProvider(providerFactory: (_) => provider);

    await wallet.connect();

    expect(wallet.connectionState, WalletConnectionState.error);
    expect(wallet.provider, isNull);
    expect(wallet.api, isNull);
    expect(provider.disconnectCount, 1);
    expect(wallet.connectionError, contains('ERA RPC readiness check failed'));
  });

  test('replaces a stale connected provider before returning ready', () async {
    var firstReady = true;
    final first = _FakeProvider(
      onSend: (_, _) async => firstReady
          ? polkadart.RpcResponse(id: 1, result: 'ERA')
          : throw StateError('No element'),
    );
    final second = _FakeProvider(
      onSend: (_, _) async => polkadart.RpcResponse(id: 2, result: 'ERA'),
    );
    final providers = [first, second];
    final wallet = EraWalletProvider(
      providerFactory: (_) => providers.removeAt(0),
    );
    await wallet.connect();
    firstReady = false;

    final ready = await wallet.ensureConnected();

    expect(ready, isTrue);
    expect(first.disconnectCount, 1);
    expect(wallet.provider, same(second));
    expect(wallet.connectionState, WalletConnectionState.connected);
  });
}

class _FakeProvider extends polkadart.Provider {
  _FakeProvider({required this.onSend});

  final Future<polkadart.RpcResponse> Function(
    String method,
    List<dynamic> params,
  )
  onSend;
  final List<String> methods = [];
  int disconnectCount = 0;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {
    disconnectCount++;
  }

  @override
  bool isConnected() => disconnectCount == 0;

  @override
  Future<polkadart.RpcResponse> send(String method, List<dynamic> params) {
    methods.add(method);
    return onSend(method, params);
  }

  @override
  Future<polkadart.SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) => throw UnsupportedError('Subscriptions are not used by this test.');
}
