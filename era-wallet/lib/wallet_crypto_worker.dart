import 'dart:isolate';
import 'dart:typed_data';

import 'package:polkadart_keyring/polkadart_keyring.dart';

/// sr25519 initializes large curve tables synchronously, even though
/// fromMnemonic returns a Future. Keep that work off Android's main thread.
/// The existing keyring defaults, URI derivation and crypto parameters remain
/// unchanged. Only in-process data is passed; no storage or platform calls run
/// in the worker, which exits when the operation completes.
Future<KeyPair> deriveWalletKeyPair(String mnemonic) =>
    Isolate.run(() => Keyring().fromMnemonic(mnemonic));

/// Signing can also initialize curve tables in a fresh isolate. Keep the entire
/// operation in the worker, without changing the signed payload or signature.
Future<Uint8List> signWalletPayload(KeyPair wallet, Uint8List payload) =>
    Isolate.run(() => wallet.sign(payload));
