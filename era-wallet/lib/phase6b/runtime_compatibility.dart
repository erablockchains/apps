/// Pure-Dart runtime compatibility policy for the ERA AI Predictions pallet.
///
/// The approved values in this file come from the pinned spec-13 capture recorded
/// in `docs/phase6b-wallet-runtime-discovery.md`.  This module does not decode
/// metadata itself.  Instead, a metadata adapter supplies an observed
/// [EraRuntimeFingerprint], including resolved SCALE type names, and this policy
/// compares it with the reviewed capture before signing is allowed.
library;

const bool enablePhase6bTestingTools = bool.fromEnvironment(
  'ENABLE_PHASE6B_TESTING_TOOLS',
  defaultValue: false,
);

const bool enablePhase6bGovernanceActions = bool.fromEnvironment(
  'ENABLE_PHASE6B_GOVERNANCE_ACTIONS',
  defaultValue: false,
);

enum Phase6bCapabilityLevel {
  unavailable,
  phase6aParticipant,
  phase6bParticipant,
  phase6bOperator,
}

extension Phase6bCapabilityLevelLabel on Phase6bCapabilityLevel {
  String get label => switch (this) {
    Phase6bCapabilityLevel.unavailable => 'Unavailable',
    Phase6bCapabilityLevel.phase6aParticipant => 'Phase 6A participant mode',
    Phase6bCapabilityLevel.phase6bParticipant => 'Phase 6B participant mode',
    Phase6bCapabilityLevel.phase6bOperator => 'Phase 6B operator mode',
  };
}

enum RuntimeStorageModifier { defaultValue, optional }

enum RuntimeStorageShape { plain, map }

enum RuntimeCompatibilityIssueKind {
  runtimeIdentity,
  metadataIdentity,
  palletIdentity,
  missingCall,
  callIndex,
  callTypeSignature,
  missingStorage,
  storageTypeSignature,
}

/// Compile-time feature switches, injectable so policy tests do not depend on
/// the process-wide Dart environment.
class Phase6bBuildFlags {
  final bool testingToolsEnabled;
  final bool governanceActionsEnabled;

  const Phase6bBuildFlags({
    required this.testingToolsEnabled,
    required this.governanceActionsEnabled,
  });

  const Phase6bBuildFlags.fromEnvironment()
    : testingToolsEnabled = enablePhase6bTestingTools,
      governanceActionsEnabled = enablePhase6bGovernanceActions;
}

/// A metadata type reference as observed on a call argument or storage entry.
///
/// [metadataTypeName] is the alias encoded on a call field, such as `ModelId`
/// or `BalanceOf<T>`. Storage entries do not carry such aliases, so their
/// expected value is null. [resolvedScaleType] records the decoded SCALE shape.
class RuntimeTypeSignature {
  final int portableTypeId;
  final String? metadataTypeName;
  final String resolvedScaleType;

  const RuntimeTypeSignature({
    required this.portableTypeId,
    required this.resolvedScaleType,
    this.metadataTypeName,
  });

  RuntimeTypeSignature copyWith({
    int? portableTypeId,
    Object? metadataTypeName = _notProvided,
    String? resolvedScaleType,
  }) {
    return RuntimeTypeSignature(
      portableTypeId: portableTypeId ?? this.portableTypeId,
      metadataTypeName: identical(metadataTypeName, _notProvided)
          ? this.metadataTypeName
          : metadataTypeName as String?,
      resolvedScaleType: resolvedScaleType ?? this.resolvedScaleType,
    );
  }

  String describe({bool includePortableTypeId = true}) {
    final alias = metadataTypeName == null ? '' : '$metadataTypeName => ';
    final typeId = includePortableTypeId ? ' (type $portableTypeId)' : '';
    return '$alias$resolvedScaleType$typeId';
  }
}

class RuntimeCallArgumentSignature {
  final String name;
  final RuntimeTypeSignature type;

  const RuntimeCallArgumentSignature({required this.name, required this.type});

