import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'account_qr_dialog.dart';
import 'wallet_crypto_worker.dart';
import 'config.dart';
import 'era_v14_compatibility.dart';
import 'generated/era/era.dart' as era_api;
import 'generated/era/types/sp_runtime/multiaddress/multi_address.dart'
    as era_multi;
import 'generated/era/types/pallet_staking/reward_destination.dart'
    as staking_types;
import 'generated/era/types/pallet_staking/nominations.dart' as staking_noms;
import 'package:polkadart/scale_codec.dart' show encodeHex;

// NEW: shared luxury background scaffold
import 'era_scaffold.dart';
import 'recipient_qr_scanner.dart';
import 'staking_disclosure.dart';
import 'v14/v14_operations_screen.dart';

// ===== ERA DECIMALS (from chain_spec: tokenDecimals = 18) =====
const int kEraDecimals = 18;
final BigInt kEraUnit = BigInt.from(10).pow(kEraDecimals);

// Global navigator key for session lock navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

String formatEra(BigInt? value) {
  if (value == null) return '0';
  var v = value;
  final negative = v.isNegative;
  if (negative) v = -v;

  final whole = v ~/ kEraUnit;
  final frac = v.remainder(kEraUnit);

  if (frac == BigInt.zero) {
    return '${negative ? '-' : ''}$whole';
  }

  var fracStr = frac.toString().padLeft(kEraDecimals, '0');
  // trim trailing zeros
  fracStr = fracStr.replaceFirst(RegExp(r'0+$'), '');

  return '${negative ? '-' : ''}$whole.$fracStr';
}

/// Parse a human ERA string (e.g. "1", "0.5", "1.234")
/// into base units (BigInt). Returns null if invalid.
BigInt? parseEraToUnits(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;

  var negative = false;
  if (text.startsWith('-')) {
    negative = true;
    text = text.substring(1);
  }

  final parts = text.split('.');
  if (parts.length > 2) return null;

  final wholeStr = parts[0].isEmpty ? '0' : parts[0];
  if (!RegExp(r'^\d+$').hasMatch(wholeStr)) return null;

  var fracStr = parts.length == 2 ? parts[1] : '';
  if (!RegExp(r'^\d*$').hasMatch(fracStr)) return null;

  if (fracStr.length > kEraDecimals) {
    // truncate extra precision instead of failing hard
    fracStr = fracStr.substring(0, kEraDecimals);
  }
  fracStr = fracStr.padRight(kEraDecimals, '0');

  final whole = BigInt.parse(wholeStr);
  final frac = fracStr.isEmpty ? BigInt.zero : BigInt.parse(fracStr);

  var result = whole * kEraUnit + frac;
  if (negative) result = -result;
  return result;
}

// ===== CONFIG =====
const String kEraIconPath = 'assets/images/era_icon.png';

// ===== SECURE STORAGE KEYS =====
class StorageKeys {
  static const String pinSalt = 'pin_salt';
  static const String pinVerifier = 'pin_verifier';
  static const String biometricsEnabled = 'biometrics_enabled';

  // legacy global encrypted mnemonic (old design)
  static const String mnemonicBlob = 'mnemonic_blob';
  static const String mnemonicNonce = 'mnemonic_nonce';

  // Per-account mnemonic prefix (new design)
  static String accountMnemonicKey(String accountId) =>
      'acc_mnemonic_$accountId';
}

// ===== SECURE STORAGE =====
const _secure = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

// ===== CRYPTO HELPERS (for PIN + legacy mnemonic) =====
class PinCrypto {
  static final _pbkdf2 = crypto.Pbkdf2(
    macAlgorithm: crypto.Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );
  static final _hmac = crypto.Hmac.sha256();
  static final _aesGcm = crypto.AesGcm.with256bits(); // for legacy mnemonic

  static Future<crypto.SecretKey> deriveKeyFromPin(
    String pin,
    List<int> salt,
  ) async {
    return await _pbkdf2.deriveKey(
      secretKey: crypto.SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }

  static Future<List<int>> randomBytes(int length) async {
    final rng = Random.secure();
    return List<int>.generate(length, (_) => rng.nextInt(256));
  }

  static Future<String> createPinVerifier(crypto.SecretKey key) async {
    final mac = await _hmac.calculateMac(
      utf8.encode('PIN_VERIFIER_V1'),
      secretKey: key,
    );
    return base64Encode(mac.bytes);
  }

  static Future<bool> verifyPinWithStoredVerifier(
    crypto.SecretKey key,
    String stored,
  ) async {
    final mac = await _hmac.calculateMac(
      utf8.encode('PIN_VERIFIER_V1'),
      secretKey: key,
    );
    return base64Encode(mac.bytes) == stored;
  }

  /// Legacy decrypt for old global mnemonic stored as blob+nonce.
  static Future<String> decryptLegacyMnemonic(
    String blobB64,
    String nonceB64,
    crypto.SecretKey key,
  ) async {
    final bytes = base64Decode(blobB64);
    final nonce = base64Decode(nonceB64);
    final macBytes = bytes.sublist(bytes.length - 16);
    final ct = bytes.sublist(0, bytes.length - 16);
    final box = crypto.SecretBox(ct, nonce: nonce, mac: crypto.Mac(macBytes));
    final clear = await _aesGcm.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }
}

// ===== KEYSTORE (PIN ONLY) =====
class KeyStore with ChangeNotifier {
  bool _unlocked = false;
  bool _hasWallet = false;

  bool get unlocked => _unlocked;
  bool get hasWallet => _hasWallet;

  Future<void> init() async {
    final saltB64 = await _secure.read(key: StorageKeys.pinSalt);
    final verifier = await _secure.read(key: StorageKeys.pinVerifier);
    _hasWallet = saltB64 != null && verifier != null;
    _unlocked = false;
    notifyListeners();
  }

  /// Explicit lock (used by inactivity/session expiry).
  void lock() {
    if (_unlocked) {
      _unlocked = false;
      notifyListeners();
    }
  }

  /// Set up PIN (no mnemonic stored here).
  Future<void> setupPin({required String pin}) async {
    final salt = await PinCrypto.randomBytes(16);
    await _secure.write(key: StorageKeys.pinSalt, value: base64Encode(salt));
    final key = await PinCrypto.deriveKeyFromPin(pin, salt);
    final verifier = await PinCrypto.createPinVerifier(key);
    await _secure.write(key: StorageKeys.pinVerifier, value: verifier);

    _unlocked = true;
    _hasWallet = true;
    notifyListeners();
  }

  Future<bool> unlockWithPin(String pin) async {
    final saltB64 = await _secure.read(key: StorageKeys.pinSalt);
    final verifier = await _secure.read(key: StorageKeys.pinVerifier);

    if (saltB64 == null || verifier == null) {
      return false;
    }

    final salt = base64Decode(saltB64);
    final key = await PinCrypto.deriveKeyFromPin(pin, salt);
    final ok = await PinCrypto.verifyPinWithStoredVerifier(key, verifier);
    if (!ok) return false;

    _unlocked = true;
    notifyListeners();
    return true;
  }

  /// Used after successful biometric auth on unlock screen.
  void forceUnlock() {
    _unlocked = true;
    notifyListeners();
  }
}

// ===== ACCOUNT MANAGER =====
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
  final Map<String, String> _mnemonicCache = {}; // in-memory for current run
  final Map<String, String> _pendingRevealMnemonic =
      {}; // show once in AccountsScreen

  WalletAccount? _active;

  List<WalletAccount> get accounts => List.unmodifiable(_accounts);
  WalletAccount? get active => _active;

  String? getCachedMnemonic(String accountId) => _mnemonicCache[accountId];
  String? getPendingRevealMnemonic(String accountId) =>
      _pendingRevealMnemonic[accountId];

  void clearAllPendingRevealMnemonics() {
    _pendingRevealMnemonic.clear();
    notifyListeners();
  }

  void clearPendingRevealForAccount(String id) {
    _pendingRevealMnemonic.remove(id);
    notifyListeners();
  }

