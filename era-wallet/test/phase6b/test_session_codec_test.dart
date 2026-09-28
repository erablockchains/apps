import 'dart:convert';
import 'dart:typed_data';

import 'package:era_wallet/phase6b/test_session.dart';
import 'package:flutter_test/flutter_test.dart';

const _accountA = '5EraPublicAccountA';
const _accountB = '5EraPublicAccountB';
final _startedAt = DateTime.utc(2026, 7, 17, 10);
const _transactionHash =
    '0x1111111111111111111111111111111111111111111111111111111111111111';
const _inclusionHash =
    '0x2222222222222222222222222222222222222222222222222222222222222222';
const _finalizedHash =
    '0x3333333333333333333333333333333333333333333333333333333333333333';
const _differentTransactionHash =
    '0x4444444444444444444444444444444444444444444444444444444444444444';

void main() {
  group('Phase6bTestSession strict codec', () {
    test('round-trips ordered nested stage evidence', () {
      final session = _sessionThroughOnboarding();

      final restored = Phase6bTestSession.fromJson(session.toJson());

      expect(restored.sessionId, session.sessionId);
      expect(restored.startedAt, session.startedAt);
      expect(restored.participatingPublicAddresses, [_accountA, _accountB]);
      expect(restored.records.length, 3);
      expect(restored.records.last.stage, Phase6bTestStage.onboardModel);
      expect(restored.records.last.feeEstimate?.baseUnits, BigInt.from(1234));
      expect(restored.records.last.receipt?.finalizedBlockNumber, 99);
      expect(restored.nextStage, Phase6bTestStage.approveModel);
    });

    test('rejects tampered derived stage and overall values', () {
      final stageTamper = _mutableJson(_sessionThroughOnboarding().toJson());
      final stages = stageTamper['stages']! as List<Object?>;
      (stages.first as Map<String, Object?>)['stageTitle'] = 'Tampered';
      expect(
        () => Phase6bTestSession.fromJson(stageTamper),
        throwsFormatException,
      );

      final resultTamper = _mutableJson(_sessionThroughOnboarding().toJson());
      resultTamper['overallResult'] = 'PASS';
      expect(
        () => Phase6bTestSession.fromJson(resultTamper),
        throwsFormatException,
      );
    });

    test('rejects contradictory receipt hash and finality evidence', () {
      final receipt = _transactionStage(Phase6bTestStage.onboardModel).receipt!;

      for (final mutate in <void Function(Map<String, Object?>)>[
        (json) => json['transactionHash'] = '0x1234',
        (json) => json['inclusionBlockHash'] = null,
        (json) => json['finalized'] = false,
        (json) => json['finalizedBlockNumber'] = 97,
        (json) => json['succeeded'] = false,
        (json) => json['dispatchResult'] = 'pending',
      ]) {
        final tampered = _mutableJson(receipt.toJson());
        mutate(tampered);
        expect(
          () => Phase6bTransactionReceiptRef.fromJson(tampered),
          throwsArgumentError,
        );
      }
    });

    test('keeps terminal auxiliary calls separate from stage advancement', () {
      expect(
        resolvePhase6bPendingCall(
          matchesStage: false,
          isAllowedAuxiliary: true,
          isDefinitiveTerminal: true,
        ),
        Phase6bPendingCallResolution.clearWithoutAdvancing,
      );
      expect(
        resolvePhase6bPendingCall(
          matchesStage: false,
          isAllowedAuxiliary: true,
          isDefinitiveTerminal: false,
        ),
        Phase6bPendingCallResolution.retain,
      );
      expect(
        resolvePhase6bPendingCall(
          matchesStage: true,
          isAllowedAuxiliary: false,
          isDefinitiveTerminal: true,
        ),
        Phase6bPendingCallResolution.advanceStage,
      );
    });
  });

  group('Phase6bTestSessionCheckpoint', () {
    test('round-trips public balances, IDs, and session state', () {
      final checkpoint = Phase6bTestSessionCheckpoint(
        savedAt: _startedAt.add(const Duration(minutes: 4)),
        session: _sessionThroughOnboarding(),
        startingBalances: {
          _accountA: BigInt.from(100000),
          _accountB: BigInt.from(200000),
        },
        latestBalances: {
          _accountA: BigInt.from(99000),
          _accountB: BigInt.from(200000),
        },
        modelId: '41',
      );

      final encoded = checkpoint.encode();
      final restored = Phase6bTestSessionCheckpoint.decode(encoded);

      expect(restored.session.records.length, 3);
      expect(restored.session.nextStage, Phase6bTestStage.approveModel);
      expect(restored.modelId, '41');
      expect(restored.startingBalances[_accountA], BigInt.from(100000));
      expect(restored.latestBalances[_accountA], BigInt.from(99000));
      expect(encoded, isNot(contains('mnemonic')));
      expect(encoded, isNot(contains('privateKey')));
    });

    test('persists only a public descriptor for uncertain reconciliation', () {
      final session =
          Phase6bTestSession(
              sessionId: 'session-pending',
              startedAt: _startedAt,
              participatingPublicAddresses: const [_accountA, _accountB],
            )
            ..recordStage(_readOnlyStage(Phase6bTestStage.selectTestAccounts))
            ..recordStage(
              _readOnlyStage(Phase6bTestStage.verifyBalancesAndRuntime),
            );
      final pending = Phase6bPendingCallEvidence(
        recordId: 'journal-record-1',
        callName: 'register_model',
        callPath: 'AiPredictions.register_model',
        arguments: {
          'model_hash': Uint8List.fromList([1, 2, 3]),
          'metadata_reference': 'ipfs://public-model-metadata',
          'model_id_hint': BigInt.from(41),
        },
        feeBaseUnits: BigInt.from(77),
        typedConfirmation: 'REGISTER MODEL',
      );
      final checkpoint = Phase6bTestSessionCheckpoint(
        savedAt: _startedAt.add(const Duration(minutes: 3)),
        session: session,
        startingBalances: {
          _accountA: BigInt.from(100000),
          _accountB: BigInt.from(200000),
        },
        latestBalances: {
          _accountA: BigInt.from(100000),
          _accountB: BigInt.from(200000),
        },
        pendingCalls: [pending],
      );

      final restored = Phase6bTestSessionCheckpoint.decode(
        checkpoint.encode(),
      ).pendingCalls.single;

      expect(restored.recordId, 'journal-record-1');
      expect(restored.arguments['model_hash'], '0x010203');
      expect(restored.arguments['model_id_hint'], '41');
      expect(restored.feeBaseUnits, BigInt.from(77));
      expect(
        Phase6bPendingCallEvidence.fromJson({
          ...pending.toJson(),
          'feeBaseUnits': null,
        }).feeBaseUnits,
        isNull,
      );
    });

    test('fails closed on unknown schema, missing IDs, and secret keys', () {
      final valid = Phase6bTestSessionCheckpoint(
        savedAt: _startedAt.add(const Duration(minutes: 4)),
        session: _sessionThroughOnboarding(),
        startingBalances: {
          _accountA: BigInt.from(100000),
          _accountB: BigInt.from(200000),
        },
        latestBalances: {
          _accountA: BigInt.from(100000),
          _accountB: BigInt.from(200000),
        },
        modelId: '41',
      );
      final schemaTamper = jsonDecode(valid.encode()) as Map<String, Object?>;
      schemaTamper['schemaVersion'] = 2;
      expect(
        () => Phase6bTestSessionCheckpoint.decode(jsonEncode(schemaTamper)),
        throwsFormatException,
      );

      expect(
        () => Phase6bTestSessionCheckpoint(
          savedAt: _startedAt.add(const Duration(minutes: 4)),
          session: _sessionThroughOnboarding(),
          startingBalances: {
            _accountA: BigInt.from(100000),
            _accountB: BigInt.from(200000),
          },
          latestBalances: {
            _accountA: BigInt.from(100000),
            _accountB: BigInt.from(200000),
          },
        ),
        throwsFormatException,
      );

      expect(
        () => Phase6bPendingCallEvidence(
          recordId: 'unsafe',
          callName: 'register_model',
          callPath: 'AiPredictions.register_model',
          arguments: const {
            'mnemonic': 'abandon ability able about above absent',
          },
          feeBaseUnits: BigInt.one,
        ),
        throwsFormatException,
      );
    });

    test('validates canonical market and position evidence', () {
      final market = Phase6bPersistedMarketEvidence.fromJson(_marketEvidence());
      final position = Phase6bPersistedPositionEvidence.fromJson(
        _positionEvidence(),
      );

      expect(market.tokenId, BigInt.from(52));
      expect(market.provenance, 'canonicalStorage');
      expect(position.account, _accountA);
      expect(position.claimed, isTrue);

      final derived = _marketEvidence()..['provenance'] = 'derivedIndex';
      expect(
        () => Phase6bPersistedMarketEvidence.fromJson(derived),
        throwsFormatException,
      );
    });

    test(
      'round-trips a frozen completed-report snapshot and enforces state',
      () {
        final finished = _completedBlockedSession();
        final snapshot = Phase6bCompletedReportSnapshot.fromJson(
          _completedReportData(finished),
        );
        final checkpoint = Phase6bTestSessionCheckpoint(
          savedAt: _startedAt.add(const Duration(minutes: 17)),
          session: finished,
          startingBalances: {
            _accountA: BigInt.from(100000),
            _accountB: BigInt.from(200000),
          },
          latestBalances: {
            _accountA: BigInt.from(98766),
            _accountB: BigInt.from(200000),
          },
          modelId: '41',
          completedReport: snapshot,
        );

        final restored = Phase6bTestSessionCheckpoint.decode(
          checkpoint.encode(),
        );

        expect(restored.session.isFinished, isTrue);
        expect(restored.completedReport?.toJson(), snapshot.toJson());
        expect(
          jsonEncode(restored.completedReport?.toJson()),
          jsonEncode(snapshot.toJson()),
        );

        final tamperedReport = _mutableJson(_completedReportData(finished));
        (tamperedReport['transactionHashes']! as List)[0] =
            _differentTransactionHash;
        expect(
          () => Phase6bTestSessionCheckpoint(
            savedAt: _startedAt.add(const Duration(minutes: 16)),
            session: finished,
            startingBalances: {
              _accountA: BigInt.from(100000),
              _accountB: BigInt.from(200000),
            },
            latestBalances: {
              _accountA: BigInt.from(98766),
              _accountB: BigInt.from(200000),
            },
            modelId: '41',
            completedReport: Phase6bCompletedReportSnapshot.fromJson(
              tamperedReport,
            ),
          ),
          throwsFormatException,
        );

        expect(
          () => Phase6bTestSessionCheckpoint(
            savedAt: _startedAt.add(const Duration(minutes: 17)),
            session: finished,
            startingBalances: {
              _accountA: BigInt.from(100000),
              _accountB: BigInt.from(200000),
            },
            latestBalances: {
              _accountA: BigInt.from(98766),
              _accountB: BigInt.from(200000),
            },
            modelId: '41',
          ),
          throwsFormatException,
        );

        expect(
          () => Phase6bTestSessionCheckpoint(
            savedAt: _startedAt.add(const Duration(minutes: 4)),
            session: _sessionThroughOnboarding(),
            startingBalances: {
              _accountA: BigInt.from(100000),
              _accountB: BigInt.from(200000),
            },
            latestBalances: {
              _accountA: BigInt.from(98766),
              _accountB: BigInt.from(200000),
            },
            modelId: '41',
            completedReport: snapshot,
          ),
          throwsFormatException,
        );
      },
    );

    test(
      'rejects completed outcomes that conflict with market and claim state',
      () {
        final finished = _completedBlockedSession();
        final report = _mutableJson(_completedReportData(finished))
          ..['predictionId'] = '52'
          ..['marketId'] = '52'
          ..['settlementResult'] = 'Finalized'
          ..['claimResult'] = 'Claimed';

        Phase6bTestSessionCheckpoint checkpointFor(
          Map<String, Object?> reportData,
        ) => Phase6bTestSessionCheckpoint(
          savedAt: _startedAt.add(const Duration(minutes: 17)),
          session: finished,
          startingBalances: {
            _accountA: BigInt.from(100000),
            _accountB: BigInt.from(200000),
          },
          latestBalances: {
            _accountA: BigInt.from(98766),
            _accountB: BigInt.from(200000),
          },
          modelId: '41',
          predictionId: '52',
          marketId: '52',
          latestMarket: Phase6bPersistedMarketEvidence.fromJson(
            _marketEvidence(),
          ),
          claimPosition: Phase6bPersistedPositionEvidence.fromJson(
            _positionEvidence(),
          ),
          completedReport: Phase6bCompletedReportSnapshot.fromJson(reportData),
        );

        expect(
          Phase6bTestSessionCheckpoint.decode(
            checkpointFor(report).encode(),
          ).completedReport,
          isNotNull,
        );

        for (final tamper in const {
          'settlementResult': 'Proposed',
          'claimResult': 'Not completed',
          'postStateVerification':
              'All recorded stages have canonical/local export verification.',
        }.entries) {
          final tampered = _mutableJson(report)..[tamper.key] = tamper.value;
          expect(() => checkpointFor(tampered), throwsFormatException);
        }
      },
    );

    test('rejects finishing an incomplete session', () {
      expect(
        () => _sessionThroughOnboarding().finish(
          _startedAt.add(const Duration(minutes: 5)),
        ),
        throwsStateError,
      );
    });
  });
}

