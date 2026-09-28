import 'dart:convert';

/// Lifecycle states for a wallet-submitted extrinsic.
///
/// [unknownNeedsVerification] is deliberately not a retry state. It means the
/// submission may have reached the node and must be reconciled against chain
/// data before the wallet can offer another submission for the same intent.
enum TransactionLifecycleState {
  preparing,
  awaitingAuthentication,
  signing,
  submitting,
  submitted,
  inBlock,
  finalized,
  succeeded,
  failed,
  unknownNeedsVerification,
}

enum DispatchResultStatus { success, failure, unknown }

enum PostStateVerificationStatus {
  notRun,
  confirmed,
  contradicted,
  inconclusive,
}

enum ChainVerificationStatus {
  notFound,
  pending,
  succeeded,
  failed,
  inconclusive,
}

enum StartupReconciliationAction {
  discardUnsignedDraft,
  markUnknownThenVerify,
  resumeWatchingAndVerify,
  verifyDispatchAndPostState,
  verifyBeforeAnyRetry,
  noAction,
}

const _redactedValue = '[REDACTED]';

/// A submission intent with a stable, non-secret duplicate-detection key.
class TransactionIntent {
  factory TransactionIntent({
    required String pallet,
    required String call,
    required Map<String, Object?> argumentsSummary,
    required String signer,
  }) {
    final safeArguments = _safeMap(argumentsSummary);
    final canonical = _canonicalJson({
      'pallet': pallet,
      'call': call,
      'arguments': safeArguments,
      'signer': signer,
    });
    return TransactionIntent._(
      pallet: pallet,
      call: call,
      argumentsSummary: safeArguments,
      signer: signer,
      key: 'era-intent-v1:${_fnv1a64(utf8.encode(canonical))}',
    );
  }

  const TransactionIntent._({
    required this.pallet,
    required this.call,
    required this.argumentsSummary,
    required this.signer,
    required this.key,
  });

  final String pallet;
  final String call;
  final Map<String, Object?> argumentsSummary;
  final String signer;

  /// Deterministic across processes and independent of map insertion order.
  final String key;
}

class BlockReference {
  const BlockReference({required this.number, required this.hash});

  final BigInt number;
  final String hash;

  Map<String, Object?> toJson() => {'number': number.toString(), 'hash': hash};

  factory BlockReference.fromJson(Map<String, Object?> json) => BlockReference(
    number: BigInt.parse(json['number']! as String),
    hash: json['hash']! as String,
  );

  @override
  bool operator ==(Object other) =>
      other is BlockReference && other.number == number && other.hash == hash;

  @override
  int get hashCode => Object.hash(number, hash);
}

/// A decoded module error. No signed payload or authentication material is
/// retained in this model.
class DecodedModuleError {
  DecodedModuleError({
    required this.pallet,
    required this.error,
    this.palletIndex,
    List<int> errorBytes = const <int>[],
    List<String> docs = const <String>[],
  }) : errorBytes = List<int>.unmodifiable(errorBytes),
       docs = List<String>.unmodifiable(docs);

  final String pallet;
  final String error;
  final int? palletIndex;
  final List<int> errorBytes;
  final List<String> docs;

  String get qualifiedName => '$pallet.$error';

  Map<String, Object?> toJson() => {
    'pallet': pallet,
    'error': error,
    if (palletIndex != null) 'palletIndex': palletIndex,
    'errorBytes': errorBytes,
    'docs': docs,
  };

  factory DecodedModuleError.fromJson(Map<String, Object?> json) =>
      DecodedModuleError(
        pallet: json['pallet']! as String,
        error: json['error']! as String,
        palletIndex: json['palletIndex'] as int?,
        errorBytes: (json['errorBytes'] as List<Object?>? ?? const [])
            .map((value) => value as int)
            .toList(),
        docs: (json['docs'] as List<Object?>? ?? const [])
            .map((value) => value as String)
            .toList(),
      );
}

class RuntimeDispatchError {
  const RuntimeDispatchError({
    required this.kind,
    this.moduleError,
    this.safeDetails,
  });

  final String kind;
  final DecodedModuleError? moduleError;
  final String? safeDetails;

  String get displayCode => moduleError?.qualifiedName ?? kind;

  Map<String, Object?> toJson() => {
    'kind': kind,
    if (moduleError != null) 'moduleError': moduleError!.toJson(),
    if (safeDetails != null) 'safeDetails': safeDetails,
  };

  factory RuntimeDispatchError.fromJson(Map<String, Object?> json) =>
      RuntimeDispatchError(
        kind: json['kind']! as String,
        moduleError: json['moduleError'] == null
            ? null
            : DecodedModuleError.fromJson(
                (json['moduleError']! as Map).cast<String, Object?>(),
              ),
        safeDetails: json['safeDetails'] as String?,
      );
}

/// Inner dispatch result emitted by `sudo.Sudid`.
class SudoDispatchResult {
  const SudoDispatchResult.success()
    : status = DispatchResultStatus.success,
      error = null;

  const SudoDispatchResult.failure(this.error)
    : status = DispatchResultStatus.failure;

  const SudoDispatchResult.unknown()
    : status = DispatchResultStatus.unknown,
      error = null;

  final DispatchResultStatus status;
  final RuntimeDispatchError? error;

  Map<String, Object?> toJson() => {
    'status': status.name,
    if (error != null) 'error': error!.toJson(),
  };

  factory SudoDispatchResult.fromJson(Map<String, Object?> json) {
    final status = _enumByName(
      DispatchResultStatus.values,
      json['status']! as String,
    );
    final error = json['error'] == null
        ? null
        : RuntimeDispatchError.fromJson(
            (json['error']! as Map).cast<String, Object?>(),
          );
    if (status == DispatchResultStatus.failure && error == null) {
      throw const FormatException(
        'A failed sudo dispatch requires a dispatch error.',
      );
    }
    if (status != DispatchResultStatus.failure && error != null) {
      throw const FormatException(
        'Only a failed sudo dispatch may contain a dispatch error.',
      );
    }
    return switch (status) {
      DispatchResultStatus.success => const SudoDispatchResult.success(),
      DispatchResultStatus.failure => SudoDispatchResult.failure(error!),
      DispatchResultStatus.unknown => const SudoDispatchResult.unknown(),
    };
  }
}

