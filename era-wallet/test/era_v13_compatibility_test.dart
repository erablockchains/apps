import 'dart:io';
import 'dart:typed_data';

import 'package:era_wallet/era_v14_compatibility.dart';
import 'package:era_wallet/generated/era/era.dart' as era_api;
import 'package:era_wallet/generated/era/types/pallet_staking/reward_destination.dart'
    as staking_types;
import 'package:era_wallet/generated/era/types/sp_runtime/multiaddress/multi_address.dart'
    as era_multi;
import 'package:era_wallet/staking_disclosure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart' as polkadart;

void main() {
  group('ERA V14 identity and metadata', () {
    test('pins the canonical live network properties', () {
      const identity = EraV14RuntimeIdentity(
        chainName: 'ERA',
        genesisHash: kEraGenesisHash,
        specName: 'era',
        specVersion: 16,
        transactionVersion: 1,
        tokenSymbol: 'ETKN',
        tokenDecimals: 18,
        ss58Prefix: 42,
      );

      expect(identity.verify, returnsNormally);
      expect(kEraPublicName, 'ERA');
      expect(kEraRuntimeWasmSha256, hasLength(64));
    });

    test('rejects a stale runtime before transaction construction', () {
      const stale = EraV14RuntimeIdentity(
        chainName: 'ERA',
        genesisHash: kEraGenesisHash,
        specName: 'era',
        specVersion: 12,
        transactionVersion: 1,
        tokenSymbol: 'ETKN',
        tokenDecimals: 18,
        ss58Prefix: 42,
      );

      expect(
        stale.verify,
        throwsA(
          isA<EraV14CompatibilityException>().having(
            (error) => error.message,
            'message',
            contains('specVersion=12'),
          ),
        ),
      );
    });

    test('rejects the previously accepted spec15 runtime after cutover', () {
      const oldRuntime = EraV14RuntimeIdentity(
        chainName: 'ERA',
        genesisHash: kEraGenesisHash,
        specName: 'era',
        specVersion: 15,
        transactionVersion: 1,
        tokenSymbol: 'ETKN',
        tokenDecimals: 18,
        ss58Prefix: 42,
      );
      expect(oldRuntime.verify, throwsA(isA<EraV14CompatibilityException>()));
    });

    test('rejects an incorrect production chain name', () {
      const wrongChain = EraV14RuntimeIdentity(
        chainName: 'ERA-MAINNET',
        genesisHash: kEraGenesisHash,
        specName: 'era',
        specVersion: 16,
        transactionVersion: 1,
        tokenSymbol: 'ETKN',
        tokenDecimals: 18,
        ss58Prefix: 42,
      );

      expect(
        wrongChain.verify,
        throwsA(
          isA<EraV14CompatibilityException>().having(
            (error) => error.message,
            'message',
            contains('chain=ERA-MAINNET'),
          ),
        ),
      );
    });

    test('accepts the pinned metadata and required wallet surface', () async {
      final bytes = File(
        'artifacts/v14/era-spec16-metadata.scale',
      ).readAsBytesSync();
      final surface = await EraV14RuntimeGuard.inspectMetadata(bytes);

      expect(surface.version, 14);
      expect(surface.sha256, kEraMetadataSha256);
      expect(surface.calls['Balances'], contains('transfer_allow_death'));
      expect(
        surface.calls['Staking'],
        containsAll(['bond', 'nominate', 'unbond']),
      );
      expect(
        surface.storage['Staking'],
        containsAll(['MinValidatorBond', 'ErasValidatorReward']),
      );
      expect(
        surface.calls['AiPredictions'],
        contains('claim_prediction_market_payout'),
      );
      expect(surface.calls['SecurityBudget'], contains('claim_reward_page'));
      expect(
        surface.calls['Nfts'],
        containsAll(['set_price', 'buy_item', 'create_swap', 'claim_swap']),
      );
    });

    test('refuses stale metadata with a clear compatibility error', () async {
      final bytes = File(
        'artifacts/v14/era-spec16-metadata.scale',
      ).readAsBytesSync();
      bytes[bytes.length - 1] ^= 1;

      await expectLater(
        EraV14RuntimeGuard.inspectMetadata(bytes),
        throwsA(
          isA<EraV14CompatibilityException>().having(
            (error) => error.message,
            'message',
            anyOf(
              contains('stale or unreviewed'),
              contains('cannot be decoded'),
            ),
          ),
        ),
      );
    });
  });

  test('constructs balance and staking calls without signing', () {
    final provider = polkadart.Provider.fromUri(
      Uri.parse('wss://metadata-only.invalid'),
    );
    final api = era_api.Era(provider);
    final account = era_multi.Id(Uint8List(32));

    expect(
      api.tx.balances
          .transferAllowDeath(dest: account, value: BigInt.one)
          .encode()
          .take(2),
      [2, 0],
    );
    expect(
      api.tx.staking
          .bond(value: BigInt.one, payee: const staking_types.Staked())
          .encode()
          .take(2),
      [10, 0],
    );
    expect(api.tx.staking.nominate(targets: [account]).encode().take(2), [
      10,
      5,
    ]);
    expect(api.tx.staking.unbond(value: BigInt.one).encode().take(2), [10, 2]);
    expect(
      api.tx.staking.withdrawUnbonded(numSlashingSpans: 0).encode().take(2),
      [10, 3],
    );
  });

  testWidgets('shows the V14 SecurityBudget staking notice', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EraStakingRewardNotice())),
    );

    expect(find.text('Current staking rewards'), findsOneWidget);
    expect(find.text(kEraStakingRewardNotice), findsOneWidget);
    expect(kEraStakingRewardNotice, contains('staking, nomination'));
    expect(kEraStakingRewardNotice, contains('SecurityBudget'));
  });

  test('transaction logging never includes secret or payload material', () {
    for (final path in ['lib/era_chain.dart', 'lib/main.dart']) {
      final debugLines = File(path)
          .readAsLinesSync()
          .where((line) => line.contains('debugPrint'))
          .map((line) => line.toLowerCase());
      for (final line in debugLines) {
        expect(
          line,
          isNot(
            matches(
              RegExp(
                r'\$\{?(frommnemonic|mnemonic|signingpayload|signature|extrinsichex)',
              ),
            ),
          ),
          reason: path,
        );
      }
    }
  });
}