  RuntimeCallArgumentSignature copyWith({
    String? name,
    RuntimeTypeSignature? type,
  }) {
    return RuntimeCallArgumentSignature(
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  String describe({bool includePortableTypeId = true}) =>
      '$name: ${type.describe(includePortableTypeId: includePortableTypeId)}';
}

class RuntimeCallSignature {
  final String name;
  final int index;
  final List<RuntimeCallArgumentSignature> arguments;

  RuntimeCallSignature({
    required this.name,
    required this.index,
    required Iterable<RuntimeCallArgumentSignature> arguments,
  }) : arguments = List.unmodifiable(arguments);

  const RuntimeCallSignature._approved(this.name, this.index, this.arguments);

  RuntimeCallSignature copyWith({
    String? name,
    int? index,
    Iterable<RuntimeCallArgumentSignature>? arguments,
  }) {
    return RuntimeCallSignature(
      name: name ?? this.name,
      index: index ?? this.index,
      arguments: arguments ?? this.arguments,
    );
  }

  String describe({bool includePortableTypeIds = true}) {
    final args = arguments
        .map(
          (argument) =>
              argument.describe(includePortableTypeId: includePortableTypeIds),
        )
        .join(', ');
    return '$name[$index]($args)';
  }
}

class RuntimeStorageSignature {
  final String name;
  final RuntimeStorageModifier modifier;
  final RuntimeStorageShape shape;
  final RuntimeTypeSignature? keyType;
  final List<String> hashers;
  final RuntimeTypeSignature valueType;

  RuntimeStorageSignature({
    required this.name,
    required this.modifier,
    required this.shape,
    required this.valueType,
    this.keyType,
    Iterable<String> hashers = const [],
  }) : hashers = List.unmodifiable(hashers) {
    if (shape == RuntimeStorageShape.plain &&
        (keyType != null || this.hashers.isNotEmpty)) {
      throw ArgumentError('Plain storage cannot have a key or hashers.');
    }
    if (shape == RuntimeStorageShape.map &&
        (keyType == null || this.hashers.isEmpty)) {
      throw ArgumentError(
        'Map storage requires a key and at least one hasher.',
      );
    }
  }

  RuntimeStorageSignature copyWith({
    String? name,
    RuntimeStorageModifier? modifier,
    RuntimeStorageShape? shape,
    Object? keyType = _notProvided,
    Iterable<String>? hashers,
    RuntimeTypeSignature? valueType,
  }) {
    return RuntimeStorageSignature(
      name: name ?? this.name,
      modifier: modifier ?? this.modifier,
      shape: shape ?? this.shape,
      keyType: identical(keyType, _notProvided)
          ? this.keyType
          : keyType as RuntimeTypeSignature?,
      hashers: hashers ?? this.hashers,
      valueType: valueType ?? this.valueType,
    );
  }

  String describe({bool includePortableTypeIds = true}) {
    final modifierName = modifier == RuntimeStorageModifier.defaultValue
        ? 'Default'
        : 'Optional';
    if (shape == RuntimeStorageShape.plain) {
      return '$name ($modifierName plain -> '
          '${valueType.describe(includePortableTypeId: includePortableTypeIds)})';
    }
    return '$name ($modifierName map '
        '${keyType!.describe(includePortableTypeId: includePortableTypeIds)} '
        '[${hashers.join(', ')}] -> '
        '${valueType.describe(includePortableTypeId: includePortableTypeIds)})';
  }
}

class RuntimePalletFingerprint {
  final String name;
  final int index;
  final String storagePrefix;
  final Map<String, RuntimeCallSignature> calls;
  final Map<String, RuntimeStorageSignature> storage;

  RuntimePalletFingerprint({
    required this.name,
    required this.index,
    required this.storagePrefix,
    required Map<String, RuntimeCallSignature> calls,
    required Map<String, RuntimeStorageSignature> storage,
  }) : calls = Map.unmodifiable(calls),
       storage = Map.unmodifiable(storage);

  factory RuntimePalletFingerprint.fromSignatures({
    required String name,
    required int index,
    required String storagePrefix,
    required Iterable<RuntimeCallSignature> calls,
    required Iterable<RuntimeStorageSignature> storage,
  }) {
    return RuntimePalletFingerprint(
      name: name,
      index: index,
      storagePrefix: storagePrefix,
      calls: {for (final call in calls) call.name: call},
      storage: {for (final item in storage) item.name: item},
    );
  }

  RuntimePalletFingerprint copyWith({
    String? name,
    int? index,
    String? storagePrefix,
    Map<String, RuntimeCallSignature>? calls,
    Map<String, RuntimeStorageSignature>? storage,
  }) {
    return RuntimePalletFingerprint(
      name: name ?? this.name,
      index: index ?? this.index,
      storagePrefix: storagePrefix ?? this.storagePrefix,
      calls: calls ?? this.calls,
      storage: storage ?? this.storage,
    );
  }
}

class EraRuntimeFingerprint {
  final String genesisHash;
  final String specName;
  final int specVersion;
  final int transactionVersion;
  final int metadataVersion;
  final String metadataHash;
  final String runtimeWasmHash;
  final int? aiPredictionsStorageVersion;
  final RuntimePalletFingerprint? aiPredictionsPallet;

  const EraRuntimeFingerprint({
    required this.genesisHash,
    required this.specName,
    required this.specVersion,
    required this.transactionVersion,
    required this.metadataVersion,
    required this.metadataHash,
    required this.runtimeWasmHash,
    required this.aiPredictionsStorageVersion,
    required this.aiPredictionsPallet,
  });

  EraRuntimeFingerprint copyWith({
    String? genesisHash,
    String? specName,
    int? specVersion,
    int? transactionVersion,
    int? metadataVersion,
    String? metadataHash,
    String? runtimeWasmHash,
    Object? aiPredictionsStorageVersion = _notProvided,
    Object? aiPredictionsPallet = _notProvided,
  }) {
    return EraRuntimeFingerprint(
      genesisHash: genesisHash ?? this.genesisHash,
      specName: specName ?? this.specName,
      specVersion: specVersion ?? this.specVersion,
      transactionVersion: transactionVersion ?? this.transactionVersion,
      metadataVersion: metadataVersion ?? this.metadataVersion,
      metadataHash: metadataHash ?? this.metadataHash,
      runtimeWasmHash: runtimeWasmHash ?? this.runtimeWasmHash,
      aiPredictionsStorageVersion:
          identical(aiPredictionsStorageVersion, _notProvided)
          ? this.aiPredictionsStorageVersion
          : aiPredictionsStorageVersion as int?,
      aiPredictionsPallet: identical(aiPredictionsPallet, _notProvided)
          ? this.aiPredictionsPallet
          : aiPredictionsPallet as RuntimePalletFingerprint?,
    );
  }

  String get shortDescription =>
      '$specName/$specVersion tx=$transactionVersion metadata=v$metadataVersion '
      '${_normalizeHash(metadataHash)} wasm=${_normalizeHash(runtimeWasmHash)} '
      'AI-storage='
      '${aiPredictionsStorageVersion ?? 'unknown'}';
}

class RuntimeCompatibilityIssue {
  final RuntimeCompatibilityIssueKind kind;
  final String code;
  final String message;
  final String? expected;
  final String? actual;

  const RuntimeCompatibilityIssue({
    required this.kind,
    required this.code,
    required this.message,
    this.expected,
    this.actual,
  });

  String get explanation {
    final comparison = expected == null && actual == null
        ? ''
        : ' Expected: ${expected ?? '(not present)'}. '
              'Observed: ${actual ?? '(not present)'}.';
    return '$message$comparison';
  }
}

class RuntimeCompatibilityResult {
  final Phase6bCapabilityLevel level;
  final bool metadataCompatible;
  final bool metadataDriftDetected;
  final bool participantSigningEnabled;
  final bool testingToolsEnabled;
  final bool governanceActionsEnabled;
  final List<RuntimeCompatibilityIssue> issues;
  final List<String> warnings;

  RuntimeCompatibilityResult({
    required this.level,
    required this.metadataCompatible,
    required this.metadataDriftDetected,
    required this.participantSigningEnabled,
    required this.testingToolsEnabled,
    required this.governanceActionsEnabled,
    required Iterable<RuntimeCompatibilityIssue> issues,
    required Iterable<String> warnings,
  }) : issues = List.unmodifiable(issues),
       warnings = List.unmodifiable(warnings);

  bool get signingEnabled =>
      participantSigningEnabled || governanceActionsEnabled;

  bool get operatorMode => level == Phase6bCapabilityLevel.phase6bOperator;

  String get explanation {
    if (issues.isNotEmpty) {
      return issues.map((issue) => issue.explanation).join('\n');
    }
    if (warnings.isNotEmpty) return warnings.join('\n');
    return '${level.label} is compatible.';
  }
}

/// Reviewed compatibility surface for ERA Phase 6B.
///
/// Spec 13 is fail-closed: every identity value and every decoded call/storage
/// signature below must match. Spec 8 can be recognized only as legacy Phase 6A
/// participant mode, using the preserved market calls and their canonical
/// storage. No version greater than 13 is accepted without a new reviewed pin.
class Phase6bRuntimeCompatibility {
  static const approvedGenesisHash =
      '0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7';
  static const approvedSpecName = 'era';
  static const approvedSpecVersion = 13;
  static const approvedTransactionVersion = 1;
  static const approvedMetadataVersion = 14;
  static const approvedMetadataHash =
      '5c3715502b0f4cd3c3bc124f13f7f153cd3486e0c3877dc1d685335e57ed4c3f';
  static const approvedRuntimeWasmHash =
      'ecca5baddc60d4e8522c8ea6206fec0c29175d59ddf2359e6d43201f1faa44a2';
  static const approvedAiPalletName = 'AiPredictions';
  static const approvedAiPalletIndex = 12;
  static const approvedAiStoragePrefix = 'AiPredictions';
  static const approvedAiStorageVersion = 3;

  static final EraRuntimeFingerprint approvedSpec13Fingerprint =
      EraRuntimeFingerprint(
        genesisHash: approvedGenesisHash,
        specName: approvedSpecName,
        specVersion: approvedSpecVersion,
        transactionVersion: approvedTransactionVersion,
        metadataVersion: approvedMetadataVersion,
        metadataHash: approvedMetadataHash,
        runtimeWasmHash: approvedRuntimeWasmHash,
        aiPredictionsStorageVersion: approvedAiStorageVersion,
        aiPredictionsPallet: RuntimePalletFingerprint.fromSignatures(
          name: approvedAiPalletName,
          index: approvedAiPalletIndex,
          storagePrefix: approvedAiStoragePrefix,
          calls: approvedCalls,
          storage: approvedStorage,
        ),
      );

  @Deprecated('Use approvedSpec13Fingerprint.')
  static final EraRuntimeFingerprint approvedSpec9Fingerprint =
      approvedSpec13Fingerprint;

  static List<RuntimeCallSignature> get phase6aParticipantCalls => approvedCalls
      .where((call) => const {31, 32, 33}.contains(call.index))
      .toList(growable: false);

  static List<RuntimeStorageSignature> get phase6aParticipantStorage {
    const names = {
      'PredictionTokens',
      'PredictionTokenByPrediction',
      'PredictionTokenSettlements',
      'PredictionMarketEconomicsConfig',
      'PredictionTokenSideStakes',
      'PredictionTokenSideTotals',
      'PredictionTokenSidePayoutClaims',
      'PredictionTokenMarketLocked',
      'PredictionTokenMarketAccounting',
    };
    return approvedStorage
        .where((storage) => names.contains(storage.name))
        .toList(growable: false);
  }

  const Phase6bRuntimeCompatibility();

  RuntimeCompatibilityResult assess(
    EraRuntimeFingerprint observed, {
    Phase6bBuildFlags flags = const Phase6bBuildFlags.fromEnvironment(),
  }) {
    final warnings = <String>[];
    final issues = <RuntimeCompatibilityIssue>[];
    final pallet = observed.aiPredictionsPallet;

    if (observed.specName != approvedSpecName) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.runtimeIdentity,
          'spec_name_mismatch',
          'The runtime spec name is not approved for ERA wallet signing.',
          approvedSpecName,
          observed.specName,
        ),
      );
    }
    if (_normalizeHash(observed.genesisHash) !=
        _normalizeHash(approvedGenesisHash)) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.runtimeIdentity,
          'genesis_hash_mismatch',
          'The connected chain is not the reviewed ERA mainnet genesis.',
          approvedGenesisHash,
          observed.genesisHash,
        ),
      );
    }
    if (observed.transactionVersion != approvedTransactionVersion) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.runtimeIdentity,
          'transaction_version_mismatch',
          'The signed-transaction version differs from the reviewed binding.',
          '$approvedTransactionVersion',
          '${observed.transactionVersion}',
        ),
      );
    }
    if (observed.metadataVersion != approvedMetadataVersion) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.metadataIdentity,
          'metadata_version_mismatch',
          'The metadata compatibility version is not supported.',
          'V$approvedMetadataVersion',
          'V${observed.metadataVersion}',
        ),
      );
    }
    if (pallet == null) {
      issues.add(
        const RuntimeCompatibilityIssue(
          kind: RuntimeCompatibilityIssueKind.palletIdentity,
          code: 'ai_pallet_missing',
          message: 'The AiPredictions pallet is absent from runtime metadata.',
          expected: approvedAiPalletName,
        ),
      );
    } else {
      _comparePalletIdentity(pallet, issues);
    }

    if (issues.isNotEmpty) {
      return _unavailable(
        observed: observed,
        issues: issues,
        warnings: warnings,
      );
    }

    if (observed.specVersion == approvedSpecVersion) {
      _compareSpec13Identity(observed, issues);
      _compareCalls(
        expected: approvedCalls,
        observed: pallet!.calls,
        comparePortableTypeIds: true,
        issues: issues,
      );
      _compareStorage(
        expected: approvedStorage,
        observed: pallet.storage,
        comparePortableTypeIds: true,
        issues: issues,
      );
      if (issues.isNotEmpty) {
        return _unavailable(
          observed: observed,
          issues: issues,
          warnings: warnings,
          forceDrift: true,
        );
      }

      if (flags.governanceActionsEnabled && !flags.testingToolsEnabled) {
        warnings.add(
          'ENABLE_PHASE6B_GOVERNANCE_ACTIONS is ignored unless '
          'ENABLE_PHASE6B_TESTING_TOOLS is also enabled.',
        );
      }
      final testingEnabled = flags.testingToolsEnabled;
      final governanceEnabled =
          flags.testingToolsEnabled && flags.governanceActionsEnabled;
      return RuntimeCompatibilityResult(
        level: governanceEnabled
            ? Phase6bCapabilityLevel.phase6bOperator
            : Phase6bCapabilityLevel.phase6bParticipant,
        metadataCompatible: true,
        metadataDriftDetected: false,
        participantSigningEnabled: true,
        testingToolsEnabled: testingEnabled,
        governanceActionsEnabled: governanceEnabled,
        issues: const [],
        warnings: warnings,
      );
    }

    if (observed.specVersion == 8) {
      if (observed.metadataHash.trim().isEmpty) {
        issues.add(
          const RuntimeCompatibilityIssue(
            kind: RuntimeCompatibilityIssueKind.metadataIdentity,
            code: 'metadata_hash_missing',
            message: 'The legacy runtime metadata fingerprint is missing.',
            expected: 'a SHA-256 metadata fingerprint',
            actual: '(empty)',
          ),
        );
      }
      if (observed.aiPredictionsStorageVersion == null) {
        issues.add(
          const RuntimeCompatibilityIssue(
            kind: RuntimeCompatibilityIssueKind.metadataIdentity,
            code: 'ai_storage_version_missing',
            message: 'The AI Predictions storage version could not be read.',
            expected: 'a decoded FRAME storage version',
            actual: '(unavailable)',
          ),
        );
      }
      _compareCalls(
        expected: phase6aParticipantCalls,
        observed: pallet!.calls,
        comparePortableTypeIds: false,
        issues: issues,
      );
      _compareStorage(
        expected: phase6aParticipantStorage,
        observed: pallet.storage,
        comparePortableTypeIds: false,
        issues: issues,
      );
      if (issues.isNotEmpty) {
        return _unavailable(
          observed: observed,
          issues: issues,
          warnings: warnings,
        );
      }
      warnings.add(
        'Legacy spec 8 is structurally compatible only with the preserved '
        'Phase 6A market data. Signing remains disabled until an exact spec-8 '
        'metadata/WASM fingerprint and the persistent finalized lifecycle '
        'runner are reviewed for that runtime.',
      );
      if (flags.testingToolsEnabled || flags.governanceActionsEnabled) {
        warnings.add('Phase 6B build flags cannot elevate a legacy runtime.');
      }
      return RuntimeCompatibilityResult(
        level: Phase6bCapabilityLevel.phase6aParticipant,
        metadataCompatible: true,
        metadataDriftDetected: false,
        participantSigningEnabled: false,
        testingToolsEnabled: false,
        governanceActionsEnabled: false,
        issues: const [],
        warnings: warnings,
      );
    }

    issues.add(
      _issue(
        RuntimeCompatibilityIssueKind.runtimeIdentity,
        'spec_version_unsupported',
        observed.specVersion > approvedSpecVersion
            ? 'The runtime is newer than the reviewed wallet binding.'
            : 'The runtime does not expose a supported Phase 6A or Phase 6B surface.',
        '8 or $approvedSpecVersion',
        '${observed.specVersion}',
      ),
    );
    return _unavailable(
      observed: observed,
      issues: issues,
      warnings: warnings,
      forceDrift: observed.specVersion > approvedSpecVersion,
    );
  }

  void _comparePalletIdentity(
    RuntimePalletFingerprint observed,
    List<RuntimeCompatibilityIssue> issues,
  ) {
    if (observed.name != approvedAiPalletName) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.palletIdentity,
          'ai_pallet_name_mismatch',
          'The AI Predictions pallet name changed.',
          approvedAiPalletName,
          observed.name,
        ),
      );
    }
    if (observed.index != approvedAiPalletIndex) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.palletIdentity,
          'ai_pallet_index_mismatch',
          'The AI Predictions pallet index changed.',
          '$approvedAiPalletIndex',
          '${observed.index}',
        ),
      );
    }
    if (observed.storagePrefix != approvedAiStoragePrefix) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.palletIdentity,
          'ai_storage_prefix_mismatch',
          'The AI Predictions storage prefix changed.',
          approvedAiStoragePrefix,
          observed.storagePrefix,
        ),
      );
    }
  }

  void _compareSpec13Identity(
    EraRuntimeFingerprint observed,
    List<RuntimeCompatibilityIssue> issues,
  ) {
    if (_normalizeHash(observed.metadataHash) !=
        _normalizeHash(approvedMetadataHash)) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.metadataIdentity,
          'metadata_hash_mismatch',
          'Runtime metadata differs from the pinned spec-13 binding.',
          approvedMetadataHash,
          observed.metadataHash,
        ),
      );
    }
    if (_normalizeHash(observed.runtimeWasmHash) !=
        _normalizeHash(approvedRuntimeWasmHash)) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.runtimeIdentity,
          'runtime_wasm_hash_mismatch',
          'Runtime executable code differs from the approved deployment.',
          approvedRuntimeWasmHash,
          observed.runtimeWasmHash,
        ),
      );
    }
    if (observed.aiPredictionsStorageVersion != approvedAiStorageVersion) {
      issues.add(
        _issue(
          RuntimeCompatibilityIssueKind.metadataIdentity,
          'ai_storage_version_mismatch',
          'The AI Predictions pallet storage version changed.',
          '$approvedAiStorageVersion',
          '${observed.aiPredictionsStorageVersion ?? '(unavailable)'}',
        ),
      );
    }
  }

  void _compareCalls({
    required Iterable<RuntimeCallSignature> expected,
    required Map<String, RuntimeCallSignature> observed,
    required bool comparePortableTypeIds,
    required List<RuntimeCompatibilityIssue> issues,
  }) {
    for (final requiredCall in expected) {
      final actual = observed[requiredCall.name];
      if (actual == null) {
        issues.add(
          RuntimeCompatibilityIssue(
            kind: RuntimeCompatibilityIssueKind.missingCall,
            code: 'missing_call_${requiredCall.name}',
            message: 'Required call `${requiredCall.name}` is missing.',
            expected: requiredCall.describe(
              includePortableTypeIds: comparePortableTypeIds,
            ),
            actual: null,
          ),
        );
        continue;
      }
      if (actual.index != requiredCall.index) {
        issues.add(
          _issue(
            RuntimeCompatibilityIssueKind.callIndex,
            'call_index_${requiredCall.name}',
            'Call `${requiredCall.name}` has an incompatible index.',
            '${requiredCall.index}',
            '${actual.index}',
          ),
        );
      }
      if (!_argumentsMatch(
        requiredCall.arguments,
        actual.arguments,
        comparePortableTypeIds: comparePortableTypeIds,
      )) {
        issues.add(
          _issue(
            RuntimeCompatibilityIssueKind.callTypeSignature,
            'call_signature_${requiredCall.name}',
            'Call `${requiredCall.name}` has incompatible arguments.',
            requiredCall.describe(
              includePortableTypeIds: comparePortableTypeIds,
            ),
            actual.describe(includePortableTypeIds: comparePortableTypeIds),
          ),
        );
      }
    }
  }

  void _compareStorage({
    required Iterable<RuntimeStorageSignature> expected,
    required Map<String, RuntimeStorageSignature> observed,
    required bool comparePortableTypeIds,
    required List<RuntimeCompatibilityIssue> issues,
  }) {
    for (final requiredStorage in expected) {
      final actual = observed[requiredStorage.name];
      if (actual == null) {
        issues.add(
          RuntimeCompatibilityIssue(
            kind: RuntimeCompatibilityIssueKind.missingStorage,
            code: 'missing_storage_${requiredStorage.name}',
            message: 'Required storage `${requiredStorage.name}` is missing.',
            expected: requiredStorage.describe(
              includePortableTypeIds: comparePortableTypeIds,
            ),
            actual: null,
          ),
        );
        continue;
      }
      if (!_storageMatches(
        requiredStorage,
        actual,
        comparePortableTypeIds: comparePortableTypeIds,
      )) {
        issues.add(
          _issue(
            RuntimeCompatibilityIssueKind.storageTypeSignature,
            'storage_signature_${requiredStorage.name}',
            'Storage `${requiredStorage.name}` has an incompatible signature.',
            requiredStorage.describe(
              includePortableTypeIds: comparePortableTypeIds,
            ),
            actual.describe(includePortableTypeIds: comparePortableTypeIds),
          ),
        );
      }
    }
  }

  RuntimeCompatibilityResult _unavailable({
    required EraRuntimeFingerprint observed,
    required List<RuntimeCompatibilityIssue> issues,
    required List<String> warnings,
    bool forceDrift = false,
  }) {
    final drift =
        forceDrift ||
        (observed.specName == approvedSpecName &&
            observed.specVersion >= approvedSpecVersion);
    return RuntimeCompatibilityResult(
      level: Phase6bCapabilityLevel.unavailable,
      metadataCompatible: false,
      metadataDriftDetected: drift,
      participantSigningEnabled: false,
      testingToolsEnabled: false,
      governanceActionsEnabled: false,
      issues: issues,
      warnings: warnings,
    );
  }

  static const List<RuntimeCallSignature> approvedCalls = [
    RuntimeCallSignature._approved('register_model', 0, [
      RuntimeCallArgumentSignature(name: 'model_hash', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'metadata_uri', type: _vecU8),
    ]),
    RuntimeCallSignature._approved('update_model', 1, [
      RuntimeCallArgumentSignature(name: 'model_id', type: _modelId),
      RuntimeCallArgumentSignature(name: 'model_hash', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'metadata_uri', type: _vecU8),
    ]),
    RuntimeCallSignature._approved('submit_prediction', 2, [
      RuntimeCallArgumentSignature(name: 'model_id', type: _modelId),
      RuntimeCallArgumentSignature(name: 'domain', type: _predictionDomain),
      RuntimeCallArgumentSignature(name: 'category_code', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'prediction_hash', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'metadata_uri', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'confidence', type: _u8Call),
      RuntimeCallArgumentSignature(name: 'expires_at', type: _blockNumber),
    ]),
    RuntimeCallSignature._approved('validate_prediction', 3, [
      RuntimeCallArgumentSignature(name: 'prediction_id', type: _predictionId),
      RuntimeCallArgumentSignature(name: 'outcome', type: _predictionOutcome),
    ]),
    RuntimeCallSignature._approved('close_prediction', 4, [
      RuntimeCallArgumentSignature(name: 'prediction_id', type: _predictionId),
    ]),
    RuntimeCallSignature._approved('authorize_validator', 5, [
      RuntimeCallArgumentSignature(name: 'account', type: _accountIdCall),
    ]),
    RuntimeCallSignature._approved('remove_validator', 6, [
      RuntimeCallArgumentSignature(name: 'account', type: _accountIdCall),
    ]),
    RuntimeCallSignature._approved('set_tokenization_config', 7, [
      RuntimeCallArgumentSignature(
        name: 'tokenization_enabled',
        type: _boolCall,
      ),
      RuntimeCallArgumentSignature(name: 'transfers_enabled', type: _boolCall),
    ]),
    RuntimeCallSignature._approved('tokenize_prediction', 8, [
      RuntimeCallArgumentSignature(name: 'prediction_id', type: _predictionId),
      RuntimeCallArgumentSignature(name: 'metadata_uri', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'transferable', type: _boolCall),
    ]),
    RuntimeCallSignature._approved('approve_prediction_token_transfer', 9, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'approved', type: _accountIdCall),
    ]),
    RuntimeCallSignature._approved('revoke_prediction_token_approval', 10, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('transfer_prediction_token', 11, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'to', type: _accountIdCall),
    ]),
    RuntimeCallSignature._approved('freeze_prediction_token', 12, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('unfreeze_prediction_token', 13, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('burn_prediction_token', 14, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('update_prediction_token_metadata', 15, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'metadata_uri', type: _vecU8),
    ]),
    RuntimeCallSignature._approved('set_staking_config', 16, [
      RuntimeCallArgumentSignature(name: 'staking_enabled', type: _boolCall),
      RuntimeCallArgumentSignature(name: 'min_stake', type: _balance),
    ]),
    RuntimeCallSignature._approved('stake_on_prediction_token', 17, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'amount', type: _balance),
    ]),
    RuntimeCallSignature._approved('unstake_prediction_token', 18, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'amount', type: _balance),
    ]),
    RuntimeCallSignature._approved('lock_prediction_token_stake', 19, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('release_prediction_token_stake', 20, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('set_settlement_config', 21, [
      RuntimeCallArgumentSignature(name: 'settlement_enabled', type: _boolCall),
      RuntimeCallArgumentSignature(
        name: 'dispute_window_blocks',
        type: _blockNumber,
      ),
      RuntimeCallArgumentSignature(name: 'min_dispute_bond', type: _balance),
    ]),
    RuntimeCallSignature._approved('propose_prediction_outcome', 22, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(
        name: 'proposed_outcome',
        type: _settlementOutcome,
      ),
      RuntimeCallArgumentSignature(name: 'evidence_uri', type: _vecU8),
    ]),
    RuntimeCallSignature._approved('dispute_prediction_outcome', 23, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'reason', type: _disputeReason),
      RuntimeCallArgumentSignature(name: 'evidence_uri', type: _vecU8),
      RuntimeCallArgumentSignature(name: 'bond', type: _balance),
    ]),
    RuntimeCallSignature._approved('admin_finalize_prediction_outcome', 24, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(
        name: 'final_outcome',
        type: _settlementOutcome,
      ),
      RuntimeCallArgumentSignature(name: 'evidence_uri', type: _vecU8),
    ]),
    RuntimeCallSignature._approved(
      'finalize_prediction_outcome_after_dispute_window',
      25,
      [RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId)],
    ),
    RuntimeCallSignature._approved('cancel_prediction_settlement', 26, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'evidence_uri', type: _vecU8),
    ]),
    RuntimeCallSignature._approved('set_settlement_economics_config', 27, [
      RuntimeCallArgumentSignature(name: 'economics_enabled', type: _boolCall),
      RuntimeCallArgumentSignature(name: 'slash_incorrect', type: _boolCall),
      RuntimeCallArgumentSignature(name: 'slash_fraudulent', type: _boolCall),
    ]),
    RuntimeCallSignature._approved('claim_prediction_token_settlement', 28, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('resolve_prediction_dispute_bond', 29, [
      RuntimeCallArgumentSignature(name: 'dispute_id', type: _disputeId),
      RuntimeCallArgumentSignature(name: 'accepted', type: _boolCall),
    ]),
    RuntimeCallSignature._approved('set_market_economics_config', 30, [
      RuntimeCallArgumentSignature(name: 'market_enabled', type: _boolCall),
      RuntimeCallArgumentSignature(
        name: 'allow_unstake_before_settlement',
        type: _boolCall,
      ),
    ]),
    RuntimeCallSignature._approved('stake_on_prediction_outcome_side', 31, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'side', type: _predictionOutcomeSide),
      RuntimeCallArgumentSignature(name: 'amount', type: _balance),
    ]),
    RuntimeCallSignature._approved('unstake_from_prediction_outcome_side', 32, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
      RuntimeCallArgumentSignature(name: 'side', type: _predictionOutcomeSide),
      RuntimeCallArgumentSignature(name: 'amount', type: _balance),
    ]),
    RuntimeCallSignature._approved('claim_prediction_market_payout', 33, [
      RuntimeCallArgumentSignature(name: 'token_id', type: _tokenId),
    ]),
    RuntimeCallSignature._approved('set_market_fee_config', 34, [
      RuntimeCallArgumentSignature(name: 'fees_enabled', type: _boolCall),
      RuntimeCallArgumentSignature(name: 'fee_bps', type: _u16Call),
      RuntimeCallArgumentSignature(name: 'treasury_enabled', type: _boolCall),
    ]),
    RuntimeCallSignature._approved('set_model_onboarding_config', 35, [
      RuntimeCallArgumentSignature(
        name: 'config',
        type: _modelOnboardingSettings,
      ),
    ]),
    RuntimeCallSignature._approved('approve_model', 36, [
      RuntimeCallArgumentSignature(name: 'model_id', type: _modelId),
    ]),
    RuntimeCallSignature._approved('suspend_model', 37, [
      RuntimeCallArgumentSignature(name: 'model_id', type: _modelId),
    ]),
    RuntimeCallSignature._approved('reject_model', 38, [
      RuntimeCallArgumentSignature(name: 'model_id', type: _modelId),
    ]),
    RuntimeCallSignature._approved('set_model_submitter', 39, [
      RuntimeCallArgumentSignature(name: 'model_id', type: _modelId),
      RuntimeCallArgumentSignature(name: 'submitter', type: _optionalAccountId),
    ]),
  ];

  static final List<RuntimeStorageSignature> approvedStorage =
      List.unmodifiable([
        _plain('NextModelId', RuntimeStorageModifier.defaultValue, _u64Storage),
        _plain(
          'NextPredictionId',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
        ),
        _map('Models', RuntimeStorageModifier.optional, _u64Storage, _aiModel),
        _map(
          'Predictions',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _prediction,
        ),
        _map(
          'ModelStatsById',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _modelStats,
        ),
        _map(
          'ModelGovernanceById',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _modelGovernance,
        ),
        _plain(
          'ModelOnboardingConfig',
          RuntimeStorageModifier.defaultValue,
          _modelOnboardingSettingsStorage,
        ),
        _map(
          'ModelIdsByOwner',
          RuntimeStorageModifier.defaultValue,
          _accountIdStorage,
          _boundedModelIds,
        ),
        _map(
          'PredictionIdsByModel',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
          _boundedPredictionIds,
        ),
        _map(
          'ActivePredictionCountByModel',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
          _u32Storage,
        ),
        _map(
          'AuthorizedValidators',
          RuntimeStorageModifier.defaultValue,
          _accountIdStorage,
          _boolStorage,
        ),
        _plain(
          'NextPredictionTokenId',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
        ),
        _map(
          'PredictionTokens',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _predictionToken,
        ),
        _map(
          'PredictionTokenByPrediction',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _u64Storage,
        ),
        _map(
          'PredictionTokenApprovals',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _accountIdStorage,
        ),
        _plain(
          'TokenizationConfig',
          RuntimeStorageModifier.defaultValue,
          _tokenizationSettings,
        ),
        _plain(
          'StakingConfig',
          RuntimeStorageModifier.defaultValue,
          _stakingSettings,
        ),
        _map(
          'PredictionTokenStakes',
          RuntimeStorageModifier.optional,
          _tokenAccountTuple,
          _predictionTokenStake,
          hashers: _doubleBlake2,
        ),
        _map(
          'PredictionTokenTotalStake',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
          _u128Storage,
        ),
        _map(
          'PredictionTokenStakeLocked',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
          _boolStorage,
        ),
        _plain(
          'SettlementConfig',
          RuntimeStorageModifier.defaultValue,
          _settlementSettings,
        ),
        _map(
          'PredictionTokenSettlements',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _predictionTokenSettlement,
        ),
        _plain(
          'NextDisputeId',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
        ),
        _map(
          'PredictionTokenDisputes',
          RuntimeStorageModifier.optional,
          _u64Storage,
          _predictionTokenDispute,
        ),
        _plain(
          'SettlementEconomicsConfig',
          RuntimeStorageModifier.defaultValue,
          _settlementEconomicsSettings,
        ),
        _map(
          'PredictionTokenSettlementClaims',
          RuntimeStorageModifier.optional,
          _tokenAccountTuple,
          _predictionTokenSettlementClaim,
          hashers: _doubleBlake2,
        ),
        _plain(
          'PredictionMarketEconomicsConfig',
          RuntimeStorageModifier.defaultValue,
          _predictionMarketEconomicsSettings,
        ),
        _map(
          'PredictionTokenSideStakes',
          RuntimeStorageModifier.optional,
          _tokenAccountTuple,
          _predictionSideStake,
          hashers: _doubleBlake2,
        ),
        _map(
          'PredictionTokenSideTotals',
          RuntimeStorageModifier.defaultValue,
          _tokenSideTuple,
          _u128Storage,
          hashers: _doubleBlake2,
        ),
        _map(
          'PredictionTokenSidePayoutClaims',
          RuntimeStorageModifier.optional,
          _tokenAccountTuple,
          _predictionSidePayoutClaim,
          hashers: _doubleBlake2,
        ),
        _map(
          'PredictionTokenMarketLocked',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
          _boolStorage,
        ),
        _map(
          'PredictionTokenMarketAccounting',
          RuntimeStorageModifier.defaultValue,
          _u64Storage,
          _predictionMarketAccounting,
        ),
      ]);
}