/// Effective dispatch result, including a nested sudo result when present.
class TransactionDispatchResult {
  const TransactionDispatchResult._({
    required this.status,
    this.systemError,
    this.sudoResult,
  });

  const TransactionDispatchResult.success({SudoDispatchResult? sudoResult})
    : this._(status: DispatchResultStatus.success, sudoResult: sudoResult);

  const TransactionDispatchResult.failure({
    RuntimeDispatchError? systemError,
    SudoDispatchResult? sudoResult,
  }) : this._(
         status: DispatchResultStatus.failure,
         systemError: systemError,
         sudoResult: sudoResult,
       );

  const TransactionDispatchResult.unknown()
    : this._(status: DispatchResultStatus.unknown);

  final DispatchResultStatus status;
  final RuntimeDispatchError? systemError;
  final SudoDispatchResult? sudoResult;

  RuntimeDispatchError? get effectiveError => systemError ?? sudoResult?.error;

  Map<String, Object?> toJson() => {
    'status': status.name,
    if (systemError != null) 'systemError': systemError!.toJson(),
    if (sudoResult != null) 'sudoResult': sudoResult!.toJson(),
  };

  factory TransactionDispatchResult.fromJson(Map<String, Object?> json) {
    final status = _enumByName(
      DispatchResultStatus.values,
      json['status']! as String,
    );
    final systemError = json['systemError'] == null
        ? null
        : RuntimeDispatchError.fromJson(
            (json['systemError']! as Map).cast<String, Object?>(),
          );
    final sudoResult = json['sudoResult'] == null
        ? null
        : SudoDispatchResult.fromJson(
            (json['sudoResult']! as Map).cast<String, Object?>(),
          );
    if (status == DispatchResultStatus.success) {
      if (systemError != null ||
          (sudoResult != null &&
              sudoResult.status != DispatchResultStatus.success)) {
        throw const FormatException(
          'A successful dispatch cannot contain failure or unknown evidence.',
        );
      }
      return TransactionDispatchResult.success(sudoResult: sudoResult);
    }
    if (status == DispatchResultStatus.failure) {
      final hasSystemFailure = systemError != null;
      final hasSudoFailure = sudoResult?.status == DispatchResultStatus.failure;
      if (hasSystemFailure == hasSudoFailure) {
        throw const FormatException(
          'A failed dispatch requires exactly one system or sudo error.',
        );
      }
      return TransactionDispatchResult.failure(
        systemError: systemError,
        sudoResult: sudoResult,
      );
    }
    if (systemError != null || sudoResult != null) {
      throw const FormatException(
        'An unknown dispatch cannot contain definitive dispatch evidence.',
      );
    }
    return const TransactionDispatchResult.unknown();
  }
}

class LifecycleRelevantEvent {
  LifecycleRelevantEvent({
    required this.pallet,
    required this.event,
    Map<String, Object?> fields = const {},
  }) : fields = _safeMap(fields);

  final String pallet;
  final String event;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'pallet': pallet,
    'event': event,
    'fields': fields,
  };

  factory LifecycleRelevantEvent.fromJson(Map<String, Object?> json) =>
      LifecycleRelevantEvent(
        pallet: json['pallet']! as String,
        event: json['event']! as String,
        fields: (json['fields']! as Map).cast<String, Object?>(),
      );
}

class PostStateVerification {
  PostStateVerification({
    required this.status,
    this.checkedAt,
    Map<String, Object?> details = const {},
  }) : details = _safeMap(details);

  const PostStateVerification.notRun()
    : status = PostStateVerificationStatus.notRun,
      checkedAt = null,
      details = const {};

  final PostStateVerificationStatus status;
  final DateTime? checkedAt;
  final Map<String, Object?> details;

  Map<String, Object?> toJson() => {
    'status': status.name,
    if (checkedAt != null) 'checkedAt': checkedAt!.toUtc().toIso8601String(),
    'details': details,
  };

  factory PostStateVerification.fromJson(Map<String, Object?> json) =>
      PostStateVerification(
        status: _enumByName(
          PostStateVerificationStatus.values,
          json['status']! as String,
        ),
        checkedAt: json['checkedAt'] == null
            ? null
            : DateTime.parse(json['checkedAt']! as String).toUtc(),
        details: (json['details']! as Map).cast<String, Object?>(),
      );
}

typedef TransactionPostStateVerifier =
    Future<PostStateVerification> Function(
      TransactionLifecycleRecord finalizedRecord,
    );

/// Immutable, persistence-safe lifecycle record.
class TransactionLifecycleRecord {
  TransactionLifecycleRecord._({
    required this.id,
    required this.intentKey,
    required this.state,
    required this.pallet,
    required this.call,
    required Map<String, Object?> argumentsSummary,
    required this.signer,
    required this.createdAt,
    required this.requiresPostStateVerification,
    this.nonce,
    this.genesisHash,
    this.mortalityReferenceBlock,
    this.mortalityPeriod,
    this.txHash,
    this.submittedAt,
    this.inclusionBlock,
    this.finalityBlock,
    this.dispatchResult,
    this.decodedModuleError,
    List<LifecycleRelevantEvent> relevantEvents = const [],
    this.postStateVerification = const PostStateVerification.notRun(),
  }) : argumentsSummary = _safeMap(argumentsSummary),
       relevantEvents = List<LifecycleRelevantEvent>.unmodifiable(
         relevantEvents,
       ) {
    _validateStateFields();
  }

  factory TransactionLifecycleRecord.preparing({
    required TransactionIntent intent,
    required DateTime createdAt,
    bool requiresPostStateVerification = false,
    String? id,
  }) => TransactionLifecycleRecord._(
    id: id ?? '${intent.key}:${createdAt.toUtc().microsecondsSinceEpoch}',
    intentKey: intent.key,
    state: TransactionLifecycleState.preparing,
    pallet: intent.pallet,
    call: intent.call,
    argumentsSummary: intent.argumentsSummary,
    signer: intent.signer,
    createdAt: createdAt.toUtc(),
    requiresPostStateVerification: requiresPostStateVerification,
  );

