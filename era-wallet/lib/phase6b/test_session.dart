/// Domain objects for a controlled ERA Phase 6B lifecycle test session.
///
/// This library deliberately does not execute transactions. A caller must
/// review, confirm, submit, finalize, and verify each live action separately,
/// then record the resulting evidence here.
library;

import 'dart:convert';
import 'dart:typed_data';

enum Phase6bTestOutcome {
  pass,
  fail,
  blocked;

  String get label => switch (this) {
    Phase6bTestOutcome.pass => 'PASS',
    Phase6bTestOutcome.fail => 'FAIL',
    Phase6bTestOutcome.blocked => 'BLOCKED',
  };
}

enum Phase6bTestStage {
  selectTestAccounts,
  verifyBalancesAndRuntime,
  onboardModel,
  approveModel,
  configureDelegation,
  createPrediction,
  createOrTokenizeMarket,
  stakeYesFromAccountA,
  stakeNoFromAccountB,
  refreshAndVerifyAccounting,
  validateOrClosePrediction,
  settleMarket,
  claimWinningPayout,
  verifyFinalBalancesAndTreasury,
  exportReport,
}

enum Phase6bStageActionKind {
  readOnly,
  signedTransaction,
  conditionalSignedTransaction,
  export,
}

class Phase6bTestStageDefinition {
  final Phase6bTestStage stage;
  final int number;
  final String title;
  final Phase6bStageActionKind actionKind;
  final List<Phase6bTestStage> prerequisites;

  const Phase6bTestStageDefinition({
    required this.stage,
    required this.number,
    required this.title,
    required this.actionKind,
    this.prerequisites = const [],
  });

  factory Phase6bTestStageDefinition.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'test stage definition',
      requiredKeys: const {
        'stage',
        'number',
        'title',
        'actionKind',
        'prerequisites',
      },
    );
    final stage = _enumByName(
      Phase6bTestStage.values,
      _requiredString(data, 'stage'),
      'stage',
    );
    final canonical = Phase6bTestLifecycle.definitionFor(stage);
    final prerequisites = _stringList(data['prerequisites'], 'prerequisites')
        .map(
          (name) => _enumByName(Phase6bTestStage.values, name, 'prerequisite'),
        )
        .toList(growable: false);
    if (_requiredInt(data, 'number') != canonical.number ||
        _requiredString(data, 'title') != canonical.title ||
        _requiredString(data, 'actionKind') != canonical.actionKind.name ||
        !_sameList(prerequisites, canonical.prerequisites)) {
      throw const FormatException(
        'Persisted stage definition does not match the controlled lifecycle.',
      );
    }
    return canonical;
  }

  Map<String, Object?> toJson() => {
    'stage': stage.name,
    'number': number,
    'title': title,
    'actionKind': actionKind.name,
    'prerequisites': prerequisites.map((item) => item.name).toList(),
  };
}

abstract final class Phase6bTestLifecycle {
  /// Batch transaction automation is intentionally forbidden for live tests.
  static const bool batchAutomationAllowed = false;

  /// One explicit confirmation can authorize at most one transaction.
  static const int maximumTransactionsPerConfirmation = 1;

  static const List<Phase6bTestStageDefinition> stages = [
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.selectTestAccounts,
      number: 1,
      title: 'Select test accounts',
      actionKind: Phase6bStageActionKind.readOnly,
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.verifyBalancesAndRuntime,
      number: 2,
      title: 'Verify balances and runtime',
      actionKind: Phase6bStageActionKind.readOnly,
      prerequisites: [Phase6bTestStage.selectTestAccounts],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.onboardModel,
      number: 3,
      title: 'Onboard or register model',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.verifyBalancesAndRuntime],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.approveModel,
      number: 4,
      title: 'Approve model if required',
      actionKind: Phase6bStageActionKind.conditionalSignedTransaction,
      prerequisites: [Phase6bTestStage.onboardModel],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.configureDelegation,
      number: 5,
      title: 'Configure delegation if required',
      actionKind: Phase6bStageActionKind.conditionalSignedTransaction,
      prerequisites: [Phase6bTestStage.approveModel],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.createPrediction,
      number: 6,
      title: 'Create prediction',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.configureDelegation],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.createOrTokenizeMarket,
      number: 7,
      title: 'Create or tokenize market',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.createPrediction],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.stakeYesFromAccountA,
      number: 8,
      title: 'Stake YES from Account A',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.createOrTokenizeMarket],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.stakeNoFromAccountB,
      number: 9,
      title: 'Stake NO from Account B',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.stakeYesFromAccountA],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.refreshAndVerifyAccounting,
      number: 10,
      title: 'Refresh and verify accounting',
      actionKind: Phase6bStageActionKind.readOnly,
      prerequisites: [Phase6bTestStage.stakeNoFromAccountB],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.validateOrClosePrediction,
      number: 11,
      title: 'Validate or close prediction',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.refreshAndVerifyAccounting],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.settleMarket,
      number: 12,
      title: 'Settle market',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.validateOrClosePrediction],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.claimWinningPayout,
      number: 13,
      title: 'Claim winning payout',
      actionKind: Phase6bStageActionKind.signedTransaction,
      prerequisites: [Phase6bTestStage.settleMarket],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.verifyFinalBalancesAndTreasury,
      number: 14,
      title: 'Verify final balances and treasury effects',
      actionKind: Phase6bStageActionKind.readOnly,
      prerequisites: [Phase6bTestStage.claimWinningPayout],
    ),
    Phase6bTestStageDefinition(
      stage: Phase6bTestStage.exportReport,
      number: 15,
      title: 'Export report',
      actionKind: Phase6bStageActionKind.export,
      prerequisites: [Phase6bTestStage.verifyFinalBalancesAndTreasury],
    ),
  ];

  static Phase6bTestStageDefinition definitionFor(Phase6bTestStage stage) {
    return stages.firstWhere((definition) => definition.stage == stage);
  }
}

class Phase6bPrerequisiteCheck {
  final String name;
  final bool passed;
  final String evidence;

  Phase6bPrerequisiteCheck({
    required String name,
    required this.passed,
    required String evidence,
  }) : name = _requireText(name, 'name'),
       evidence = _requireText(evidence, 'evidence');

  factory Phase6bPrerequisiteCheck.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'prerequisite check',
      requiredKeys: const {'name', 'passed', 'evidence'},
    );
    return Phase6bPrerequisiteCheck(
      name: _requiredString(data, 'name'),
      passed: _requiredBool(data, 'passed'),
      evidence: _requiredString(data, 'evidence'),
    );
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'passed': passed,
    'evidence': evidence,
  };
}

class Phase6bFeeEstimate {
  final BigInt baseUnits;
  final String tokenSymbol;
  final int decimals;

  Phase6bFeeEstimate({
    required this.baseUnits,
    this.tokenSymbol = 'ETKN',
    this.decimals = 18,
  }) {
    if (baseUnits.isNegative) {
      throw ArgumentError.value(baseUnits, 'baseUnits', 'Must not be negative');
    }
    if (decimals < 0 || decimals > 30) {
      throw RangeError.range(decimals, 0, 30, 'decimals');
    }
    _requireText(tokenSymbol, 'tokenSymbol');
  }

  factory Phase6bFeeEstimate.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'fee estimate',
      requiredKeys: const {'baseUnits', 'tokenSymbol', 'decimals', 'display'},
    );
    final fee = Phase6bFeeEstimate(
      baseUnits: _requiredBigInt(data, 'baseUnits'),
      tokenSymbol: _requiredString(data, 'tokenSymbol'),
      decimals: _requiredInt(data, 'decimals'),
    );
    if (_requiredString(data, 'display') != fee.display) {
      throw const FormatException('Persisted fee display is inconsistent.');
    }
    return fee;
  }

  String get decimalAmount {
    if (decimals == 0) return baseUnits.toString();
    final padded = baseUnits.toString().padLeft(decimals + 1, '0');
    final whole = padded.substring(0, padded.length - decimals);
    var fraction = padded.substring(padded.length - decimals);
    fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    return fraction.isEmpty ? whole : '$whole.$fraction';
  }

  String get display => '$decimalAmount $tokenSymbol';

  Map<String, Object?> toJson() => {
    'baseUnits': baseUnits.toString(),
    'tokenSymbol': tokenSymbol,
    'decimals': decimals,
    'display': display,
  };
}

class Phase6bActionConfirmation {
  final bool confirmed;
  final String statement;
  final String? confirmedByPublicAddress;
  final DateTime? confirmedAt;

  Phase6bActionConfirmation({
    required this.confirmed,
    required String statement,
    this.confirmedByPublicAddress,
    this.confirmedAt,
  }) : statement = _requireText(statement, 'statement') {
    if (confirmed && confirmedAt == null) {
      throw ArgumentError('A confirmed action must include confirmedAt.');
    }
    if (confirmed &&
        (confirmedByPublicAddress == null ||
            confirmedByPublicAddress!.trim().isEmpty)) {
      throw ArgumentError(
        'A confirmed action must identify the public signer address.',
      );
    }
  }