const _notProvided = Object();

const _accountIdCall = RuntimeTypeSignature(
  portableTypeId: 0,
  metadataTypeName: 'T::AccountId',
  resolvedScaleType: 'AccountId32',
);
const _balance = RuntimeTypeSignature(
  portableTypeId: 6,
  metadataTypeName: 'BalanceOf<T>',
  resolvedScaleType: 'u128',
);
const _blockNumber = RuntimeTypeSignature(
  portableTypeId: 4,
  metadataTypeName: 'BlockNumberFor<T>',
  resolvedScaleType: 'u32',
);
const _boolCall = RuntimeTypeSignature(
  portableTypeId: 8,
  metadataTypeName: 'bool',
  resolvedScaleType: 'bool',
);
const _disputeId = RuntimeTypeSignature(
  portableTypeId: 12,
  metadataTypeName: 'DisputeId',
  resolvedScaleType: 'u64',
);
const _disputeReason = RuntimeTypeSignature(
  portableTypeId: 58,
  metadataTypeName: 'DisputeReason',
  resolvedScaleType: 'DisputeReason',
);
const _modelId = RuntimeTypeSignature(
  portableTypeId: 12,
  metadataTypeName: 'ModelId',
  resolvedScaleType: 'u64',
);
const _modelOnboardingSettings = RuntimeTypeSignature(
  portableTypeId: 54,
  metadataTypeName: 'ModelOnboardingSettings',
  resolvedScaleType: 'ModelOnboardingSettings',
);
const _optionalAccountId = RuntimeTypeSignature(
  portableTypeId: 38,
  metadataTypeName: 'Option<T::AccountId>',
  resolvedScaleType: 'Option<AccountId32>',
);
const _predictionDomain = RuntimeTypeSignature(
  portableTypeId: 55,
  metadataTypeName: 'PredictionDomain',
  resolvedScaleType: 'PredictionDomain',
);
const _predictionId = RuntimeTypeSignature(
  portableTypeId: 12,
  metadataTypeName: 'PredictionId',
  resolvedScaleType: 'u64',
);
const _predictionOutcome = RuntimeTypeSignature(
  portableTypeId: 56,
  metadataTypeName: 'PredictionOutcome',
  resolvedScaleType: 'PredictionOutcome',
);
const _predictionOutcomeSide = RuntimeTypeSignature(
  portableTypeId: 59,
  metadataTypeName: 'PredictionOutcomeSide',
  resolvedScaleType: 'PredictionOutcomeSide',
);
const _settlementOutcome = RuntimeTypeSignature(
  portableTypeId: 57,
  metadataTypeName: 'SettlementOutcome',
  resolvedScaleType: 'SettlementOutcome',
);
const _tokenId = RuntimeTypeSignature(
  portableTypeId: 12,
  metadataTypeName: 'PredictionTokenId',
  resolvedScaleType: 'u64',
);
const _u8Call = RuntimeTypeSignature(
  portableTypeId: 2,
  metadataTypeName: 'u8',
  resolvedScaleType: 'u8',
);
const _u16Call = RuntimeTypeSignature(
  portableTypeId: 60,
  metadataTypeName: 'u16',
  resolvedScaleType: 'u16',
);
const _vecU8 = RuntimeTypeSignature(
  portableTypeId: 14,
  metadataTypeName: 'Vec<u8>',
  resolvedScaleType: 'Vec<u8>',
);