  final String id;
  final String intentKey;
  final TransactionLifecycleState state;
  final String pallet;
  final String call;
  final Map<String, Object?> argumentsSummary;
  final String signer;
  final DateTime createdAt;
  final bool requiresPostStateVerification;
  final BigInt? nonce;
  final String? genesisHash;
  final BigInt? mortalityReferenceBlock;
  final int? mortalityPeriod;
  final String? txHash;
  final DateTime? submittedAt;
  final BlockReference? inclusionBlock;
  final BlockReference? finalityBlock;
  final TransactionDispatchResult? dispatchResult;
  final DecodedModuleError? decodedModuleError;
  final List<LifecycleRelevantEvent> relevantEvents;
  final PostStateVerification postStateVerification;

  bool get protectsAgainstDuplicate => switch (state) {
    TransactionLifecycleState.preparing ||
    TransactionLifecycleState.awaitingAuthentication ||
    TransactionLifecycleState.signing ||
    TransactionLifecycleState.submitting ||
    TransactionLifecycleState.submitted ||
    TransactionLifecycleState.inBlock ||
    TransactionLifecycleState.finalized ||
    TransactionLifecycleState.unknownNeedsVerification => true,
    TransactionLifecycleState.succeeded ||
    TransactionLifecycleState.failed => false,
  };

  /// Advances this record while enforcing the lifecycle graph and state data
  /// invariants. Existing evidence is retained unless a replacement is passed.
  TransactionLifecycleRecord transitionTo(
    TransactionLifecycleState next, {
    BigInt? nonce,
    String? genesisHash,
    BigInt? mortalityReferenceBlock,
    int? mortalityPeriod,
    String? txHash,
    DateTime? submittedAt,
    BlockReference? inclusionBlock,
    BlockReference? finalityBlock,
    TransactionDispatchResult? dispatchResult,
    DecodedModuleError? decodedModuleError,
    List<LifecycleRelevantEvent>? relevantEvents,
    PostStateVerification? postStateVerification,
  }) {
    if (!_allowedTransitions[state]!.contains(next)) {
      throw LifecycleTransitionException(from: state, to: next);
    }
    return TransactionLifecycleRecord._(
      id: id,
      intentKey: intentKey,
      state: next,
      pallet: pallet,
      call: call,
      argumentsSummary: argumentsSummary,
      signer: signer,
      createdAt: createdAt,
      requiresPostStateVerification: requiresPostStateVerification,
      nonce: nonce ?? this.nonce,
      genesisHash: genesisHash ?? this.genesisHash,
      mortalityReferenceBlock:
          mortalityReferenceBlock ?? this.mortalityReferenceBlock,
      mortalityPeriod: mortalityPeriod ?? this.mortalityPeriod,
      txHash: txHash ?? this.txHash,
      submittedAt: (submittedAt ?? this.submittedAt)?.toUtc(),
      inclusionBlock: inclusionBlock ?? this.inclusionBlock,
      finalityBlock: finalityBlock ?? this.finalityBlock,
      dispatchResult: dispatchResult ?? this.dispatchResult,
      decodedModuleError: dispatchResult != null
          ? decodedModuleError ?? dispatchResult.effectiveError?.moduleError
          : decodedModuleError ?? this.decodedModuleError,
      relevantEvents: relevantEvents ?? this.relevantEvents,
      postStateVerification:
          postStateVerification ?? this.postStateVerification,
    );
  }

  void _validateStateFields() {
    if ((mortalityReferenceBlock == null) != (mortalityPeriod == null)) {
      throw ArgumentError(
        'Mortality reference block and period must be recorded together.',
      );
    }
    if (genesisHash != null &&
        !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(genesisHash!)) {
      throw ArgumentError('Genesis hash evidence must be a 32-byte hex hash.');
    }
    if (mortalityReferenceBlock?.isNegative == true ||
        (mortalityPeriod != null &&
            (mortalityPeriod! < 4 ||
                mortalityPeriod! > 65536 ||
                (mortalityPeriod! & (mortalityPeriod! - 1)) != 0))) {
      throw ArgumentError('Invalid mortal-era evidence.');
    }
    const submittedStates = {
      TransactionLifecycleState.submitted,
      TransactionLifecycleState.inBlock,
      TransactionLifecycleState.finalized,
      TransactionLifecycleState.succeeded,
    };
    if (submittedStates.contains(state) &&
        ((txHash?.isEmpty ?? true) || submittedAt == null)) {
      throw ArgumentError(
        '${state.name} requires both a transaction hash and submission time.',
      );
    }
    const includedStates = {
      TransactionLifecycleState.inBlock,
      TransactionLifecycleState.finalized,
      TransactionLifecycleState.succeeded,
    };
    if (includedStates.contains(state) && inclusionBlock == null) {
      throw ArgumentError('${state.name} requires an inclusion block.');
    }
    const finalizedStates = {
      TransactionLifecycleState.finalized,
      TransactionLifecycleState.succeeded,
    };
    if (finalizedStates.contains(state) && finalityBlock == null) {
      throw ArgumentError('${state.name} requires a finality block.');
    }
    if (state == TransactionLifecycleState.succeeded &&
        dispatchResult?.status != DispatchResultStatus.success) {
      throw ArgumentError('succeeded requires a successful dispatch result.');
    }
    if (state == TransactionLifecycleState.succeeded &&
        requiresPostStateVerification &&
        postStateVerification.status != PostStateVerificationStatus.confirmed) {
      throw ArgumentError(
        'succeeded requires confirmed canonical post-state evidence.',
      );
    }
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': 4,
    'id': id,
    'intentKey': intentKey,
    'state': state.name,
    'pallet': pallet,
    'call': call,
    'argumentsSummary': argumentsSummary,
    'signer': signer,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'requiresPostStateVerification': requiresPostStateVerification,
    if (nonce != null) 'nonce': nonce.toString(),
    if (genesisHash != null) 'genesisHash': genesisHash,
    if (mortalityReferenceBlock != null)
      'mortalityReferenceBlock': mortalityReferenceBlock.toString(),
    if (mortalityPeriod != null) 'mortalityPeriod': mortalityPeriod,
    if (txHash != null) 'txHash': txHash,
    if (submittedAt != null)
      'submittedAt': submittedAt!.toUtc().toIso8601String(),
    if (inclusionBlock != null) 'inclusionBlock': inclusionBlock!.toJson(),
    if (finalityBlock != null) 'finalityBlock': finalityBlock!.toJson(),
    if (dispatchResult != null) 'dispatchResult': dispatchResult!.toJson(),
    if (decodedModuleError != null)
      'decodedModuleError': decodedModuleError!.toJson(),
    'relevantEvents': relevantEvents.map((event) => event.toJson()).toList(),
    'postStateVerification': postStateVerification.toJson(),
  };