Phase6bTestSession _sessionThroughOnboarding() {
  return Phase6bTestSession(
      sessionId: 'session-codec',
      startedAt: _startedAt,
      participatingPublicAddresses: const [_accountA, _accountB],
    )
    ..recordStage(_readOnlyStage(Phase6bTestStage.selectTestAccounts))
    ..recordStage(_readOnlyStage(Phase6bTestStage.verifyBalancesAndRuntime))
    ..recordStage(_transactionStage(Phase6bTestStage.onboardModel));
}

Phase6bTestSession _completedBlockedSession() {
  final session = _sessionThroughOnboarding();
  while (session.nextStage != null) {
    final stage = session.nextStage!;
    session.recordStage(
      Phase6bStageRecord(
        stage: stage,
        prerequisiteChecks: [
          Phase6bPrerequisiteCheck(
            name: 'Earlier controlled-session stage',
            passed: false,
            evidence: 'Fixture closes all remaining stages as BLOCKED.',
          ),
        ],
        exactCall: 'Wallet.blocked.${stage.name}',
        confirmation: Phase6bActionConfirmation.notRequired(),
        chainStateVerification: Phase6bChainStateVerification.notPerformed(
          summary: 'Not performed in the completed blocked fixture.',
        ),
        outcome: Phase6bTestOutcome.blocked,
        completedAt: _startedAt.add(
          Duration(minutes: Phase6bTestLifecycle.definitionFor(stage).number),
        ),
      ),
    );
  }
  session.finish(_startedAt.add(const Duration(minutes: 16)));
  return session;
}