  factory Phase6bActionConfirmation.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'action confirmation',
      requiredKeys: const {
        'confirmed',
        'statement',
        'confirmedByPublicAddress',
        'confirmedAt',
      },
    );
    return Phase6bActionConfirmation(
      confirmed: _requiredBool(data, 'confirmed'),
      statement: _requiredString(data, 'statement'),
      confirmedByPublicAddress: _nullableString(
        data,
        'confirmedByPublicAddress',
      ),
      confirmedAt: _nullableDateTime(data, 'confirmedAt'),
    );
  }

  factory Phase6bActionConfirmation.notRequired({
    String statement = 'No signed transaction required.',
  }) {
    return Phase6bActionConfirmation(confirmed: false, statement: statement);
  }

  Map<String, Object?> toJson() => {
    'confirmed': confirmed,
    'statement': statement,
    'confirmedByPublicAddress': confirmedByPublicAddress,
    'confirmedAt': confirmedAt?.toUtc().toIso8601String(),
  };
}

class Phase6bTransactionReceiptRef {
  final String referenceId;
  final String transactionHash;
  final int? inclusionBlockNumber;
  final String? inclusionBlockHash;
  final int? finalizedBlockNumber;
  final String? finalizedBlockHash;
  final String dispatchResult;
  final List<String> relevantEvents;
  final bool finalized;
  final bool succeeded;

  Phase6bTransactionReceiptRef({
    required String referenceId,
    required String transactionHash,
    this.inclusionBlockNumber,
    this.inclusionBlockHash,
    this.finalizedBlockNumber,
    this.finalizedBlockHash,
    required String dispatchResult,
    this.relevantEvents = const [],
    required this.finalized,
    required this.succeeded,
  }) : referenceId = _requireText(referenceId, 'referenceId'),
       transactionHash = _requireText(transactionHash, 'transactionHash'),
       dispatchResult = _requireText(dispatchResult, 'dispatchResult') {
    _validatePublicChainHash(this.transactionHash, 'transactionHash');
    if (inclusionBlockNumber != null && inclusionBlockNumber! < 0) {
      throw ArgumentError.value(inclusionBlockNumber, 'inclusionBlockNumber');
    }
    if (finalizedBlockNumber != null && finalizedBlockNumber! < 0) {
      throw ArgumentError.value(finalizedBlockNumber, 'finalizedBlockNumber');
    }
    final hasInclusionNumber = inclusionBlockNumber != null;
    final hasInclusionHash = inclusionBlockHash != null;
    if (hasInclusionNumber != hasInclusionHash) {
      throw ArgumentError(
        'Inclusion evidence must include both block number and hash.',
      );
    }
    if (hasInclusionHash) {
      _validatePublicChainHash(inclusionBlockHash!, 'inclusionBlockHash');
    }
    final hasFinalizedNumber = finalizedBlockNumber != null;
    final hasFinalizedHash = finalizedBlockHash != null;
    if (hasFinalizedNumber != hasFinalizedHash) {
      throw ArgumentError(
        'Finality evidence must include both block number and hash.',
      );
    }
    if (hasFinalizedHash) {
      _validatePublicChainHash(finalizedBlockHash!, 'finalizedBlockHash');
    }
    if (finalized != hasFinalizedNumber) {
      throw ArgumentError(
        'The finalized flag must exactly match the finality evidence.',
      );
    }
    if (finalized && !hasInclusionNumber) {
      throw ArgumentError(
        'A finalized receipt must include canonical inclusion evidence.',
      );
    }
    if (hasFinalizedNumber && finalizedBlockNumber! < inclusionBlockNumber!) {
      throw ArgumentError(
        'The finality block cannot precede the inclusion block.',
      );
    }
    final dispatchSucceeded = _dispatchResultSucceeded(this.dispatchResult);
    if (dispatchSucceeded == null) {
      throw ArgumentError.value(
        this.dispatchResult,
        'dispatchResult',
        'Must identify a successful or failed dispatch',
      );
    }
    if (succeeded != dispatchSucceeded) {
      throw ArgumentError(
        'The succeeded flag contradicts the dispatch result.',
      );
    }
    if (succeeded && !finalized) {
      throw ArgumentError(
        'A successful receipt requires canonical finality evidence.',
      );
    }
  }

  factory Phase6bTransactionReceiptRef.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'transaction receipt reference',
      requiredKeys: const {
        'referenceId',
        'transactionHash',
        'inclusionBlockNumber',
        'inclusionBlockHash',
        'finalizedBlockNumber',
        'finalizedBlockHash',
        'dispatchResult',
        'relevantEvents',
        'finalized',
        'succeeded',
      },
    );
    return Phase6bTransactionReceiptRef(
      referenceId: _requiredString(data, 'referenceId'),
      transactionHash: _requiredString(data, 'transactionHash'),
      inclusionBlockNumber: _nullableInt(data, 'inclusionBlockNumber'),
      inclusionBlockHash: _nullableString(data, 'inclusionBlockHash'),
      finalizedBlockNumber: _nullableInt(data, 'finalizedBlockNumber'),
      finalizedBlockHash: _nullableString(data, 'finalizedBlockHash'),
      dispatchResult: _requiredString(data, 'dispatchResult'),
      relevantEvents: _stringList(data['relevantEvents'], 'relevantEvents'),
      finalized: _requiredBool(data, 'finalized'),
      succeeded: _requiredBool(data, 'succeeded'),
    );
  }

  Map<String, Object?> toJson() => {
    'referenceId': referenceId,
    'transactionHash': transactionHash,
    'inclusionBlockNumber': inclusionBlockNumber,
    'inclusionBlockHash': inclusionBlockHash,
    'finalizedBlockNumber': finalizedBlockNumber,
    'finalizedBlockHash': finalizedBlockHash,
    'dispatchResult': dispatchResult,
    'relevantEvents': List<String>.from(relevantEvents),
    'finalized': finalized,
    'succeeded': succeeded,
  };
}

/// Controls how a durable pending descriptor is handled after reconciliation.
///
/// Auxiliary settlement calls are deliberately allowed without closing the
/// settle stage. Once their journal record is terminal, their descriptor must
/// be cleared without recording the stage itself.
enum Phase6bPendingCallResolution {
  retain,
  clearWithoutAdvancing,
  advanceStage,
}

Phase6bPendingCallResolution resolvePhase6bPendingCall({
  required bool matchesStage,
  required bool isAllowedAuxiliary,
  required bool isDefinitiveTerminal,
}) {
  if (!matchesStage && !isAllowedAuxiliary) {
    return Phase6bPendingCallResolution.retain;
  }
  if (!isDefinitiveTerminal) {
    return Phase6bPendingCallResolution.retain;
  }
  return matchesStage
      ? Phase6bPendingCallResolution.advanceStage
      : Phase6bPendingCallResolution.clearWithoutAdvancing;
}

class Phase6bChainStateVerification {
  final bool verified;
  final String summary;
  final Map<String, Object?> evidence;

  Phase6bChainStateVerification({
    required this.verified,
    required String summary,
    this.evidence = const {},
  }) : summary = _requireText(summary, 'summary');

  factory Phase6bChainStateVerification.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'chain-state verification',
      requiredKeys: const {'verified', 'summary', 'evidence'},
    );
    return Phase6bChainStateVerification(
      verified: _requiredBool(data, 'verified'),
      summary: _requiredString(data, 'summary'),
      evidence: _publicJsonMap(data['evidence'], 'evidence'),
    );
  }

  factory Phase6bChainStateVerification.notPerformed({
    String summary = 'Chain-state verification was not performed.',
  }) {
    return Phase6bChainStateVerification(verified: false, summary: summary);
  }

  Map<String, Object?> toJson() => {
    'verified': verified,
    'summary': summary,
    'evidence': Map<String, Object?>.from(evidence),
  };
}

class Phase6bStageRecord {
  final Phase6bTestStage stage;
  final List<Phase6bPrerequisiteCheck> prerequisiteChecks;
  final String exactCall;
  final String? publicSigner;
  final Phase6bFeeEstimate? feeEstimate;
  final Phase6bActionConfirmation confirmation;
  final Phase6bTransactionReceiptRef? receipt;
  final Phase6bChainStateVerification chainStateVerification;
  final Phase6bTestOutcome outcome;
  final String notes;
  final List<String> warnings;
  final bool isLiveTransaction;
  final int transactionCount;
  final DateTime completedAt;