  factory TransactionLifecycleRecord.fromJson(Map<String, Object?> json) {
    final schemaValue = json['schemaVersion'];
    if (schemaValue is! int || !const <int>{1, 2, 3, 4}.contains(schemaValue)) {
      throw const FormatException('Unsupported transaction record schema.');
    }
    final schemaVersion = schemaValue;
    final decodedState = _enumByName(
      TransactionLifecycleState.values,
      json['state']! as String,
    );
    final requiresPostStateVerification = schemaVersion >= 2
        ? json['requiresPostStateVerification']! as bool
        : _legacyCallRequiresPostStateVerification(
            json['pallet']! as String,
            json['call']! as String,
          );
    final postStateVerification = PostStateVerification.fromJson(
      (json['postStateVerification']! as Map).cast<String, Object?>(),
    );
    final pallet = json['pallet']! as String;
    final call = json['call']! as String;
    final argumentsSummary = (json['argumentsSummary']! as Map)
        .cast<String, Object?>();
    final signer = json['signer']! as String;
    final expectedIntentKey = TransactionIntent(
      pallet: pallet,
      call: call,
      argumentsSummary: argumentsSummary,
      signer: signer,
    ).key;
    if (json['intentKey'] != expectedIntentKey) {
      throw const FormatException(
        'Persisted transaction intent key does not match its evidence.',
      );
    }
    final state =
        schemaVersion < 3 &&
            decodedState == TransactionLifecycleState.succeeded &&
            requiresPostStateVerification &&
            postStateVerification.status !=
                PostStateVerificationStatus.confirmed
        ? TransactionLifecycleState.unknownNeedsVerification
        : decodedState;
    return TransactionLifecycleRecord._(
      id: json['id']! as String,
      intentKey: json['intentKey']! as String,
      state: state,
      pallet: pallet,
      call: call,
      argumentsSummary: argumentsSummary,
      signer: signer,
      createdAt: DateTime.parse(json['createdAt']! as String).toUtc(),
      requiresPostStateVerification: requiresPostStateVerification,
      nonce: json['nonce'] == null
          ? null
          : BigInt.parse(json['nonce']! as String),
      genesisHash: json['genesisHash'] as String?,
      mortalityReferenceBlock: json['mortalityReferenceBlock'] == null
          ? null
          : BigInt.parse(json['mortalityReferenceBlock']! as String),
      mortalityPeriod: json['mortalityPeriod'] as int?,
      txHash: json['txHash'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt']! as String).toUtc(),
      inclusionBlock: json['inclusionBlock'] == null
          ? null
          : BlockReference.fromJson(
              (json['inclusionBlock']! as Map).cast<String, Object?>(),
            ),
      finalityBlock: json['finalityBlock'] == null
          ? null
          : BlockReference.fromJson(
              (json['finalityBlock']! as Map).cast<String, Object?>(),
            ),
      dispatchResult: json['dispatchResult'] == null
          ? null
          : TransactionDispatchResult.fromJson(
              (json['dispatchResult']! as Map).cast<String, Object?>(),
            ),
      decodedModuleError: json['decodedModuleError'] == null
          ? null
          : DecodedModuleError.fromJson(
              (json['decodedModuleError']! as Map).cast<String, Object?>(),
            ),
      relevantEvents: (json['relevantEvents']! as List<Object?>)
          .map(
            (value) => LifecycleRelevantEvent.fromJson(
              (value! as Map).cast<String, Object?>(),
            ),
          )
          .toList(),
      postStateVerification: postStateVerification,
    );
  }
}

/// Resolves a finalized successful dispatch without weakening a required
/// canonical post-state check. A missing, failed, or inconclusive verifier is
/// an ambiguous outcome and remains duplicate-protected.
class TransactionFinalizationPolicy {
  const TransactionFinalizationPolicy();

  Future<TransactionLifecycleRecord> resolveSuccessfulDispatch(
    TransactionLifecycleRecord finalizedRecord, {
    TransactionPostStateVerifier? verifyPostState,
  }) async {
    if (finalizedRecord.state != TransactionLifecycleState.finalized ||
        finalizedRecord.dispatchResult?.status !=
            DispatchResultStatus.success) {
      throw StateError(
        'Post-state resolution requires a finalized successful dispatch.',
      );
    }

    PostStateVerification verification;
    if (verifyPostState == null) {
      verification = finalizedRecord.requiresPostStateVerification
          ? PostStateVerification(
              status: PostStateVerificationStatus.inconclusive,
              checkedAt: DateTime.now().toUtc(),
              details: const {
                'reason':
                    'A required canonical post-state verifier was not '
                    'available.',
              },
            )
          : const PostStateVerification.notRun();
    } else {
      try {
        verification = await verifyPostState(finalizedRecord);
      } catch (error) {
        verification = PostStateVerification(
          status: PostStateVerificationStatus.inconclusive,
          checkedAt: DateTime.now().toUtc(),
          details: {
            'reason': 'Canonical post-state verification failed safely.',
            'error': _safeErrorText(error),
          },
        );
      }
    }

    if (finalizedRecord.requiresPostStateVerification &&
        verification.status != PostStateVerificationStatus.confirmed) {
      return finalizedRecord.transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
        postStateVerification: verification,
      );
    }
    return finalizedRecord.transitionTo(
      TransactionLifecycleState.succeeded,
      postStateVerification: verification,
    );
  }
}