const _accountIdStorage = RuntimeTypeSignature(
  portableTypeId: 0,
  resolvedScaleType: 'AccountId32',
);
const _aiModel = RuntimeTypeSignature(
  portableTypeId: 265,
  resolvedScaleType: 'pallet_ai_predictions::AiModel',
);
const _boolStorage = RuntimeTypeSignature(
  portableTypeId: 8,
  resolvedScaleType: 'bool',
);
const _boundedModelIds = RuntimeTypeSignature(
  portableTypeId: 275,
  resolvedScaleType: 'BoundedVec<u64>',
);
const _boundedPredictionIds = RuntimeTypeSignature(
  portableTypeId: 277,
  resolvedScaleType: 'BoundedVec<u64>',
);
const _modelGovernance = RuntimeTypeSignature(
  portableTypeId: 273,
  resolvedScaleType: 'pallet_ai_predictions::ModelGovernance',
);
const _modelOnboardingSettingsStorage = RuntimeTypeSignature(
  portableTypeId: 54,
  resolvedScaleType: 'pallet_ai_predictions::ModelOnboardingSettings',
);
const _modelStats = RuntimeTypeSignature(
  portableTypeId: 272,
  resolvedScaleType: 'pallet_ai_predictions::ModelStats',
);
const _prediction = RuntimeTypeSignature(
  portableTypeId: 268,
  resolvedScaleType: 'pallet_ai_predictions::Prediction',
);
const _predictionMarketAccounting = RuntimeTypeSignature(
  portableTypeId: 296,
  resolvedScaleType: 'pallet_ai_predictions::PredictionMarketAccounting',
);
const _predictionMarketEconomicsSettings = RuntimeTypeSignature(
  portableTypeId: 292,
  resolvedScaleType: 'pallet_ai_predictions::PredictionMarketEconomicsSettings',
);
const _predictionSidePayoutClaim = RuntimeTypeSignature(
  portableTypeId: 295,
  resolvedScaleType: 'pallet_ai_predictions::PredictionSidePayoutClaim',
);
const _predictionSideStake = RuntimeTypeSignature(
  portableTypeId: 293,
  resolvedScaleType: 'pallet_ai_predictions::PredictionSideStake',
);
const _predictionToken = RuntimeTypeSignature(
  portableTypeId: 278,
  resolvedScaleType: 'pallet_ai_predictions::PredictionToken',
);
const _predictionTokenDispute = RuntimeTypeSignature(
  portableTypeId: 288,
  resolvedScaleType: 'pallet_ai_predictions::PredictionTokenDispute',
);
const _predictionTokenSettlement = RuntimeTypeSignature(
  portableTypeId: 284,
  resolvedScaleType: 'pallet_ai_predictions::PredictionTokenSettlement',
);
const _predictionTokenSettlementClaim = RuntimeTypeSignature(
  portableTypeId: 291,
  resolvedScaleType: 'pallet_ai_predictions::PredictionTokenSettlementClaim',
);
const _predictionTokenStake = RuntimeTypeSignature(
  portableTypeId: 282,
  resolvedScaleType: 'pallet_ai_predictions::PredictionTokenStake',
);
const _settlementEconomicsSettings = RuntimeTypeSignature(
  portableTypeId: 290,
  resolvedScaleType: 'pallet_ai_predictions::SettlementEconomicsSettings',
);
const _settlementSettings = RuntimeTypeSignature(
  portableTypeId: 283,
  resolvedScaleType: 'pallet_ai_predictions::SettlementSettings',
);
const _stakingSettings = RuntimeTypeSignature(
  portableTypeId: 280,
  resolvedScaleType: 'pallet_ai_predictions::StakingSettings',
);
const _tokenAccountTuple = RuntimeTypeSignature(
  portableTypeId: 281,
  resolvedScaleType: '(u64, AccountId32)',
);
const _tokenizationSettings = RuntimeTypeSignature(
  portableTypeId: 279,
  resolvedScaleType: 'pallet_ai_predictions::TokenizationSettings',
);
const _tokenSideTuple = RuntimeTypeSignature(
  portableTypeId: 294,
  resolvedScaleType: '(u64, PredictionOutcomeSide)',
);
const _u32Storage = RuntimeTypeSignature(
  portableTypeId: 4,
  resolvedScaleType: 'u32',
);
const _u64Storage = RuntimeTypeSignature(
  portableTypeId: 12,
  resolvedScaleType: 'u64',
);
const _u128Storage = RuntimeTypeSignature(
  portableTypeId: 6,
  resolvedScaleType: 'u128',
);