Phase6bStageRecord _readOnlyStage(Phase6bTestStage stage) {
  return Phase6bStageRecord(
    stage: stage,
    prerequisiteChecks: [
      Phase6bPrerequisiteCheck(
        name: 'Canonical prerequisite',
        passed: true,
        evidence: 'Verified from public chain state.',
      ),
    ],
    exactCall: 'Wallet.${stage.name}',
    confirmation: Phase6bActionConfirmation.notRequired(),
    chainStateVerification: Phase6bChainStateVerification(
      verified: true,
      summary: 'Canonical state verified.',
      evidence: const {'block': 98},
    ),
    outcome: Phase6bTestOutcome.pass,
    completedAt: _startedAt.add(
      Duration(minutes: Phase6bTestLifecycle.definitionFor(stage).number),
    ),
  );
}

Phase6bStageRecord _transactionStage(Phase6bTestStage stage) {
  final at = _startedAt.add(const Duration(minutes: 3));
  return Phase6bStageRecord(
    stage: stage,
    prerequisiteChecks: [
      Phase6bPrerequisiteCheck(
        name: 'Previous stage',
        passed: true,
        evidence: 'PASS',
      ),
    ],
    exactCall: 'AiPredictions.register_model',
    publicSigner: _accountA,
    feeEstimate: Phase6bFeeEstimate(baseUnits: BigInt.from(1234)),
    confirmation: Phase6bActionConfirmation(
      confirmed: true,
      statement: 'REGISTER MODEL',
      confirmedByPublicAddress: _accountA,
      confirmedAt: at,
    ),
    receipt: Phase6bTransactionReceiptRef(
      referenceId: 'receipt-3',
      transactionHash: _transactionHash,
      inclusionBlockNumber: 98,
      inclusionBlockHash: _inclusionHash,
      finalizedBlockNumber: 99,
      finalizedBlockHash: _finalizedHash,
      dispatchResult: 'success',
      relevantEvents: const ['AiPredictions.ModelRegistered'],
      finalized: true,
      succeeded: true,
    ),
    chainStateVerification: Phase6bChainStateVerification(
      verified: true,
      summary: 'Canonical model storage verified.',
      evidence: const {'modelId': '41'},
    ),
    outcome: Phase6bTestOutcome.pass,
    isLiveTransaction: true,
    completedAt: at,
  );
}