const Map<TransactionLifecycleState, Set<TransactionLifecycleState>>
_allowedTransitions = {
  TransactionLifecycleState.preparing: {
    TransactionLifecycleState.awaitingAuthentication,
    TransactionLifecycleState.failed,
  },
  TransactionLifecycleState.awaitingAuthentication: {
    TransactionLifecycleState.signing,
    TransactionLifecycleState.failed,
  },
  TransactionLifecycleState.signing: {
    TransactionLifecycleState.submitting,
    TransactionLifecycleState.failed,
  },
  TransactionLifecycleState.submitting: {
    TransactionLifecycleState.submitted,
    TransactionLifecycleState.failed,
    TransactionLifecycleState.unknownNeedsVerification,
  },
  TransactionLifecycleState.submitted: {
    TransactionLifecycleState.inBlock,
    TransactionLifecycleState.finalized,
    TransactionLifecycleState.failed,
    TransactionLifecycleState.unknownNeedsVerification,
  },
  TransactionLifecycleState.inBlock: {
    TransactionLifecycleState.finalized,
    TransactionLifecycleState.failed,
    TransactionLifecycleState.unknownNeedsVerification,
  },
  TransactionLifecycleState.finalized: {
    TransactionLifecycleState.succeeded,
    TransactionLifecycleState.failed,
    TransactionLifecycleState.unknownNeedsVerification,
  },
  TransactionLifecycleState.succeeded: {},
  TransactionLifecycleState.failed: {},
  TransactionLifecycleState.unknownNeedsVerification: {
    TransactionLifecycleState.submitted,
    TransactionLifecycleState.inBlock,
    TransactionLifecycleState.finalized,
    TransactionLifecycleState.succeeded,
    TransactionLifecycleState.failed,
  },
};

class LifecycleTransitionException implements Exception {
  const LifecycleTransitionException({required this.from, required this.to});

  final TransactionLifecycleState from;
  final TransactionLifecycleState to;

  @override
  String toString() =>
      'Illegal transaction lifecycle transition: ${from.name} -> ${to.name}.';
}

class DuplicateSubmissionException implements Exception {
  const DuplicateSubmissionException(this.intentKey);

  final String intentKey;

  @override
  String toString() =>
      'A transaction for this intent is already active or needs verification.';
}

class VerificationAlreadyInProgressException implements Exception {
  const VerificationAlreadyInProgressException(this.intentKey);

  final String intentKey;

  @override
  String toString() => 'Chain verification is already running for this intent.';
}

class ChainVerificationResult {
  ChainVerificationResult({
    required this.status,
    this.reconciledRecord,
    Map<String, Object?> evidence = const {},
  }) : evidence = _safeMap(evidence);

  final ChainVerificationStatus status;
  final TransactionLifecycleRecord? reconciledRecord;
  final Map<String, Object?> evidence;
}

class RetryDecision {
  const RetryDecision({
    required this.retryAllowed,
    required this.status,
    required this.guidance,
  });

  final bool retryAllowed;
  final ChainVerificationStatus status;
  final String guidance;
}

typedef UnknownTransactionVerifier =
    Future<ChainVerificationResult> Function(TransactionLifecycleRecord record);

/// Guards an intent while it is in flight or has an ambiguous outcome.
///
/// It never performs or schedules a retry. The only way to release an unknown
/// intent for retry is a caller-provided asynchronous chain verification that
/// conclusively reports that the transaction was not found or failed.
class DuplicateSubmissionGuard {
  final Map<String, TransactionLifecycleRecord> _records = {};
  final Set<String> _verificationInProgress = {};

  /// Restores the newest unresolved record for each intent after an app
  /// restart. Definitively completed records do not need duplicate protection.
  void restore(Iterable<TransactionLifecycleRecord> records) {
    final unresolvedByIntent = <String, List<TransactionLifecycleRecord>>{};
    for (final record in records) {
      if (!record.protectsAgainstDuplicate) continue;
      unresolvedByIntent.putIfAbsent(record.intentKey, () => []).add(record);
    }
    for (final entry in unresolvedByIntent.entries) {
      if (entry.value.length > 1) {
        throw StateError(
          'Multiple unresolved submissions exist for intent ${entry.key}. '
          'Every record must be reconciled before retry.',
        );
      }
      final record = entry.value.single;
      final existing = _records[record.intentKey];
      if ((existing?.protectsAgainstDuplicate ?? false) &&
          existing!.id != record.id) {
        throw StateError(
          'In-memory and durable unresolved transaction records conflict.',
        );
      }
      if (existing == null || !existing.protectsAgainstDuplicate) {
        _records[record.intentKey] = record;
      }
    }
  }

  void register(TransactionLifecycleRecord record) {
    final existing = _records[record.intentKey];
    if (existing?.protectsAgainstDuplicate ?? false) {
      throw DuplicateSubmissionException(record.intentKey);
    }
    _records[record.intentKey] = record;
  }

  void update(TransactionLifecycleRecord record) {
    final existing = _records[record.intentKey];
    if (existing != null && existing.id != record.id) {
      throw DuplicateSubmissionException(record.intentKey);
    }
    _records[record.intentKey] = record;
  }

  TransactionLifecycleRecord? tracked(String intentKey) => _records[intentKey];

