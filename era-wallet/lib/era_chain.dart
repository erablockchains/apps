import 'package:flutter/foundation.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show encodeHex;
import 'package:polkadart_keyring/polkadart_keyring.dart';

import 'generated/era/era.dart' as era_api;
import 'generated/era/types/era_runtime/runtime_event.dart' as era_events;
import 'generated/era/types/frame_system/phase.dart' as era_phase;
import 'generated/era/types/pallet_balances/pallet/event.dart'
    as balance_events;
import 'generated/era/types/pallet_staking/pallet/pallet/event.dart'
    as staking_events;
import 'generated/era/types/sp_runtime/multiaddress/multi_address.dart'
    as era_multi;

import 'config.dart';
import 'era_v14_compatibility.dart';
import 'transfer_history.dart';

const int kEraDecimals = 18;
final BigInt kEraUnit = BigInt.from(10).pow(kEraDecimals);
const String kTokenSymbol = 'ETKN';

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
  fracStr = fracStr.replaceFirst(RegExp(r'0+$'), '');

  return '${negative ? '-' : ''}$whole.$fracStr';
}

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
    fracStr = fracStr.substring(0, kEraDecimals);
  }
  fracStr = fracStr.padRight(kEraDecimals, '0');

  final whole = BigInt.parse(wholeStr);
  final frac = fracStr.isEmpty ? BigInt.zero : BigInt.parse(fracStr);

  var result = whole * kEraUnit + frac;
  if (negative) result = -result;
  return result;
}

enum WalletConnectionState { disconnected, connecting, connected, error }

class EraWalletProvider extends ChangeNotifier {
  static const String defaultWsEndpoint = kDefaultEraWsEndpoint;
  static const Duration connectionHealthTimeout = Duration(seconds: 5);

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

  Future<void> connect({String? wsEndpoint, bool force = false}) async {
    if (_isConnecting ||
        (!force && _connectionState == WalletConnectionState.connected)) {
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
    await disconnect();
    final endpoint = wsEndpoint ?? defaultWsEndpoint;
    polkadart.Provider? freshProvider;
    try {
      freshProvider = polkadart.Provider.fromUri(
        validateEraWsEndpoint(endpoint),
      );
      await freshProvider
          .send('system_health', const <dynamic>[])
          .timeout(connectionHealthTimeout);
      _provider = freshProvider;
      _api = era_api.Era(freshProvider);
      _connectionState = WalletConnectionState.connected;
      _connectionError = null;
      notifyListeners();
    } catch (e) {
      try {
        if (freshProvider?.isConnected() == true) {
          await freshProvider!.disconnect();
        }
      } catch (_) {}
      _provider = null;
      _api = null;
      _connectionState = WalletConnectionState.error;
      _connectionError = e.toString();
      notifyListeners();
    }
  }

  Future<bool> _isConnectionHealthy() async {
    final provider = _provider;
    if (provider == null || _api == null) {
      return false;
    }

    try {
      await provider
          .send('system_health', const <dynamic>[])
          .timeout(connectionHealthTimeout);
      return true;
    } catch (e) {
      debugPrint('ERA connection health check failed: $e');
      return false;
    }
  }

  Future<bool> ensureConnected({String? wsEndpoint}) async {
    if (_connectionState == WalletConnectionState.connected &&
        _provider != null &&
        _api != null) {
      if (await _isConnectionHealthy()) {
        return true;
      }

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
        await _provider!.disconnect();
      } catch (_) {}
      _provider = null;
    }
    _api = null;
    _connectionState = WalletConnectionState.disconnected;
    notifyListeners();
  }
}

class TxService {
  final polkadart.Provider provider;
  final era_api.Era api;

  TxService(this.provider, this.api);

