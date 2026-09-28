import 'dart:convert';

import 'test_session.dart';

const String phase6bRedactedValue = '[REDACTED]';

/// Removes credentials, query parameters, and fragments from an RPC endpoint
/// before it can enter a persisted or shared report.
String sanitizePhase6bEndpoint(String value) {
  final endpoint = _requireReportText(value, 'endpoint');
  final uri = Uri.tryParse(endpoint);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }
  return phase6bRedactedValue;
}

class Phase6bBalanceObservation {
  final String publicAddress;
  final BigInt beforeBaseUnits;
  final BigInt afterBaseUnits;
  final String tokenSymbol;

  Phase6bBalanceObservation({
    required String publicAddress,
    required this.beforeBaseUnits,
    required this.afterBaseUnits,
    this.tokenSymbol = 'ETKN',
  }) : publicAddress = _requireReportText(publicAddress, 'publicAddress') {
    _requireReportText(tokenSymbol, 'tokenSymbol');
  }

  BigInt get deltaBaseUnits => afterBaseUnits - beforeBaseUnits;

  Map<String, Object?> toJson() => {
    'publicAddress': publicAddress,
    'tokenSymbol': tokenSymbol,
    'beforeBaseUnits': beforeBaseUnits.toString(),
    'afterBaseUnits': afterBaseUnits.toString(),
    'deltaBaseUnits': deltaBaseUnits.toString(),
  };
}

class Phase6bMarketTotalsObservation {
  final BigInt yesBeforeBaseUnits;
  final BigInt yesAfterBaseUnits;
  final BigInt noBeforeBaseUnits;
  final BigInt noAfterBaseUnits;
  final String tokenSymbol;

  Phase6bMarketTotalsObservation({
    required this.yesBeforeBaseUnits,
    required this.yesAfterBaseUnits,
    required this.noBeforeBaseUnits,
    required this.noAfterBaseUnits,
    this.tokenSymbol = 'ETKN',
  });

  Map<String, Object?> toJson() => {
    'tokenSymbol': tokenSymbol,
    'yesBeforeBaseUnits': yesBeforeBaseUnits.toString(),
    'yesAfterBaseUnits': yesAfterBaseUnits.toString(),
    'noBeforeBaseUnits': noBeforeBaseUnits.toString(),
    'noAfterBaseUnits': noAfterBaseUnits.toString(),
  };
}

class Phase6bTreasuryFeeObservation {
  final String label;
  final String before;
  final String after;
  final String detail;

  Phase6bTreasuryFeeObservation({
    required String label,
    required String before,
    required String after,
    required String detail,
  }) : label = _requireReportText(label, 'label'),
       before = _requireReportText(before, 'before'),
       after = _requireReportText(after, 'after'),
       detail = _requireReportText(detail, 'detail');

  Map<String, Object?> toJson() => {
    'label': label,
    'before': before,
    'after': after,
    'detail': detail,
  };
}

/// Recursively removes wallet secrets from JSON-compatible report data.
///
/// Public addresses, public keys, hashes, block identifiers, and metadata
/// fingerprints are intentionally preserved. Sensitive keys are redacted at
/// every nesting level, including maps contained in lists. Sensitive labelled
/// strings and likely unlabeled mnemonic phrases/private key material are also
/// removed.
abstract final class Phase6bReportRedactor {
  static Object? redact(Object? value) => _redact(value);

  static Map<String, Object?> redactMap(Map<Object?, Object?> value) {
    return _redact(value) as Map<String, Object?>;
  }

  static Object? _redact(Object? value, {String? contextKey}) {
    if (value == null || value is num || value is bool) return value;
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is BigInt) return value.toString();

