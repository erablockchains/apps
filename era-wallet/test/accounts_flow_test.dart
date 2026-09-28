import 'package:bip39/bip39.dart' as bip39;
import 'package:era_wallet/accounts_flow.dart';
import 'package:era_wallet/auth_flow.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String mnemonicAlice;
  late String mnemonicBob;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    // Generate ephemeral test-only signing material instead of storing a
    // mnemonic fixture in source control.
    mnemonicAlice = bip39.generateMnemonic();
    mnemonicBob = bip39.generateMnemonic();
  });

  group('AccountManager', () {
    test('adds an account, stores its mnemonic, and marks it active', () async {
      final manager = AccountManager();

      final account = await manager.addAccount(
        name: 'Alice',
        mnemonic: mnemonicAlice,
      );

      expect(account.name, 'Alice');
      expect(manager.accounts, hasLength(1));
      expect(manager.active?.id, account.id);
      expect(await manager.loadMnemonicForAccount(account.id), mnemonicAlice);
      expect(manager.getPendingRevealMnemonic(account.id), mnemonicAlice);
    });

    test('loads persisted accounts and restores active selection', () async {
      final manager = AccountManager();
      final alice = await manager.addAccount(
        name: 'Alice',
        mnemonic: mnemonicAlice,
      );
      final bob = await manager.addAccount(name: 'Bob', mnemonic: mnemonicBob);
      await manager.setActive(alice.id);

      final reloaded = AccountManager();
      await reloaded.loadAccounts();

      expect(reloaded.accounts, hasLength(2));
      expect(reloaded.active?.id, alice.id);
      expect(await reloaded.loadMnemonicForAccount(alice.id), mnemonicAlice);
      expect(await reloaded.loadMnemonicForAccount(bob.id), mnemonicBob);
    });

    test(
      'deleteAccount removes storage and falls back to another active account',
      () async {
        final manager = AccountManager();
        final alice = await manager.addAccount(
          name: 'Alice',
          mnemonic: mnemonicAlice,
        );
        final bob = await manager.addAccount(
          name: 'Bob',
          mnemonic: mnemonicBob,
        );

        await manager.setActive(alice.id);
        await manager.deleteAccount(alice.id);

        expect(manager.accounts.map((account) => account.id), [bob.id]);
        expect(manager.active?.id, bob.id);
        expect(
          await secureStorage.read(
            key: StorageKeys.accountMnemonicKey(alice.id),
          ),
          isNull,
        );
      },
    );

    test('can create a new generated mnemonic account', () async {
      final manager = AccountManager();
      final account = await manager.addAccount(name: 'Generated');
      final mnemonic = await manager.loadMnemonicForAccount(account.id);

      expect(mnemonic, isNotNull);
      expect(bip39.validateMnemonic(mnemonic!), isTrue);
      expect(manager.active?.id, account.id);
    });
  });
}