const _doubleBlake2 = ['Blake2_128Concat', 'Blake2_128Concat'];

RuntimeStorageSignature _plain(
  String name,
  RuntimeStorageModifier modifier,
  RuntimeTypeSignature valueType,
) {
  return RuntimeStorageSignature(
    name: name,
    modifier: modifier,
    shape: RuntimeStorageShape.plain,
    valueType: valueType,
  );
}

RuntimeStorageSignature _map(
  String name,
  RuntimeStorageModifier modifier,
  RuntimeTypeSignature keyType,
  RuntimeTypeSignature valueType, {
  List<String> hashers = const ['Blake2_128Concat'],
}) {
  return RuntimeStorageSignature(
    name: name,
    modifier: modifier,
    shape: RuntimeStorageShape.map,
    keyType: keyType,
    hashers: hashers,
    valueType: valueType,
  );
}

RuntimeCompatibilityIssue _issue(
  RuntimeCompatibilityIssueKind kind,
  String code,
  String message,
  String expected,
  String actual,
) {
  return RuntimeCompatibilityIssue(
    kind: kind,
    code: code,
    message: message,
    expected: expected,
    actual: actual,
  );
}

bool _argumentsMatch(
  List<RuntimeCallArgumentSignature> expected,
  List<RuntimeCallArgumentSignature> observed, {
  required bool comparePortableTypeIds,
}) {
  if (expected.length != observed.length) return false;
  for (var index = 0; index < expected.length; index++) {
    final wanted = expected[index];
    final actual = observed[index];
    if (wanted.name != actual.name ||
        !_typeMatches(
          wanted.type,
          actual.type,
          comparePortableTypeIds: comparePortableTypeIds,
        )) {
      return false;
    }
  }
  return true;
}