  /// Lazily load mnemonic for this account from cache or secure storage.
  Future<String?> loadMnemonicForAccount(String id) async {
    final cached = _mnemonicCache[id];
    if (cached != null) return cached;

    final stored = await _secure.read(key: StorageKeys.accountMnemonicKey(id));
    if (stored != null && stored.trim().isNotEmpty) {
      final trimmed = stored.trim();
      _mnemonicCache[id] = trimmed;
      return trimmed;
    }
    return null;
  }

  /// Mark mnemonic to be revealed once in AccountsScreen.
  void markMnemonicForReveal(String id, String mnemonic) {
    _pendingRevealMnemonic[id] = mnemonic;
    notifyListeners();
  }

  Future<void> loadAccounts() async {
    final listJson = await _secure.read(key: 'accounts_list');
    if (listJson != null) {
      final decoded = jsonDecode(listJson) as List;
      _accounts.clear();
      _accounts.addAll(decoded.map((e) => WalletAccount.fromJson(e)));
    }
    final activeId = await _secure.read(key: 'active_account_id');
    if (_accounts.isNotEmpty) {
      _active = _accounts.firstWhere(
        (a) => a.id == activeId,
        orElse: () => _accounts.first,
      );
    } else {
      _active = null;
    }
    notifyListeners();
  }

  Future<void> saveAccounts() async {
    await _secure.write(
      key: 'accounts_list',
      value: jsonEncode(_accounts.map((a) => a.toJson()).toList()),
    );
    await _secure.write(key: 'active_account_id', value: _active?.id);
  }

  /// Create/add an account. If [mnemonic] is null, a new one is generated.
  /// Returns the created [WalletAccount].
  Future<WalletAccount> addAccount({
    required String name,
    String? mnemonic,
  }) async {
    final String finalMnemonic = (mnemonic == null || mnemonic.trim().isEmpty)
        ? bip39.generateMnemonic()
        : mnemonic.trim();

    final pair = await deriveWalletKeyPair(finalMnemonic);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final acc = WalletAccount(id: id, name: name, address: pair.address);

    _accounts.add(acc);
    _active = acc;
    await saveAccounts();

    await storeMnemonicForAccount(id, finalMnemonic, revealOnce: true);

    return acc;
  }

  /// Store/caches mnemonic for an account (used for new accounts and migration).
  Future<void> storeMnemonicForAccount(
    String id,
    String mnemonic, {
    bool revealOnce = false,
  }) async {
    final trimmed = mnemonic.trim();
    _mnemonicCache[id] = trimmed;
    await _secure.write(
      key: StorageKeys.accountMnemonicKey(id),
      value: trimmed,
    );
    if (revealOnce) {
      _pendingRevealMnemonic[id] = trimmed;
    }
    notifyListeners();
  }

  Future<void> setActive(String id) async {
    _active = _accounts.firstWhere((a) => a.id == id);
    await saveAccounts();
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);

    if (_active?.id == id) {
      if (_accounts.isNotEmpty) {
        _active = _accounts.first;
      } else {
        _active = null;
      }
    }

    await saveAccounts();

    // Remove stored mnemonic for this account
    await _secure.delete(key: StorageKeys.accountMnemonicKey(id));
    _mnemonicCache.remove(id);
    _pendingRevealMnemonic.remove(id);

    notifyListeners();
  }
}

// ===== ERA CHAIN PROVIDER =====
typedef EraProviderFactory = polkadart.Provider Function(Uri endpoint);

enum WalletConnectionState { disconnected, connecting, connected, error }

class EraWalletProvider extends ChangeNotifier {
  EraWalletProvider({EraProviderFactory? providerFactory})
    : _providerFactory = providerFactory ?? _createProvider;

  static polkadart.Provider _createProvider(Uri endpoint) {
    // WsProvider's default constructor starts an unawaited connect Future.
    // Own that Future so offline/timeout failures reach the visible retry state.
    if (endpoint.scheme == 'ws' || endpoint.scheme == 'wss') {
      return polkadart.WsProvider(endpoint, autoConnect: false);
    }
    return polkadart.Provider.fromUri(endpoint);
  }

  static const String defaultWsEndpoint = kDefaultEraWsEndpoint;
  final EraProviderFactory _providerFactory;

  polkadart.Provider? _provider;
  era_api.Era? _api;

  WalletConnectionState _connectionState = WalletConnectionState.disconnected;
  String? _connectionError;
  bool _isConnecting = false;
  Future<void>? _currentConnectFuture;

  polkadart.Provider? get provider => _provider;
  era_api.Era? get api => _api;
  WalletConnectionState get connectionState => _connectionState;
  String? get connectionError => _connectionError;

  Future<void> connect({String? wsEndpoint}) async {
    if (_isConnecting || _connectionState == WalletConnectionState.connected) {
      return _currentConnectFuture ?? Future.value();
    }
    _isConnecting = true;
    _connectionError = null;
    _connectionState = WalletConnectionState.connecting;
    notifyListeners();
    _currentConnectFuture = _connectInternal(wsEndpoint: wsEndpoint);
    try {
      await _currentConnectFuture;
    } finally {
      _isConnecting = false;
      _currentConnectFuture = null;
    }
  }

  Future<void> _connectInternal({String? wsEndpoint}) async {
    if (_provider != null) {
      try {
        await _provider!.disconnect().timeout(const Duration(seconds: 2));
      } catch (_) {}
      _provider = null;
      _api = null;
    }
    final endpoint = wsEndpoint ?? defaultWsEndpoint;
    polkadart.Provider? freshProvider;
    try {
      freshProvider = _providerFactory(Uri.parse(endpoint));
      await freshProvider.connect().timeout(const Duration(seconds: 20));
      if (!await _isReadyEraProvider(freshProvider)) {
        throw StateError('ERA RPC readiness check failed.');
      }

      _provider = freshProvider;
      _api = era_api.Era(freshProvider);

      _connectionState = WalletConnectionState.connected;
      _connectionError = null;
      notifyListeners();
    } catch (e) {
      if (freshProvider != null) {
        try {
          await freshProvider.disconnect().timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
      _provider = null;
      _api = null;
      _connectionState = WalletConnectionState.error;
      _connectionError = e.toString();
      notifyListeners();
    }
  }

  /// Ensure we are connected before doing any chain queries.
  /// Returns true if api/provider are ready.
  Future<bool> ensureConnected({String? wsEndpoint}) async {
    final existing = _provider;
    if (_connectionState == WalletConnectionState.connected &&
        existing != null &&
        _api != null) {
      if (await _isReadyEraProvider(existing)) return true;
      await disconnect();
    }

    await connect(wsEndpoint: wsEndpoint);

    return _connectionState == WalletConnectionState.connected &&
        _provider != null &&
        _api != null;
  }

  Future<void> disconnect() async {
    if (_provider != null) {
      try {
        await _provider!.disconnect().timeout(const Duration(seconds: 2));
      } catch (_) {}
      _provider = null;
    }
    _api = null;
    _connectionState = WalletConnectionState.disconnected;
    notifyListeners();
  }

  Future<bool> _isReadyEraProvider(polkadart.Provider candidate) async {
    try {
      final response = await candidate
          .send('system_chain', const [])
          .timeout(const Duration(seconds: 20));
      return response.error == null && response.result == 'ERA';
    } catch (_) {
      return false;
    }
  }
}

// ===== MAIN APP ENTRY =====
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyStore = KeyStore();
  await keyStore.init();
  final accountManager = AccountManager();
  await accountManager.loadAccounts();

  runApp(
    flutter_provider.MultiProvider(
      providers: [
        flutter_provider.ChangeNotifierProvider(create: (_) => keyStore),
        flutter_provider.ChangeNotifierProvider(create: (_) => accountManager),
        flutter_provider.ChangeNotifierProvider(
          create: (_) => EraWalletProvider(),
        ),
      ],
      child: const EraWalletApp(),
    ),
  );
}

class EraWalletApp extends StatefulWidget {
  const EraWalletApp({super.key});

