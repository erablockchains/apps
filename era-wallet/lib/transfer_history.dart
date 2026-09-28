import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum TransferDirection { sent, received }

enum TransferHistoryKind {
  transfer,
  stakingBonded,
  stakingUnbonded,
  stakingWithdrawn,
  aiPredictionStake,
  aiPredictionUnstake,
  aiPredictionClaim,
}

class TransferHistoryEntry {
  final String id;
  final String accountAddress;
  final String counterpartyAddress;
  final BigInt amount;
  final TransferDirection direction;
  final DateTime timestamp;
  final int? blockNumber;
  final String? txHash;
  final bool isOnChain;
  final TransferHistoryKind kind;

  const TransferHistoryEntry({
    required this.id,
    required this.accountAddress,
    this.counterpartyAddress = '',
    required this.amount,
    required this.direction,
    required this.timestamp,
    this.blockNumber,
    this.txHash,
    this.isOnChain = false,
    this.kind = TransferHistoryKind.transfer,
  });

  bool get isSent => direction == TransferDirection.sent;
  bool get isTransfer => kind == TransferHistoryKind.transfer;
  bool get isAiPrediction =>
      kind == TransferHistoryKind.aiPredictionStake ||
      kind == TransferHistoryKind.aiPredictionUnstake ||
      kind == TransferHistoryKind.aiPredictionClaim;

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountAddress': accountAddress,
        'counterpartyAddress': counterpartyAddress,
        'amount': amount.toString(),
        'direction': direction.name,
        'timestamp': timestamp.toIso8601String(),
        'blockNumber': blockNumber,
        'txHash': txHash,
        'isOnChain': isOnChain,
        'kind': kind.name,
      };

  static TransferHistoryEntry fromJson(Map<String, dynamic> json) {
    return TransferHistoryEntry(
      id: json['id']?.toString() ?? '',
      accountAddress: json['accountAddress']?.toString() ?? '',
      counterpartyAddress: json['counterpartyAddress']?.toString() ?? '',
      amount: BigInt.tryParse(json['amount']?.toString() ?? '') ?? BigInt.zero,
      direction: json['direction'] == TransferDirection.received.name
          ? TransferDirection.received
          : TransferDirection.sent,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      blockNumber: json['blockNumber'] is int ? json['blockNumber'] : null,
      txHash: json['txHash']?.toString(),
      isOnChain: json['isOnChain'] == true,
      kind: TransferHistoryKind.values.firstWhere(
        (kind) => kind.name == json['kind']?.toString(),
        orElse: () => TransferHistoryKind.transfer,
      ),
    );
  }
}

class TransferHistoryStore with ChangeNotifier {
  static const _storageKey = 'transfer_history_v1';
  static const _maxEntriesPerAccount = 60;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final Map<String, List<TransferHistoryEntry>> _entriesByAccount = {};

  List<TransferHistoryEntry> forAccount(String? accountAddress) {
    if (accountAddress == null) return const [];
    return List.unmodifiable(_entriesByAccount[accountAddress] ?? const []);
  }

  Future<void> load() async {
    final historyJson = await _storage.read(key: _storageKey);
    _entriesByAccount.clear();

    if (historyJson == null || historyJson.isEmpty) {
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(historyJson);
    if (decoded is! List) {
      notifyListeners();
      return;
    }

    for (final raw in decoded) {
      if (raw is! Map) continue;
      final entry = TransferHistoryEntry.fromJson(
        Map<String, dynamic>.from(raw),
      );
      if (entry.id.isEmpty || entry.accountAddress.isEmpty) continue;
      _put(entry);
    }

    _trimAll();
    notifyListeners();
  }

  Future<void> recordSubmittedSend({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required String txHash,
  }) async {
    _put(
      TransferHistoryEntry(
        id: 'local:sent:$txHash:$fromAddress',
        accountAddress: fromAddress,
        counterpartyAddress: toAddress,
        amount: amount,
        direction: TransferDirection.sent,
        timestamp: DateTime.now(),
        txHash: txHash,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> recordSubmittedReceive({
    required String accountAddress,
    required String fromAddress,
    required BigInt amount,
    required String txHash,
  }) async {
    _put(
      TransferHistoryEntry(
        id: 'local:received:$txHash:$accountAddress',
        accountAddress: accountAddress,
        counterpartyAddress: fromAddress,
        amount: amount,
        direction: TransferDirection.received,
        timestamp: DateTime.now(),
        txHash: txHash,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> recordSubmittedStaking({
    required String accountAddress,
    required BigInt amount,
    required String txHash,
    required TransferHistoryKind kind,
  }) async {
    assert(kind != TransferHistoryKind.transfer);
    _put(
      TransferHistoryEntry(
        id: 'local:${kind.name}:$txHash:$accountAddress',
        accountAddress: accountAddress,
        amount: amount,
        direction: TransferDirection.sent,
        timestamp: DateTime.now(),
        txHash: txHash,
        kind: kind,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> recordSubmittedAiPrediction({
    required String accountAddress,
    required int predictionId,
    required String? side,
    required BigInt amount,
    required String txHash,
    required TransferHistoryKind kind,
  }) async {
    assert(kind == TransferHistoryKind.aiPredictionStake ||
        kind == TransferHistoryKind.aiPredictionUnstake ||
        kind == TransferHistoryKind.aiPredictionClaim);
    _put(
      TransferHistoryEntry(
        id: 'local:${kind.name}:$txHash:$accountAddress:$predictionId',
        accountAddress: accountAddress,
        counterpartyAddress: 'prediction:$predictionId:${side ?? 'none'}',
        amount: amount,
        direction: kind == TransferHistoryKind.aiPredictionClaim
            ? TransferDirection.received
            : TransferDirection.sent,
        timestamp: DateTime.now(),
        txHash: txHash,
        kind: kind,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> mergeOnChainEntries(
    List<TransferHistoryEntry> entries,
  ) async {
    var changed = false;
    for (final entry in entries) {
      final accountEntries =
          _entriesByAccount.putIfAbsent(entry.accountAddress, () => []);
      accountEntries.removeWhere((existing) {
        return !existing.isOnChain &&
            existing.kind == entry.kind &&
            existing.direction == entry.direction &&
            existing.counterpartyAddress == entry.counterpartyAddress &&
            existing.amount == entry.amount;
      });

      final index = accountEntries.indexWhere((item) => item.id == entry.id);
      if (index == -1) {
        accountEntries.add(entry);
        changed = true;
      } else if (!accountEntries[index].isOnChain) {
        accountEntries[index] = entry;
        changed = true;
      }
    }

    if (!changed && entries.isEmpty) return;
    _trimAll();
    await _save();
    notifyListeners();
  }

  void _put(TransferHistoryEntry entry) {
    final entries = _entriesByAccount.putIfAbsent(
      entry.accountAddress,
      () => [],
    );
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      entries.add(entry);
    } else {
      entries[index] = entry;
    }
    _trim(entry.accountAddress);
  }

  void _trimAll() {
    for (final accountAddress in _entriesByAccount.keys.toList()) {
      _trim(accountAddress);
    }
  }

  void _trim(String accountAddress) {
    final entries = _entriesByAccount[accountAddress];
    if (entries == null) return;
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (entries.length > _maxEntriesPerAccount) {
      entries.removeRange(_maxEntriesPerAccount, entries.length);
    }
  }

  Future<void> _save() async {
    final allEntries = _entriesByAccount.values
        .expand((entries) => entries)
        .map((entry) => entry.toJson())
        .toList();
    await _storage.write(key: _storageKey, value: jsonEncode(allEntries));
  }
}