  factory Phase6bStageRecord({
    required Phase6bTestStage stage,
    required List<Phase6bPrerequisiteCheck> prerequisiteChecks,
    required String exactCall,
    String? publicSigner,
    Phase6bFeeEstimate? feeEstimate,
    required Phase6bActionConfirmation confirmation,
    Phase6bTransactionReceiptRef? receipt,
    required Phase6bChainStateVerification chainStateVerification,
    required Phase6bTestOutcome outcome,
    String notes = '',
    List<String> warnings = const [],
    bool isLiveTransaction = false,
    int? transactionCount,
    required DateTime completedAt,
  }) {
    final checkedCall = _requireText(exactCall, 'exactCall');
    final checkedTransactionCount =
        transactionCount ?? (isLiveTransaction ? 1 : 0);
    final definition = Phase6bTestLifecycle.definitionFor(stage);

    if (prerequisiteChecks.isEmpty) {
      throw ArgumentError(
        'Every stage must record at least one prerequisite check.',
      );
    }

    if (isLiveTransaction) {
      _validateSingleLiveCall(checkedCall, checkedTransactionCount);
      if (publicSigner == null || publicSigner.trim().isEmpty) {
        throw ArgumentError('A live transaction requires a public signer.');
      }
      if (feeEstimate == null) {
        throw ArgumentError('A live transaction requires a fee estimate.');
      }
      if (!confirmation.confirmed) {
        throw ArgumentError(
          'A live transaction requires its own explicit confirmation.',
        );
      }
      if (confirmation.confirmedByPublicAddress != publicSigner) {
        throw ArgumentError(
          'The confirming public address must match the selected signer.',
        );
      }
      if (receipt == null) {
        throw ArgumentError('A submitted live transaction requires a receipt.');
      }
    } else if (checkedTransactionCount != 0) {
      throw ArgumentError.value(
        checkedTransactionCount,
        'transactionCount',
        'A non-transaction stage must record zero transactions.',
      );
    }

    if ((definition.actionKind == Phase6bStageActionKind.readOnly ||
            definition.actionKind == Phase6bStageActionKind.export) &&
        isLiveTransaction) {
      throw ArgumentError(
        '${definition.title} must not submit a live transaction.',
      );
    }

    if (outcome == Phase6bTestOutcome.pass) {
      if (prerequisiteChecks.any((check) => !check.passed)) {
        throw ArgumentError('A PASS stage cannot have a failed prerequisite.');
      }
      if (!chainStateVerification.verified) {
        throw ArgumentError(
          'A PASS stage requires successful chain-state verification.',
        );
      }
      if (definition.actionKind == Phase6bStageActionKind.signedTransaction &&
          !isLiveTransaction) {
        throw ArgumentError(
          '${definition.title} requires one separately confirmed transaction.',
        );
      }
      if (isLiveTransaction && (!receipt!.finalized || !receipt.succeeded)) {
        throw ArgumentError(
          'A PASS transaction stage requires a finalized successful receipt.',
        );
      }
    }

    return Phase6bStageRecord._(
      stage: stage,
      prerequisiteChecks: List.unmodifiable(prerequisiteChecks),
      exactCall: checkedCall,
      publicSigner: publicSigner,
      feeEstimate: feeEstimate,
      confirmation: confirmation,
      receipt: receipt,
      chainStateVerification: chainStateVerification,
      outcome: outcome,
      notes: notes,
      warnings: List.unmodifiable(warnings),
      isLiveTransaction: isLiveTransaction,
      transactionCount: checkedTransactionCount,
      completedAt: completedAt,
    );
  }

  const Phase6bStageRecord._({
    required this.stage,
    required this.prerequisiteChecks,
    required this.exactCall,
    required this.publicSigner,
    required this.feeEstimate,
    required this.confirmation,
    required this.receipt,
    required this.chainStateVerification,
    required this.outcome,
    required this.notes,
    required this.warnings,
    required this.isLiveTransaction,
    required this.transactionCount,
    required this.completedAt,
  });

  factory Phase6bStageRecord.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'stage record',
      requiredKeys: const {
        'stage',
        'stageNumber',
        'stageTitle',
        'prerequisiteChecks',
        'exactCall',
        'publicSigner',
        'feeEstimate',
        'perActionConfirmation',
        'receiptReference',
        'chainStateVerification',
        'result',
        'notes',
        'warnings',
        'isLiveTransaction',
        'transactionCount',
        'completedAt',
      },
    );
    final stage = _enumByName(
      Phase6bTestStage.values,
      _requiredString(data, 'stage'),
      'stage',
    );
    final definition = Phase6bTestLifecycle.definitionFor(stage);
    if (_requiredInt(data, 'stageNumber') != definition.number ||
        _requiredString(data, 'stageTitle') != definition.title) {
      throw const FormatException(
        'Persisted stage number/title does not match the lifecycle.',
      );
    }
    final outcome = _testOutcomeFromLabel(_requiredString(data, 'result'));
    final checks = _objectList(
      data['prerequisiteChecks'],
      'prerequisiteChecks',
    ).map(Phase6bPrerequisiteCheck.fromJson).toList(growable: false);
    final feeValue = data['feeEstimate'];
    final receiptValue = data['receiptReference'];
    return Phase6bStageRecord(
      stage: stage,
      prerequisiteChecks: checks,
      exactCall: _requiredString(data, 'exactCall'),
      publicSigner: _nullableString(data, 'publicSigner'),
      feeEstimate: feeValue == null
          ? null
          : Phase6bFeeEstimate.fromJson(feeValue),
      confirmation: Phase6bActionConfirmation.fromJson(
        data['perActionConfirmation'],
      ),
      receipt: receiptValue == null
          ? null
          : Phase6bTransactionReceiptRef.fromJson(receiptValue),
      chainStateVerification: Phase6bChainStateVerification.fromJson(
        data['chainStateVerification'],
      ),
      outcome: outcome,
      notes: _requiredStringAllowEmpty(data, 'notes'),
      warnings: _stringList(data['warnings'], 'warnings'),
      isLiveTransaction: _requiredBool(data, 'isLiveTransaction'),
      transactionCount: _requiredInt(data, 'transactionCount'),
      completedAt: _requiredDateTime(data, 'completedAt'),
    );
  }

  Phase6bTestStageDefinition get definition =>
      Phase6bTestLifecycle.definitionFor(stage);

  Map<String, Object?> toJson() => {
    'stage': stage.name,
    'stageNumber': definition.number,
    'stageTitle': definition.title,
    'prerequisiteChecks': prerequisiteChecks
        .map((check) => check.toJson())
        .toList(),
    'exactCall': exactCall,
    'publicSigner': publicSigner,
    'feeEstimate': feeEstimate?.toJson(),
    'perActionConfirmation': confirmation.toJson(),
    'receiptReference': receipt?.toJson(),
    'chainStateVerification': chainStateVerification.toJson(),
    'result': outcome.label,
    'notes': notes,
    'warnings': List<String>.from(warnings),
    'isLiveTransaction': isLiveTransaction,
    'transactionCount': transactionCount,
    'completedAt': completedAt.toUtc().toIso8601String(),
  };
}

class Phase6bBatchAutomationException implements Exception {
  final String message;

  const Phase6bBatchAutomationException(this.message);

  @override
  String toString() => 'Phase6bBatchAutomationException: $message';
}

class Phase6bTestSession {
  final String sessionId;
  final DateTime startedAt;
  final List<String> participatingPublicAddresses;
  final Map<Phase6bTestStage, Phase6bStageRecord> _records = {};
  DateTime? _endedAt;

  Phase6bTestSession({
    required String sessionId,
    required this.startedAt,
    required List<String> participatingPublicAddresses,
  }) : sessionId = _requireText(sessionId, 'sessionId'),
       participatingPublicAddresses = List.unmodifiable(
         _uniqueNonEmpty(participatingPublicAddresses),
       ) {
    if (this.participatingPublicAddresses.isEmpty) {
      throw ArgumentError(
        'At least one participating public address is required.',
      );
    }
  }

  factory Phase6bTestSession.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'test session',
      requiredKeys: const {
        'testSessionId',
        'startedAt',
        'endedAt',
        'participatingPublicAddresses',
        'batchAutomationAllowed',
        'maximumTransactionsPerConfirmation',
        'stages',
        'overallResult',
      },
    );
    if (_requiredBool(data, 'batchAutomationAllowed') !=
            Phase6bTestLifecycle.batchAutomationAllowed ||
        _requiredInt(data, 'maximumTransactionsPerConfirmation') !=
            Phase6bTestLifecycle.maximumTransactionsPerConfirmation) {
      throw const FormatException(
        'Persisted session safety policy does not match this wallet build.',
      );
    }
    final session = Phase6bTestSession(
      sessionId: _requiredString(data, 'testSessionId'),
      startedAt: _requiredDateTime(data, 'startedAt'),
      participatingPublicAddresses: _stringList(
        data['participatingPublicAddresses'],
        'participatingPublicAddresses',
      ),
    );
    for (final stageValue in _objectList(data['stages'], 'stages')) {
      session.recordStage(Phase6bStageRecord.fromJson(stageValue));
    }
    final endedAt = _nullableDateTime(data, 'endedAt');
    if (endedAt != null) session.finish(endedAt);
    if (_requiredString(data, 'overallResult') !=
        session.overallOutcome.label) {
      throw const FormatException(
        'Persisted overall result does not match its stage records.',
      );
    }
    return session;
  }

  DateTime? get endedAt => _endedAt;

  bool get isFinished => _endedAt != null;

  bool get isComplete => _records.length == Phase6bTestLifecycle.stages.length;

  List<Phase6bStageRecord> get records => List.unmodifiable(
    Phase6bTestLifecycle.stages
        .map((definition) => _records[definition.stage])
        .whereType<Phase6bStageRecord>(),
  );

  Phase6bTestStage? get nextStage => isFinished || isComplete
      ? null
      : Phase6bTestLifecycle.stages[_records.length].stage;

  Phase6bTestOutcome get overallOutcome => aggregatePhase6bTestOutcome(records);

  /// Records one completed stage. It never submits or advances transactions.
  void recordStage(Phase6bStageRecord record) {
    if (isFinished) {
      throw StateError('A finished test session cannot be changed.');
    }
    final expected = nextStage;
    if (record.stage != expected) {
      throw StateError(
        'Expected stage ${expected?.name ?? 'none'}, got ${record.stage.name}.',
      );
    }
    if (record.publicSigner != null &&
        !participatingPublicAddresses.contains(record.publicSigner)) {
      throw ArgumentError(
        'The selected signer must be a participating public address.',
      );
    }

    final definition = record.definition;
    final failedLifecyclePrerequisites = definition.prerequisites.where(
      (stage) => _records[stage]?.outcome != Phase6bTestOutcome.pass,
    );
    if (failedLifecyclePrerequisites.isNotEmpty &&
        record.outcome != Phase6bTestOutcome.blocked) {
      throw StateError(
        'A stage with unmet lifecycle prerequisites must be BLOCKED.',
      );
    }

    _records[record.stage] = record;
  }

  void finish(DateTime endedAt) {
    if (isFinished) {
      throw StateError('The test session is already finished.');
    }
    if (endedAt.isBefore(startedAt)) {
      throw ArgumentError.value(
        endedAt,
        'endedAt',
        'Must not be before startedAt',
      );
    }
    if (!isComplete) {
      throw StateError(
        'A test session can finish only after all lifecycle stages are '
        'recorded.',
      );
    }
    _endedAt = endedAt;
  }

  Map<String, Object?> toJson() => {
    'testSessionId': sessionId,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'endedAt': endedAt?.toUtc().toIso8601String(),
    'participatingPublicAddresses': List<String>.from(
      participatingPublicAddresses,
    ),
    'batchAutomationAllowed': Phase6bTestLifecycle.batchAutomationAllowed,
    'maximumTransactionsPerConfirmation':
        Phase6bTestLifecycle.maximumTransactionsPerConfirmation,
    'stages': records.map((record) => record.toJson()).toList(),
    'overallResult': overallOutcome.label,
  };
}