Map<String, Object?> _mutableJson(Map<String, Object?> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, Object?>;

Map<String, Object?> _marketEvidence() => {
  'tokenId': '52',
  'predictionId': '52',
  'owner': _accountA,
  'metadataReference': 'ipfs://public-market-metadata',
  'createdAt': 100,
  'transferable': true,
  'frozen': false,
  'burned': false,
  'locked': false,
  'yesTotal': '10',
  'noTotal': '11',
  'settlementStatus': 'Finalized',
  'proposedOutcome': 'Correct',
  'finalOutcome': 'Correct',
  'disputeUntil': 120,
  'totalStakeAtFinalization': '21',
  'feesCollected': '1',
  'remaindersCollected': '0',
  'totalPaid': '20',
  'totalRefunded': '0',
  'totalSlashed': '0',
  'provenance': 'canonicalStorage',
};

Map<String, Object?> _positionEvidence() => {
  'tokenId': '52',
  'predictionId': '52',
  'account': _accountA,
  'side': 'Yes',
  'amount': '10',
  'stakedAt': 101,
  'updatedAt': 121,
  'claimed': true,
  'stakeReturned': '10',
  'rewardPaid': '9',
  'slashed': '0',
  'provenance': 'canonicalStorage',
};

Map<String, Object?> _completedReportData(Phase6bTestSession session) => {
  'walletAppVersion': '1.0.0+1',
  'platform': 'windows',
  'endpoint': 'wss://eraprojects.org/',
  'genesisHash': '0xgenesis',
  'runtimeSpecName': 'era',
  'runtimeSpecVersion': 9,
  'transactionVersion': 1,
  'metadataVersion': 14,
  'metadataFingerprint': 'sha256:public-metadata',
  'runtimeWasmHash': null,
  'aiStorageVersion': 4,
  'aiPalletIndex': 12,
  'testSessionId': session.sessionId,
  'startTimestamp': session.startedAt.toUtc().toIso8601String(),
  'endTimestamp': session.endedAt!.toUtc().toIso8601String(),
  'participatingPublicAddresses': session.participatingPublicAddresses,
  'modelId': '41',
  'predictionId': null,
  'marketId': null,
  'callNames': const ['AiPredictions.register_model'],
  'transactionHashes': const [_transactionHash],
  'inclusionBlocks': const [
    {
      'callName': 'AiPredictions.register_model',
      'transactionHash': _transactionHash,
      'blockNumber': 98,
      'blockHash': _inclusionHash,
    },
  ],
  'finalityBlocks': const [
    {
      'callName': 'AiPredictions.register_model',
      'transactionHash': _transactionHash,
      'blockNumber': 99,
      'blockHash': _finalizedHash,
    },
  ],
  'dispatchResults': const [
    {
      'callName': 'AiPredictions.register_model',
      'transactionHash': _transactionHash,
      'dispatchResult': 'success',
    },
  ],
  'relevantEvents': const [
    {
      'callName': 'AiPredictions.register_model',
      'transactionHash': _transactionHash,
      'event': 'AiPredictions.ModelRegistered',
    },
  ],
  'balancesBeforeAfter': const [
    {
      'publicAddress': _accountA,
      'tokenSymbol': 'ETKN',
      'beforeBaseUnits': '100000',
      'afterBaseUnits': '98766',
      'deltaBaseUnits': '-1234',
    },
    {
      'publicAddress': _accountB,
      'tokenSymbol': 'ETKN',
      'beforeBaseUnits': '200000',
      'afterBaseUnits': '200000',
      'deltaBaseUnits': '0',
    },
  ],
  'yesNoTotalsBeforeAfter': null,
  'treasuryAndFeeObservations': const [],
  'settlementResult': 'Not completed',
  'claimResult': 'Not completed',
  'postStateVerification': 'Session has incomplete post-state verification.',
  'warnings': const ['No private material is included.'],
  'overallResult': 'BLOCKED',
  'batchAutomationAllowed': false,
  'stages': session.records.map((record) => record.toJson()).toList(),
  'additionalEvidence': const {'historyComplete': false},
};
