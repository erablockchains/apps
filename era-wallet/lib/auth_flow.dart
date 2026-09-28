import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart' as flutter_provider;

import 'era_chain.dart';
import 'era_scaffold.dart';

const String kEraIconPath = 'assets/images/era_icon.png';

class StorageKeys {
  static const String pinSalt = 'pin_salt';
  static const String pinVerifier = 'pin_verifier';
  static const String biometricsEnabled = 'biometrics_enabled';
  static const String mnemonicBlob = 'mnemonic_blob';
  static const String mnemonicNonce = 'mnemonic_nonce';
  static const String failedPinAttempts = 'failed_pin_attempts';
  static const String pinLockedUntil = 'pin_locked_until';

  static String accountMnemonicKey(String accountId) =>
      'acc_mnemonic_$accountId';
}

const int kMinimumNewPinLength = 6;
const int kMaximumPinLength = 12;

const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

Future<void> copySensitiveTextWithAutoClear(
  String value, {
  Duration clearAfter = const Duration(seconds: 60),
}) async {
  await Clipboard.setData(ClipboardData(text: value));
  Timer(clearAfter, () async {
    try {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == value) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {
      // Clipboard clearing is best-effort because platform support varies.
    }
  });
}

class DeviceAuthStatus {
  final bool canCheckBiometrics;
  final bool isDeviceSupported;
  final List<BiometricType> availableBiometrics;

  const DeviceAuthStatus({
    required this.canCheckBiometrics,
    required this.isDeviceSupported,
    required this.availableBiometrics,
  });

  bool get canAuthenticate =>
      isDeviceSupported || canCheckBiometrics || availableBiometrics.isNotEmpty;
}

Future<bool> isBiometricLoginEnabled() async {
  final stored = await secureStorage.read(key: StorageKeys.biometricsEnabled);
  return stored != 'false';
}

Future<void> setBiometricLoginEnabled(bool enabled) async {
  await secureStorage.write(
    key: StorageKeys.biometricsEnabled,
    value: enabled.toString(),
  );
}

Future<DeviceAuthStatus> getDeviceAuthStatus(
  LocalAuthentication localAuth,
) async {
  final canCheckBiometrics = await localAuth.canCheckBiometrics;
  final isDeviceSupported = await localAuth.isDeviceSupported();
  final availableBiometrics = await localAuth.getAvailableBiometrics();
  return DeviceAuthStatus(
    canCheckBiometrics: canCheckBiometrics,
    isDeviceSupported: isDeviceSupported,
    availableBiometrics: availableBiometrics,
  );
}

Future<bool> authenticateWithDevice({
  required LocalAuthentication localAuth,
  required String reason,
}) async {
  final status = await getDeviceAuthStatus(localAuth);
  debugPrint(
    'LocalAuth status: canCheck=${status.canCheckBiometrics}, '
    'isSupported=${status.isDeviceSupported}, '
    'availableBiometrics=${status.availableBiometrics}',
  );

  if (!status.canAuthenticate) {
    return false;
  }

  return localAuth.authenticate(
    localizedReason: reason,
    biometricOnly: false,
    sensitiveTransaction: true,
    persistAcrossBackgrounding: true,
  );
}

class PinCrypto {
  static final _pbkdf2 = crypto.Pbkdf2(
    macAlgorithm: crypto.Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );
  static final _hmac = crypto.Hmac.sha256();
  static final _aesGcm = crypto.AesGcm.with256bits();