  Future<RetryDecision> verifyUnknownBeforeRetry(
    String intentKey,
    UnknownTransactionVerifier verifier,
  ) async {
    final record = _records[intentKey];
    if (record == null ||
        record.state != TransactionLifecycleState.unknownNeedsVerification) {
      throw StateError(
        'Retry verification requires a tracked unknown transaction.',
      );
    }
    if (!_verificationInProgress.add(intentKey)) {
      throw VerificationAlreadyInProgressException(intentKey);
    }
    try {
      final result = await verifier(record);
      final current = _records[intentKey];
      if (!identical(current, record) ||
          current?.state !=
              TransactionLifecycleState.unknownNeedsVerification) {
        throw StateError(
          'The tracked transaction changed while verification was running.',
        );
      }
      final reconciled = result.reconciledRecord;
      if (reconciled != null) {
        if (reconciled.id != record.id ||
            reconciled.intentKey != record.intentKey) {
          throw StateError(
            'Verifier returned an unrelated transaction record.',
          );
        }
      }

      final consistent = switch (result.status) {
        ChainVerificationStatus.notFound =>
          reconciled?.state == TransactionLifecycleState.failed,
        ChainVerificationStatus.failed =>
          reconciled?.state == TransactionLifecycleState.failed &&
              reconciled?.dispatchResult?.status !=
                  DispatchResultStatus.success,
        ChainVerificationStatus.succeeded =>
          reconciled?.state == TransactionLifecycleState.succeeded,
        ChainVerificationStatus.pending =>
          reconciled == null || reconciled.protectsAgainstDuplicate,
        ChainVerificationStatus.inconclusive =>
          reconciled == null || reconciled.protectsAgainstDuplicate,
      };
      if (!consistent) {
        throw StateError(
          'Verifier status and reconciled transaction state are inconsistent.',
        );
      }
      if (reconciled != null) _records[intentKey] = reconciled;

      switch (result.status) {
        case ChainVerificationStatus.notFound:
          _records.remove(intentKey);
          return const RetryDecision(
            retryAllowed: true,
            status: ChainVerificationStatus.notFound,
            guidance:
                'No matching chain transaction was found. Review the '
                'details before creating a fresh submission.',
          );
        case ChainVerificationStatus.failed:
          _records.remove(intentKey);
          return const RetryDecision(
            retryAllowed: true,
            status: ChainVerificationStatus.failed,
            guidance:
                'The earlier transaction conclusively failed. Correct '
                'the cause before creating a fresh submission.',
          );
        case ChainVerificationStatus.pending:
          return const RetryDecision(
            retryAllowed: false,
            status: ChainVerificationStatus.pending,
            guidance:
                'The earlier transaction is still pending. Keep '
                'watching it instead of submitting a duplicate.',
          );
        case ChainVerificationStatus.succeeded:
          return const RetryDecision(
            retryAllowed: false,
            status: ChainVerificationStatus.succeeded,
            guidance: 'The earlier transaction succeeded. Do not retry it.',
          );
        case ChainVerificationStatus.inconclusive:
          return const RetryDecision(
            retryAllowed: false,
            status: ChainVerificationStatus.inconclusive,
            guidance:
                'Chain verification is inconclusive. Retry remains '
                'disabled to avoid a duplicate transaction.',
          );
      }
    } finally {
      _verificationInProgress.remove(intentKey);
    }
  }
}

/// Restart behavior for persisted records. This policy never submits anything.
class StartupReconciliationPolicy {
  const StartupReconciliationPolicy();

  StartupReconciliationAction actionFor(
    TransactionLifecycleRecord record,
  ) => switch (record.state) {
    TransactionLifecycleState.preparing ||
    TransactionLifecycleState.awaitingAuthentication ||
    TransactionLifecycleState.signing =>
      StartupReconciliationAction.discardUnsignedDraft,
    TransactionLifecycleState.submitting =>
      StartupReconciliationAction.markUnknownThenVerify,
    TransactionLifecycleState.submitted || TransactionLifecycleState.inBlock =>
      StartupReconciliationAction.resumeWatchingAndVerify,
    TransactionLifecycleState.finalized =>
      StartupReconciliationAction.verifyDispatchAndPostState,
    TransactionLifecycleState.unknownNeedsVerification =>
      StartupReconciliationAction.verifyBeforeAnyRetry,
    TransactionLifecycleState.succeeded ||
    TransactionLifecycleState.failed => StartupReconciliationAction.noAction,
  };

  /// Converts a record interrupted during the submission RPC into an explicit
  /// unknown state. It does not retry or infer that submission failed.
  TransactionLifecycleRecord prepareForStartup(
    TransactionLifecycleRecord record,
  ) {
    if (record.state == TransactionLifecycleState.submitting) {
      return record.transitionTo(
        TransactionLifecycleState.unknownNeedsVerification,
      );
    }
    return record;
  }

  List<TransactionLifecycleRecord> recordsRequiringChainVerification(
    Iterable<TransactionLifecycleRecord> records,
  ) => records
      .map(prepareForStartup)
      .where(
        (record) => {
          StartupReconciliationAction.markUnknownThenVerify,
          StartupReconciliationAction.resumeWatchingAndVerify,
          StartupReconciliationAction.verifyDispatchAndPostState,
          StartupReconciliationAction.verifyBeforeAnyRetry,
        }.contains(actionFor(record)),
      )
      .toList(growable: false);
}

/// Versioned JSON encoding suitable for an encrypted/secure storage value.
class TransactionLifecycleCodec {
  const TransactionLifecycleCodec();

  String encode(Iterable<TransactionLifecycleRecord> records) => jsonEncode({
    'schemaVersion': 4,
    'records': records.map((record) => record.toJson()).toList(),
  });

  List<TransactionLifecycleRecord> decode(String encoded) {
    final json = (jsonDecode(encoded) as Map).cast<String, Object?>();
    if (json['schemaVersion'] != 1 &&
        json['schemaVersion'] != 2 &&
        json['schemaVersion'] != 3 &&
        json['schemaVersion'] != 4) {
      throw const FormatException('Unsupported lifecycle journal schema.');
    }
    return (json['records']! as List<Object?>)
        .map(
          (value) => TransactionLifecycleRecord.fromJson(
            (value! as Map).cast<String, Object?>(),
          ),
        )
        .toList(growable: false);
  }
}

bool _legacyCallRequiresPostStateVerification(String pallet, String call) {
  if (pallet != 'AiPredictions') return true;
  return !const {
    'stake_on_prediction_outcome_side',
    'unstake_from_prediction_outcome_side',
  }.contains(call);
}