/// Public, resumable evidence for a market observed from canonical storage.
///
/// This mirrors only public chain fields. It deliberately has no wallet,
/// authentication, or signing-material fields.
class Phase6bPersistedMarketEvidence {
  final BigInt tokenId;
  final BigInt predictionId;
  final String owner;
  final String metadataReference;
  final int createdAt;
  final bool transferable;
  final bool frozen;
  final bool burned;
  final bool locked;
  final BigInt yesTotal;
  final BigInt noTotal;
  final String settlementStatus;
  final String? proposedOutcome;
  final String? finalOutcome;
  final int? disputeUntil;
  final BigInt totalStakeAtFinalization;
  final BigInt feesCollected;
  final BigInt remaindersCollected;
  final BigInt totalPaid;
  final BigInt totalRefunded;
  final BigInt totalSlashed;
  final String provenance;

  const Phase6bPersistedMarketEvidence({
    required this.tokenId,
    required this.predictionId,
    required this.owner,
    required this.metadataReference,
    required this.createdAt,
    required this.transferable,
    required this.frozen,
    required this.burned,
    required this.locked,
    required this.yesTotal,
    required this.noTotal,
    required this.settlementStatus,
    required this.proposedOutcome,
    required this.finalOutcome,
    required this.disputeUntil,
    required this.totalStakeAtFinalization,
    required this.feesCollected,
    required this.remaindersCollected,
    required this.totalPaid,
    required this.totalRefunded,
    required this.totalSlashed,
    required this.provenance,
  });

  factory Phase6bPersistedMarketEvidence.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'market evidence',
      requiredKeys: const {
        'tokenId',
        'predictionId',
        'owner',
        'metadataReference',
        'createdAt',
        'transferable',
        'frozen',
        'burned',
        'locked',
        'yesTotal',
        'noTotal',
        'settlementStatus',
        'proposedOutcome',
        'finalOutcome',
        'disputeUntil',
        'totalStakeAtFinalization',
        'feesCollected',
        'remaindersCollected',
        'totalPaid',
        'totalRefunded',
        'totalSlashed',
        'provenance',
      },
    );
    final provenance = _requiredString(data, 'provenance');
    if (provenance != 'canonicalStorage') {
      throw const FormatException(
        'Only canonical-storage market evidence can be resumed.',
      );
    }
    return Phase6bPersistedMarketEvidence(
      tokenId: _requiredBigInt(data, 'tokenId'),
      predictionId: _requiredBigInt(data, 'predictionId'),
      owner: _requiredString(data, 'owner'),
      metadataReference: _requiredString(data, 'metadataReference'),
      createdAt: _requiredNonNegativeInt(data, 'createdAt'),
      transferable: _requiredBool(data, 'transferable'),
      frozen: _requiredBool(data, 'frozen'),
      burned: _requiredBool(data, 'burned'),
      locked: _requiredBool(data, 'locked'),
      yesTotal: _requiredBigInt(data, 'yesTotal'),
      noTotal: _requiredBigInt(data, 'noTotal'),
      settlementStatus: _requiredString(data, 'settlementStatus'),
      proposedOutcome: _nullableString(data, 'proposedOutcome'),
      finalOutcome: _nullableString(data, 'finalOutcome'),
      disputeUntil: _nullableNonNegativeInt(data, 'disputeUntil'),
      totalStakeAtFinalization: _requiredBigInt(
        data,
        'totalStakeAtFinalization',
      ),
      feesCollected: _requiredBigInt(data, 'feesCollected'),
      remaindersCollected: _requiredBigInt(data, 'remaindersCollected'),
      totalPaid: _requiredBigInt(data, 'totalPaid'),
      totalRefunded: _requiredBigInt(data, 'totalRefunded'),
      totalSlashed: _requiredBigInt(data, 'totalSlashed'),
      provenance: provenance,
    );
  }

  Map<String, Object?> toJson() => {
    'tokenId': tokenId.toString(),
    'predictionId': predictionId.toString(),
    'owner': owner,
    'metadataReference': metadataReference,
    'createdAt': createdAt,
    'transferable': transferable,
    'frozen': frozen,
    'burned': burned,
    'locked': locked,
    'yesTotal': yesTotal.toString(),
    'noTotal': noTotal.toString(),
    'settlementStatus': settlementStatus,
    'proposedOutcome': proposedOutcome,
    'finalOutcome': finalOutcome,
    'disputeUntil': disputeUntil,
    'totalStakeAtFinalization': totalStakeAtFinalization.toString(),
    'feesCollected': feesCollected.toString(),
    'remaindersCollected': remaindersCollected.toString(),
    'totalPaid': totalPaid.toString(),
    'totalRefunded': totalRefunded.toString(),
    'totalSlashed': totalSlashed.toString(),
    'provenance': provenance,
  };
}

/// Public, resumable evidence for one canonical market position.
class Phase6bPersistedPositionEvidence {
  final BigInt tokenId;
  final BigInt predictionId;
  final String account;
  final String side;
  final BigInt amount;
  final int stakedAt;
  final int? updatedAt;
  final bool claimed;
  final BigInt stakeReturned;
  final BigInt rewardPaid;
  final BigInt slashed;
  final String provenance;

  const Phase6bPersistedPositionEvidence({
    required this.tokenId,
    required this.predictionId,
    required this.account,
    required this.side,
    required this.amount,
    required this.stakedAt,
    required this.updatedAt,
    required this.claimed,
    required this.stakeReturned,
    required this.rewardPaid,
    required this.slashed,
    required this.provenance,
  });

  factory Phase6bPersistedPositionEvidence.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'position evidence',
      requiredKeys: const {
        'tokenId',
        'predictionId',
        'account',
        'side',
        'amount',
        'stakedAt',
        'updatedAt',
        'claimed',
        'stakeReturned',
        'rewardPaid',
        'slashed',
        'provenance',
      },
    );
    final side = _requiredString(data, 'side');
    if (side != 'Yes' && side != 'No') {
      throw const FormatException('Persisted position side is invalid.');
    }
    final provenance = _requiredString(data, 'provenance');
    if (provenance != 'canonicalStorage') {
      throw const FormatException(
        'Only canonical-storage position evidence can be resumed.',
      );
    }
    return Phase6bPersistedPositionEvidence(
      tokenId: _requiredBigInt(data, 'tokenId'),
      predictionId: _requiredBigInt(data, 'predictionId'),
      account: _requiredString(data, 'account'),
      side: side,
      amount: _requiredBigInt(data, 'amount'),
      stakedAt: _requiredNonNegativeInt(data, 'stakedAt'),
      updatedAt: _nullableNonNegativeInt(data, 'updatedAt'),
      claimed: _requiredBool(data, 'claimed'),
      stakeReturned: _requiredBigInt(data, 'stakeReturned'),
      rewardPaid: _requiredBigInt(data, 'rewardPaid'),
      slashed: _requiredBigInt(data, 'slashed'),
      provenance: provenance,
    );
  }

  Map<String, Object?> toJson() => {
    'tokenId': tokenId.toString(),
    'predictionId': predictionId.toString(),
    'account': account,
    'side': side,
    'amount': amount.toString(),
    'stakedAt': stakedAt,
    'updatedAt': updatedAt,
    'claimed': claimed,
    'stakeReturned': stakeReturned.toString(),
    'rewardPaid': rewardPaid.toString(),
    'slashed': slashed.toString(),
    'provenance': provenance,
  };
}

class Phase6bPersistedMarketTotals {
  final BigInt yesBeforeBaseUnits;
  final BigInt yesAfterBaseUnits;
  final BigInt noBeforeBaseUnits;
  final BigInt noAfterBaseUnits;
  final String tokenSymbol;