  Future<BigInt?> estimateFee({
    required String fromMnemonic,
    required String toAddress,
    required BigInt amount,
  }) async {
    await EraV14RuntimeGuard(provider).verify();
    try {
      final keyring = Keyring();
      final wallet = await keyring.fromMnemonic(fromMnemonic.trim());
      final signerAddress = wallet.address;

      debugPrint('FEE: estimating for signer: $signerAddress');
      debugPrint('FEE: dest: $toAddress, amount: $amount');

      final runtimeVersion = await api.rpc.state.getRuntimeVersion();
      final currentBlockNumber = (await api.query.system.number()) - 1;
      final currentBlockHash = await api.query.system.blockHash(
        currentBlockNumber,
      );
      final genesisHash = await api.query.system.blockHash(0);
      final nonce = await api.rpc.system.accountNextIndex(signerAddress);

      final destPublicKey = keyring.decodeAddress(toAddress);
      final multiAddress = era_multi.Id(Uint8List.fromList(destPublicKey));

      final transferCall = api.tx.balances.transferAllowDeath(
        dest: multiAddress,
        value: amount,
      );
      final encodedCall = transferCall.encode();

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

      final signature = wallet.sign(payload);

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
      final resp = await provider.send('payment_queryInfo', [extrinsicHex]);
      final result = resp.result;
      debugPrint('FEE: payment_queryInfo result = $result');

      if (result == null) return null;

      final partial = (result is Map) ? result['partialFee'] : null;
      if (partial == null) return null;

      final feeStr = partial.toString();
      if (feeStr.startsWith('0x')) {
        return BigInt.parse(feeStr.substring(2), radix: 16);
      }
      return BigInt.parse(feeStr);
    } catch (e, st) {
      debugPrint('FEE: estimateFee error: $e');
      debugPrint('FEE: stack: $st');
      return null;
    }
  }

  Future<String> sendTransfer({
    required String fromMnemonic,
    required String toAddress,
    required BigInt amount,
  }) async {
    await EraV14RuntimeGuard(provider).verify();
    final keyring = Keyring();
    final wallet = await keyring.fromMnemonic(fromMnemonic.trim());
    final signerAddress = wallet.address;

    debugPrint('TxService.sendTransfer -> signer: $signerAddress');
    debugPrint('TxService.sendTransfer -> dest:   $toAddress');
    debugPrint('TxService.sendTransfer -> amount: $amount');

    final runtimeVersion = await api.rpc.state.getRuntimeVersion();
    final currentBlockNumber = (await api.query.system.number()) - 1;
    final currentBlockHash = await api.query.system.blockHash(
      currentBlockNumber,
    );
    final genesisHash = await api.query.system.blockHash(0);
    final nonce = await api.rpc.system.accountNextIndex(signerAddress);

    final destPublicKey = keyring.decodeAddress(toAddress);
    final multiAddress = era_multi.Id(Uint8List.fromList(destPublicKey));

    final transferCall = api.tx.balances.transferAllowDeath(
      dest: multiAddress,
      value: amount,
    );
    final encodedCall = transferCall.encode();

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

    final signature = wallet.sign(payload);

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
}

class TransferHistoryService {
  final era_api.Era api;

  TransferHistoryService(this.api);