  @override
  State<EraWalletApp> createState() => _EraWalletAppState();
}

// Session expiry: if app is backgrounded > 1 minute, lock and force re-auth
class _EraWalletAppState extends State<EraWalletApp>
    with WidgetsBindingObserver {
  DateTime? _lastInactiveAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lastInactiveAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastInactiveAt == null) return;
      final elapsed = DateTime.now().difference(_lastInactiveAt!);
      if (elapsed > const Duration(minutes: 1)) {
        final ctx = rootNavigatorKey.currentContext ?? context;
        try {
          final ks = flutter_provider.Provider.of<KeyStore>(ctx, listen: false);
          if (ks.hasWallet && ks.unlocked) {
            ks.lock();
            rootNavigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PinUnlockScreen()),
              (route) => false,
            );
          }
        } catch (_) {
          // ignore if provider not ready
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'ERA Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // First-run + gate logic
      home: const SplashDecider(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ===== SPLASH DECIDER (first run vs normal flow) =====
class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDecState();
}

class _SplashDecState extends State<SplashDecider> {
  bool _loading = true;
  bool _showSplash = false;

  @override
  void initState() {
    super.initState();
    _checkFirstStart();
  }

  Future<void> _checkFirstStart() async {
    final seen = await _secure.read(key: 'has_seen_splash');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _showSplash = seen != 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showSplash) {
      return FirstRunSplashScreen(
        onFinished: () async {
          await _secure.write(key: 'has_seen_splash', value: 'true');
          if (!mounted) return;
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return const GateScreen();
  }
}

// ===== FIRST-RUN LUXURY SPLASH SCREEN =====
class FirstRunSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const FirstRunSplashScreen({super.key, required this.onFinished});

  @override
  State<FirstRunSplashScreen> createState() => _FirstRunSplashScreenState();
}

class _FirstRunSplashScreenState extends State<FirstRunSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-continue after short delay
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      widget.onFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(kEraIconPath, width: 96, height: 96),
            const SizedBox(height: 24),
            Text(
              'ERA Wallet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your private island for digital assets.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== GATE SCREEN =====
class GateScreen extends StatelessWidget {
  const GateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ks = flutter_provider.Provider.of<KeyStore>(context);
    if (!ks.hasWallet) {
      return const PinSetupScreen();
    }
    if (!ks.unlocked) {
      return const PinUnlockScreen();
    }
    return const WalletHomeScreen();
  }
}

// ===== PIN SETUP SCREEN (PIN ONLY) =====
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});
  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ks = flutter_provider.Provider.of<KeyStore>(context, listen: false);

    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('ERA Wallet — Setup PIN'),
          ],
        ),
      ),
      body: ListView(
        children: [
          Center(child: Image.asset(kEraIconPath, width: 72, height: 72)),
          const SizedBox(height: 12),
          const Text(
            'Create a PIN to protect your wallet. '
            'After this, you will create your first account and get its mnemonic.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pin1,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pin2,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    final a = _pin1.text.trim();
                    final b = _pin2.text.trim();
                    if (a.length < 4 || a != b) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PINs must match and be at least 4 digits.',
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() => _saving = true);
                    try {
                      await ks.setupPin(pin: a);
                      if (!context.mounted) return;
                      // After setting PIN, go directly to "Create Account" screen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AddAccountScreen(),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to setup PIN: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            icon: const Icon(Icons.check),
            label: Text(_saving ? 'Setting up...' : 'Create PIN'),
          ),
        ],
      ),
    );
  }
}

// ===== PIN UNLOCK SCREEN (BIOMETRIC FIRST) =====
class PinUnlockScreen extends StatefulWidget {
  const PinUnlockScreen({super.key});
  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final _pin = TextEditingController();
  bool _busy = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    // Try biometric automatically when unlock screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricUnlock();
    });
  }

  Future<void> _tryBiometricUnlock() async {
    final ks = flutter_provider.Provider.of<KeyStore>(context, listen: false);

    try {
      // Optional debug to see what the device reports (very useful on Android)
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final available = await _localAuth.getAvailableBiometrics();
      debugPrint(
        'LocalAuth unlock: canCheck=$canCheck, isSupported=$isSupported, '
        'availableBiometrics=$available',
      );

      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock ERA Wallet',
        // Allow OS to choose best method: fingerprint/face/PIN/etc.
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      if (!didAuth) return;

      ks.forceUnlock();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WalletHomeScreen()),
      );
    } catch (e) {
      debugPrint('Biometric / device auth unlock failed: $e');
      // Fallback is the PIN field already on this screen.
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ks = flutter_provider.Provider.of<KeyStore>(context);
    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('ERA Wallet — Unlock'),
          ],
        ),
      ),
      body: ListView(
        children: [
          Center(child: Image.asset(kEraIconPath, width: 72, height: 72)),
          const SizedBox(height: 12),
          const Text(
            'Use biometric/device authentication if available.\nOr enter your PIN to unlock.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    final ok = await ks.unlockWithPin(_pin.text.trim());
                    if (!context.mounted) return;
                    setState(() => _busy = false);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid PIN')),
                      );
                      return;
                    }
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WalletHomeScreen(),
                      ),
                    );
                  },
            icon: const Icon(Icons.lock_open),
            label: Text(_busy ? 'Unlocking...' : 'Unlock'),
          ),
        ],
      ),
    );
  }
}

// ===== ACCOUNTS SCREEN =====
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  AccountManager? _accountManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accountManager ??= flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    // Once user leaves this screen, don't show mnemonics again.
    _accountManager?.clearAllPendingRevealMnemonics();
    super.dispose();
  }

  /// Render mnemonic as a normal wrapped block that fills the screen width.
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
              await am.setActive(acc.id);
              if (!context.mounted) return;
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
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
                    // ACTION ICONS BELOW THE ADDRESS
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
                        AccountQrButton(
                          accountName: acc.name,
                          address: acc.address,
                        ),
                        if (isActive)
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            tooltip: 'Show mnemonic (requires PIN/biometric)',
                            onPressed: () async {
                              // Use same auth helper as send/stake, but we only need gating
                              final authResult =
                                  await authenticateWalletForSensitiveAction(
                                    context,
                                    reason: 'Authenticate to view seed phrase',
                                  );
                              if (!authResult.success) return;
                              if (!context.mounted) return;

                              final amLocal =
                                  flutter_provider.Provider.of<AccountManager>(
                                    context,
                                    listen: false,
                                  );

                              final mnemonic = await amLocal
                                  .loadMnemonicForAccount(acc.id);
                              if (!context.mounted) return;
                              if (mnemonic == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No mnemonic stored for this account on this device.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              amLocal.markMnemonicForReveal(acc.id, mnemonic);

                              ScaffoldMessenger.of(context).showSnackBar(
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

                            if (confirmed == true) {
                              await am.deleteAccount(acc.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
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
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: pendingMnemonic),
                                  );
                                  // Hide this mnemonic after copy
                                  final amLocal =
                                      flutter_provider.Provider.of<
                                        AccountManager
                                      >(context, listen: false);
                                  amLocal.clearPendingRevealForAccount(acc.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Mnemonic copied for "${acc.name}". Keep it safe!',
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
                // Single tap: just select, stay on screen
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
          ).push(MaterialPageRoute(builder: (_) => const AddAccountScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}

// ===== ADD / CREATE ACCOUNT SCREEN =====
class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

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
            '• Create new mnemonic (default)\n'
            '• Import existing mnemonic',
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
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please paste a mnemonic to import.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (!bip39.validateMnemonic(mnemonic)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Imported mnemonic is not a valid BIP39 phrase.',
                              ),
                            ),
                          );
                          return;
                        }
                      } else {
                        // mnemonic will be generated in addAccount()
                        mnemonic = null;
                      }

                      await am.addAccount(name: name, mnemonic: mnemonic);

                      if (!context.mounted) return;
                      // After account creation, go to WalletHomeScreen.
                      // WalletHomeScreen will detect pending mnemonic and push AccountsScreen.
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const WalletHomeScreen(),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
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