  const Phase6bPersistedMarketTotals({
    required this.yesBeforeBaseUnits,
    required this.yesAfterBaseUnits,
    required this.noBeforeBaseUnits,
    required this.noAfterBaseUnits,
    this.tokenSymbol = 'ETKN',
  });

  factory Phase6bPersistedMarketTotals.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'market totals',
      requiredKeys: const {
        'tokenSymbol',
        'yesBeforeBaseUnits',
        'yesAfterBaseUnits',
        'noBeforeBaseUnits',
        'noAfterBaseUnits',
      },
    );
    final symbol = _requiredString(data, 'tokenSymbol');
    if (symbol != 'ETKN') {
      throw const FormatException('Persisted market token symbol is invalid.');
    }
    return Phase6bPersistedMarketTotals(
      yesBeforeBaseUnits: _requiredBigInt(data, 'yesBeforeBaseUnits'),
      yesAfterBaseUnits: _requiredBigInt(data, 'yesAfterBaseUnits'),
      noBeforeBaseUnits: _requiredBigInt(data, 'noBeforeBaseUnits'),
      noAfterBaseUnits: _requiredBigInt(data, 'noAfterBaseUnits'),
      tokenSymbol: symbol,
    );
  }

  Map<String, Object?> toJson() => {
    'tokenSymbol': tokenSymbol,
    'yesBeforeBaseUnits': yesBeforeBaseUnits.toString(),
    'yesAfterBaseUnits': yesAfterBaseUnits.toString(),
    'noBeforeBaseUnits': noBeforeBaseUnits.toString(),
    'noAfterBaseUnits': noAfterBaseUnits.toString(),
  };
}

/// Minimal public evidence needed to finish reconciling an uncertain call.
/// It contains no encoded call bytes and no signing/authentication material.
class Phase6bPendingCallEvidence {
  final String recordId;
  final String callName;
  final String callPath;
  final Map<String, Object?> arguments;
  final BigInt? feeBaseUnits;
  final String? typedConfirmation;

  Phase6bPendingCallEvidence({
    required String recordId,
    required String callName,
    required String callPath,
    required Map<String, Object?> arguments,
    required this.feeBaseUnits,
    this.typedConfirmation,
  }) : recordId = _requireText(recordId, 'recordId'),
       callName = _requireText(callName, 'callName'),
       callPath = _requireText(callPath, 'callPath'),
       arguments = Map.unmodifiable(_normalizePublicJsonMap(arguments)) {
    _validateSingleLiveCall(this.callPath, 1);
    if (!this.callPath.endsWith('.${this.callName}') &&
        !this.callPath.endsWith('::${this.callName}')) {
      throw ArgumentError('callPath must end with the exact callName.');
    }
    if (feeBaseUnits?.isNegative == true) {
      throw ArgumentError.value(
        feeBaseUnits,
        'feeBaseUnits',
        'Must not be negative',
      );
    }
    if (typedConfirmation != null && typedConfirmation!.trim().isEmpty) {
      throw ArgumentError.value(
        typedConfirmation,
        'typedConfirmation',
        'Must be null or non-empty',
      );
    }
  }

  factory Phase6bPendingCallEvidence.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'pending call evidence',
      requiredKeys: const {
        'recordId',
        'callName',
        'callPath',
        'arguments',
        'feeBaseUnits',
        'typedConfirmation',
      },
    );
    return Phase6bPendingCallEvidence(
      recordId: _requiredString(data, 'recordId'),
      callName: _requiredString(data, 'callName'),
      callPath: _requiredString(data, 'callPath'),
      arguments: _publicJsonMap(data['arguments'], 'arguments'),
      feeBaseUnits: data['feeBaseUnits'] == null
          ? null
          : _requiredBigInt(data, 'feeBaseUnits'),
      typedConfirmation: _nullableString(data, 'typedConfirmation'),
    );
  }

  Map<String, Object?> toJson() => {
    'recordId': recordId,
    'callName': callName,
    'callPath': callPath,
    'arguments': Map<String, Object?>.from(arguments),
    'feeBaseUnits': feeBaseUnits?.toString(),
    'typedConfirmation': typedConfirmation,
  };
}

/// Immutable, already-redacted report data retained after stage 15.
///
/// The wallet reconstructs the report object from this validated source data,
/// so completed reports can be exported again without contacting the chain.
class Phase6bCompletedReportSnapshot {
  static const Set<String> _keys = {
    'walletAppVersion',
    'platform',
    'endpoint',
    'genesisHash',
    'runtimeSpecName',
    'runtimeSpecVersion',
    'transactionVersion',
    'metadataVersion',
    'metadataFingerprint',
    'runtimeWasmHash',
    'aiStorageVersion',
    'aiPalletIndex',
    'testSessionId',
    'startTimestamp',
    'endTimestamp',
    'participatingPublicAddresses',
    'modelId',
    'predictionId',
    'marketId',
    'callNames',
    'transactionHashes',
    'inclusionBlocks',
    'finalityBlocks',
    'dispatchResults',
    'relevantEvents',
    'balancesBeforeAfter',
    'yesNoTotalsBeforeAfter',
    'treasuryAndFeeObservations',
    'settlementResult',
    'claimResult',
    'postStateVerification',
    'warnings',
    'overallResult',
    'batchAutomationAllowed',
    'stages',
    'additionalEvidence',
  };

  final Map<String, Object?> data;

  Phase6bCompletedReportSnapshot.fromJson(Object? value)
    : data = Map.unmodifiable(
        _validateCompletedReport(
          _copyPublicJsonValue(value, 'completedReport'),
        ),
      );

  Map<String, Object?> toJson() =>
      _copyPublicJsonValue(data, 'completedReport') as Map<String, Object?>;

  static Map<String, Object?> _validateCompletedReport(Object? value) {
    final data = _strictMap(
      value,
      'completed report snapshot',
      requiredKeys: _keys,
    );
    for (final key in const {
      'walletAppVersion',
      'platform',
      'endpoint',
      'genesisHash',
      'runtimeSpecName',
      'metadataFingerprint',
      'testSessionId',
      'settlementResult',
      'claimResult',
      'postStateVerification',
      'overallResult',
    }) {
      _requiredString(data, key);
    }
    _requiredNonNegativeInt(data, 'runtimeSpecVersion');
    for (final key in const {
      'transactionVersion',
      'metadataVersion',
      'aiStorageVersion',
      'aiPalletIndex',
    }) {
      _nullableNonNegativeInt(data, key);
    }
    _nullableString(data, 'runtimeWasmHash');
    for (final key in const {'modelId', 'predictionId', 'marketId'}) {
      _nullableDecimalId(data, key);
    }
    _requiredDateTime(data, 'startTimestamp');
    if (_nullableDateTime(data, 'endTimestamp') == null) {
      throw const FormatException(
        'A completed report snapshot requires an end timestamp.',
      );
    }
    _stringList(
      data['participatingPublicAddresses'],
      'participatingPublicAddresses',
    );
    _stringList(data['callNames'], 'callNames');
    _stringList(data['transactionHashes'], 'transactionHashes');
    _stringList(data['warnings'], 'warnings');
    for (final key in const {
      'inclusionBlocks',
      'finalityBlocks',
      'dispatchResults',
      'relevantEvents',
    }) {
      for (final entry in _objectList(data[key], key)) {
        _publicJsonMap(entry, key);
      }
    }
    for (final entry in _objectList(
      data['balancesBeforeAfter'],
      'balancesBeforeAfter',
    )) {
      final balance = _strictMap(
        entry,
        'report balance observation',
        requiredKeys: const {
          'publicAddress',
          'tokenSymbol',
          'beforeBaseUnits',
          'afterBaseUnits',
          'deltaBaseUnits',
        },
      );
      _requiredString(balance, 'publicAddress');
      _requiredString(balance, 'tokenSymbol');
      final before = _requiredSignedBigInt(balance, 'beforeBaseUnits');
      final after = _requiredSignedBigInt(balance, 'afterBaseUnits');
      if (_requiredSignedBigInt(balance, 'deltaBaseUnits') != after - before) {
        throw const FormatException('Persisted balance delta is inconsistent.');
      }
    }
    final totals = data['yesNoTotalsBeforeAfter'];
    if (totals != null) Phase6bPersistedMarketTotals.fromJson(totals);
    for (final entry in _objectList(
      data['treasuryAndFeeObservations'],
      'treasuryAndFeeObservations',
    )) {
      final observation = _strictMap(
        entry,
        'treasury/fee observation',
        requiredKeys: const {'label', 'before', 'after', 'detail'},
      );
      for (final key in const {'label', 'before', 'after', 'detail'}) {
        _requiredString(observation, key);
      }
    }
    final stages = _objectList(
      data['stages'],
      'stages',
    ).map(Phase6bStageRecord.fromJson).toList(growable: false);
    if (_requiredString(data, 'overallResult') !=
        aggregatePhase6bTestOutcome(stages).label) {
      throw const FormatException(
        'Completed report overall result is inconsistent.',
      );
    }
    if (_requiredBool(data, 'batchAutomationAllowed') !=
        Phase6bTestLifecycle.batchAutomationAllowed) {
      throw const FormatException(
        'Completed report batch policy is inconsistent.',
      );
    }
    _publicJsonMap(data['additionalEvidence'], 'additionalEvidence');
    _validatePublicJsonValue(data, 'completedReport');
    return data;
  }
}

