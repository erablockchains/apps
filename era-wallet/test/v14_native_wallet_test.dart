import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:era_wallet/generated/era/era.dart' as era_api;
import 'package:era_wallet/v14/approved_nft_metadata.dart';
import 'package:era_wallet/v14/v14_chain_services.dart';
import 'package:era_wallet/v14/v14_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart' as polkadart;

const _owner = '5Gzp5Kcgkg42WQ1LoWfrV9icX6HE7ZssCRT1eB4GESa1cy9X';

void main() {
  group('approved native NFT metadata', () {
    const fixtureNames = {
      'bafkreigneb4mdfbsrjf764whskvoo2pqsl5d2kjc6kyxsnyz5ikxcede6m':
          'collection.json',
      'bafkreifnjhrm572sicfwfx6wurmavad4vkab3tdfk4btxob43shh6qhiey':
          'item-1.json',
      'bafkreiby6jtpx5bdtosvclzjssu4rze37w7ehdlluilefjadhs737mwonu':
          'item-2.json',
      'bafkreihxzvde4g7s2p6c3k7rkdtbumeobgtfe6fgp2dca7cugc3mns6noq':
          'item-3.json',
    };

    ApprovedNftMetadataResolver resolver({
      bool tamper = false,
      bool appendNewline = false,
    }) =>
        ApprovedNftMetadataResolver(
          fetcher: (uri, _) async {
            final cid = uri.pathSegments.last;
            final name = fixtureNames[cid];
            if (name == null) throw StateError('Unexpected fixture request.');
            final bytes = await File('test/fixtures/v14/$name').readAsBytes();
            if (appendNewline) return Uint8List.fromList([...bytes, 0x0a]);
            if (tamper) bytes[0] ^= 1;
            return bytes;
          },
        );

    test('verifies all four authenticated metadata objects', () async {
      for (final entry in fixtureNames.entries) {
        final uri = 'ipfs://${entry.key}';
        final result = await resolver().resolve(uri);
        expect(result.uri, uri);
        expect(result.cid, entry.key);
        expect(result.retrievedFrom.scheme, 'https');
        expect(result.retrievedFrom.host, 'metadata.eraprojects.org');
        expect(
          await File('test/fixtures/v14/${entry.value}').length(),
          kApprovedNftMetadata[entry.key]!.bytes,
        );
        expect(result.sha256, kApprovedNftMetadata[entry.key]!.sha256);
        expect(result.json, isNotEmpty);
      }
    });

    test(
      'rejects unknown, malformed, and hash-mismatched references',
      () async {
        await expectLater(
          resolver().resolve('ipfs://bafkreiunknown'),
          throwsStateError,
        );
        await expectLater(
          resolver().resolve(
            'https://metadata.eraprojects.org/ipfs/'
            '${fixtureNames.keys.first}',
          ),
          throwsStateError,
        );
        await expectLater(
          resolver(tamper: true).resolve('ipfs://${fixtureNames.keys.first}'),
          throwsStateError,
        );
        await expectLater(
          resolver(appendNewline: true).resolve('ipfs://${fixtureNames.keys.first}'),
          throwsStateError,
        );
      },
    );
  });

  group('spec16 native operation bindings', () {
    final provider = _NoopProvider();
    final api = era_api.Era(provider);
    final calls = V14CallFactory(api);

    test('pins SecurityBudget reward-page claim to pallet 20 call 1', () {
      final plan = calls.claimRewardPage(era: 1, validator: _owner, page: 0);
      expect(plan.call.encode().take(2), [20, 1]);
      expect(plan.callName, 'claim_reward_page');
      expect(plan.arguments, {'era': 1, 'validator': _owner, 'page': 0});
    });

    test('pins approved NFT market and swap calls', () {
      expect(
        calls
            .setPrice(
              collection: 1,
              item: 1,
              price: BigInt.from(10),
              whitelistedBuyer: _owner,
            )
            .call
            .encode()
            .take(2),
        [17, 31],
      );
      expect(
        calls
            .buyItem(collection: 1, item: 1, bidPrice: BigInt.from(10))
            .call
            .encode()
            .take(2),
        [17, 32],
      );
      expect(
        calls
            .createSwap(
              offeredCollection: 1,
              offeredItem: 3,
              desiredCollection: 1,
              desiredItem: 2,
              price: BigInt.from(5),
              duration: 100,
            )
            .call
            .encode()
            .take(2),
        [17, 34],
      );
      expect(
        calls
            .claimSwap(
              sendCollection: 1,
              sendItem: 2,
              receiveCollection: 1,
              receiveItem: 3,
              witnessPrice: BigInt.from(5),
            )
            .call
            .encode()
            .take(2),
        [17, 36],
      );
    });
  });

  test('reward claim gate rejects incomplete or already-claimed state', () {
    SecurityBudgetClaimSnapshot snapshot({
      bool claimed = false,
      int page = 0,
      int pageCount = 1,
      bool paused = false,
    }) => SecurityBudgetClaimSnapshot(
      finalizedHead: '0x01',
      active: true,
      allocationPaused: paused,
      activeEra: 10,
      firstEligibleEra: 1,
      era: 9,
      validator: _owner,
      page: page,
      eligiblePoints: 10,
      eraBudget: BigInt.one,
      eraLiability: BigInt.one,
      exposureTotal: BigInt.one,
      exposureOwn: BigInt.one,
      pageCount: pageCount,
      commissionPerbill: BigInt.zero,
      claimed: claimed,
      expired: false,
    );

    expect(snapshot().eligible, isTrue);
    expect(snapshot(claimed: true).eligible, isFalse);
    expect(snapshot(page: 1).eligible, isFalse);
    expect(snapshot(paused: true).eligible, isFalse);
  });

  group('finalized Twox64Concat account lookup', () {
    test(
      'uses the actual prefix and encoded suffix from finalized storage',
      () async {
        final prefix = Uint8List.fromList([1, 2, 3]);
        final account = Uint8List.fromList(List<int>.generate(32, (i) => i));
        final actual = Uint8List.fromList([
          ...prefix,
          9,
          8,
          7,
          6,
          5,
          4,
          3,
          2,
          ...account,
        ]);
        final adjacent = Uint8List.fromList([
          ...prefix,
          1,
          1,
          1,
          1,
          1,
          1,
          1,
          1,
          ...List<int>.filled(32, 255),
        ]);
        final provider = _StorageProvider(
          keys: [actual, adjacent],
          values: {
            _hex(actual): Uint8List.fromList([42, 0, 0, 0]),
          },
        );
        final reader = FinalizedTwox64ConcatMapReader(
          era_api.Era(provider).rpc.state,
        );

        final result = await reader.read(
          prefix: prefix,
          encodedKey: account,
          at: Uint8List(32),
        );

        expect(result, [42, 0, 0, 0]);
      },
    );

    test('rejects ambiguous matching finalized keys', () async {
      final prefix = Uint8List.fromList([1]);
      final account = Uint8List.fromList(List<int>.filled(32, 7));
      Uint8List key(int hashByte) => Uint8List.fromList([
        ...prefix,
        ...List<int>.filled(8, hashByte),
        ...account,
      ]);
      final provider = _StorageProvider(keys: [key(1), key(2)], values: {});
      final reader = FinalizedTwox64ConcatMapReader(
        era_api.Era(provider).rpc.state,
      );

      await expectLater(
        reader.read(prefix: prefix, encodedKey: account, at: Uint8List(32)),
        throwsStateError,
      );
    });
  });

  testWidgets('native V14 screen exposes read, NFT, and reward routes', (
    tester,
  ) async {
    final provider = _NoopProvider();
    final api = era_api.Era(provider);
    var authenticationRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: V14OperationsScreen(
          provider: provider,
          api: api,
          selectedAccount: _owner,
          authenticateAndLoadMnemonic: (_) async {
            authenticationRequested = true;
            return null;
          },
        ),
      ),
    );

    expect(find.text('ERA V14 Assets & Rewards'), findsOneWidget);
    expect(find.text('NFT read'), findsOneWidget);
    expect(find.text('NFT actions'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Read finalized NFT'), findsOneWidget);
    expect(authenticationRequested, isFalse);

    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();
    expect(find.text('Inspect finalized eligibility'), findsOneWidget);
    expect(find.text('Recheck, review and claim once'), findsOneWidget);
    expect(authenticationRequested, isFalse);
  });
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

class _StorageProvider extends polkadart.Provider {
  final List<Uint8List> keys;
  final Map<String, Uint8List> values;

  const _StorageProvider({required this.keys, required this.values});

  @override
  Future<polkadart.RpcResponse> send(
    String method,
    List<dynamic> params,
  ) async {
    if (method == 'state_getKeysPaged') {
      return polkadart.RpcResponse(id: 1, result: keys.map(_hex).toList());
    }
    if (method == 'state_getStorage') {
      final value = values[params.first as String];
      return polkadart.RpcResponse(
        id: 2,
        result: value == null ? null : _hex(value),
      );
    }
    throw StateError('Unexpected RPC method $method.');
  }

  @override
  bool isConnected() => true;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<polkadart.SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) => throw UnsupportedError('Subscriptions are not used by this test.');
}

String _hex(List<int> value) =>
    '0x${value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
