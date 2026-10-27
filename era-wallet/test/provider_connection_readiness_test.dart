import 'dart:async';
import 'dart:io';

import 'package:era_wallet/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:polkadart/polkadart.dart' as polkadart;

void main() {
  test('stalled connect and cleanup reach a bounded retryable error', () {
    fakeAsync((clock) {
      final stalled = _FakeProvider(
        onSend: (_, _) async => polkadart.RpcResponse(id: 1, result: 'ERA'),
        onConnect: () => Completer<void>().future,
        onDisconnect: () => Completer<void>().future,
      );
      final healthy = _FakeProvider(
        onSend: (_, _) async => polkadart.RpcResponse(id: 2, result: 'ERA'),
      );
      final providers = [stalled, healthy];
      final wallet = EraWalletProvider(
        providerFactory: (_) => providers.removeAt(0),
      );
      var completed = false;
      wallet.connect().then((_) => completed = true);
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 23));
      clock.flushMicrotasks();
      expect(completed, isTrue);
      expect(wallet.connectionState, WalletConnectionState.error);
      expect(wallet.connectionError, contains('TimeoutException'));
      expect(wallet.provider, isNull);
      wallet.connect();
      clock.flushMicrotasks();
      expect(wallet.connectionState, WalletConnectionState.connected);
      expect(wallet.provider, same(healthy));
    });
  });

  test(
    'real websocket closing before readiness has no unhandled constructor Future',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        await request.response.close();
      });
      final wallet = EraWalletProvider();
      try {
        await wallet.connect(wsEndpoint: 'ws://127.0.0.1:${server.port}');
        expect(wallet.connectionState, WalletConnectionState.error);
        expect(wallet.provider, isNull);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } finally {
        await wallet.disconnect();
        await server.close(force: true);
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

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
  _FakeProvider({required this.onSend, this.onConnect, this.onDisconnect});

  final Future<void> Function()? onConnect;
  final Future<void> Function()? onDisconnect;

  final Future<polkadart.RpcResponse> Function(
    String method,
    List<dynamic> params,
  )
  onSend;
  final List<String> methods = [];
  int disconnectCount = 0;

  @override
  Future<void> connect() async {
    await onConnect?.call();
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    await onDisconnect?.call();
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