String _safeErrorText(Object error) {
  final text = error.toString().replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  return text.length <= 200 ? text : '${text.substring(0, 200)}...';
}

typedef ModuleErrorResolver =
    DecodedModuleError? Function(int palletIndex, List<int> errorBytes);

/// Decodes already-structured event fields for `system.ExtrinsicSuccess`,
/// `system.ExtrinsicFailed`, and the nested result in `sudo.Sudid`.
///
/// SCALE decoding remains the responsibility of the generated runtime binding;
/// this class deliberately accepts only decoded, safe event summaries.
class DispatchEventDecoder {
  const DispatchEventDecoder();

  TransactionDispatchResult decode(
    Iterable<LifecycleRelevantEvent> events, {
    ModuleErrorResolver? resolveModuleError,
  }) {
    LifecycleRelevantEvent? systemSuccess;
    LifecycleRelevantEvent? systemFailure;
    LifecycleRelevantEvent? sudid;
    for (final event in events) {
      final qualified = '${event.pallet}.${event.event}'.toLowerCase();
      if (qualified == 'system.extrinsicsuccess') {
        systemSuccess = event;
      } else if (qualified == 'system.extrinsicfailed') {
        systemFailure = event;
      } else if (qualified == 'sudo.sudid') {
        sudid = event;
      }
    }

    if (systemFailure != null) {
      final value = _firstPresent(systemFailure.fields, const [
        'dispatchError',
        'dispatch_error',
        'error',
      ]);
      return TransactionDispatchResult.failure(
        systemError: _decodeDispatchError(
          value,
          resolveModuleError: resolveModuleError,
        ),
      );
    }
    if (systemSuccess == null) {
      return const TransactionDispatchResult.unknown();
    }
    if (sudid == null) {
      return const TransactionDispatchResult.success();
    }

    final value = _firstPresent(sudid.fields, const [
      'sudoResult',
      'sudo_result',
      'result',
    ]);
    final sudoResult = _decodeSudoResult(
      value,
      resolveModuleError: resolveModuleError,
    );
    if (sudoResult.status == DispatchResultStatus.failure) {
      return TransactionDispatchResult.failure(sudoResult: sudoResult);
    }
    if (sudoResult.status == DispatchResultStatus.unknown) {
      return const TransactionDispatchResult.unknown();
    }
    return TransactionDispatchResult.success(sudoResult: sudoResult);
  }
}

class TransactionErrorGuidance {
  const TransactionErrorGuidance({
    required this.title,
    required this.explanation,
    required this.nextStep,
    required this.retryOnlyAfterCorrection,
  });

  final String title;
  final String explanation;
  final String nextStep;
  final bool retryOnlyAfterCorrection;

  factory TransactionErrorGuidance.forError(RuntimeDispatchError error) {
    final searchable = [
      error.kind,
      error.moduleError?.pallet,
      error.moduleError?.error,
      ...?error.moduleError?.docs,
    ].whereType<String>().join(' ').toLowerCase();
    if (searchable.contains('badorigin') ||
        searchable.contains('bad origin') ||
        searchable.contains('notauthorized')) {
      return const TransactionErrorGuidance(
        title: 'Permission denied',
        explanation: 'This account is not authorized to perform that action.',
        nextStep:
            'Use an eligible account or ask the appropriate governance '
            'or operator authority to perform the action.',
        retryOnlyAfterCorrection: true,
      );
    }
    if (searchable.contains('insufficientbalance') ||
        searchable.contains('insufficient balance') ||
        searchable.contains('payment')) {
      return const TransactionErrorGuidance(
        title: 'Insufficient balance',
        explanation: 'The account could not cover the amount, deposit, or fee.',
        nextStep:
            'Check the spendable balance and fee estimate, then reduce '
            'the amount or fund the account before retrying.',
        retryOnlyAfterCorrection: true,
      );
    }
    if (searchable.contains('stale') || searchable.contains('future')) {
      return const TransactionErrorGuidance(
        title: 'Account nonce changed',
        explanation: 'The transaction sequence no longer matches chain state.',
        nextStep:
            'Refresh the account state and build a newly signed '
            'transaction. Never resubmit the old signed payload.',
        retryOnlyAfterCorrection: true,
      );
    }
    return TransactionErrorGuidance(
      title: 'Transaction was rejected',
      explanation: error.moduleError == null
          ? 'The runtime rejected the transaction.'
          : 'The runtime reported ${error.moduleError!.qualifiedName}.',
      nextStep: error.moduleError?.docs.isNotEmpty ?? false
          ? error.moduleError!.docs.join(' ')
          : 'Review the action and current chain state before deciding whether '
                'to create a new transaction.',
      retryOnlyAfterCorrection: true,
    );
  }
}

SudoDispatchResult _decodeSudoResult(
  Object? value, {
  ModuleErrorResolver? resolveModuleError,
}) {
  if (value is Map) {
    final map = value.cast<Object?, Object?>();
    final ok = _mapValueCaseInsensitive(map, 'ok');
    if (ok.found) return const SudoDispatchResult.success();
    final err = _mapValueCaseInsensitive(map, 'err');
    if (err.found) {
      return SudoDispatchResult.failure(
        _decodeDispatchError(err.value, resolveModuleError: resolveModuleError),
      );
    }
  }
  return const SudoDispatchResult.unknown();
}

RuntimeDispatchError _decodeDispatchError(
  Object? value, {
  ModuleErrorResolver? resolveModuleError,
}) {
  if (value is String) {
    return RuntimeDispatchError(kind: value);
  }
  if (value is Map) {
    final map = value.cast<Object?, Object?>();
    final moduleEntry = _mapValueCaseInsensitive(map, 'module');
    if (moduleEntry.found && moduleEntry.value is Map) {
      final module = (moduleEntry.value! as Map).cast<Object?, Object?>();
      final indexValue = _mapValueCaseInsensitive(module, 'index').value;
      final errorValue = _mapValueCaseInsensitive(module, 'error').value;
      final index = _asInt(indexValue) ?? -1;
      final bytes = _asBytes(errorValue);
      final decoded = index >= 0
          ? resolveModuleError?.call(index, bytes)
          : null;
      return RuntimeDispatchError(
        kind: 'Module',
        moduleError:
            decoded ??
            DecodedModuleError(
              pallet: index >= 0 ? 'Pallet $index' : 'Unknown pallet',
              error: bytes.isEmpty ? 'Unknown error' : 'Error ${bytes.first}',
              palletIndex: index >= 0 ? index : null,
              errorBytes: bytes,
            ),
      );
    }
    if (map.length == 1) {
      return RuntimeDispatchError(kind: map.keys.single.toString());
    }
  }
  return const RuntimeDispatchError(
    kind: 'UnknownDispatchError',
    safeDetails: 'The runtime returned an unrecognized dispatch error.',
  );
}