    if (value is Map) {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        result[key] = _isSensitiveKey(key)
            ? phase6bRedactedValue
            : _redact(entry.value, contextKey: key);
      }
      return result;
    }

    if (value is Iterable) {
      return value
          .map((item) => _redact(item, contextKey: contextKey))
          .toList();
    }

    if (value is String) {
      return _redactString(value, contextKey: contextKey);
    }

    return _redactString(value.toString(), contextKey: contextKey);
  }

  static String _redactString(String value, {String? contextKey}) {
    if (_containsSensitiveLabel(value)) return phase6bRedactedValue;

    final trimmed = value.trim();
    if (_looksLikeMnemonic(trimmed)) return phase6bRedactedValue;

    if (_looksLikePrivateHexMaterial(trimmed) &&
        !_isPublicContextKey(contextKey)) {
      return phase6bRedactedValue;
    }

    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map || decoded is List) {
          return jsonEncode(_redact(decoded, contextKey: contextKey));
        }
      } on FormatException {
        // It only looked like JSON. Continue with the original public value.
      }
    }

    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = _normalizedKey(key);

    const exact = {
      'mnemonic',
      'mnemonics',
      'seed',
      'seedphrase',
      'recoveryphrase',
      'privatekey',
      'privatekeys',
      'secretkey',
      'secretkeys',
      'keypair',
      'keymaterial',
      'pin',
      'pincode',
      'pinhash',
      'passcode',
      'password',
      'passphrase',
      'securestorage',
      'securestoragecontents',
      'biometric',
      'biometrics',
      'biometricdata',
      'biometricinformation',
      'apikey',
      'apitoken',
      'accesstoken',
      'authtoken',
      'bearertoken',
      'refreshtoken',
      'authorization',
      'authorizationheader',
      'clientsecret',
      'credential',
      'credentials',
    };
    if (exact.contains(normalized)) return true;

    return normalized.contains('mnemonic') ||
        normalized.contains('privatekey') ||
        normalized.contains('secretkey') ||
        normalized.contains('seedphrase') ||
        normalized.contains('recoveryphrase') ||
        normalized.contains('securestorage') ||
        normalized.contains('biometric') ||
        normalized.contains('apikey') ||
        normalized.contains('accesstoken') ||
        normalized.contains('authtoken') ||
        normalized.contains('bearertoken') ||
        normalized.contains('refreshtoken') ||
        normalized.contains('clientsecret') ||
        normalized.contains('credential') ||
        normalized.endsWith('password') ||
        normalized.endsWith('passphrase');
  }

  static bool _isPublicContextKey(String? key) {
    if (key == null) return false;
    final normalized = _normalizedKey(key);
    return normalized.endsWith('publicaddress') ||
        normalized.endsWith('publicaddresses') ||
        normalized.endsWith('publickey') ||
        normalized == 'signer' ||
        normalized.endsWith('publicsigner') ||
        normalized.endsWith('transactionhash') ||
        normalized.endsWith('extrinsichash') ||
        normalized.endsWith('blockhash') ||
        normalized == 'genesishash' ||
        normalized == 'modelhash' ||
        normalized == 'predictionhash' ||
        normalized == 'metadatahash' ||
        normalized == 'runtimewasmhash' ||
        normalized == 'runtimecodehash' ||
        normalized == 'metadatafingerprint' ||
        normalized == 'accountid' ||
        normalized == 'owner' ||
        normalized == 'delegate';
  }

  static bool _containsSensitiveLabel(String value) {
    return RegExp(
      r'(^|[^a-z0-9])(mnemonic|seed([ _-]?phrase)?|recovery[ _-]?phrase|private[ _-]?key|secret[ _-]?key|pin([ _-]?code)?|passcode|password|passphrase|secure[ _-]?storage|biometric(s|[ _-]?(data|information))?|api[ _-]?key|access[ _-]?token|auth[ _-]?token|bearer[ _-]?token|refresh[ _-]?token|authorization([ _-]?header)?|client[ _-]?secret|credentials?)([^a-z0-9]|$)',
      caseSensitive: false,
    ).hasMatch(value);
  }

  static bool _looksLikeMnemonic(String value) {
    final words = value.split(RegExp(r'\s+'));
    const mnemonicWordCounts = {12, 15, 18, 21, 24};
    return mnemonicWordCounts.contains(words.length) &&
        words.every((word) => RegExp(r'^[a-z]{2,12}$').hasMatch(word));
  }

  static bool _looksLikePrivateHexMaterial(String value) {
    return RegExp(r'^(0x)?[0-9a-fA-F]{64,128}$').hasMatch(value);
  }

  static String _normalizedKey(String key) =>
      key.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
}

