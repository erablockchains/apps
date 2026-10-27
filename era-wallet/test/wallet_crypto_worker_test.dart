import 'dart:async';
import 'dart:typed_data';

import 'package:era_wallet/wallet_crypto_worker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';

const fixture =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

void main() {
  test('cold derivation leaves the caller event loop responsive', () async {
    var ticks = 0;
    final clock = Stopwatch()..start();
    var previous = 0;
    var longestGap = 0;
    final timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      final now = clock.elapsedMilliseconds;
      final gap = now - previous;
      if (gap > longestGap) longestGap = gap;
      previous = now;
      ticks++;
    });
    try {
      final pair = await deriveWalletKeyPair(fixture);
      expect(pair.ss58Format, 42);
      expect(ticks, greaterThan(2));
      // The old cold path blocks for seconds. Allow scheduler variation while
      // checking that the caller continues to process events during that work.
      expect(longestGap, lessThan(500));
    } finally {
      timer.cancel();
    }
  });

  for (final uri in [fixture, '$fixture//hard/soft', '$fixture///fixture-password']) {
    test('worker preserves sr25519 derivation and signing for $uri', () async {
      final expected = await Keyring().fromMnemonic(uri);
      final actual = await deriveWalletKeyPair(uri);
      expect(actual.address, expected.address);
      expect(actual.bytes(), expected.bytes());
      final payload = Uint8List.fromList([69, 82, 65, 0, 1, 2, 3]);
      final signature = await signWalletPayload(actual, payload);
      expect(expected.verify(payload, signature), isTrue);
      final changed = Uint8List.fromList(payload)..[0] ^= 1;
      expect(expected.verify(changed, signature), isFalse);
    });
  }
  test('invalid derivation still fails without a substitute account', () async {
    await expectLater(deriveWalletKeyPair('not a valid phrase'), throwsA(isA<Exception>()));
  });
}