Object? _firstPresent(Map<String, Object?> map, List<String> keys) {
  for (final key in keys) {
    if (map.containsKey(key)) return map[key];
  }
  return null;
}

({bool found, Object? value}) _mapValueCaseInsensitive(
  Map<Object?, Object?> map,
  String key,
) {
  for (final entry in map.entries) {
    if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
      return (found: true, value: entry.value);
    }
  }
  return (found: false, value: null);
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is BigInt) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<int> _asBytes(Object? value) {
  if (value is Iterable) {
    return value.map(_asInt).whereType<int>().toList(growable: false);
  }
  if (value is int) return [value];
  final text = value?.toString() ?? '';
  final hex = text.startsWith('0x') ? text.substring(2) : text;
  if (hex.isEmpty ||
      hex.length.isOdd ||
      !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
    return const [];
  }
  return [
    for (var offset = 0; offset < hex.length; offset += 2)
      int.parse(hex.substring(offset, offset + 2), radix: 16),
  ];
}

T _enumByName<T extends Enum>(List<T> values, String name) => values.firstWhere(
  (value) => value.name == name,
  orElse: () => throw FormatException('Unknown enum value: $name'),
);

Map<String, Object?> _safeMap(Map<String, Object?> source) =>
    Map<String, Object?>.unmodifiable({
      for (final entry in source.entries)
        entry.key: _isSensitiveKey(entry.key)
            ? _redactedValue
            : _safeValue(entry.value, contextKey: entry.key),
    });

Object? _safeValue(Object? value, {String? contextKey}) {
  if (value == null || value is bool || value is num) {
    return value;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (_containsSensitiveLabel(trimmed) ||
        _looksLikeMnemonic(trimmed) ||
        _credentialBearingUri.hasMatch(trimmed)) {
      return _redactedValue;
    }
    if (_looksLikePrivateHexMaterial(trimmed) &&
        !_isPublicContextKey(contextKey)) {
      return _redactedValue;
    }
    return value;
  }
  if (value is BigInt) return value.toString();
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is Enum) return value.name;
  if (value is Map) {
    return _safeMap({
      for (final entry in value.entries) entry.key.toString(): entry.value,
    });
  }
  if (value is Iterable) {
    return List<Object?>.unmodifiable(
      value.map((item) => _safeValue(item, contextKey: contextKey)),
    );
  }
  return value.toString();
}

bool _isSensitiveKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return const {
    'mnemonic',
    'seed',
    'seedphrase',
    'recoveryphrase',
    'privatekey',
    'secretkey',
    'password',
    'passphrase',
    'pin',
    'signedextrinsic',
    'rawextrinsic',
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
  }.contains(normalized);
}

bool _isPublicContextKey(String? key) {
  if (key == null) return false;
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  if (normalized.endsWith('hash') || normalized.endsWith('hashes')) {
    return true;
  }
  return const {
    'noncanonicalstoredevidence',
    'unavailableevidence',
    'submitter',
    'publickey',
    'publicaddress',
  }.contains(normalized);
}

bool _containsSensitiveLabel(String value) => RegExp(
  r'(^|[^a-z0-9])(mnemonic|seed([ _-]?phrase)?|recovery[ _-]?phrase|private[ _-]?key|secret[ _-]?key|pin([ _-]?code)?|passcode|password|passphrase|secure[ _-]?storage|biometric|api[ _-]?key|access[ _-]?token|auth[ _-]?token|bearer[ _-]?token|refresh[ _-]?token|authorization([ _-]?header)?|client[ _-]?secret|credentials?)([^a-z0-9]|$)',
  caseSensitive: false,
).hasMatch(value);

final RegExp _credentialBearingUri = RegExp(
  r'(^[a-z][a-z0-9+.-]*://[^/@\s]+@)|([?&](api[_-]?key|access[_-]?token|auth[_-]?token|token|client[_-]?secret)=)',
  caseSensitive: false,
);

bool _looksLikeMnemonic(String value) {
  final words = value.split(RegExp(r'\s+'));
  return const {12, 15, 18, 21, 24}.contains(words.length) &&
      words.every((word) => RegExp(r'^[a-z]{2,12}$').hasMatch(word));
}

bool _looksLikePrivateHexMaterial(String value) =>
    RegExp(r'^(0x)?[0-9a-fA-F]{64,128}$').hasMatch(value);

String _canonicalJson(Object? value) {
  if (value == null) return 'null';
  if (value is bool || value is num) return value.toString();
  if (value is BigInt) return jsonEncode(value.toString());
  if (value is String) return jsonEncode(value);
  if (value is Enum) return jsonEncode(value.name);
  if (value is Map) {
    final entries =
        value.entries
            .map((entry) => MapEntry(entry.key.toString(), entry.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return '{${entries.map((entry) => '${jsonEncode(entry.key)}:'
        '${_canonicalJson(entry.value)}').join(',')}}';
  }
  if (value is Iterable) {
    return '[${value.map(_canonicalJson).join(',')}]';
  }
  return jsonEncode(value.toString());
}

String _fnv1a64(List<int> bytes) {
  var hash = BigInt.parse('cbf29ce484222325', radix: 16);
  final prime = BigInt.parse('100000001b3', radix: 16);
  final mask = (BigInt.one << 64) - BigInt.one;
  for (final byte in bytes) {
    hash = ((hash ^ BigInt.from(byte)) * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
