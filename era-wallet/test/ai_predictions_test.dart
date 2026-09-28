import 'package:era_wallet/ai_predictions.dart';
import 'package:era_wallet/era_chain.dart';
import 'package:era_wallet/phase6b/runtime_compatibility.dart';
import 'package:era_wallet/transfer_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AI prediction amount formatting', () {
    test('uses ETKN base units', () {
      expect(AiPredictionAmountFormatter.parse('1'), kEraUnit);
      expect(AiPredictionAmountFormatter.format(kEraUnit), '1');
    });
  });

  group('ERA chain display name', () {
    test('preserves the authoritative ERA-MAINNET live chain name', () {
      final liveChainName = String.fromCharCodes(const [
        69,
        82,
        65,
        45,
        77,
        65,
        73,
        78,
        78,
        69,
        84,
      ]);
      expect(eraWalletChainDisplayName(liveChainName), 'ERA-MAINNET');
      expect(eraWalletChainDisplayName('ERA'), 'ERA');
    });
  });

  group('legacy AI prediction runtime safety', () {
    EraRuntimeCapabilities capabilities(int specVersion) =>
        EraRuntimeCapabilities(
          endpoint: 'ws://127.0.0.1:9944',
          chainName: 'ERA-MAINNET',
          specName: Phase6bRuntimeCompatibility.approvedSpecName,
          specVersion: specVersion,
          aiPredictionsAvailable: true,
          sideMarketsAvailable: true,
          settlementAvailable: true,
          marketFeesAvailable: true,
          metadataRefreshedAt: DateTime.utc(2026, 7, 17),
          aiPallet: null,
        );

    test('navigation accepts only reviewed participant runtime versions', () {
      expect(capabilities(8).runtimeReady, isFalse);
      expect(
        capabilities(
          Phase6bRuntimeCompatibility.approvedSpecVersion,
        ).runtimeReady,
        isTrue,
      );
      expect(capabilities(7).runtimeReady, isFalse);
      expect(capabilities(10).runtimeReady, isFalse);
    });

    test('signing guard rejects a fail-closed compatibility result', () {
      final compatibility = RuntimeCompatibilityResult(
        level: Phase6bCapabilityLevel.unavailable,
        metadataCompatible: false,
        metadataDriftDetected: true,
        participantSigningEnabled: false,
        testingToolsEnabled: false,
        governanceActionsEnabled: false,
        issues: const [
          RuntimeCompatibilityIssue(
            kind: RuntimeCompatibilityIssueKind.runtimeIdentity,
            code: 'runtime_wasm_hash_mismatch',
            message: 'Runtime executable code differs.',
          ),
        ],
        warnings: const [],
      );

      expect(
        () => AiPredictionRuntimeSigningGuard.requireParticipantSigningEnabled(
          compatibility,
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('runtime_wasm_hash_mismatch'),
          ),
        ),
      );
      expect(
        AiPredictionErrorMapper.map(
          StateError('AI Prediction signing blocked'),
        ),
        contains('reviewed compatibility checks'),
      );
    });

    test('signing guard accepts participant signing only when enabled', () {
      final compatibility = RuntimeCompatibilityResult(
        level: Phase6bCapabilityLevel.phase6bParticipant,
        metadataCompatible: true,
        metadataDriftDetected: false,
        participantSigningEnabled: true,
        testingToolsEnabled: false,
        governanceActionsEnabled: false,
        issues: const [],
        warnings: const [],
      );

      expect(
        () => AiPredictionRuntimeSigningGuard.requireParticipantSigningEnabled(
          compatibility,
        ),
        returnsNormally,
      );
    });
  });

  group('PredictionOutcomeSide', () {
    test('encodes metadata enum variants by exact runtime name', () {
      final yes = PredictionOutcomeSide.yes.toCallValue(['Yes', 'No']);
      final no = PredictionOutcomeSide.no.toCallValue(['Yes', 'No']);

      expect(yes.key, 'Yes');
      expect(yes.value, isNull);
      expect(no.key, 'No');
      expect(no.value, isNull);
    });
  });

  group('AI prediction error mapping', () {
    test('maps common runtime messages to user-facing text', () {
      expect(
        AiPredictionErrorMapper.map(Exception('InsufficientBalance')),
        contains('Insufficient balance'),
      );
      expect(
        AiPredictionErrorMapper.map(Exception('AlreadyClaimed')),
        contains('already been claimed'),
      );
      expect(
        AiPredictionErrorMapper.map(Exception('BadOrigin')),
        contains('not authorized'),
      );
    });
  });

  group('local AI prediction positions', () {
    test(
      'groups submitted stake and unstake history by prediction and side',
      () {
        final now = DateTime(2026, 7, 2);
        final history = [
          TransferHistoryEntry(
            id: 'stake-yes',
            accountAddress: 'account',
            counterpartyAddress: predictionHistoryRef(
              predictionId: 7,
              side: PredictionOutcomeSide.yes,
            ),
            amount: BigInt.from(10),
            direction: TransferDirection.sent,
            timestamp: now,
            kind: TransferHistoryKind.aiPredictionStake,
          ),
          TransferHistoryEntry(
            id: 'unstake-yes',
            accountAddress: 'account',
            counterpartyAddress: predictionHistoryRef(
              predictionId: 7,
              side: PredictionOutcomeSide.yes,
            ),
            amount: BigInt.from(3),
            direction: TransferDirection.sent,
            timestamp: now,
            kind: TransferHistoryKind.aiPredictionUnstake,
          ),
          TransferHistoryEntry(
            id: 'claim',
            accountAddress: 'account',
            counterpartyAddress: predictionHistoryRef(predictionId: 7),
            amount: BigInt.zero,
            direction: TransferDirection.received,
            timestamp: now,
            kind: TransferHistoryKind.aiPredictionClaim,
          ),
        ];

        final positions = AiPredictionRepository.buildLocalPositions(history);

        expect(positions, hasLength(1));
        expect(positions.single.predictionId, 7);
        expect(positions.single.side, PredictionOutcomeSide.yes);
        expect(positions.single.netAmount, BigInt.from(7));
        expect(positions.single.claimed, isTrue);
      },
    );
  });
}