// ===== WALLET HOME SCREEN =====
class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});
  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  BigInt? _balance;
  String? _lastAccountId;
  bool _isRefreshingBalance = false;
  String? _refreshingForAccountId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFlow());
  }

  Future<void> _initFlow() async {
    if (!mounted) return;
    final ep = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    await ep.connect();
    if (!mounted) return;

    debugPrint('ERA WS endpoint at runtime: $kDefaultEraWsEndpoint');

    if (ep.provider != null) {
      try {
        final chainName = await ep.provider!.send('system_chain', []);
        debugPrint('Connected to chain: ${chainName.result}');
      } catch (e) {
        debugPrint('RPC health check failed: $e');
      }
    }

    if (ep.api != null && mounted) {
      await _refreshBalance();
    }

    // After balance refresh, check if active account has pending mnemonic:
    if (!mounted) return;
    final am = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final acc = am.active;
    if (acc != null) {
      final pending = am.getPendingRevealMnemonic(acc.id);
      if (pending != null) {
        // Automatically open AccountsScreen so user sees mnemonic.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AccountsScreen()));
        });
      }
    }
  }

  Future<void> _refreshBalance({bool showErrors = true}) async {
    if (!mounted) return;

    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );

    // Make sure we are really connected (handles node down / reconnect)
    final ok = await chain.ensureConnected();
    if (!mounted) return;
    if (!ok || chain.api == null) {
      if (showErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
      }
      return;
    }

    final api = chain.api!;

    final am = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final acc = am.active;
    if (acc == null) {
      if (!mounted) return;
      if (showErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active account to refresh balance for'),
          ),
        );
      }
      return;
    }

    final String requestedAccountId = acc.id;

    setState(() {
      _isRefreshingBalance = true;
      _refreshingForAccountId = requestedAccountId;
    });

    try {
      final keyring = Keyring();

      // decode SS58 address to AccountId32 bytes
      final publicKey = keyring.decodeAddress(acc.address);

      final accountInfo = await api.query.system.account(
        Uint8List.fromList(publicKey),
      );

      final dynamic freeRaw = accountInfo.data.free;
      final BigInt free = freeRaw is BigInt
          ? freeRaw
          : BigInt.parse(freeRaw.toString());

      if (!mounted) return;

      final currentId = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      ).active?.id;

      if (currentId != requestedAccountId) {
        // active account changed while we were loading -> ignore stale result
        return;
      }

      setState(() {
        _balance = free;
        _lastAccountId = requestedAccountId;
      });
    } on StateError catch (e) {
      if (!mounted) return;

      final msg = e.toString();
      // Safer: don't overwrite known balance with 0 on "No element"
      if (showErrors) {
        if (msg.contains('No element')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Balance unavailable for this account (No element from node).',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error fetching balance: $e')));
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Network / RPC error: DON'T overwrite balance, just notify
      if (showErrors) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching balance: $e')));
      }
    } finally {
      if (mounted && _refreshingForAccountId == requestedAccountId) {
        setState(() {
          _isRefreshingBalance = false;
          _refreshingForAccountId = null;
        });
      }
    }
  }

  Future<void> _refreshBalanceUntilChanged({
    BigInt? before,
    int attempts = 10,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      await Future.delayed(delay);
      await _refreshBalance(showErrors: false);

      if (!mounted) return;

      // If we had no previous balance, one successful refresh is enough.
      if (before == null && _balance != null) {
        return;
      }

      // Stop once balance actually changes.
      if (before != null && _balance != before) {
        return;
      }
    }
  }

  Future<void> _openSend() async {
    final before = _balance;

    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const SendScreen()));
    if (result == true) {
      await _refreshBalanceUntilChanged(before: before);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer processed. Balance refreshed.')),
      );
    }
  }

  Future<void> _openStaking() async {
    final before = _balance;

    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const StakingScreen()));
    if (result == true) {
      await _refreshBalanceUntilChanged(before: before);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staking action processed. Balance refreshed.'),
        ),
      );
    }
  }

  Future<void> _openV14Operations() async {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final accounts = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final selected = accounts.active;
    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select an account first.')));
      return;
    }
    final connected = await chain.ensureConnected();
    if (!mounted) return;
    if (!connected || chain.provider == null || chain.api == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to the ERA node.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => V14OperationsScreen(
          provider: chain.provider!,
          api: chain.api!,
          selectedAccount: selected.address,
          authenticateAndLoadMnemonic: (reason) async {
            if (!mounted || accounts.active?.id != selected.id) return null;
            final result = await authenticateWalletForSensitiveAction(
              context,
              reason: reason,
            );
            if (!result.success || accounts.active?.id != selected.id) {
              return null;
            }
            return accounts.loadMnemonicForAccount(selected.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(context);
    final am = flutter_provider.Provider.of<AccountManager>(context);

    final currentId = am.active?.id;
    if (currentId != _lastAccountId) {
      _lastAccountId = currentId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _balance = null;
        });
        _refreshBalance();
      });
    }

    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('ERA Wallet'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Accounts',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AccountsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Send Funds',
            onPressed: _openSend,
          ),
          IconButton(
            icon: const Icon(Icons.stacked_line_chart),
            tooltip: 'Staking',
            onPressed: _openStaking,
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark),
            tooltip: 'V14 NFTs and SecurityBudget rewards',
            onPressed: _openV14Operations,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh balance',
            onPressed: _isRefreshingBalance ? null : _refreshBalance,
          ),
        ],
      ),
      body: ListView(
        children: [
          _connectionStatusWidget(chain),
          const SizedBox(height: 16),
          _accountCard(am),
        ],
      ),
    );
  }

  Widget _connectionStatusWidget(EraWalletProvider wp) {
    String label;
    Color color;
    switch (wp.connectionState) {
      case WalletConnectionState.connected:
        label = 'Connected to ERA node.';
        color = Colors.green;
        break;
      case WalletConnectionState.connecting:
        label = 'Connecting...';
        color = Colors.orange;
        break;
      case WalletConnectionState.error:
        label = 'Connection error: ${wp.connectionError}';
        color = Colors.red;
        break;
      default:
        label = 'Disconnected.';
        color = Colors.grey;
    }
    return Row(
      children: [
        Icon(Icons.link, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _accountCard(AccountManager am) {
    final acc = am.active;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(kEraIconPath, width: 40, height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    acc?.name ?? 'No active account',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (acc != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SelectableText(
                            acc.address,
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy address',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: acc.address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Address copied to clipboard'),
                              ),
                            );
                          },
                        ),
                        AccountQrButton(
                          accountName: acc.name,
                          address: acc.address,
                        ),
                      ],
                    )
                  else
                    const Text('—'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Balance: ${formatEra(_balance)} ERA',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isRefreshingBalance) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== PIN PROMPT DIALOG =====
class _PinPromptDialog extends StatefulWidget {
  const _PinPromptDialog();

  @override
  State<_PinPromptDialog> createState() => _PinPromptDialogState();
}

class _PinPromptDialogState extends State<_PinPromptDialog> {
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter PIN'),
      content: TextField(
        controller: _pin,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'PIN',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _pin.text.trim()),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// ===== AUTH HELPER (BIOMETRIC FIRST, THEN PIN) =====
class AuthResult {
  final bool success;
  final String? pin; // only set when PIN was entered
  AuthResult(this.success, this.pin);
}

Future<AuthResult> authenticateWalletForSensitiveAction(
  BuildContext context, {
  required String reason,
}) async {
  final ks = flutter_provider.Provider.of<KeyStore>(context, listen: false);
  final localAuth = LocalAuthentication();

  // 1) Try OS-level auth (biometrics or device credentials)
  try {
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();
    final available = await localAuth.getAvailableBiometrics();
    debugPrint(
      'LocalAuth sensitive: canCheck=$canCheck, isSupported=$isSupported, '
      'availableBiometrics=$available',
    );

    final didAuth = await localAuth.authenticate(
      localizedReason: reason,
      biometricOnly: false,
      sensitiveTransaction: true,
      persistAcrossBackgrounding: true,
    );

    if (didAuth) {
      // OS auth succeeded, no wallet PIN needed
      return AuthResult(true, null);
    }
  } catch (e) {
    debugPrint('Biometric / device auth error: $e');
    // Fall through to PIN
  }

  // 2) Fallback to wallet PIN
  if (!context.mounted) return AuthResult(false, null);
  final pin = await showDialog<String>(
    context: context,
    builder: (_) => const _PinPromptDialog(),
  );
  if (pin == null) {
    return AuthResult(false, null);
  }

  final ok = await ks.unlockWithPin(pin);
  if (!ok) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid PIN')));
    }
    return AuthResult(false, null);
  }

  return AuthResult(true, pin);
}

// ===== TRANSACTION SERVICE =====
class TxService {
  final polkadart.Provider provider;
  final era_api.Era api;

  TxService(this.provider, this.api);

  /// Proper fee estimation by building a real extrinsic and calling
  /// `payment_queryInfo` with the SCALE-encoded extrinsic bytes.
  Future<BigInt?> estimateFee({
    required String fromMnemonic,
    required String toAddress,
    required BigInt amount,
  }) async {
    await EraV14RuntimeGuard(provider).verify();
    try {
      final keyring = Keyring();
      final wallet = await deriveWalletKeyPair(fromMnemonic.trim());
      final signerAddress = wallet.address;

      debugPrint('FEE: estimating for signer: $signerAddress');
      debugPrint('FEE: dest: $toAddress, amount: $amount');

      // 1) Chain context – same as in sendTransfer
      final runtimeVersion = await api.rpc.state.getRuntimeVersion();
      final currentBlockNumber = (await api.query.system.number()) - 1;
      final currentBlockHash = await api.query.system.blockHash(
        currentBlockNumber,
      );
      final genesisHash = await api.query.system.blockHash(0);
      final nonce = await api.rpc.system.accountNextIndex(signerAddress);

      // 2) Destination MultiAddress
      final destPublicKey = keyring.decodeAddress(toAddress);
      final multiAddress = era_multi.Id(
        Uint8List.fromList(destPublicKey),
      ); // Id variant

      // 3) Build balances.transferAllowDeath call
      final transferCall = api.tx.balances.transferAllowDeath(
        dest: multiAddress,
        value: amount,
      );
      final encodedCall = transferCall.encode();

      // 4) Signing payload (same structure as sendTransfer)
      final payload = polkadart.SigningPayload(
        method: encodedCall,
        specVersion: runtimeVersion.specVersion,
        transactionVersion: runtimeVersion.transactionVersion,
        genesisHash: encodeHex(genesisHash),
        blockHash: encodeHex(currentBlockHash),
        blockNumber: currentBlockNumber,
        eraPeriod: 64,
        nonce: nonce,
        tip: 0,
      ).encode(api.registry);

      // 5) Real signature – we’re using the actual key here
      final signature = await signWalletPayload(wallet, payload);

      // 6) Build full extrinsic bytes
      final extrinsicBytes = polkadart.ExtrinsicPayload(
        signer: wallet.bytes(),
        method: encodedCall,
        signature: signature,
        eraPeriod: 64,
        blockNumber: currentBlockNumber,
        nonce: nonce,
        tip: 0,
      ).encode(api.registry, polkadart.SignatureType.sr25519);

      final extrinsicHex = '0x${encodeHex(extrinsicBytes)}';

      // 7) Call payment_queryInfo with the *encoded extrinsic*, as required
      final resp = await provider.send('payment_queryInfo', [extrinsicHex]);

      final result = resp.result;
      debugPrint('FEE: payment_queryInfo result = $result');

      if (result == null) return null;

      // polkadart may decode to Map<String, dynamic> or a typed object.
      // Handle both hex and decimal representations of partialFee.
      dynamic partial = (result is Map) ? result['partialFee'] : null;
      if (partial == null) return null;

      final feeStr = partial.toString();
      if (feeStr.startsWith('0x')) {
        return BigInt.parse(feeStr.substring(2), radix: 16);
      } else {
        return BigInt.parse(feeStr);
      }
    } catch (e, st) {
      debugPrint('FEE: estimateFee error: $e');
      debugPrint('FEE: stack: $st');
      return null;
    }
  }

  /// Build, sign, and submit a balances transfer using the
  /// official Polkadart SigningPayload / ExtrinsicPayload flow.
  Future<String> sendTransfer({
    required String fromMnemonic,
    required String toAddress,
    required BigInt amount,
  }) async {
    await EraV14RuntimeGuard(provider).verify();
    final keyring = Keyring();
    final wallet = await deriveWalletKeyPair(fromMnemonic.trim());
    final signerAddress = wallet.address;

    debugPrint('TxService.sendTransfer -> signer: $signerAddress');
    debugPrint('TxService.sendTransfer -> dest:   $toAddress');
    debugPrint('TxService.sendTransfer -> amount: $amount');

    // 1) Chain context for the extrinsic
    final runtimeVersion = await api.rpc.state.getRuntimeVersion();
    final currentBlockNumber = (await api.query.system.number()) - 1;
    final currentBlockHash = await api.query.system.blockHash(
      currentBlockNumber,
    );
    final genesisHash = await api.query.system.blockHash(0);
    final nonce = await api.rpc.system.accountNextIndex(signerAddress);

    // 2) Destination MultiAddress (Id variant, passing bytes directly)
    final destPublicKey = keyring.decodeAddress(toAddress);
    final multiAddress = era_multi.Id(
      Uint8List.fromList(destPublicKey),
    ); // Id variant

    // 3) Build balances.transferAllowDeath call and encode
    final transferCall = api.tx.balances.transferAllowDeath(
      dest: multiAddress,
      value: amount,
    );
    final encodedCall = transferCall.encode();

    // 4) Create signing payload
    final payload = polkadart.SigningPayload(
      method: encodedCall,
      specVersion: runtimeVersion.specVersion,
      transactionVersion: runtimeVersion.transactionVersion,
      genesisHash: encodeHex(genesisHash),
      blockHash: encodeHex(currentBlockHash),
      blockNumber: currentBlockNumber,
      eraPeriod: 64,
      nonce: nonce,
      tip: 0,
    ).encode(api.registry);

    // 5) Sign payload
    final signature = await signWalletPayload(wallet, payload);

    // 6) Build final extrinsic and encode
    final extrinsic = polkadart.ExtrinsicPayload(
      signer: wallet.bytes(),
      method: encodedCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: currentBlockNumber,
      nonce: nonce,
      tip: 0,
    ).encode(api.registry, polkadart.SignatureType.sr25519);

    // 7) Submit via AuthorApi
    final author = polkadart.AuthorApi(provider);
    final hashBytes = await author.submitExtrinsic(
      Uint8List.fromList(extrinsic),
    );
    final txHash = '0x${encodeHex(hashBytes)}';

    return txHash;
  }
}

// ===== SEND SCREEN =====
class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  BigInt? _estimatedFee;
  bool _estimating = false;
  bool _sending = false;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scanRecipientAddress() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!recipientQrScannerSupported()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Camera QR scanning is available in the Android wallet. Paste the public recipient address on this platform.',
          ),
        ),
      );
      return;
    }

    final scannedAddress = await showRecipientQrScanner(context);
    if (!mounted || scannedAddress == null) return;

    final address = normalizeRecipientQrPayload(scannedAddress);
    if (address == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('The QR code does not contain a valid public address.'),
        ),
      );
      return;
    }

    setState(() {
      _toController.text = address;
      _toController.selection = TextSelection.collapsed(offset: address.length);
      _estimatedFee = null;
    });
  }

  Future<void> _showSubmittedDialog({
    required String title,
    required String hash,
    required String body,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SelectableText('$body\n\nTransaction hash:\n$hash'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _estimateFee() async {
    try {
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final am = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      final acc = am.active;

      if (acc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
        return;
      }

      final amount = parseEraToUnits(_amountController.text.trim());
      if (amount == null || amount <= BigInt.zero) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
        return;
      }

      final connected = await chain.ensureConnected();
      if (!mounted) return;
      if (!connected || chain.provider == null || chain.api == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
        return;
      }

      // 🔐 Authenticate first (biometric / device auth, then PIN fallback)
      final auth = await authenticateWalletForSensitiveAction(
        context,
        reason: 'Authenticate to estimate fee for this transfer',
      );
      if (!auth.success) {
        return;
      }

      // 🔑 Load mnemonic (per-account storage first, then legacy migration)
      String? accountMnemonic = await am.loadMnemonicForAccount(acc.id);

      if (accountMnemonic == null) {
        debugPrint('FEE: no per-account mnemonic, trying legacy migration...');
        final legacy = await _tryLoadLegacyMnemonicForAccount(
          pin: auth.pin,
          accountAddress: acc.address,
        );
        if (legacy != null) {
          await am.storeMnemonicForAccount(acc.id, legacy, revealOnce: false);
          accountMnemonic = legacy;
        }
      }

      if (accountMnemonic == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No mnemonic stored for this account on this device.\n'
              'Please remove and re-add this account (with its seed phrase) to enable fee estimation and sending.',
            ),
          ),
        );
        return;
      }

      final trimmedMnemonic = accountMnemonic.trim();
      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored seed phrase for this account is not a valid BIP39 mnemonic.\n'
              'Please remove this account and re-import it with the correct phrase.',
            ),
          ),
        );
        return;
      }

      // Double-check that mnemonic really matches the active address
      final signerWallet = await deriveWalletKeyPair(trimmedMnemonic);
      final signerAddress = signerWallet.address;

      if (signerAddress != acc.address) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored mnemonic for this account does not match its address.\n'
              'Please remove and re-add the account with the correct seed.',
            ),
          ),
        );
        return;
      }

      setState(() => _estimating = true);
      try {
        final txService = TxService(chain.provider!, chain.api!);
        final fee = await txService.estimateFee(
          fromMnemonic: trimmedMnemonic,
          toAddress: _toController.text.trim(),
          amount: amount,
        );

        if (!mounted) return;

        if (fee == null) {
          _estimatedFee = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fee estimation not available (node did not return partialFee).',
              ),
            ),
          );
        } else {
          setState(() {
            _estimatedFee = fee;
          });
        }
      } finally {
        if (mounted) setState(() => _estimating = false);
      }
    } catch (e, st) {
      debugPrint('FEE: unexpected error: $e');
      debugPrint('FEE: stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected fee estimation error: $e')),
      );
    }
  }

  /// Try to migrate legacy global mnemonic (if any) to this account,
  /// using the PIN provided for this send (if any).
  Future<String?> _tryLoadLegacyMnemonicForAccount({
    required String? pin,
    required String accountAddress,
  }) async {
    if (pin == null || pin.isEmpty) {
      return null;
    }

    try {
      final saltB64 = await _secure.read(key: StorageKeys.pinSalt);
      final blob = await _secure.read(key: StorageKeys.mnemonicBlob);
      final nonce = await _secure.read(key: StorageKeys.mnemonicNonce);

      if (saltB64 == null || blob == null || nonce == null) {
        debugPrint('SEND: no legacy mnemonic blob/nonce found.');
        return null;
      }

      final salt = base64Decode(saltB64);
      final key = await PinCrypto.deriveKeyFromPin(pin, salt);

      final mnemonic = await PinCrypto.decryptLegacyMnemonic(blob, nonce, key);
      final trimmed = mnemonic.trim();

      if (!bip39.validateMnemonic(trimmed)) {
        debugPrint('SEND: legacy mnemonic failed BIP39 validation.');
        return null;
      }

      final wallet = await deriveWalletKeyPair(trimmed);
      final derivedAddress = wallet.address;

      debugPrint('SEND: legacy mnemonic address: $derivedAddress');

      if (derivedAddress != accountAddress) {
        debugPrint(
          'SEND: legacy mnemonic address does not match active account.',
        );
        return null;
      }

      debugPrint('SEND: legacy mnemonic MATCHES active account, migrating.');
      return trimmed;
    } catch (e) {
      debugPrint('SEND: legacy mnemonic decrypt/match failed: $e');
      return null;
    }
  }

  Future<void> _send() async {
    debugPrint('SEND: tapped');

    try {
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final am = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      final acc = am.active;

      // 1) Validate active account
      if (acc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
        return;
      }

      // 2) Validate amount
      final amount = parseEraToUnits(_amountController.text.trim());
      if (amount == null || amount <= BigInt.zero) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
        return;
      }

      // 3) Make sure we are connected
      debugPrint('SEND: ensuring connection...');
      final connected = await chain.ensureConnected();
      if (!mounted) return;
      if (!connected || chain.provider == null || chain.api == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
        return;
      }

      // 4) Biometric first, then PIN fallback
      debugPrint('SEND: authenticating...');
      final auth = await authenticateWalletForSensitiveAction(
        context,
        reason: 'Authenticate to send ERA',
      );
      if (!auth.success) {
        debugPrint('SEND: auth failed/cancelled');
        return;
      }

      // 5) Load mnemonic for the ACTIVE ACCOUNT (cache first, then per-account storage)
      String? accountMnemonic = await am.loadMnemonicForAccount(acc.id);

      // 5b) Migration: if still null and PIN exists, try legacy global mnemonic
      if (accountMnemonic == null) {
        debugPrint('SEND: no per-account mnemonic, trying legacy migration...');
        final legacy = await _tryLoadLegacyMnemonicForAccount(
          pin: auth.pin,
          accountAddress: acc.address,
        );
        if (legacy != null) {
          // store & cache for future sends, but don't auto-display in Accounts screen
          await am.storeMnemonicForAccount(acc.id, legacy, revealOnce: false);
          accountMnemonic = legacy;
        }
      }

      if (accountMnemonic == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No mnemonic stored for this account on this device.\n'
              'Please remove and re-add this account (with its seed phrase) to enable sending.',
            ),
          ),
        );
        return;
      }

      final trimmedMnemonic = accountMnemonic.trim();

      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored seed phrase for this account is not a valid BIP39 mnemonic.\n'
              'Please remove this account and re-import it with the correct phrase.',
            ),
          ),
        );
        debugPrint(
          'SEND: invalid BIP39 mnemonic for active account, aborting send.',
        );
        return;
      }

      final signerWallet = await deriveWalletKeyPair(trimmedMnemonic);
      final signerAddress = signerWallet.address;

      debugPrint('SEND: UI active address: ${acc.address}');
      debugPrint('SEND: signer address:    $signerAddress');

      if (signerAddress != acc.address) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored mnemonic for this account does not match its address.\n'
              'Please remove and re-add the account with the correct seed.',
            ),
          ),
        );
        return;
      }

      // 6) Actually send
      setState(() => _sending = true);
      try {
        debugPrint('SEND: building and submitting extrinsic...');
        final txService = TxService(chain.provider!, chain.api!);
        final hash = await txService.sendTransfer(
          fromMnemonic: trimmedMnemonic,
          toAddress: _toController.text.trim(),
          amount: amount,
        );
        if (!mounted) return;

        final msg = 'Transaction submitted: $hash';
        debugPrint('SEND: $msg');

        FocusScope.of(context).unfocus();
        _toController.clear();
        _amountController.clear();

        if (mounted) {
          setState(() {
            _estimatedFee = null;
          });
        }

        await _showSubmittedDialog(
          title: 'Transfer submitted',
          hash: hash,
          body:
              'Your transfer was submitted successfully.\n'
              'The wallet will now refresh your balance automatically.',
        );

        if (!mounted) return;
        Navigator.pop(context, true); // tell home screen to refresh balance
      } catch (e) {
        if (!mounted) return;
        debugPrint('SEND: sendTransfer threw: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Send failed: $e')));
      } finally {
        if (mounted) setState(() => _sending = false);
      }
    } catch (e, st) {
      debugPrint('SEND: unexpected error: $e');
      debugPrint('SEND: stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected send error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Send Funds'),
          ],
        ),
      ),
      body: ListView(
        children: [
          TextField(
            controller: _toController,
            decoration: InputDecoration(
              labelText: 'Recipient Address',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Scan recipient QR code',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanRecipientAddress,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (ERA)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (_estimatedFee != null)
            Text(
              'Estimated Fee: ${formatEra(_estimatedFee)} ERA',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _estimating ? null : _estimateFee,
                  child: Text(_estimating ? 'Estimating...' : 'Estimate Fee'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _sending ? null : _send,
                  child: Text(_sending ? 'Sending...' : 'Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== STAKING SCREEN (COMBINED BOND + NOMINATE + UNBOND) =====
class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  final _bondAmountController = TextEditingController();
  final _validatorAddressController = TextEditingController();
  final _unbondAmountController = TextEditingController();

  bool _submitting = false;

  // Staking status
  BigInt? _bondedAmount;
  List<String> _activeTargets = [];
  bool _loadingStatus = false;

  // Validators list
  List<String> _validators = [];
  String? _selectedValidator;
  bool _loadingValidators = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStakingStatus();
      _loadValidators();
    });
  }

  @override
  void dispose() {
    _bondAmountController.dispose();
    _validatorAddressController.dispose();
    _unbondAmountController.dispose();
    super.dispose();
  }

  void _clearBondForm() {
    FocusScope.of(context).unfocus();
    setState(() {
      _bondAmountController.text = '';
    });
  }

  void _clearUnbondForm() {
    FocusScope.of(context).unfocus();
    setState(() {
      _unbondAmountController.text = '';
    });
  }

  bool _sameStringSet(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b) && b.toSet().containsAll(a);
  }

  Future<void> _waitForStakingRefresh({
    BigInt? previousBonded,
    List<String>? previousTargets,
    int attempts = 10,
    Duration delay = const Duration(seconds: 2),
  }) async {
    final oldTargets = previousTargets ?? const <String>[];

    for (var i = 0; i < attempts; i++) {
      await Future.delayed(delay);
      await _loadStakingStatus();

      if (!mounted) return;

      final bondedChanged = _bondedAmount != previousBonded;
      final targetsChanged = !_sameStringSet(_activeTargets, oldTargets);

      if (bondedChanged || targetsChanged) {
        return;
      }
    }
  }

  Future<void> _showStakingSubmittedDialog({
    required String title,
    required String body,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStakingStatus() async {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final am = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final acc = am.active;

    if (acc == null) {
      setState(() {
        _bondedAmount = null;
        _activeTargets = [];
      });
      return;
    }

    final connected = await chain.ensureConnected();
    if (!connected || chain.api == null) {
      return;
    }

    final api = chain.api!;
    final keyring = Keyring();

    setState(() => _loadingStatus = true);

    try {
      debugPrint(
        'STAKING: status for active account (controller?) ${acc.address}',
      );

      // 1) Decode active account SS58 -> raw 32 bytes
      final controllerPk = keyring.decodeAddress(acc.address);
      final List<int> controllerId = controllerPk.toList();

      BigInt? bonded;
      List<int> nominatorsKey = controllerId; // default to controller
      String nominatorsKeySs58 = acc.address;

      // 2) staking.ledger(controller) to get bonded + stash
      try {
        final ledger = await api.query.staking.ledger(controllerId);
        debugPrint('STAKING: ledger = $ledger');

        if (ledger != null) {
          final dynamic d = ledger;

          // active bonded
          final dynamic activeField = d.active;
          if (activeField is BigInt) {
            bonded = activeField;
          } else {
            bonded = BigInt.parse(activeField.toString());
          }

          // stash is also AccountId32 = List<int>
          try {
            final dynamic stashField = d.stash;
            if (stashField is List<int>) {
              final List<int> stashBytes = List<int>.from(stashField);
              if (stashBytes.length == 32) {
                final ss58 = keyring.encodeAddress(
                  Uint8List.fromList(stashBytes),
                );
                debugPrint(
                  'STAKING: ledger.stash = $ss58 (using this as nominators key)',
                );
                nominatorsKey = stashBytes;
                nominatorsKeySs58 = ss58;
              } else {
                debugPrint(
                  'STAKING: ledger.stash length=${stashBytes.length}, expected 32',
                );
              }
            } else {
              debugPrint(
                'STAKING: ledger.stash is not List<int>, using controller as nominators key',
              );
            }
          } catch (e) {
            debugPrint('STAKING: error decoding ledger.stash: $e');
          }
        }
      } catch (e) {
        debugPrint('STAKING: error reading ledger: $e');
      }

      // 3) staking.nominators(nominatorsKey) with AccountId32 = List<int>
      final List<String> targets = [];
      try {
        final staking_noms.Nominations? nominatorsOpt = await api.query.staking
            .nominators(nominatorsKey);

        debugPrint(
          'STAKING: nominatorsOpt = $nominatorsOpt '
          '(runtimeType=${nominatorsOpt?.runtimeType}) '
          'for nominators key $nominatorsKeySs58',
        );

        if (nominatorsOpt != null) {
          // nominatorsOpt.targets is List<AccountId32> = List<List<int>>
          for (final targetBytes in nominatorsOpt.targets) {
            try {
              final Uint8List b = Uint8List.fromList(targetBytes);
              final ss58 = keyring.encodeAddress(b);
              targets.add(ss58);
            } catch (e) {
              debugPrint('STAKING: skipping target $targetBytes: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('STAKING: error reading nominators for active account: $e');
      }

      if (!mounted) return;
      setState(() {
        _bondedAmount = bonded;
        _activeTargets = targets;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingStatus = false);
      }
    }
  }

  Future<void> _loadValidators() async {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );

    final connected = await chain.ensureConnected();
    if (!connected || chain.api == null) return;

    final api = chain.api!;
    final keyring = Keyring();

    setState(() => _loadingValidators = true);

    try {
      final rawValidators = await api.query.session.validators();
      final List<String> vals = [];
      for (final v in rawValidators) {
        vals.add(keyring.encodeAddress(Uint8List.fromList(v)));
      }

      if (!mounted) return;
      setState(() {
        _validators = vals;
        if (vals.isNotEmpty && _selectedValidator == null) {
          _selectedValidator = vals.first;
          _validatorAddressController.text = _selectedValidator!;
        }
      });
    } catch (e) {
      debugPrint('STAKING: loadValidators error: $e');
    } finally {
      if (mounted) setState(() => _loadingValidators = false);
    }
  }

  Future<String> _signAndSubmit(
    era_api.Era api,
    polkadart.Provider provider,
    Keyring keyring,
    dynamic wallet,
    String signerAddress,
    Uint8List encodedCall, {
    int? explicitNonce,
  }) async {
    await EraV14RuntimeGuard(provider).verify();
    final runtimeVersion = await api.rpc.state.getRuntimeVersion();
    final currentBlockNumber = (await api.query.system.number()) - 1;
    final currentBlockHash = await api.query.system.blockHash(
      currentBlockNumber,
    );
    final genesisHash = await api.query.system.blockHash(0);

    final nonceRaw =
        explicitNonce ?? await api.rpc.system.accountNextIndex(signerAddress);
    final int nonce = nonceRaw is BigInt ? nonceRaw.toInt() : nonceRaw;

    final payload = polkadart.SigningPayload(
      method: encodedCall,
      specVersion: runtimeVersion.specVersion,
      transactionVersion: runtimeVersion.transactionVersion,
      genesisHash: encodeHex(genesisHash),
      blockHash: encodeHex(currentBlockHash),
      blockNumber: currentBlockNumber,
      eraPeriod: 64,
      nonce: nonce,
      tip: 0,
    ).encode(api.registry);

    final signature = await signWalletPayload(wallet, payload);

    final extrinsic = polkadart.ExtrinsicPayload(
      signer: wallet.bytes(),
      method: encodedCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: currentBlockNumber,
      nonce: nonce,
      tip: 0,
    ).encode(api.registry, polkadart.SignatureType.sr25519);

    final author = polkadart.AuthorApi(provider);
    final hashBytes = await author.submitExtrinsic(
      Uint8List.fromList(extrinsic),
    );
    return '0x${encodeHex(hashBytes)}';
  }

  Future<void> _bondAndNominate() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final am = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      final acc = am.active;

      if (acc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
        return;
      }

      final amount = parseEraToUnits(_bondAmountController.text.trim());
      if (amount == null || amount <= BigInt.zero) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid amount to bond')));
        return;
      }

      final manual = _validatorAddressController.text.trim();
      final chosenValidator = manual.isNotEmpty ? manual : _selectedValidator;
      if (chosenValidator == null || chosenValidator.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select or enter a validator address to nominate'),
          ),
        );
        return;
      }

      final connected = await chain.ensureConnected();
      if (!mounted) return;
      if (!connected || chain.api == null || chain.provider == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
        return;
      }

      final api = chain.api!;
      final provider = chain.provider!;
      final keyring = Keyring();

      final auth = await authenticateWalletForSensitiveAction(
        context,
        reason: 'Authenticate to bond and nominate',
      );
      if (!auth.success) {
        return;
      }

      String? accountMnemonic = await am.loadMnemonicForAccount(acc.id);
      if (!mounted) return;
      if (accountMnemonic == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No mnemonic stored for this account on this device.\n'
              'Please remove and re-add this account (with its seed phrase) '
              'to enable staking.',
            ),
          ),
        );
        return;
      }

      final trimmedMnemonic = accountMnemonic.trim();
      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored seed phrase for this account is not a valid BIP39 mnemonic.\n'
              'Please remove this account and re-import it with the correct phrase.',
            ),
          ),
        );
        return;
      }

      final wallet = await deriveWalletKeyPair(trimmedMnemonic);
      if (!mounted) return;
      final signerAddress = wallet.address;
      if (signerAddress != acc.address) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored mnemonic for this account does not match its address.\n'
              'Please remove and re-add the account with the correct seed.',
            ),
          ),
        );
        return;
      }

      final previousBonded = _bondedAmount;
      final previousTargets = List<String>.from(_activeTargets);

      final accountPk = keyring.decodeAddress(acc.address);
      final accountId = Uint8List.fromList(accountPk);

      // Determine if already bonded
      BigInt? bonded;
      try {
        final ledger = await api.query.staking.ledger(accountId);
        if (ledger != null) {
          final dynamic d = ledger;
          final dynamic activeField = d.active;
          if (activeField is BigInt) {
            bonded = activeField;
          } else {
            bonded = BigInt.parse(activeField.toString());
          }
        }
      } catch (e) {
        debugPrint('STAKING: error reading ledger before bond: $e');
      }

      // Get base nonce for this batch (bond + nominate)
      final nonceRaw = await api.rpc.system.accountNextIndex(signerAddress);
      final int baseNonce = nonceRaw is BigInt ? nonceRaw.toInt() : nonceRaw;

      // 1) Bond or BondExtra
      String firstHash;
      if (bonded == null || bonded == BigInt.zero) {
        final payee = const staking_types.Staked();
        final call = api.tx.staking.bond(value: amount, payee: payee);
        final encoded = Uint8List.fromList(call.encode());
        firstHash = await _signAndSubmit(
          api,
          provider,
          keyring,
          wallet,
          signerAddress,
          encoded,
          explicitNonce: baseNonce,
        );
      } else {
        final call = api.tx.staking.bondExtra(maxAdditional: amount);
        final encoded = Uint8List.fromList(call.encode());
        firstHash = await _signAndSubmit(
          api,
          provider,
          keyring,
          wallet,
          signerAddress,
          encoded,
          explicitNonce: baseNonce,
        );
      }

      // 2) Nominate
      final validatorPk = keyring.decodeAddress(chosenValidator);
      final targets = <era_multi.MultiAddress>[
        era_multi.Id(Uint8List.fromList(validatorPk)),
      ];
      final nomCall = api.tx.staking.nominate(targets: targets);
      final nomEncoded = Uint8List.fromList(nomCall.encode());
      final nominateHash = await _signAndSubmit(
        api,
        provider,
        keyring,
        wallet,
        signerAddress,
        nomEncoded,
        explicitNonce: baseNonce + 1,
      );

      if (mounted) {
        _clearBondForm();
      }

      await _waitForStakingRefresh(
        previousBonded: previousBonded,
        previousTargets: previousTargets,
      );

      if (!mounted) return;
      await _showStakingSubmittedDialog(
        title: 'Staking submitted',
        body:
            'Bonding / nomination submitted successfully.\n\n'
            'Bond/BondExtra hash:\n$firstHash\n\n'
            'Nominate hash:\n$nominateHash\n\n'
            'The wallet refreshed staking state automatically.',
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, st) {
      debugPrint('STAKING: bond+nominate error: $e');
      debugPrint('STAKING: stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bond & Nominate failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _unbond() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final am = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      final acc = am.active;

      if (acc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
        return;
      }

      final amount = parseEraToUnits(_unbondAmountController.text.trim());
      if (amount == null || amount <= BigInt.zero) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount to unbond')),
        );
        return;
      }

      final connected = await chain.ensureConnected();
      if (!mounted) return;
      if (!connected || chain.api == null || chain.provider == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not connected to ERA node')),
        );
        return;
      }

      final api = chain.api!;
      final provider = chain.provider!;
      final keyring = Keyring();

      final auth = await authenticateWalletForSensitiveAction(
        context,
        reason: 'Authenticate to unbond ERA',
      );
      if (!auth.success) {
        return;
      }

      String? accountMnemonic = await am.loadMnemonicForAccount(acc.id);
      if (!mounted) return;
      if (accountMnemonic == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No mnemonic stored for this account on this device.\n'
              'Please remove and re-add this account (with its seed phrase) '
              'to enable staking.',
            ),
          ),
        );
        return;
      }

      final trimmedMnemonic = accountMnemonic.trim();
      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored seed phrase for this account is not a valid BIP39 mnemonic.\n'
              'Please remove this account and re-import it with the correct phrase.',
            ),
          ),
        );
        return;
      }

      final wallet = await deriveWalletKeyPair(trimmedMnemonic);
      if (!mounted) return;
      final signerAddress = wallet.address;
      if (signerAddress != acc.address) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored mnemonic for this account does not match its address.\n'
              'Please remove and re-add the account with the correct seed.',
            ),
          ),
        );
        return;
      }

      final previousBonded = _bondedAmount;
      final previousTargets = List<String>.from(_activeTargets);

      final call = api.tx.staking.unbond(value: amount);
      final encoded = Uint8List.fromList(call.encode());
      final txHash = await _signAndSubmit(
        api,
        provider,
        keyring,
        wallet,
        signerAddress,
        encoded,
      );

      if (mounted) {
        _clearUnbondForm();
      }

      await _waitForStakingRefresh(
        previousBonded: previousBonded,
        previousTargets: previousTargets,
      );

      if (!mounted) return;
      await _showStakingSubmittedDialog(
        title: 'Unbond submitted',
        body:
            'Unbond submitted successfully.\n\n'
            'Transaction hash:\n$txHash\n\n'
            'The wallet refreshed staking state automatically.',
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, st) {
      debugPrint('STAKING: unbond error: $e');
      debugPrint('STAKING: stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unbond failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final am = flutter_provider.Provider.of<AccountManager>(context);
    final acc = am.active;

    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Staking'),
          ],
        ),
      ),
      body: ListView(
        children: [
          const EraStakingRewardNotice(),
          const SizedBox(height: 12),
          if (acc != null) ...[
            const Text(
              'Active account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(acc.name),
            const SizedBox(height: 4),
            SelectableText(acc.address, style: const TextStyle(fontSize: 12)),
            const Divider(height: 24),
          ] else ...[
            const Text(
              'No active account selected. Please select or create one first.',
              style: TextStyle(color: Colors.red),
            ),
            const Divider(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current staking status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: _loadingStatus
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: _loadingStatus ? null : _loadStakingStatus,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bonded: ${formatEra(_bondedAmount)} ERA',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (_activeTargets.isEmpty)
            const Text(
              'No active nominations yet.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            )
          else ...[
            const Text(
              'Nominating these validator(s):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            for (final t in _activeTargets)
              SelectableText(t, style: const TextStyle(fontSize: 11)),
          ],
          const Divider(height: 24),
          const Text(
            'Bond & Nominate',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _bondAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount to bond (ERA)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select validator',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  initialValue: _selectedValidator,
                  items: _validators
                      .map(
                        (v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(
                            v,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedValidator = val;
                      if (val != null) {
                        _validatorAddressController.text = val;
                      }
                    });
                  },
                ),
              ),
              IconButton(
                icon: _loadingValidators
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Reload validators',
                onPressed: _loadingValidators ? null : _loadValidators,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _validatorAddressController,
            decoration: const InputDecoration(
              labelText: 'Validator stash address (optional override)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submitting ? null : _bondAndNominate,
            child: Text(_submitting ? 'Submitting...' : 'Bond & Nominate'),
          ),
          const Divider(height: 24),
          const Text('Unbond', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _unbondAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount to unbond (ERA)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submitting ? null : _unbond,
            child: Text(_submitting ? 'Submitting...' : 'Unbond'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Note: This screen performs staking.bond / staking.bondExtra, '
            'staking.nominate, and staking.unbond for your account on the ERA '
            'chain using your mnemonic and biometric/PIN.',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