class Phase6bTestReport {
  final String walletAppVersion;
  final String platform;
  final String endpoint;
  final String genesisHash;
  final String runtimeSpecName;
  final int runtimeSpecVersion;
  final int? transactionVersion;
  final int? metadataVersion;
  final String metadataFingerprint;
  final String? runtimeWasmHash;
  final int? aiStorageVersion;
  final int? aiPalletIndex;
  final String testSessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<String> participatingPublicAddresses;
  final String? modelId;
  final String? predictionId;
  final String? marketId;
  final List<Phase6bStageRecord> stages;
  final List<Phase6bBalanceObservation> balanceObservations;
  final Phase6bMarketTotalsObservation? marketTotals;
  final List<Phase6bTreasuryFeeObservation> treasuryAndFeeObservations;
  final String settlementResult;
  final String claimResult;
  final String postStateVerification;
  final List<String> warnings;
  final Map<String, Object?> additionalEvidence;

  Phase6bTestReport({
    required String walletAppVersion,
    required String platform,
    required String endpoint,
    required String genesisHash,
    required String runtimeSpecName,
    required this.runtimeSpecVersion,
    this.transactionVersion,
    this.metadataVersion,
    required String metadataFingerprint,
    String? runtimeWasmHash,
    this.aiStorageVersion,
    this.aiPalletIndex,
    required String testSessionId,
    required this.startedAt,
    required this.endedAt,
    required List<String> participatingPublicAddresses,
    this.modelId,
    this.predictionId,
    this.marketId,
    required List<Phase6bStageRecord> stages,
    this.balanceObservations = const [],
    this.marketTotals,
    this.treasuryAndFeeObservations = const [],
    required String settlementResult,
    required String claimResult,
    required String postStateVerification,
    this.warnings = const [],
    this.additionalEvidence = const {},
  }) : walletAppVersion = _requireReportText(
         walletAppVersion,
         'walletAppVersion',
       ),
       platform = _requireReportText(platform, 'platform'),
       endpoint = sanitizePhase6bEndpoint(endpoint),
       genesisHash = _requireReportText(genesisHash, 'genesisHash'),
       runtimeSpecName = _requireReportText(runtimeSpecName, 'runtimeSpecName'),
       metadataFingerprint = _requireReportText(
         metadataFingerprint,
         'metadataFingerprint',
       ),
       runtimeWasmHash = runtimeWasmHash == null
           ? null
           : _requireReportText(runtimeWasmHash, 'runtimeWasmHash'),
       testSessionId = _requireReportText(testSessionId, 'testSessionId'),
       participatingPublicAddresses = List.unmodifiable(
         _uniqueReportValues(participatingPublicAddresses),
       ),
       stages = List.unmodifiable(_validateAndSortStages(stages)),
       settlementResult = _requireReportText(
         settlementResult,
         'settlementResult',
       ),
       claimResult = _requireReportText(claimResult, 'claimResult'),
       postStateVerification = _requireReportText(
         postStateVerification,
         'postStateVerification',
       ) {
    if (runtimeSpecVersion < 0) {
      throw ArgumentError.value(runtimeSpecVersion, 'runtimeSpecVersion');
    }
    for (final entry in {
      'transactionVersion': transactionVersion,
      'metadataVersion': metadataVersion,
      'aiStorageVersion': aiStorageVersion,
      'aiPalletIndex': aiPalletIndex,
    }.entries) {
      if (entry.value != null && entry.value! < 0) {
        throw ArgumentError.value(entry.value, entry.key);
      }
    }
    if (this.participatingPublicAddresses.isEmpty) {
      throw ArgumentError('At least one participating address is required.');
    }
    if (endedAt != null && endedAt!.isBefore(startedAt)) {
      throw ArgumentError('endedAt must not be before startedAt.');
    }
  }

  Phase6bTestOutcome get overallResult {
    final aggregate = aggregatePhase6bTestOutcome(stages);
    if (aggregate == Phase6bTestOutcome.fail) return aggregate;
    if (endedAt == null) return Phase6bTestOutcome.blocked;
    return aggregate;
  }

  List<String> get callNames => List.unmodifiable(
    stages
        .where((stage) => stage.isLiveTransaction)
        .map((stage) => stage.exactCall),
  );

  List<String> get transactionHashes => List.unmodifiable(
    stages.map((stage) => stage.receipt?.transactionHash).whereType<String>(),
  );