bool _storageMatches(
  RuntimeStorageSignature expected,
  RuntimeStorageSignature observed, {
  required bool comparePortableTypeIds,
}) {
  if (expected.modifier != observed.modifier ||
      expected.shape != observed.shape ||
      !_stringListsEqual(expected.hashers, observed.hashers) ||
      !_typeMatches(
        expected.valueType,
        observed.valueType,
        comparePortableTypeIds: comparePortableTypeIds,
      )) {
    return false;
  }
  final expectedKey = expected.keyType;
  final observedKey = observed.keyType;
  if (expectedKey == null || observedKey == null) {
    return expectedKey == null && observedKey == null;
  }
  return _typeMatches(
    expectedKey,
    observedKey,
    comparePortableTypeIds: comparePortableTypeIds,
  );
}

bool _typeMatches(
  RuntimeTypeSignature expected,
  RuntimeTypeSignature observed, {
  required bool comparePortableTypeIds,
}) {
  return (!comparePortableTypeIds ||
          expected.portableTypeId == observed.portableTypeId) &&
      expected.metadataTypeName == observed.metadataTypeName &&
      expected.resolvedScaleType == observed.resolvedScaleType;
}

bool _stringListsEqual(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

String _normalizeHash(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.startsWith('0x') ? normalized.substring(2) : normalized;
}