/// Versioned secure-storage payload for resuming a controlled test session.
///
/// The codec is intentionally strict: unknown fields, inconsistent derived
/// values, missing lifecycle evidence, and sensitive key names all fail
/// closed instead of being partially restored.
class Phase6bTestSessionCheckpoint {
  static const int currentSchemaVersion = 1;
  static const int maximumEncodedBytes = 1024 * 1024;

  final DateTime savedAt;
  final Phase6bTestSession session;
  final Map<String, BigInt> startingBalances;
  final Map<String, BigInt> latestBalances;
  final String? modelId;
  final String? predictionId;
  final String? marketId;
  final Phase6bPersistedMarketTotals? marketTotals;
  final Phase6bPersistedMarketEvidence? baselineMarket;
  final Phase6bPersistedMarketEvidence? latestMarket;
  final Phase6bPersistedPositionEvidence? claimPosition;
  final List<Phase6bPendingCallEvidence> pendingCalls;
  final Phase6bCompletedReportSnapshot? completedReport;

  Phase6bTestSessionCheckpoint({
    required this.savedAt,
    required this.session,
    required Map<String, BigInt> startingBalances,
    required Map<String, BigInt> latestBalances,
    this.modelId,
    this.predictionId,
    this.marketId,
    this.marketTotals,
    this.baselineMarket,
    this.latestMarket,
    this.claimPosition,
    List<Phase6bPendingCallEvidence> pendingCalls = const [],
    this.completedReport,
  }) : startingBalances = Map.unmodifiable(startingBalances),
       latestBalances = Map.unmodifiable(latestBalances),
       pendingCalls = List.unmodifiable(pendingCalls) {
    _validate();
  }

  factory Phase6bTestSessionCheckpoint.decode(String encoded) {
    if (encoded.trim().isEmpty) {
      throw const FormatException('The session checkpoint is empty.');
    }
    if (utf8.encode(encoded).length > maximumEncodedBytes) {
      throw const FormatException('The session checkpoint is too large.');
    }
    Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException catch (error) {
      throw FormatException('Invalid session checkpoint JSON: $error');
    }
    return Phase6bTestSessionCheckpoint.fromJson(decoded);
  }

  factory Phase6bTestSessionCheckpoint.fromJson(Object? value) {
    final data = _strictMap(
      value,
      'session checkpoint',
      requiredKeys: const {
        'schemaVersion',
        'publicDataOnly',
        'savedAt',
        'session',
        'balances',
        'identifiers',
        'marketEvidence',
        'pendingCalls',
        'completedReport',
      },
    );
    if (_requiredInt(data, 'schemaVersion') != currentSchemaVersion) {
      throw const FormatException('Unsupported session checkpoint schema.');
    }
    if (!_requiredBool(data, 'publicDataOnly')) {
      throw const FormatException(
        'A session checkpoint must be marked public-data-only.',
      );
    }
    final balances = _strictMap(
      data['balances'],
      'checkpoint balances',
      requiredKeys: const {'starting', 'latest'},
    );
    final identifiers = _strictMap(
      data['identifiers'],
      'checkpoint identifiers',
      requiredKeys: const {'modelId', 'predictionId', 'marketId'},
    );
    final market = _strictMap(
      data['marketEvidence'],
      'checkpoint market evidence',
      requiredKeys: const {
        'totals',
        'baselineMarket',
        'latestMarket',
        'claimPosition',
      },
    );
    final totalsValue = market['totals'];
    final baselineValue = market['baselineMarket'];
    final latestValue = market['latestMarket'];
    final positionValue = market['claimPosition'];
    return Phase6bTestSessionCheckpoint(
      savedAt: _requiredDateTime(data, 'savedAt'),
      session: Phase6bTestSession.fromJson(data['session']),
      startingBalances: _bigIntMap(balances['starting'], 'starting balances'),
      latestBalances: _bigIntMap(balances['latest'], 'latest balances'),
      modelId: _nullableDecimalId(identifiers, 'modelId'),
      predictionId: _nullableDecimalId(identifiers, 'predictionId'),
      marketId: _nullableDecimalId(identifiers, 'marketId'),
      marketTotals: totalsValue == null
          ? null
          : Phase6bPersistedMarketTotals.fromJson(totalsValue),
      baselineMarket: baselineValue == null
          ? null
          : Phase6bPersistedMarketEvidence.fromJson(baselineValue),
      latestMarket: latestValue == null
          ? null
          : Phase6bPersistedMarketEvidence.fromJson(latestValue),
      claimPosition: positionValue == null
          ? null
          : Phase6bPersistedPositionEvidence.fromJson(positionValue),
      pendingCalls: _objectList(
        data['pendingCalls'],
        'pendingCalls',
      ).map(Phase6bPendingCallEvidence.fromJson).toList(growable: false),
      completedReport: data['completedReport'] == null
          ? null
          : Phase6bCompletedReportSnapshot.fromJson(data['completedReport']),
    );
  }

  String encode() {
    _validate();
    final data = toJson();
    _validatePublicJsonValue(data, r'$');
    final encoded = jsonEncode(data);
    if (utf8.encode(encoded).length > maximumEncodedBytes) {
      throw const FormatException('The session checkpoint is too large.');
    }
    return encoded;
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': currentSchemaVersion,
    'publicDataOnly': true,
    'savedAt': savedAt.toUtc().toIso8601String(),
    'session': session.toJson(),
    'balances': {
      'starting': startingBalances.map(
        (address, value) => MapEntry(address, value.toString()),
      ),
      'latest': latestBalances.map(
        (address, value) => MapEntry(address, value.toString()),
      ),
    },
    'identifiers': {
      'modelId': modelId,
      'predictionId': predictionId,
      'marketId': marketId,
    },
    'marketEvidence': {
      'totals': marketTotals?.toJson(),
      'baselineMarket': baselineMarket?.toJson(),
      'latestMarket': latestMarket?.toJson(),
      'claimPosition': claimPosition?.toJson(),
    },
    'pendingCalls': pendingCalls.map((item) => item.toJson()).toList(),
    'completedReport': completedReport?.toJson(),
  };