  /// Returns only redacted, JSON-compatible values.
  Map<String, Object?> toJson() {
    return Phase6bReportRedactor.redactMap(_unredactedJson());
  }

  String toJsonString({bool pretty = true}) {
    return pretty
        ? const JsonEncoder.withIndent('  ').convert(toJson())
        : jsonEncode(toJson());
  }

  String toMarkdown() => _markdownFromRedactedJson(toJson());

  String get copySummary => _summaryFromRedactedJson(toJson());

  Phase6bReportExportPayload get exportPayload => Phase6bReportExportPayload._(
    json: toJsonString(),
    markdown: toMarkdown(),
    summary: copySummary,
  );

  Map<Object?, Object?> _unredactedJson() {
    final receipts = stages
        .where((stage) => stage.receipt != null)
        .map((stage) => MapEntry(stage, stage.receipt!))
        .toList();

    return {
      'walletAppVersion': walletAppVersion,
      'platform': platform,
      'endpoint': endpoint,
      'genesisHash': genesisHash,
      'runtimeSpecName': runtimeSpecName,
      'runtimeSpecVersion': runtimeSpecVersion,
      'transactionVersion': transactionVersion,
      'metadataVersion': metadataVersion,
      'metadataFingerprint': metadataFingerprint,
      'runtimeWasmHash': runtimeWasmHash,
      'aiStorageVersion': aiStorageVersion,
      'aiPalletIndex': aiPalletIndex,
      'testSessionId': testSessionId,
      'startTimestamp': startedAt,
      'endTimestamp': endedAt,
      'participatingPublicAddresses': participatingPublicAddresses,
      'modelId': modelId,
      'predictionId': predictionId,
      'marketId': marketId,
      'callNames': callNames,
      'transactionHashes': transactionHashes,
      'inclusionBlocks': receipts
          .map(
            (entry) => {
              'callName': entry.key.exactCall,
              'transactionHash': entry.value.transactionHash,
              'blockNumber': entry.value.inclusionBlockNumber,
              'blockHash': entry.value.inclusionBlockHash,
            },
          )
          .toList(),
      'finalityBlocks': receipts
          .map(
            (entry) => {
              'callName': entry.key.exactCall,
              'transactionHash': entry.value.transactionHash,
              'blockNumber': entry.value.finalizedBlockNumber,
              'blockHash': entry.value.finalizedBlockHash,
            },
          )
          .toList(),
      'dispatchResults': receipts
          .map(
            (entry) => {
              'callName': entry.key.exactCall,
              'transactionHash': entry.value.transactionHash,
              'dispatchResult': entry.value.dispatchResult,
            },
          )
          .toList(),
      'relevantEvents': receipts
          .expand(
            (entry) => entry.value.relevantEvents.map(
              (event) => {
                'callName': entry.key.exactCall,
                'transactionHash': entry.value.transactionHash,
                'event': event,
              },
            ),
          )
          .toList(),
      'balancesBeforeAfter': balanceObservations
          .map((item) => item.toJson())
          .toList(),
      'yesNoTotalsBeforeAfter': marketTotals?.toJson(),
      'treasuryAndFeeObservations': treasuryAndFeeObservations
          .map((item) => item.toJson())
          .toList(),
      'settlementResult': settlementResult,
      'claimResult': claimResult,
      'postStateVerification': postStateVerification,
      'warnings': warnings,
      'overallResult': overallResult.label,
      'batchAutomationAllowed': Phase6bTestLifecycle.batchAutomationAllowed,
      'stages': stages.map((stage) => stage.toJson()).toList(),
      'additionalEvidence': additionalEvidence,
    };
  }
}

class Phase6bReportExportPayload {
  final String json;
  final String markdown;
  final String summary;

  const Phase6bReportExportPayload._({
    required this.json,
    required this.markdown,
    required this.summary,
  });
}