  Future<List<TransferHistoryEntry>> fetchRecentAccountTransfers({
    required String accountAddress,
    int blockLookback = 120,
    int limit = 30,
  }) async {
    final keyring = Keyring();
    final accountPublicKey = keyring.decodeAddress(accountAddress);
    final entries = <TransferHistoryEntry>[];

    final currentBlock = await api.query.system.number();
    final latestCompletedBlock = currentBlock > 0 ? currentBlock - 1 : 0;
    var blockNumber = latestCompletedBlock;
    final firstBlock = latestCompletedBlock - blockLookback;
    final stopBlock = firstBlock < 0 ? 0 : firstBlock;

    while (blockNumber >= stopBlock && entries.length < limit) {
      try {
        final blockHash = await api.query.system.blockHash(blockNumber);
        final records = await api.query.system.events(
          at: Uint8List.fromList(blockHash),
        );

        for (var eventIndex = 0; eventIndex < records.length; eventIndex++) {
          final record = records[eventIndex];
          final extrinsicIndex = record.phase is era_phase.ApplyExtrinsic
              ? (record.phase as era_phase.ApplyExtrinsic).value0
              : null;
          final runtimeEvent = record.event;
          final timestamp = DateTime.now().subtract(
            Duration(seconds: latestCompletedBlock - blockNumber),
          );

          if (runtimeEvent is era_events.Balances) {
            final balanceEvent = runtimeEvent.value0;
            if (balanceEvent is! balance_events.Transfer) continue;

            final sentByAccount = _sameBytes(
              balanceEvent.from,
              accountPublicKey,
            );
            final receivedByAccount = _sameBytes(
              balanceEvent.to,
              accountPublicKey,
            );
            if (!sentByAccount && !receivedByAccount) continue;

            final fromAddress = keyring.encodeAddress(balanceEvent.from);
            final toAddress = keyring.encodeAddress(balanceEvent.to);
            final direction = sentByAccount
                ? TransferDirection.sent
                : TransferDirection.received;
            final counterpartyAddress = sentByAccount ? toAddress : fromAddress;

            entries.add(
              TransferHistoryEntry(
                id:
                    'chain:$blockNumber:${extrinsicIndex ?? 'none'}:'
                    '$eventIndex:${direction.name}:$accountAddress',
                accountAddress: accountAddress,
                counterpartyAddress: counterpartyAddress,
                amount: balanceEvent.amount,
                direction: direction,
                timestamp: timestamp,
                blockNumber: blockNumber,
                isOnChain: true,
              ),
            );
          } else if (runtimeEvent is era_events.Staking) {
            final stakingEvent = runtimeEvent.value0;
            final stakingEntry = _stakingHistoryEntry(
              stakingEvent: stakingEvent,
              accountPublicKey: accountPublicKey,
              accountAddress: accountAddress,
              blockNumber: blockNumber,
              extrinsicIndex: extrinsicIndex,
              eventIndex: eventIndex,
              timestamp: timestamp,
            );
            if (stakingEntry == null) continue;
            entries.add(stakingEntry);
          } else {
            continue;
          }

          if (entries.length >= limit) break;
        }
      } catch (e) {
        debugPrint('HISTORY: failed to read block $blockNumber events: $e');
      }

      blockNumber--;
    }

    return entries;
  }

  TransferHistoryEntry? _stakingHistoryEntry({
    required staking_events.Event stakingEvent,
    required List<int> accountPublicKey,
    required String accountAddress,
    required int blockNumber,
    required int? extrinsicIndex,
    required int eventIndex,
    required DateTime timestamp,
  }) {
    final TransferHistoryKind kind;
    final List<int> stash;
    final BigInt amount;

    if (stakingEvent is staking_events.Bonded) {
      kind = TransferHistoryKind.stakingBonded;
      stash = stakingEvent.stash;
      amount = stakingEvent.amount;
    } else if (stakingEvent is staking_events.Unbonded) {
      kind = TransferHistoryKind.stakingUnbonded;
      stash = stakingEvent.stash;
      amount = stakingEvent.amount;
    } else if (stakingEvent is staking_events.Withdrawn) {
      kind = TransferHistoryKind.stakingWithdrawn;
      stash = stakingEvent.stash;
      amount = stakingEvent.amount;
    } else {
      return null;
    }

    if (!_sameBytes(stash, accountPublicKey)) return null;

    return TransferHistoryEntry(
      id:
          'chain:$blockNumber:${extrinsicIndex ?? 'none'}:'
          '$eventIndex:${kind.name}:$accountAddress',
      accountAddress: accountAddress,
      amount: amount,
      direction: TransferDirection.sent,
      timestamp: timestamp,
      blockNumber: blockNumber,
      isOnChain: true,
      kind: kind,
    );
  }

  bool _sameBytes(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}