  static Future<crypto.SecretKey> deriveKeyFromPin(
    String pin,
    List<int> salt,
  ) async {
    return _pbkdf2.deriveKey(
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

class KeyStore with ChangeNotifier {
  bool _unlocked = false;
  bool _hasWallet = false;

  bool get unlocked => _unlocked;
  bool get hasWallet => _hasWallet;

  Future<void> init() async {
    final saltB64 = await secureStorage.read(key: StorageKeys.pinSalt);
    final verifier = await secureStorage.read(key: StorageKeys.pinVerifier);
    _hasWallet = saltB64 != null && verifier != null;
    _unlocked = false;
    notifyListeners();
  }

  void lock() {
    if (_unlocked) {
      _unlocked = false;
      notifyListeners();
    }
  }

  Future<void> setupPin({required String pin}) async {
    _validateNewPin(pin);
    await _writePin(pin);
    await _clearFailedPinAttempts();

    _unlocked = true;
    _hasWallet = true;
    notifyListeners();
  }

  Future<void> _writePin(String pin) async {
    final salt = await PinCrypto.randomBytes(16);
    await secureStorage.write(
      key: StorageKeys.pinSalt,
      value: base64Encode(salt),
    );
    final key = await PinCrypto.deriveKeyFromPin(pin, salt);
    final verifier = await PinCrypto.createPinVerifier(key);
    await secureStorage.write(key: StorageKeys.pinVerifier, value: verifier);
  }

  Future<bool> unlockWithPin(String pin) async {
    final ok = await verifyPin(pin);
    if (!ok) return false;

    _unlocked = true;
    notifyListeners();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    if (await pinLockoutRemaining() > Duration.zero) return false;
    final saltB64 = await secureStorage.read(key: StorageKeys.pinSalt);
    final verifier = await secureStorage.read(key: StorageKeys.pinVerifier);

    if (saltB64 == null || verifier == null) {
      await _recordFailedPinAttempt();
      return false;
    }

    final salt = base64Decode(saltB64);
    final key = await PinCrypto.deriveKeyFromPin(pin, salt);
    final verified = await PinCrypto.verifyPinWithStoredVerifier(key, verifier);
    if (verified) {
      await _clearFailedPinAttempts();
    } else {
      await _recordFailedPinAttempt();
    }
    return verified;
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    _validateNewPin(newPin);
    if (!await verifyPin(currentPin)) {
      throw StateError('Current PIN is incorrect or temporarily locked.');
    }
    await _writePin(newPin);
    await _clearFailedPinAttempts();
  }

  Future<Duration> pinLockoutRemaining() async {
    final stored = await secureStorage.read(key: StorageKeys.pinLockedUntil);
    final lockedUntil = stored == null ? null : DateTime.tryParse(stored);
    if (lockedUntil == null) return Duration.zero;
    final remaining = lockedUntil.difference(DateTime.now().toUtc());
    if (remaining <= Duration.zero) {
      await secureStorage.delete(key: StorageKeys.pinLockedUntil);
      return Duration.zero;
    }
    return remaining;
  }

  Future<void> _recordFailedPinAttempt() async {
    final stored = await secureStorage.read(key: StorageKeys.failedPinAttempts);
    final attempts = (int.tryParse(stored ?? '') ?? 0) + 1;
    await secureStorage.write(
      key: StorageKeys.failedPinAttempts,
      value: '$attempts',
    );
    if (attempts < 5) return;
    final exponent = (attempts - 5).clamp(0, 5).toInt();
    final seconds = 30 * (1 << exponent);
    final lockedUntil = DateTime.now().toUtc().add(
      Duration(seconds: seconds > 900 ? 900 : seconds),
    );
    await secureStorage.write(
      key: StorageKeys.pinLockedUntil,
      value: lockedUntil.toIso8601String(),
    );
  }

  Future<void> _clearFailedPinAttempts() async {
    await secureStorage.delete(key: StorageKeys.failedPinAttempts);
    await secureStorage.delete(key: StorageKeys.pinLockedUntil);
  }

  static void _validateNewPin(String pin) {
    if (!RegExp(r'^\d{6,12}$').hasMatch(pin)) {
      throw ArgumentError(
        'PIN must contain $kMinimumNewPinLength to $kMaximumPinLength digits.',
      );
    }
  }

  void forceUnlock() {
    _unlocked = true;
    notifyListeners();
  }
}

class PinUnlockScreen extends StatefulWidget {
  final WidgetBuilder onUnlockedBuilder;

  const PinUnlockScreen({super.key, required this.onUnlockedBuilder});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final _pin = TextEditingController();
  bool _busy = false;
  bool _authLoading = true;
  bool _biometricEnabled = true;
  DeviceAuthStatus? _deviceAuthStatus;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initializeDeviceAuth(),
    );
  }

  Future<void> _initializeDeviceAuth() async {
    try {
      final biometricEnabled = await isBiometricLoginEnabled();
      final status = await getDeviceAuthStatus(_localAuth);
      if (!mounted) return;
      setState(() {
        _biometricEnabled = biometricEnabled;
        _deviceAuthStatus = status;
        _authLoading = false;
      });

      if (biometricEnabled && status.canAuthenticate) {
        await _tryBiometricUnlock();
      }
    } catch (e) {
      debugPrint('Failed to initialize device auth: $e');
      if (!mounted) return;
      setState(() {
        _authLoading = false;
      });
    }
  }

  Future<void> _tryBiometricUnlock() async {
    if (_busy) return;
    final ks = flutter_provider.Provider.of<KeyStore>(context, listen: false);

    try {
      setState(() => _busy = true);
      final didAuth = await authenticateWithDevice(
        localAuth: _localAuth,
        reason: 'Authenticate to unlock ERA Wallet',
      );

      if (!didAuth) return;

      ks.forceUnlock();
      await _reconnectWalletProvider();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: widget.onUnlockedBuilder));
    } catch (e) {
      debugPrint('Biometric / device auth unlock failed: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _reconnectWalletProvider() async {
    try {
      final chain = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      await chain.ensureConnected();
    } catch (e) {
      debugPrint('Wallet reconnect after unlock failed: $e');
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
    final canUseDeviceAuth = _deviceAuthStatus?.canAuthenticate ?? false;
    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('ERA Wallet - Unlock'),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use biometric/device login'),
            subtitle: Text(
              canUseDeviceAuth
                  ? 'Use the operating system prompt when unlocking the wallet.'
                  : 'No biometric or device credential prompt is available on this device.',
            ),
            value: _biometricEnabled && canUseDeviceAuth,
            onChanged: !canUseDeviceAuth
                ? null
                : (value) async {
                    await setBiometricLoginEnabled(value);
                    if (!mounted) return;
                    setState(() => _biometricEnabled = value);
                  },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
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
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    setState(() => _busy = true);
                    final ok = await ks.unlockWithPin(_pin.text.trim());
                    if (!mounted) return;
                    if (!ok) {
                      setState(() => _busy = false);
                      final remaining = await ks.pinLockoutRemaining();
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            remaining > Duration.zero
                                ? 'Too many failed attempts. Try again in ${remaining.inSeconds + 1} seconds.'
                                : 'Invalid PIN',
                          ),
                        ),
                      );
                      return;
                    }
                    await _reconnectWalletProvider();
                    if (!mounted) return;
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: widget.onUnlockedBuilder),
                    );
                  },
            icon: const Icon(Icons.lock_open),
            label: Text(_busy ? 'Unlocking...' : 'Unlock'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed:
                (_busy ||
                    _authLoading ||
                    !canUseDeviceAuth ||
                    !_biometricEnabled)
                ? null
                : _tryBiometricUnlock,
            icon: const Icon(Icons.fingerprint),
            label: Text(
              _authLoading
                  ? 'Checking device authentication...'
                  : 'Use device authentication',
            ),
          ),
        ],
      ),
    );
  }
}

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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12),
        ],
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

