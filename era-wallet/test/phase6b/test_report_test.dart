import 'dart:convert';

import 'package:era_wallet/phase6b/test_report.dart';
import 'package:era_wallet/phase6b/test_session.dart';
import 'package:flutter_test/flutter_test.dart';

const _accountA = '5FHneW46xGXgs5mUiveU4sbTyGBzmst1TqgX2q1G7mUX9hY2';
const _accountB = '5DAAnrj7VHTz5f6M4vXjL7W9Y2Qp8Ks3bNc1Rt4Eu6Zi0AaB';
final _time = DateTime.utc(2026, 7, 16, 10);

void main() {
  group('Phase 6B lifecycle catalog', () {
    test('defines the required ordered 15-stage controlled lifecycle', () {
      final stages = Phase6bTestLifecycle.stages;

      expect(stages, hasLength(15));
      expect(
        stages.map((stage) => stage.number),
        orderedEquals(List<int>.generate(15, (index) => index + 1)),
      );
      expect(stages.first.stage, Phase6bTestStage.selectTestAccounts);
      expect(stages.last.stage, Phase6bTestStage.exportReport);
      expect(
        stages[4].actionKind,
        Phase6bStageActionKind.conditionalSignedTransaction,
      );
      expect(Phase6bTestLifecycle.batchAutomationAllowed, isFalse);
      expect(Phase6bTestLifecycle.maximumTransactionsPerConfirmation, 1);
      for (var index = 1; index < stages.length; index++) {
        expect(stages[index].prerequisites, contains(stages[index - 1].stage));
      }
    });

    test('formats exact ETKN fee estimates without floating-point loss', () {
      final fee = Phase6bFeeEstimate(
        baseUnits: BigInt.parse('1234500000000000000'),
      );

      expect(fee.decimalAmount, '1.2345');
      expect(fee.display, '1.2345 ETKN');
      expect(fee.toJson()['baseUnits'], '1234500000000000000');
    });
  });

  group('single-action safety policy', () {
    test('rejects more than one transaction per confirmation', () {
      expect(
        () => _transactionStage(
          Phase6bTestStage.onboardModel,
          transactionCount: 2,
        ),
        throwsA(isA<Phase6bBatchAutomationException>()),
      );
    });

    test('rejects Utility batch calls even with one transaction envelope', () {
      expect(
        () => _transactionStage(
          Phase6bTestStage.onboardModel,
          exactCall: 'Utility.batch_all',
        ),
        throwsA(isA<Phase6bBatchAutomationException>()),
      );
      expect(
        () => _transactionStage(
          Phase6bTestStage.onboardModel,
          exactCall: 'Utility.force_batch',
        ),
        throwsA(isA<Phase6bBatchAutomationException>()),
      );
    });

    test('requires a separate signer confirmation, fee, and receipt', () {
      expect(
        () => Phase6bStageRecord(
          stage: Phase6bTestStage.onboardModel,
          prerequisiteChecks: [_passedCheck()],
          exactCall: 'AiPredictions.register_model',
          publicSigner: _accountA,
          feeEstimate: Phase6bFeeEstimate(baseUnits: BigInt.one),
          confirmation: Phase6bActionConfirmation.notRequired(),
          receipt: _receipt(3),
          chainStateVerification: _verifiedState(),
          outcome: Phase6bTestOutcome.pass,
          isLiveTransaction: true,
          completedAt: _time,
        ),
        throwsArgumentError,
      );
    });

    test('will not mark an unverified or unfinalized action PASS', () {
      expect(
        () => _readOnlyStage(
          Phase6bTestStage.selectTestAccounts,
          verification: Phase6bChainStateVerification.notPerformed(),
        ),
        throwsArgumentError,
      );

      expect(
        () => _transactionStage(
          Phase6bTestStage.onboardModel,
          receipt: Phase6bTransactionReceiptRef(
            referenceId: 'receipt-pending',
            transactionHash: _hash(0, 4),
            dispatchResult: 'failed',
            finalized: false,
            succeeded: false,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('Phase6bTestSession', () {
    test(
      'records stages only in order and only from participating signers',
      () {
        final session = Phase6bTestSession(
          sessionId: 'session-order',
          startedAt: _time,
          participatingPublicAddresses: const [_accountA, _accountB],
        );

        expect(
          () => session.recordStage(
            _readOnlyStage(Phase6bTestStage.verifyBalancesAndRuntime),
          ),
          throwsStateError,
        );

        session.recordStage(
          _readOnlyStage(Phase6bTestStage.selectTestAccounts),
        );
        session.recordStage(
          _readOnlyStage(Phase6bTestStage.verifyBalancesAndRuntime),
        );
        expect(session.nextStage, Phase6bTestStage.onboardModel);

        expect(
          () => session.recordStage(
            _transactionStage(
              Phase6bTestStage.onboardModel,
              signer: '5UnlistedPublicSigner',
            ),
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'requires downstream stages to be BLOCKED after a failed prerequisite',
      () {
        final session = Phase6bTestSession(
          sessionId: 'session-blocked',
          startedAt: _time,
          participatingPublicAddresses: const [_accountA],
        );
        session.recordStage(
          _readOnlyStage(
            Phase6bTestStage.selectTestAccounts,
            outcome: Phase6bTestOutcome.fail,
            verification: Phase6bChainStateVerification.notPerformed(
              summary: 'Account selection failed.',
            ),
          ),
        );

        expect(
          () => session.recordStage(
            _readOnlyStage(Phase6bTestStage.verifyBalancesAndRuntime),
          ),
          throwsStateError,
        );

        session.recordStage(
          _readOnlyStage(
            Phase6bTestStage.verifyBalancesAndRuntime,
            outcome: Phase6bTestOutcome.blocked,
            prerequisitePassed: false,
            verification: Phase6bChainStateVerification.notPerformed(
              summary: 'Blocked by account selection.',
            ),
          ),
        );
        expect(session.records.last.outcome, Phase6bTestOutcome.blocked);
        expect(session.overallOutcome, Phase6bTestOutcome.fail);
      },
    );

    test('finishing freezes the session and serializes the safety policy', () {
      final session = Phase6bTestSession(
        sessionId: 'session-finished',
        startedAt: _time,
        participatingPublicAddresses: const [_accountA],
      );
      for (final stage in _allPassingStages()) {
        session.recordStage(stage);
      }
      session.finish(_time.add(const Duration(minutes: 16)));

      expect(session.isFinished, isTrue);
      expect(session.overallOutcome, Phase6bTestOutcome.pass);
      expect(session.toJson()['batchAutomationAllowed'], isFalse);
      expect(
        () => session.recordStage(
          _readOnlyStage(Phase6bTestStage.verifyBalancesAndRuntime),
        ),
        throwsStateError,
      );
    });
  });

  group('overall result aggregation', () {
    test('FAIL wins, then BLOCKED/incomplete, otherwise all 15 PASS', () {
      expect(
        aggregatePhase6bTestOutcome([
          _readOnlyStage(
            Phase6bTestStage.selectTestAccounts,
            outcome: Phase6bTestOutcome.fail,
            verification: Phase6bChainStateVerification.notPerformed(),
          ),
        ]),
        Phase6bTestOutcome.fail,
      );
      expect(
        aggregatePhase6bTestOutcome([
          _readOnlyStage(Phase6bTestStage.selectTestAccounts),
        ]),
        Phase6bTestOutcome.blocked,
      );
      expect(
        aggregatePhase6bTestOutcome(_allPassingStages()),
        Phase6bTestOutcome.pass,
      );
    });
  });

  group('Phase6bTestReport exports', () {
    test('JSON includes every required Phase 6B evidence category', () {
      final report = _completeReport();
      final data = report.toJson();

      expect(data['walletAppVersion'], '1.0.0+1');
      expect(data['platform'], 'windows');
      expect(data['endpoint'], 'wss://eraprojects.org');
      expect(data['genesisHash'], '0xgenesis');
      expect(data['runtimeSpecName'], 'era');
      expect(data['runtimeSpecVersion'], 13);
      expect(data['metadataFingerprint'], 'sha256:metadata');
      expect(data['testSessionId'], 'phase6b-session-1');
      expect(data['startTimestamp'], isNotNull);
      expect(data['endTimestamp'], isNotNull);
      expect(data['participatingPublicAddresses'], [_accountA, _accountB]);
      expect(data['modelId'], '41');
      expect(data['predictionId'], '52');
      expect(data['marketId'], '52');
      expect((data['callNames'] as List), isNotEmpty);
      expect((data['transactionHashes'] as List), isNotEmpty);
      expect((data['inclusionBlocks'] as List), isNotEmpty);
      expect((data['finalityBlocks'] as List), isNotEmpty);
      expect((data['dispatchResults'] as List), isNotEmpty);
      expect((data['relevantEvents'] as List), isNotEmpty);
      expect((data['balancesBeforeAfter'] as List), hasLength(2));
      expect(data['yesNoTotalsBeforeAfter'], isNotNull);
      expect((data['treasuryAndFeeObservations'] as List), hasLength(1));
      expect(data['settlementResult'], 'Settled YES');
      expect(data['claimResult'], 'Winning payout claimed');
      expect(data['postStateVerification'], 'All canonical storage reloaded');
      expect(data['warnings'], ['Live ERA chain; real ETKN used.']);
      expect(data['overallResult'], 'PASS');
      expect(data['batchAutomationAllowed'], isFalse);
      expect((data['stages'] as List), hasLength(15));
    });

    test(
      'sanitizes credential-bearing endpoints and preserves public hashes',
      () {
        final report = Phase6bTestReport(
          walletAppVersion: '1.0.0+1',
          platform: 'test',
          endpoint: 'wss://user:secret@example.invalid/rpc?apiKey=secret#token',
          genesisHash: '0xgenesis',
          runtimeSpecName: 'era',
          runtimeSpecVersion: 13,
          transactionVersion: 1,
          metadataVersion: 14,
          metadataFingerprint: 'sha256:metadata',
          runtimeWasmHash:
              '2bb522963e929575483d8d7bc791f236d0ef0db19f83546a6a5d2f766f6ffdf6',
          aiStorageVersion: 3,
          aiPalletIndex: 12,
          testSessionId: 'session-endpoint-safety',
          startedAt: DateTime.utc(2026, 1, 1),
          endedAt: DateTime.utc(2026, 1, 1, 0, 1),
          participatingPublicAddresses: const ['era-public-address'],
          stages: const [],
          settlementResult: 'Not exercised',
          claimResult: 'Not exercised',
          postStateVerification: 'Not exercised',
        );

        final data = report.toJson();
        expect(data['endpoint'], 'wss://example.invalid');
        expect(
          data['runtimeWasmHash'],
          '2bb522963e929575483d8d7bc791f236d0ef0db19f83546a6a5d2f766f6ffdf6',
        );
        expect(data['aiStorageVersion'], 3);
        expect(data['aiPalletIndex'], 12);
      },
    );

    test('recursively redacts sensitive keys and sensitive values', () {
      final privateHex = List.filled(64, 'a').join();
      final publicHash = List.filled(64, 'b').join();
      final report = _completeReport(
        additionalEvidence: {
          'mnemonic': 'fixture-sensitive-value',
          'nested': [
            {'private_key': privateHex, 'publicAddress': _accountA},
            {'note': 'password=hunter2'},
            {'biometricEnabled': true},
          ],
          'embeddedJson':
              '{"seed":"do-not-export","publicAddress":"$_accountB"}',
          'unlabelledPhrase':
              'fixture words are not wallet recovery material only redaction shape test data',
          'rawKeyMaterial': privateHex,
          'transactionHash': publicHash,
          'privateKeyFingerprint': privateHex,
          'privateKeyPublicAddress': privateHex,
        },
      );

      final jsonText = report.toJsonString();
      final data = jsonDecode(jsonText) as Map<String, dynamic>;
      final evidence = data['additionalEvidence'] as Map<String, dynamic>;
      final nested = evidence['nested'] as List<dynamic>;

      expect(evidence['mnemonic'], phase6bRedactedValue);
      expect((nested[0] as Map)['private_key'], phase6bRedactedValue);
      expect((nested[0] as Map)['publicAddress'], _accountA);
      expect((nested[1] as Map)['note'], phase6bRedactedValue);
      expect((nested[2] as Map)['biometricEnabled'], phase6bRedactedValue);
      expect(evidence['embeddedJson'], phase6bRedactedValue);
      expect(evidence['unlabelledPhrase'], phase6bRedactedValue);
      expect(evidence['rawKeyMaterial'], phase6bRedactedValue);
      expect(evidence['transactionHash'], publicHash);
      expect(evidence['privateKeyFingerprint'], phase6bRedactedValue);
      expect(evidence['privateKeyPublicAddress'], phase6bRedactedValue);
      expect(jsonText, isNot(contains('hunter2')));
      expect(jsonText, isNot(contains('do-not-export')));
      expect(jsonText, isNot(contains(privateHex)));
      expect(jsonText, contains(_accountA));
      expect(jsonText, contains(_accountB));
    });

    test('Markdown is human-readable, complete, and redacted by default', () {
      final report = _completeReport(
        warnings: const ['password: should-never-appear'],
        additionalEvidence: const {'secure_storage': 'vault contents'},
      );

      final markdown = report.toMarkdown();

      expect(markdown, contains('# ERA Phase 6B Lifecycle Test Report'));
      expect(markdown, contains('Overall result | PASS'));
      expect(markdown, contains('Runtime specVersion | 13'));
      expect(markdown, contains('Model ID | 41'));
      expect(markdown, contains('Exact intended call'));
      expect(markdown, contains('Receipt reference'));
      expect(markdown, contains('Chain-state verification'));
      expect(markdown, contains('Balances before/after'));
      expect(markdown, contains('YES/NO totals before/after'));
      expect(markdown, contains('Settlement result: Settled YES'));
      expect(markdown, contains(phase6bRedactedValue));
      expect(markdown, isNot(contains('should-never-appear')));
      expect(markdown, isNot(contains('vault contents')));
      expect(markdown, contains(_accountA));
    });

    test('provides JSON, Markdown, and copy-summary payload strings', () {
      final payload = _completeReport().exportPayload;

      expect(jsonDecode(payload.json), isA<Map<String, dynamic>>());
      expect(payload.markdown, startsWith('# ERA Phase 6B'));
      expect(payload.summary, contains('Overall result: PASS'));
      expect(payload.summary, contains('Runtime: era spec 13'));
      expect(payload.summary, contains('Transactions recorded: 10'));
    });

    test('an unfinished otherwise-successful report is BLOCKED', () {
      final report = _completeReport(unfinished: true);

      expect(report.overallResult, Phase6bTestOutcome.blocked);
      expect(report.toJson()['overallResult'], 'BLOCKED');
    });
  });
}

Phase6bPrerequisiteCheck _passedCheck({bool passed = true}) {
  return Phase6bPrerequisiteCheck(
    name: 'Runtime and state prerequisites',
    passed: passed,
    evidence: passed ? 'Confirmed from finalized state.' : 'Not satisfied.',
  );
}

Phase6bChainStateVerification _verifiedState() {
  return Phase6bChainStateVerification(
    verified: true,
    summary: 'Expected canonical state observed.',
    evidence: const {'finalized': true},
  );
}

Phase6bTransactionReceiptRef _receipt(int number) {
  return Phase6bTransactionReceiptRef(
    referenceId: 'receipt-$number',
    transactionHash: _hash(number, 1),
    inclusionBlockNumber: 1000 + number,
    inclusionBlockHash: _hash(number, 2),
    finalizedBlockNumber: 1001 + number,
    finalizedBlockHash: _hash(number, 3),
    dispatchResult: 'system.ExtrinsicSuccess',
    relevantEvents: ['AiPredictions.Event$number'],
    finalized: true,
    succeeded: true,
  );
}

String _hash(int number, int namespace) =>
    '0x${(namespace * 100000 + number).toRadixString(16).padLeft(64, '0')}';

Phase6bStageRecord _readOnlyStage(
  Phase6bTestStage stage, {
  Phase6bTestOutcome outcome = Phase6bTestOutcome.pass,
  bool prerequisitePassed = true,
  Phase6bChainStateVerification? verification,
}) {
  return Phase6bStageRecord(
    stage: stage,
    prerequisiteChecks: [_passedCheck(passed: prerequisitePassed)],
    exactCall: 'read.${stage.name}',
    confirmation: Phase6bActionConfirmation.notRequired(),
    chainStateVerification: verification ?? _verifiedState(),
    outcome: outcome,
    notes: 'Read-only evidence recorded.',
    completedAt: _time.add(
      Duration(minutes: Phase6bTestLifecycle.definitionFor(stage).number),
    ),
  );
}

Phase6bStageRecord _transactionStage(
  Phase6bTestStage stage, {
  String? exactCall,
  String signer = _accountA,
  int? transactionCount,
  Phase6bTransactionReceiptRef? receipt,
}) {
  final number = Phase6bTestLifecycle.definitionFor(stage).number;
  return Phase6bStageRecord(
    stage: stage,
    prerequisiteChecks: [_passedCheck()],
    exactCall: exactCall ?? 'AiPredictions.${stage.name}',
    publicSigner: signer,
    feeEstimate: Phase6bFeeEstimate(baseUnits: BigInt.from(1000 + number)),
    confirmation: Phase6bActionConfirmation(
      confirmed: true,
      statement: 'I confirm this single live ERA transaction.',
      confirmedByPublicAddress: signer,
      confirmedAt: _time.add(Duration(minutes: number)),
    ),
    receipt: receipt ?? _receipt(number),
    chainStateVerification: _verifiedState(),
    outcome: Phase6bTestOutcome.pass,
    isLiveTransaction: true,
    transactionCount: transactionCount,
    notes: 'Finalized and verified from chain state.',
    completedAt: _time.add(Duration(minutes: number)),
  );
}

List<Phase6bStageRecord> _allPassingStages() {
  return Phase6bTestLifecycle.stages.map((definition) {
    if (definition.actionKind == Phase6bStageActionKind.signedTransaction ||
        definition.actionKind ==
            Phase6bStageActionKind.conditionalSignedTransaction) {
      return _transactionStage(definition.stage);
    }
    return _readOnlyStage(definition.stage);
  }).toList();
}

Phase6bTestReport _completeReport({
  bool unfinished = false,
  List<String> warnings = const ['Live ERA chain; real ETKN used.'],
  Map<String, Object?> additionalEvidence = const {},
}) {
  return Phase6bTestReport(
    walletAppVersion: '1.0.0+1',
    platform: 'windows',
    endpoint: 'wss://eraprojects.org/',
    genesisHash: '0xgenesis',
    runtimeSpecName: 'era',
    runtimeSpecVersion: 13,
    metadataFingerprint: 'sha256:metadata',
    testSessionId: 'phase6b-session-1',
    startedAt: _time,
    endedAt: unfinished ? null : _time.add(const Duration(hours: 1)),
    participatingPublicAddresses: const [_accountA, _accountB],
    modelId: '41',
    predictionId: '52',
    marketId: '52',
    stages: _allPassingStages(),
    balanceObservations: [
      Phase6bBalanceObservation(
        publicAddress: _accountA,
        beforeBaseUnits: BigInt.parse('10000000000000000000'),
        afterBaseUnits: BigInt.parse('9890000000000000000'),
      ),
      Phase6bBalanceObservation(
        publicAddress: _accountB,
        beforeBaseUnits: BigInt.parse('10000000000000000000'),
        afterBaseUnits: BigInt.parse('10900000000000000000'),
      ),
    ],
    marketTotals: Phase6bMarketTotalsObservation(
      yesBeforeBaseUnits: BigInt.zero,
      yesAfterBaseUnits: BigInt.parse('10000000000000000'),
      noBeforeBaseUnits: BigInt.zero,
      noAfterBaseUnits: BigInt.parse('10000000000000000'),
    ),
    treasuryAndFeeObservations: [
      Phase6bTreasuryFeeObservation(
        label: 'Treasury and aggregate fees',
        before: '0 ETKN observed',
        after: '0.001 ETKN observed',
        detail: 'Compared after finalized claim.',
      ),
    ],
    settlementResult: 'Settled YES',
    claimResult: 'Winning payout claimed',
    postStateVerification: 'All canonical storage reloaded',
    warnings: warnings,
    additionalEvidence: additionalEvidence,
  );
}
