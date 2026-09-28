import 'dart:convert';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:era_wallet/auth_flow.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('biometric preference storage', () {
    test('defaults to enabled until explicitly disabled', () async {
      expect(await isBiometricLoginEnabled(), isTrue);

      await setBiometricLoginEnabled(false);
      expect(await isBiometricLoginEnabled(), isFalse);

      await setBiometricLoginEnabled(true);
      expect(await isBiometricLoginEnabled(), isTrue);
    });
  });

  group('PinCrypto', () {
    test('creates and verifies a PIN verifier', () async {
      final key = await PinCrypto.deriveKeyFromPin(
        '123456',
        List.filled(16, 7),
      );
      final verifier = await PinCrypto.createPinVerifier(key);

      expect(
        await PinCrypto.verifyPinWithStoredVerifier(key, verifier),
        isTrue,
      );

      final wrongKey = await PinCrypto.deriveKeyFromPin(
        '999999',
        List.filled(16, 7),
      );
      expect(
        await PinCrypto.verifyPinWithStoredVerifier(wrongKey, verifier),
        isFalse,
      );
    });

    test('decrypts a legacy mnemonic payload', () async {
      // The legacy decryptor handles text bytes; an intentionally invalid
      // placeholder avoids placing wallet recovery material in fixtures.
      const mnemonic = 'fixture legacy encrypted wallet payload';
      final salt = List<int>.generate(16, (index) => index + 1);
      final nonce = List<int>.generate(12, (index) => index + 11);
      final key = await PinCrypto.deriveKeyFromPin('123456', salt);

      final aes = crypto.AesGcm.with256bits();
      final secretBox = await aes.encrypt(
        utf8.encode(mnemonic),
        secretKey: key,
        nonce: nonce,
      );
      final combined = <int>[...secretBox.cipherText, ...secretBox.mac.bytes];

      final decrypted = await PinCrypto.decryptLegacyMnemonic(
        base64Encode(combined),
        base64Encode(nonce),
        key,
      );

      expect(decrypted, mnemonic);
    });
  });

  group('KeyStore', () {
    test('rejects weak new PINs', () async {
      final keyStore = KeyStore();

      expect(() => keyStore.setupPin(pin: '1234'), throwsArgumentError);
    });

    test(
      'setupPin persists wallet state and unlocks with the correct PIN',
      () async {
        final keyStore = KeyStore();

        await keyStore.init();
        expect(keyStore.hasWallet, isFalse);
        expect(keyStore.unlocked, isFalse);

        await keyStore.setupPin(pin: '123456');

        expect(keyStore.hasWallet, isTrue);
        expect(keyStore.unlocked, isTrue);
        expect(await keyStore.verifyPin('123456'), isTrue);
        expect(await keyStore.verifyPin('654321'), isFalse);

        keyStore.lock();
        expect(keyStore.unlocked, isFalse);

        expect(await keyStore.unlockWithPin('654321'), isFalse);
        expect(keyStore.unlocked, isFalse);

        expect(await keyStore.unlockWithPin('123456'), isTrue);
        expect(keyStore.unlocked, isTrue);
      },
    );

    test(
      'init detects an already configured wallet from secure storage',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          StorageKeys.pinSalt: base64Encode(List<int>.filled(16, 1)),
          StorageKeys.pinVerifier: 'stored-verifier',
        });

        final keyStore = KeyStore();
        await keyStore.init();

        expect(keyStore.hasWallet, isTrue);
        expect(keyStore.unlocked, isFalse);
      },
    );

    test('changes PIN only after current PIN verification', () async {
      final keyStore = KeyStore();
      await keyStore.setupPin(pin: '123456');

      await keyStore.changePin(currentPin: '123456', newPin: '987654');

      expect(await keyStore.verifyPin('123456'), isFalse);
      expect(await keyStore.verifyPin('987654'), isTrue);
    });

    test('persists a lockout after repeated failed attempts', () async {
      final keyStore = KeyStore();
      await keyStore.setupPin(pin: '123456');

      for (var attempt = 0; attempt < 5; attempt++) {
        expect(await keyStore.verifyPin('000000'), isFalse);
      }

      expect(await keyStore.pinLockoutRemaining(), greaterThan(Duration.zero));
      expect(await keyStore.verifyPin('123456'), isFalse);
    });
  });
}