class AuthResult {
  final bool success;
  final String? pin;

  AuthResult(this.success, this.pin);
}

Future<bool> showChangePinDialog(BuildContext context) async {
  final changed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ChangePinDialog(),
  );
  return changed == true;
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog();

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change PIN'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Use a unique 6–12 digit PIN. Existing wallet accounts and '
            'recovery phrases are unchanged.',
          ),
          const SizedBox(height: 12),
          _field(_current, 'Current PIN'),
          const SizedBox(height: 8),
          _field(_next, 'New PIN'),
          const SizedBox(height: 8),
          _field(_confirm, 'Confirm new PIN'),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _busy ? null : _change,
        child: Text(_busy ? 'Changing…' : 'Change PIN'),
      ),
    ],
  );

  Widget _field(TextEditingController controller, String label) => TextField(
    controller: controller,
    obscureText: true,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(kMaximumPinLength),
    ],
    decoration: InputDecoration(labelText: label),
  );

  Future<void> _change() async {
    if (_next.text != _confirm.text) {
      setState(() => _error = 'New PIN entries do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final keyStore = flutter_provider.Provider.of<KeyStore>(
        context,
        listen: false,
      );
      await keyStore.changePin(currentPin: _current.text, newPin: _next.text);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.toString().replaceFirst('Bad state: ', '');
      });
    }
  }
}

Future<AuthResult> authenticateWalletForSensitiveAction(
  BuildContext context, {
  required String reason,
}) async {
  final ks = flutter_provider.Provider.of<KeyStore>(context, listen: false);
  final localAuth = LocalAuthentication();

  try {
    final biometricsEnabled = await isBiometricLoginEnabled();
    final didAuth = biometricsEnabled
        ? await authenticateWithDevice(localAuth: localAuth, reason: reason)
        : false;

    if (didAuth) {
      return AuthResult(true, null);
    }
  } catch (e) {
    debugPrint('Biometric / device auth error: $e');
  }

  if (!context.mounted) {
    return AuthResult(false, null);
  }
  final pin = await showDialog<String>(
    context: context,
    builder: (_) => const _PinPromptDialog(),
  );
  if (!context.mounted) {
    return AuthResult(false, null);
  }
  if (pin == null) {
    return AuthResult(false, null);
  }

  final ok = await ks.verifyPin(pin);
  if (!context.mounted) {
    return AuthResult(false, null);
  }
  if (!ok) {
    final remaining = await ks.pinLockoutRemaining();
    if (!context.mounted) return AuthResult(false, null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          remaining > Duration.zero
              ? 'Too many failed attempts. Try again in ${remaining.inSeconds + 1} seconds.'
              : 'Invalid PIN',
        ),
      ),
    );
    return AuthResult(false, null);
  }

  return AuthResult(true, pin);
}