String _markdownFromRedactedJson(Map<String, Object?> data) {
  final buffer = StringBuffer()
    ..writeln('# ERA Phase 6B Lifecycle Test Report')
    ..writeln()
    ..writeln('| Report field | Value |')
    ..writeln('| --- | --- |')
    ..writeln('| Overall result | ${_markdownValue(data['overallResult'])} |')
    ..writeln(
      '| Wallet app version | ${_markdownValue(data['walletAppVersion'])} |',
    )
    ..writeln('| Platform | ${_markdownValue(data['platform'])} |')
    ..writeln('| Endpoint | ${_markdownValue(data['endpoint'])} |')
    ..writeln('| Genesis hash | ${_markdownValue(data['genesisHash'])} |')
    ..writeln(
      '| Runtime specName | ${_markdownValue(data['runtimeSpecName'])} |',
    )
    ..writeln(
      '| Runtime specVersion | ${_markdownValue(data['runtimeSpecVersion'])} |',
    )
    ..writeln(
      '| Transaction version | ${_markdownValue(data['transactionVersion'])} |',
    )
    ..writeln(
      '| Metadata version | ${_markdownValue(data['metadataVersion'])} |',
    )
    ..writeln(
      '| Metadata fingerprint | ${_markdownValue(data['metadataFingerprint'])} |',
    )
    ..writeln(
      '| Runtime WASM hash | ${_markdownValue(data['runtimeWasmHash'])} |',
    )
    ..writeln(
      '| AI storage version | ${_markdownValue(data['aiStorageVersion'])} |',
    )
    ..writeln('| AI pallet index | ${_markdownValue(data['aiPalletIndex'])} |')
    ..writeln('| Test-session ID | ${_markdownValue(data['testSessionId'])} |')
    ..writeln('| Start timestamp | ${_markdownValue(data['startTimestamp'])} |')
    ..writeln('| End timestamp | ${_markdownValue(data['endTimestamp'])} |')
    ..writeln('| Model ID | ${_markdownValue(data['modelId'])} |')
    ..writeln('| Prediction ID | ${_markdownValue(data['predictionId'])} |')
    ..writeln('| Market ID | ${_markdownValue(data['marketId'])} |')
    ..writeln(
      '| Batch automation allowed | ${_markdownValue(data['batchAutomationAllowed'])} |',
    )
    ..writeln()
    ..writeln('## Participating public addresses')
    ..writeln();

  _writeBullets(buffer, _asList(data['participatingPublicAddresses']));

  buffer
    ..writeln('## Calls and transaction evidence')
    ..writeln()
    ..writeln('Call names: ${_markdownValue(data['callNames'])}')
    ..writeln()
    ..writeln(
      'Transaction hashes: ${_markdownValue(data['transactionHashes'])}',
    )
    ..writeln()
    ..writeln('Inclusion blocks: ${_markdownValue(data['inclusionBlocks'])}')
    ..writeln()
    ..writeln('Finality blocks: ${_markdownValue(data['finalityBlocks'])}')
    ..writeln()
    ..writeln('Dispatch results: ${_markdownValue(data['dispatchResults'])}')
    ..writeln()
    ..writeln('Relevant events: ${_markdownValue(data['relevantEvents'])}')
    ..writeln()
    ..writeln('## Balance and market accounting')
    ..writeln()
    ..writeln(
      'Balances before/after: ${_markdownValue(data['balancesBeforeAfter'])}',
    )
    ..writeln()
    ..writeln(
      'YES/NO totals before/after: ${_markdownValue(data['yesNoTotalsBeforeAfter'])}',
    )
    ..writeln()
    ..writeln(
      'Treasury/fee observations: ${_markdownValue(data['treasuryAndFeeObservations'])}',
    )
    ..writeln()
    ..writeln('## Lifecycle outcome')
    ..writeln()
    ..writeln(
      '- Settlement result: ${_markdownValue(data['settlementResult'])}',
    )
    ..writeln('- Claim result: ${_markdownValue(data['claimResult'])}')
    ..writeln(
      '- Post-state verification: ${_markdownValue(data['postStateVerification'])}',
    )
    ..writeln()
    ..writeln('## Stage results')
    ..writeln();

  for (final rawStage in _asList(data['stages'])) {
    final stage = _asMap(rawStage);
    buffer
      ..writeln(
        '### ${_markdownValue(stage['stageNumber'])}. ${_markdownValue(stage['stageTitle'])}',
      )
      ..writeln()
      ..writeln('| Stage field | Value |')
      ..writeln('| --- | --- |')
      ..writeln('| Result | ${_markdownValue(stage['result'])} |')
      ..writeln(
        '| Prerequisite checks | ${_markdownValue(stage['prerequisiteChecks'])} |',
      )
      ..writeln(
        '| Exact intended call | ${_markdownValue(stage['exactCall'])} |',
      )
      ..writeln('| Public signer | ${_markdownValue(stage['publicSigner'])} |')
      ..writeln('| Fee estimate | ${_markdownValue(stage['feeEstimate'])} |')
      ..writeln(
        '| Per-action confirmation | ${_markdownValue(stage['perActionConfirmation'])} |',
      )
      ..writeln(
        '| Receipt reference | ${_markdownValue(stage['receiptReference'])} |',
      )
      ..writeln(
        '| Chain-state verification | ${_markdownValue(stage['chainStateVerification'])} |',
      )
      ..writeln('| Notes | ${_markdownValue(stage['notes'])} |')
      ..writeln('| Warnings | ${_markdownValue(stage['warnings'])} |')
      ..writeln('| Completed at | ${_markdownValue(stage['completedAt'])} |')
      ..writeln();
  }

  buffer
    ..writeln('## Warnings')
    ..writeln();
  _writeBullets(buffer, _asList(data['warnings']), emptyText: 'None recorded.');
  buffer
    ..writeln('## Additional evidence')
    ..writeln()
    ..writeln('```json')
    ..writeln(
      const JsonEncoder.withIndent('  ').convert(data['additionalEvidence']),
    )
    ..writeln('```');

  return buffer.toString();
}