  void _validate() {
    if (savedAt.isBefore(session.startedAt)) {
      throw ArgumentError.value(
        savedAt,
        'savedAt',
        'Must not be before the session start',
      );
    }
    if (session.endedAt != null && savedAt.isBefore(session.endedAt!)) {
      throw ArgumentError.value(
        savedAt,
        'savedAt',
        'Must not be before the completed session end',
      );
    }
    final participants = session.participatingPublicAddresses.toSet();
    if (!_sameSet(startingBalances.keys.toSet(), participants) ||
        !_sameSet(latestBalances.keys.toSet(), participants)) {
      throw const FormatException(
        'Checkpoint balances must contain exactly every participant.',
      );
    }
    if (startingBalances.values.any((value) => value.isNegative) ||
        latestBalances.values.any((value) => value.isNegative)) {
      throw const FormatException('Checkpoint balances cannot be negative.');
    }
    final checkedModelId = _validateOptionalDecimalId(modelId, 'modelId');
    final checkedPredictionId = _validateOptionalDecimalId(
      predictionId,
      'predictionId',
    );
    final checkedMarketId = _validateOptionalDecimalId(marketId, 'marketId');
    final passedStages = {
      for (final record in session.records)
        if (record.outcome == Phase6bTestOutcome.pass) record.stage,
    };
    if (passedStages.contains(Phase6bTestStage.onboardModel) &&
        checkedModelId == null) {
      throw const FormatException(
        'A passed onboarding stage requires a persisted model ID.',
      );
    }
    if (passedStages.contains(Phase6bTestStage.createPrediction) &&
        checkedPredictionId == null) {
      throw const FormatException(
        'A passed prediction stage requires a persisted prediction ID.',
      );
    }
    if (passedStages.contains(Phase6bTestStage.createOrTokenizeMarket) &&
        checkedMarketId == null) {
      throw const FormatException(
        'A passed market stage requires a persisted market ID.',
      );
    }
    if (passedStages.contains(Phase6bTestStage.stakeYesFromAccountA) &&
        (marketTotals == null ||
            baselineMarket == null ||
            latestMarket == null)) {
      throw const FormatException(
        'A passed staking stage requires persisted market baselines.',
      );
    }
    if (passedStages.contains(
          Phase6bTestStage.verifyFinalBalancesAndTreasury,
        ) &&
        (latestMarket == null || claimPosition == null)) {
      throw const FormatException(
        'Final verification requires persisted market and claim evidence.',
      );
    }
    for (final market in [baselineMarket, latestMarket]) {
      if (market == null) continue;
      if (checkedMarketId != null && market.tokenId != checkedMarketId) {
        throw const FormatException(
          'Persisted market evidence does not match the session market ID.',
        );
      }
      if (checkedPredictionId != null &&
          market.predictionId != checkedPredictionId) {
        throw const FormatException(
          'Persisted market evidence does not match the prediction ID.',
        );
      }
    }
    if (baselineMarket != null &&
        latestMarket != null &&
        (baselineMarket!.tokenId != latestMarket!.tokenId ||
            baselineMarket!.predictionId != latestMarket!.predictionId)) {
      throw const FormatException(
        'Baseline and latest market evidence identify different markets.',
      );
    }
    final position = claimPosition;
    if (position != null) {
      if (!participants.contains(position.account)) {
        throw const FormatException(
          'Claim evidence must belong to a participating public address.',
        );
      }
      if (checkedMarketId != null && position.tokenId != checkedMarketId) {
        throw const FormatException(
          'Claim evidence does not match the session market ID.',
        );
      }
      if (checkedPredictionId != null &&
          position.predictionId != checkedPredictionId) {
        throw const FormatException(
          'Claim evidence does not match the session prediction ID.',
        );
      }
    }
    final pendingIds = pendingCalls.map((item) => item.recordId).toSet();
    if (pendingIds.length != pendingCalls.length) {
      throw const FormatException('Pending transaction IDs must be unique.');
    }
    if (session.isFinished && pendingCalls.isNotEmpty) {
      throw const FormatException(
        'A finished session cannot retain pending transaction evidence.',
      );
    }
    if (session.isFinished && !session.isComplete) {
      throw const FormatException(
        'A finished session must contain every lifecycle stage.',
      );
    }
    if (session.isFinished != (completedReport != null)) {
      throw const FormatException(
        'Only a finished session may contain its immutable completed report.',
      );
    }
    final report = completedReport?.data;
    if (report != null &&
        (report['testSessionId'] != session.sessionId ||
            report['startTimestamp'] !=
                session.startedAt.toUtc().toIso8601String() ||
            report['endTimestamp'] !=
                session.endedAt!.toUtc().toIso8601String() ||
            jsonEncode(report['stages']) !=
                jsonEncode(
                  session.records.map((record) => record.toJson()).toList(),
                ))) {
      throw const FormatException(
        'Completed report snapshot does not match its test session.',
      );
    }
    if (report != null) {
      final receiptStages = session.records
          .where((record) => record.receipt != null)
          .toList(growable: false);
      final expectedBalances = [
        for (final address in session.participatingPublicAddresses)
          {
            'publicAddress': address,
            'tokenSymbol': 'ETKN',
            'beforeBaseUnits': startingBalances[address].toString(),
            'afterBaseUnits': latestBalances[address].toString(),
            'deltaBaseUnits':
                (latestBalances[address]! - startingBalances[address]!)
                    .toString(),
          },
      ];
      final expectedCallNames = session.records
          .where((record) => record.isLiveTransaction)
          .map((record) => record.exactCall)
          .toList(growable: false);
      final expectedTransactionHashes = receiptStages
          .map((record) => record.receipt!.transactionHash)
          .toList(growable: false);
      final expectedInclusionBlocks = [
        for (final record in receiptStages)
          {
            'callName': record.exactCall,
            'transactionHash': record.receipt!.transactionHash,
            'blockNumber': record.receipt!.inclusionBlockNumber,
            'blockHash': record.receipt!.inclusionBlockHash,
          },
      ];
      final expectedFinalityBlocks = [
        for (final record in receiptStages)
          {
            'callName': record.exactCall,
            'transactionHash': record.receipt!.transactionHash,
            'blockNumber': record.receipt!.finalizedBlockNumber,
            'blockHash': record.receipt!.finalizedBlockHash,
          },
      ];
      final expectedDispatchResults = [
        for (final record in receiptStages)
          {
            'callName': record.exactCall,
            'transactionHash': record.receipt!.transactionHash,
            'dispatchResult': record.receipt!.dispatchResult,
          },
      ];
      final expectedEvents = [
        for (final record in receiptStages)
          for (final event in record.receipt!.relevantEvents)
            {
              'callName': record.exactCall,
              'transactionHash': record.receipt!.transactionHash,
              'event': event,
            },
      ];
      final expectedSettlementResult =
          latestMarket?.settlementStatus ?? 'Not completed';
      final expectedClaimResult = claimPosition?.claimed == true
          ? 'Claimed'
          : 'Not completed';
      final expectedPostStateVerification =
          session.records.isNotEmpty &&
              session.records.every(
                (record) => record.chainStateVerification.verified,
              )
          ? 'All recorded stages have canonical/local export verification.'
          : 'Session has incomplete post-state verification.';
      final overlapsMatch =
          _publicJsonEquivalent(
            report['participatingPublicAddresses'],
            session.participatingPublicAddresses,
          ) &&
          report['modelId'] == modelId &&
          report['predictionId'] == predictionId &&
          report['marketId'] == marketId &&
          _publicJsonEquivalent(
            report['balancesBeforeAfter'],
            expectedBalances,
          ) &&
          _publicJsonEquivalent(
            report['yesNoTotalsBeforeAfter'],
            marketTotals?.toJson(),
          ) &&
          _publicJsonEquivalent(report['callNames'], expectedCallNames) &&
          _publicJsonEquivalent(
            report['transactionHashes'],
            expectedTransactionHashes,
          ) &&
          _publicJsonEquivalent(
            report['inclusionBlocks'],
            expectedInclusionBlocks,
          ) &&
          _publicJsonEquivalent(
            report['finalityBlocks'],
            expectedFinalityBlocks,
          ) &&
          _publicJsonEquivalent(
            report['dispatchResults'],
            expectedDispatchResults,
          ) &&
          _publicJsonEquivalent(report['relevantEvents'], expectedEvents) &&
          report['settlementResult'] == expectedSettlementResult &&
          report['claimResult'] == expectedClaimResult &&
          report['postStateVerification'] == expectedPostStateVerification;
      if (!overlapsMatch) {
        throw const FormatException(
          'Completed report snapshot conflicts with checkpoint evidence.',
        );
      }
    }
  }
}

void _validatePublicChainHash(String value, String label) {
  if (!RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(value)) {
    throw ArgumentError.value(
      value,
      label,
      'Must be a 32-byte 0x-prefixed hexadecimal hash',
    );
  }
}

bool? _dispatchResultSucceeded(String value) {
  final normalized = value.trim().toLowerCase();
  if (const {'success', 'system.extrinsicsuccess'}.contains(normalized)) {
    return true;
  }
  if (const {
    'failure',
    'failed',
    'system.extrinsicfailed',
  }.contains(normalized)) {
    return false;
  }
  return null;
}

Phase6bTestOutcome aggregatePhase6bTestOutcome(
  Iterable<Phase6bStageRecord> records,
) {
  final values = records.toList(growable: false);
  if (values.any((record) => record.outcome == Phase6bTestOutcome.fail)) {
    return Phase6bTestOutcome.fail;
  }
  if (values.length != Phase6bTestLifecycle.stages.length ||
      values.any((record) => record.outcome == Phase6bTestOutcome.blocked)) {
    return Phase6bTestOutcome.blocked;
  }
  return Phase6bTestOutcome.pass;
}

void _validateSingleLiveCall(String exactCall, int transactionCount) {
  if (transactionCount !=
      Phase6bTestLifecycle.maximumTransactionsPerConfirmation) {
    throw Phase6bBatchAutomationException(
      'Each confirmation must authorize exactly one live transaction.',
    );
  }

  final normalized = exactCall.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  const forbiddenBatchCalls = [
    'utility.batch',
    'utility::batch',
    'batch_all',
    'batchall',
    'force_batch',
    'forcebatch',
  ];
  if (forbiddenBatchCalls.any(normalized.contains)) {
    throw const Phase6bBatchAutomationException(
      'Utility batch calls are forbidden in controlled live test sessions.',
    );
  }

  final callPath = RegExp(
    r'^[A-Za-z][A-Za-z0-9_]*(?:(?:\.|::)[A-Za-z][A-Za-z0-9_]*)+$',
  );
  if (!callPath.hasMatch(exactCall)) {
    throw ArgumentError.value(
      exactCall,
      'exactCall',
      'Use one exact pallet.call path without encoded arguments',
    );
  }
}

String _requireText(String value, String name) {
  final checked = value.trim();
  if (checked.isEmpty) {
    throw ArgumentError.value(value, name, 'Must not be empty');
  }
  return checked;
}

List<String> _uniqueNonEmpty(Iterable<String> values) {
  final result = <String>[];
  for (final value in values) {
    final checked = _requireText(value, 'participatingPublicAddresses');
    if (!result.contains(checked)) result.add(checked);
  }
  return result;
}

Map<String, Object?> _strictMap(
  Object? value,
  String label, {
  required Set<String> requiredKeys,
}) {
  if (value is! Map) {
    throw FormatException('$label must be a JSON object.');
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw FormatException('$label contains a non-string key.');
    }
    result[key] = entry.value;
  }
  final actual = result.keys.toSet();
  final missing = requiredKeys.difference(actual);
  final unknown = actual.difference(requiredKeys);
  if (missing.isNotEmpty || unknown.isNotEmpty) {
    throw FormatException(
      '$label has an invalid shape '
      '(missing: ${missing.join(', ')}, unknown: ${unknown.join(', ')}).',
    );
  }
  return result;
}

String _requiredString(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String) throw FormatException('$key must be a string.');
  try {
    return _requireText(value, key);
  } on ArgumentError catch (error) {
    throw FormatException('$key is invalid: $error');
  }
}

String _requiredStringAllowEmpty(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String) throw FormatException('$key must be a string.');
  return value;
}

