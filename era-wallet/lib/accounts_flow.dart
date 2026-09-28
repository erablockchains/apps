import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:provider/provider.dart' as flutter_provider;

import 'account_qr_dialog.dart';
import 'auth_flow.dart';
import 'era_scaffold.dart';

class WalletAccount {
  final String id;
  final String name;
  final String address;

  WalletAccount({required this.id, required this.name, required this.address});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'address': address};

  static WalletAccount fromJson(Map<String, dynamic> json) => WalletAccount(
    id: json['id'],
    name: json['name'],
    address: json['address'],
  );
}

class AccountManager with ChangeNotifier {
  final List<WalletAccount> _accounts = [];
  final Map<String, String> _mnemonicCache = {};
  final Map<String, String> _pendingRevealMnemonic = {};

  WalletAccount? _active;

  List<WalletAccount> get accounts => List.unmodifiable(_accounts);
  WalletAccount? get active => _active;

  Future<void> loadAccounts() async {
    final listJson = await secureStorage.read(key: 'accounts_list');
    if (listJson != null) {
      final List data = jsonDecode(listJson);
      _accounts
        ..clear()
        ..addAll(
          data.map((e) => WalletAccount.fromJson(Map<String, dynamic>.from(e))),
        );
    }

    final activeId = await secureStorage.read(key: 'active_account_id');
    if (activeId != null) {
      try {
        _active = _accounts.firstWhere((a) => a.id == activeId);
      } catch (_) {
        _active = _accounts.isNotEmpty ? _accounts.first : null;
      }
    } else {
      _active = _accounts.isNotEmpty ? _accounts.first : null;
    }
    notifyListeners();
  }

  Future<void> saveAccounts() async {
    await secureStorage.write(
      key: 'accounts_list',
      value: jsonEncode(_accounts.map((a) => a.toJson()).toList()),
    );
    await secureStorage.write(key: 'active_account_id', value: _active?.id);
  }

  Future<WalletAccount> addAccount({
    required String name,
    String? mnemonic,
  }) async {
    final keyring = Keyring();
    final String finalMnemonic = (mnemonic == null || mnemonic.trim().isEmpty)
        ? bip39.generateMnemonic()
        : mnemonic.trim();

    final pair = await keyring.fromMnemonic(finalMnemonic);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final acc = WalletAccount(id: id, name: name, address: pair.address);

    _accounts.add(acc);
    _active = acc;
    await saveAccounts();

    await storeMnemonicForAccount(id, finalMnemonic, revealOnce: true);

    return acc;
  }

  Future<void> storeMnemonicForAccount(
    String id,
    String mnemonic, {
    bool revealOnce = false,
  }) async {
    final trimmed = mnemonic.trim();
    _mnemonicCache[id] = trimmed;
    await secureStorage.write(
      key: StorageKeys.accountMnemonicKey(id),
      value: trimmed,
    );
    if (revealOnce) {
      _pendingRevealMnemonic[id] = trimmed;
    }
    notifyListeners();
  }

  Future<String?> loadMnemonicForAccount(String id) async {
    final cached = _mnemonicCache[id];
    if (cached != null) return cached;

    final stored = await secureStorage.read(
      key: StorageKeys.accountMnemonicKey(id),
    );
    if (stored != null) {
      _mnemonicCache[id] = stored;
    }
    return stored;
  }

  Future<void> setActive(String id) async {
    _active = _accounts.firstWhere((a) => a.id == id);
    await saveAccounts();
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);

    if (_active?.id == id) {
      _active = _accounts.isNotEmpty ? _accounts.first : null;
    }

    await saveAccounts();
    await secureStorage.delete(key: StorageKeys.accountMnemonicKey(id));
    _mnemonicCache.remove(id);
    _pendingRevealMnemonic.remove(id);

    notifyListeners();
  }

  String? getPendingRevealMnemonic(String id) => _pendingRevealMnemonic[id];

  void markMnemonicForReveal(String id, String mnemonic) {
    _pendingRevealMnemonic[id] = mnemonic.trim();
    notifyListeners();
  }

  void clearPendingRevealForAccount(String id) {
    _pendingRevealMnemonic.remove(id);
    notifyListeners();
  }

  void clearAllPendingRevealMnemonics() {
    _pendingRevealMnemonic.clear();
    notifyListeners();
  }
}

class AccountsScreen extends StatefulWidget {
  final WidgetBuilder addAccountBuilder;

  const AccountsScreen({super.key, required this.addAccountBuilder});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void dispose() {
    final am = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    am.clearAllPendingRevealMnemonics();
    super.dispose();
  }