String _summaryFromRedactedJson(Map<String, Object?> data) {
  final warnings = _asList(data['warnings']);
  final callNames = _asList(data['callNames']);
  final transactionHashes = _asList(data['transactionHashes']);
  return [
    'ERA Phase 6B test session ${_plainValue(data['testSessionId'])}',
    'Overall result: ${_plainValue(data['overallResult'])}',
    'Runtime: ${_plainValue(data['runtimeSpecName'])} spec ${_plainValue(data['runtimeSpecVersion'])}',
    'Model/prediction/market: ${_plainValue(data['modelId'])} / ${_plainValue(data['predictionId'])} / ${_plainValue(data['marketId'])}',
    'Calls recorded: ${callNames.length}',
    'Transactions recorded: ${transactionHashes.length}',
    'Warnings: ${warnings.isEmpty ? 'none' : warnings.map(_plainValue).join('; ')}',
  ].join('\n');
}

void _writeBullets(
  StringBuffer buffer,
  List<Object?> values, {
  String emptyText = 'None recorded.',
}) {
  if (values.isEmpty) {
    buffer
      ..writeln(emptyText)
      ..writeln();
    return;
  }
  for (final value in values) {
    buffer.writeln('- ${_markdownValue(value)}');
  }
  buffer.writeln();
}

String _markdownValue(Object? value) {
  final raw = _plainValue(value);
  return raw
      .replaceAll('\\', '\\\\')
      .replaceAll('|', '\\|')
      .replaceAll('\r\n', '<br>')
      .replaceAll('\n', '<br>');
}

String _plainValue(Object? value) {
  if (value == null) return 'Not recorded';
  if (value is String) return value.isEmpty ? 'Not recorded' : value;
  if (value is Map || value is List) return jsonEncode(value);
  return value.toString();
}

List<Object?> _asList(Object? value) =>
    value is List ? value.cast<Object?>() : const [];

Map<String, Object?> _asMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, item) => MapEntry(key.toString(), item));
}

String _requireReportText(String value, String name) {
  final checked = value.trim();
  if (checked.isEmpty) {
    throw ArgumentError.value(value, name, 'Must not be empty');
  }
  return checked;
}

List<String> _uniqueReportValues(Iterable<String> values) {
  final result = <String>[];
  for (final value in values) {
    final checked = _requireReportText(value, 'participatingPublicAddresses');
    if (!result.contains(checked)) result.add(checked);
  }
  return result;
}

List<Phase6bStageRecord> _validateAndSortStages(
  Iterable<Phase6bStageRecord> stages,
) {
  final result = stages.toList();
  final uniqueStages = result.map((item) => item.stage).toSet();
  if (uniqueStages.length != result.length) {
    throw ArgumentError('A report cannot contain duplicate lifecycle stages.');
  }
  result.sort((a, b) => a.definition.number.compareTo(b.definition.number));
  return result;
}