String? _nullableString(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('$key must be null or a string.');
  }
  try {
    return _requireText(value, key);
  } on ArgumentError catch (error) {
    throw FormatException('$key is invalid: $error');
  }
}

bool _requiredBool(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! bool) throw FormatException('$key must be a boolean.');
  return value;
}

int _requiredInt(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! int) throw FormatException('$key must be an integer.');
  return value;
}

int _requiredNonNegativeInt(Map<String, Object?> data, String key) {
  final value = _requiredInt(data, key);
  if (value < 0) throw FormatException('$key cannot be negative.');
  return value;
}

int? _nullableInt(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value == null) return null;
  if (value is! int) throw FormatException('$key must be null or an integer.');
  return value;
}

int? _nullableNonNegativeInt(Map<String, Object?> data, String key) {
  final value = _nullableInt(data, key);
  if (value != null && value < 0) {
    throw FormatException('$key cannot be negative.');
  }
  return value;
}

BigInt _requiredBigInt(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String || !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value)) {
    throw FormatException('$key must be a non-negative decimal string.');
  }
  return BigInt.parse(value);
}

BigInt _requiredSignedBigInt(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String || !RegExp(r'^-?(0|[1-9][0-9]*)$').hasMatch(value)) {
    throw FormatException('$key must be a decimal integer string.');
  }
  return BigInt.parse(value);
}

DateTime _requiredDateTime(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String || !value.endsWith('Z')) {
    throw FormatException('$key must be a UTC ISO-8601 string.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    throw FormatException('$key must be a valid UTC ISO-8601 string.');
  }
  return parsed;
}

DateTime? _nullableDateTime(Map<String, Object?> data, String key) {
  if (data[key] == null) return null;
  return _requiredDateTime(data, key);
}

List<Object?> _objectList(Object? value, String label) {
  if (value is! List) throw FormatException('$label must be a JSON array.');
  return List<Object?>.from(value);
}

List<String> _stringList(Object? value, String label) {
  final values = _objectList(value, label);
  final result = <String>[];
  for (final item in values) {
    if (item is! String) {
      throw FormatException('$label must contain only strings.');
    }
    result.add(item);
  }
  return result;
}

T _enumByName<T extends Enum>(List<T> values, String name, String label) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Unknown $label: $name.');
}

Phase6bTestOutcome _testOutcomeFromLabel(String label) {
  for (final outcome in Phase6bTestOutcome.values) {
    if (outcome.label == label) return outcome;
  }
  throw FormatException('Unknown test outcome: $label.');
}

bool _sameList<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _sameSet<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);

Map<String, BigInt> _bigIntMap(Object? value, String label) {
  if (value is! Map) throw FormatException('$label must be a JSON object.');
  final result = <String, BigInt>{};
  for (final entry in value.entries) {
    final key = entry.key;
    final raw = entry.value;
    if (key is! String || key.trim().isEmpty) {
      throw FormatException('$label contains an invalid address.');
    }
    if (raw is! String || !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(raw)) {
      throw FormatException('$label contains an invalid balance.');
    }
    result[key] = BigInt.parse(raw);
  }
  return result;
}

String? _nullableDecimalId(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value == null) return null;
  if (value is! String || !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value)) {
    throw FormatException('$key must be null or a non-negative decimal ID.');
  }
  return value;
}

BigInt? _validateOptionalDecimalId(String? value, String label) {
  if (value == null) return null;
  if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value)) {
    throw FormatException('$label must be a non-negative decimal ID.');
  }
  return BigInt.parse(value);
}

Map<String, Object?> _publicJsonMap(Object? value, String label) {
  if (value is! Map) throw FormatException('$label must be a JSON object.');
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw FormatException('$label contains a non-string key.');
    }
    _rejectSensitiveKey(key, '$label.$key');
    result[key] = _copyPublicJsonValue(entry.value, '$label.$key');
  }
  return Map.unmodifiable(result);
}

Object? _copyPublicJsonValue(Object? value, String path) {
  if (value == null || value is bool || value is int || value is String) {
    if (value is String) _rejectSensitiveText(value, path);
    return value;
  }
  if (value is double) {
    if (!value.isFinite) throw FormatException('$path is not finite.');
    return value;
  }
  if (value is List) {
    return List<Object?>.unmodifiable(
      value.indexed.map(
        (entry) => _copyPublicJsonValue(entry.$2, '$path[${entry.$1}]'),
      ),
    );
  }
  if (value is Map) return _publicJsonMap(value, path);
  throw FormatException('$path is not JSON-compatible public evidence.');
}

bool _publicJsonEquivalent(Object? left, Object? right) {
  if (identical(left, right) || left == right) return true;
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_publicJsonEquivalent(left[index], right[index])) return false;
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_publicJsonEquivalent(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return false;
}

Map<String, Object?> _normalizePublicJsonMap(Map<String, Object?> value) {
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    _rejectSensitiveKey(entry.key, 'arguments.${entry.key}');
    result[entry.key] = _normalizePublicJsonValue(
      entry.value,
      'arguments.${entry.key}',
    );
  }
  return result;
}

Object? _normalizePublicJsonValue(Object? value, String path) {
  if (value == null || value is bool || value is int || value is String) {
    if (value is String) _rejectSensitiveText(value, path);
    return value;
  }
  if (value is double) {
    if (!value.isFinite) throw FormatException('$path is not finite.');
    return value;
  }
  if (value is BigInt) return value.toString();
  if (value is Uint8List) {
    final hex = value.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    return '0x${hex.join()}';
  }
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is Enum) return value.name;
  if (value is List) {
    return List<Object?>.unmodifiable(
      value.indexed.map(
        (entry) => _normalizePublicJsonValue(entry.$2, '$path[${entry.$1}]'),
      ),
    );
  }
  if (value is Map) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException('$path contains a non-string key.');
      }
      _rejectSensitiveKey(key, '$path.$key');
      result[key] = _normalizePublicJsonValue(entry.value, '$path.$key');
    }
    return Map<String, Object?>.unmodifiable(result);
  }
  throw FormatException('$path cannot be persisted as public evidence.');
}

void _validatePublicJsonValue(Object? value, String path) {
  if (value == null || value is bool || value is int) return;
  if (value is String) {
    _rejectSensitiveText(value, path);
    return;
  }
  if (value is double) {
    if (!value.isFinite) throw FormatException('$path is not finite.');
    return;
  }
  if (value is List) {
    for (final entry in value.indexed) {
      _validatePublicJsonValue(entry.$2, '$path[${entry.$1}]');
    }
    return;
  }
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException('$path contains a non-string key.');
      }
      _rejectSensitiveKey(key, '$path.$key');
      _validatePublicJsonValue(entry.value, '$path.$key');
    }
    return;
  }
  throw FormatException('$path is not JSON-compatible public evidence.');
}

void _rejectSensitiveKey(String key, String path) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  const sensitive = {
    'mnemonic',
    'mnemonicblob',
    'mnemonicnonce',
    'seed',
    'seedphrase',
    'recoveryphrase',
    'privatekey',
    'secretkey',
    'keymaterial',
    'password',
    'passphrase',
    'pin',
    'pincode',
    'pinhash',
    'passcode',
    'pinsalt',
    'pinverifier',
    'securestorage',
    'securestoragecontents',
    'biometric',
    'biometrics',
    'apikey',
    'apitoken',
    'accesstoken',
    'authtoken',
    'bearertoken',
    'refreshtoken',
    'authorization',
    'bearer',
    'clientsecret',
    'credential',
    'credentials',
    'ciphertext',
  };
  if (sensitive.contains(normalized)) {
    throw FormatException('$path is forbidden in public session evidence.');
  }
}

bool _looksLikeBearerCredential(String value) =>
    RegExp(r'^\s*(?:bearer|basic)\s+\S+', caseSensitive: false).hasMatch(value);

void _rejectSensitiveText(String value, String path) {
  if (_looksLikeBearerCredential(value) || _looksLikeMnemonicText(value)) {
    throw FormatException('$path contains credential-like text.');
  }
  if (RegExp(r'^(?:0x)?[0-9a-fA-F]{64,128}$').hasMatch(value.trim()) &&
      !_isPublicHexPath(path)) {
    throw FormatException('$path contains private-key-like hex material.');
  }
}

bool _looksLikeMnemonicText(String value) {
  final words = value.trim().split(RegExp(r'\s+'));
  return const {12, 15, 18, 21, 24}.contains(words.length) &&
      words.every((word) => RegExp(r'^[a-z]{2,12}$').hasMatch(word));
}

bool _isPublicHexPath(String path) {
  final normalized = path
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
      .replaceFirst(RegExp(r'\d+$'), '');
  return normalized.endsWith('hash') ||
      normalized.endsWith('hashes') ||
      normalized.endsWith('fingerprint') ||
      normalized.endsWith('fingerprints') ||
      normalized.endsWith('publickey') ||
      normalized.endsWith('publickeys') ||
      normalized.endsWith('publicaddress') ||
      normalized.endsWith('publicaddresses') ||
      normalized.endsWith('signer') ||
      normalized.endsWith('signers') ||
      normalized.endsWith('owner') ||
      normalized.endsWith('owners') ||
      normalized.endsWith('account') ||
      normalized.endsWith('accounts') ||
      normalized.endsWith('accountid') ||
      normalized.endsWith('accountids');
}