  Widget _buildMnemonicBlock(String mnemonic) {
    return SelectableText(
      mnemonic.trim(),
      style: const TextStyle(fontSize: 12, height: 1.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final am = flutter_provider.Provider.of<AccountManager>(context);
    return EraScaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Accounts'),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: am.accounts.length,
        itemBuilder: (context, index) {
          final acc = am.accounts[index];
          final isActive = am.active?.id == acc.id;
          final pendingMnemonic = am.getPendingRevealMnemonic(acc.id);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () async {
              final navigator = Navigator.of(context);
              await am.setActive(acc.id);
              if (!context.mounted) return;
              if (navigator.canPop()) {
                navigator.pop();
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Image.asset(kEraIconPath, width: 32, height: 32),
                title: Text(acc.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      acc.address,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy address',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: acc.address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Address copied: ${acc.name}'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_2, size: 18),
                          tooltip: 'Show address QR code',
                          onPressed: () {
                            showAccountQrDialog(
                              context: context,
                              accountName: acc.name,
                              address: acc.address,
                            );
                          },
                        ),
                        if (isActive)
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            tooltip: 'Show mnemonic (requires PIN/biometric)',
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final authResult =
                                  await authenticateWalletForSensitiveAction(
                                    context,
                                    reason: 'Authenticate to view seed phrase',
                                  );
                              if (!context.mounted) return;
                              if (!authResult.success) return;

                              final amLocal =
                                  flutter_provider.Provider.of<AccountManager>(
                                    context,
                                    listen: false,
                                  );

                              final mnemonic = await amLocal
                                  .loadMnemonicForAccount(acc.id);
                              if (mnemonic == null) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No mnemonic stored for this account on this device.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              amLocal.markMnemonicForReveal(acc.id, mnemonic);

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Mnemonic revealed for "${acc.name}". Save it securely.',
                                  ),
                                ),
                              );
                            },
                          ),
                        if (isActive)
                          const Icon(Icons.check, color: Colors.green),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          tooltip: 'Delete account',
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete account'),
                                content: Text(
                                  'Delete "${acc.name}" from this device?\n\n'
                                  'This does NOT delete the account on-chain. '
                                  'If you don\'t have its mnemonic backed up, you may lose access.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (!context.mounted) return;
                            if (confirmed == true) {
                              await am.deleteAccount(acc.id);
                              if (!context.mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Deleted account "${acc.name}"',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    if (pendingMnemonic != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Mnemonic (save now, shown only once):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMnemonicBlock(pendingMnemonic),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text(
                                  'Copy seed phrase',
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text(
                                        'Copy recovery phrase?',
                                      ),
                                      content: const Text(
                                        'Anyone with this phrase can control '
                                        'your wallet. Keep it offline, never '
                                        'send it to support, and clear any '
                                        'clipboard history. ERA Wallet will '
                                        'attempt to clear this clipboard value '
                                        'after 60 seconds.\n\nBy continuing, '
                                        'you acknowledge that you are '
                                        'responsible for an offline backup.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text(
                                            'I understand — copy',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed != true || !context.mounted) {
                                    return;
                                  }
                                  await copySensitiveTextWithAutoClear(
                                    pendingMnemonic,
                                  );
                                  if (!context.mounted) return;
                                  final amLocal =
                                      flutter_provider.Provider.of<
                                        AccountManager
                                      >(context, listen: false);
                                  amLocal.clearPendingRevealForAccount(acc.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Recovery phrase copied for "${acc.name}". It will be cleared after 60 seconds when supported.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () => am.setActive(acc.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: widget.addAccountBuilder));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}

class AddAccountScreen extends StatefulWidget {
  final WidgetBuilder onCreatedBuilder;

  const AddAccountScreen({super.key, required this.onCreatedBuilder});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _mnemonicController = TextEditingController();
  bool _importMode = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mnemonicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final am = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );

    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Create Account'),
          ],
        ),
      ),
      body: ListView(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose how to create this account:\n'
            '- Create new mnemonic (default)\n'
            '- Import existing mnemonic',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Import existing mnemonic'),
            subtitle: const Text(
              'Off: create new mnemonic in background\n'
              'On: use an existing seed phrase',
              style: TextStyle(fontSize: 12),
            ),
            value: _importMode,
            onChanged: (v) => setState(() {
              _importMode = v;
              if (!v) {
                _mnemonicController.clear();
              }
            }),
          ),
          const SizedBox(height: 8),
          if (_importMode) ...[
            const Text(
              'Paste your existing 12/24-word mnemonic here.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mnemonicController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '12/24-word mnemonic',
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            const Text(
              'A new mnemonic will be generated in the background when you create this account.\n\n'
              'On the Accounts screen, you will see the mnemonic under your new account to save it. '
              'After that, it will not be displayed again.',
              style: TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }

                    setState(() => _saving = true);

                    try {
                      String? mnemonic;

                      if (_importMode) {
                        mnemonic = _mnemonicController.text.trim();
                        if (mnemonic.isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please paste a mnemonic to import.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (!bip39.validateMnemonic(mnemonic)) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Imported mnemonic is not a valid BIP39 phrase.',
                              ),
                            ),
                          );
                          return;
                        }
                      } else {
                        mnemonic = null;
                      }

                      final navigator = Navigator.of(context);
                      await am.addAccount(name: name, mnemonic: mnemonic);

                      if (!mounted) return;
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: widget.onCreatedBuilder),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Failed to add account: $e')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _saving = false);
                      }
                    }
                  },
            icon: const Icon(Icons.check),
            label: Text(_saving ? 'Saving...' : 'Create Account'),
          ),
        ],
      ),
    );
  }
}
