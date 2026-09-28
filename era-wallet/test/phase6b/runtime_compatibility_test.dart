import 'package:era_wallet/phase6b/runtime_compatibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = Phase6bRuntimeCompatibility();

  group('approved spec-13 fingerprint', () {
    test('pins the complete discovered call and storage surface', () {
      final fingerprint = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final pallet = fingerprint.aiPredictionsPallet!;

      expect(fingerprint.specName, 'era');
      expect(fingerprint.specVersion, 13);
      expect(fingerprint.transactionVersion, 1);
      expect(fingerprint.metadataVersion, 14);
      expect(fingerprint.aiPredictionsStorageVersion, 3);
      expect(pallet.name, 'AiPredictions');
      expect(pallet.index, 12);
      expect(pallet.calls, hasLength(40));
      expect(
        pallet.calls.values.map((call) => call.index).toList()..sort(),
        List<int>.generate(40, (index) => index),
      );
      expect(pallet.storage, hasLength(32));

      final stake = pallet.calls['stake_on_prediction_outcome_side']!;
      expect(stake.index, 31);
      expect(stake.arguments.map((argument) => argument.name), [
        'token_id',
        'side',
        'amount',
      ]);
      expect(stake.arguments[0].type.metadataTypeName, 'PredictionTokenId');
      expect(stake.arguments[0].type.resolvedScaleType, 'u64');
      expect(stake.arguments[2].type.metadataTypeName, 'BalanceOf<T>');
      expect(stake.arguments[2].type.resolvedScaleType, 'u128');
    });

    test('ordinary builds expose participant mode only', () {
      final result = policy.assess(
        Phase6bRuntimeCompatibility.approvedSpec9Fingerprint,
        flags: const Phase6bBuildFlags(
          testingToolsEnabled: false,
          governanceActionsEnabled: false,
        ),
      );

      expect(result.level, Phase6bCapabilityLevel.phase6bParticipant);
      expect(result.metadataCompatible, isTrue);
      expect(result.metadataDriftDetected, isFalse);
      expect(result.participantSigningEnabled, isTrue);
      expect(result.signingEnabled, isTrue);
      expect(result.testingToolsEnabled, isFalse);
      expect(result.governanceActionsEnabled, isFalse);
      expect(result.issues, isEmpty);
    });

    test('operator mode requires both build flags', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;

      final testingOnly = policy.assess(
        approved,
        flags: const Phase6bBuildFlags(
          testingToolsEnabled: true,
          governanceActionsEnabled: false,
        ),
      );
      final governanceOnly = policy.assess(
        approved,
        flags: const Phase6bBuildFlags(
          testingToolsEnabled: false,
          governanceActionsEnabled: true,
        ),
      );
      final both = policy.assess(
        approved,
        flags: const Phase6bBuildFlags(
          testingToolsEnabled: true,
          governanceActionsEnabled: true,
        ),
      );

      expect(testingOnly.level, Phase6bCapabilityLevel.phase6bParticipant);
      expect(testingOnly.testingToolsEnabled, isTrue);
      expect(testingOnly.governanceActionsEnabled, isFalse);
      expect(governanceOnly.level, Phase6bCapabilityLevel.phase6bParticipant);
      expect(governanceOnly.testingToolsEnabled, isFalse);
      expect(governanceOnly.governanceActionsEnabled, isFalse);
      expect(governanceOnly.warnings.single, contains('is ignored'));
      expect(both.level, Phase6bCapabilityLevel.phase6bOperator);
      expect(both.operatorMode, isTrue);
      expect(both.governanceActionsEnabled, isTrue);
    });

    test('normalizes hash prefix and case without weakening comparison', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final observed = approved.copyWith(
        genesisHash: approved.genesisHash.toUpperCase(),
        metadataHash: '0x${approved.metadataHash.toUpperCase()}',
        runtimeWasmHash: '0x${approved.runtimeWasmHash.toUpperCase()}',
      );

      expect(policy.assess(observed).metadataCompatible, isTrue);
    });
  });

  group('fail-closed spec-13 drift handling', () {
    test('wrong genesis disables spec-13 signing', () {
      final observed = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint
          .copyWith(genesisHash: '0x${List.filled(32, '00').join()}');

      final result = policy.assess(observed);

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.signingEnabled, isFalse);
      expect(_issueCodes(result), contains('genesis_hash_mismatch'));
    });

    test('missing pallet disables all signing', () {
      final observed = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint
          .copyWith(aiPredictionsPallet: null);

      final result = policy.assess(
        observed,
        flags: const Phase6bBuildFlags(
          testingToolsEnabled: true,
          governanceActionsEnabled: true,
        ),
      );

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.signingEnabled, isFalse);
      expect(result.governanceActionsEnabled, isFalse);
      expect(_issueCodes(result), contains('ai_pallet_missing'));
      expect(result.explanation, contains('AiPredictions'));
    });

    test('metadata, runtime code, and storage drift are explained', () {
      final observed = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint
          .copyWith(
            metadataHash: '00',
            runtimeWasmHash: '11',
            aiPredictionsStorageVersion: 4,
          );

      final result = policy.assess(observed);

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.metadataDriftDetected, isTrue);
      expect(result.metadataCompatible, isFalse);
      expect(result.signingEnabled, isFalse);
      expect(_issueCodes(result), contains('metadata_hash_mismatch'));
      expect(_issueCodes(result), contains('runtime_wasm_hash_mismatch'));
      expect(_issueCodes(result), contains('ai_storage_version_mismatch'));
      expect(result.explanation, contains('pinned spec-13 binding'));
      expect(result.explanation, contains('storage version changed'));
    });

    test('pallet index drift disables signing', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final observed = approved.copyWith(
        aiPredictionsPallet: approved.aiPredictionsPallet!.copyWith(index: 13),
      );

      final result = policy.assess(observed);

      expect(result.signingEnabled, isFalse);
      expect(_issueCodes(result), contains('ai_pallet_index_mismatch'));
      expect(result.explanation, contains('Expected: 12'));
      expect(result.explanation, contains('Observed: 13'));
    });

    test('missing late governance call cannot be elevated by flags', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final calls = Map<String, RuntimeCallSignature>.of(
        approved.aiPredictionsPallet!.calls,
      )..remove('approve_model');
      final observed = approved.copyWith(
        aiPredictionsPallet: approved.aiPredictionsPallet!.copyWith(
          calls: calls,
        ),
      );

      final result = policy.assess(
        observed,
        flags: const Phase6bBuildFlags(
          testingToolsEnabled: true,
          governanceActionsEnabled: true,
        ),
      );

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.signingEnabled, isFalse);
      expect(result.testingToolsEnabled, isFalse);
      expect(result.governanceActionsEnabled, isFalse);
      expect(_issueCodes(result), contains('missing_call_approve_model'));
    });

    test('changed call index is incompatible even when the name remains', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final pallet = approved.aiPredictionsPallet!;
      final calls = Map<String, RuntimeCallSignature>.of(pallet.calls);
      calls['claim_prediction_market_payout'] =
          calls['claim_prediction_market_payout']!.copyWith(index: 34);

      final result = policy.assess(
        approved.copyWith(aiPredictionsPallet: pallet.copyWith(calls: calls)),
      );

      expect(result.signingEnabled, isFalse);
      expect(
        _issueCodes(result),
        contains('call_index_claim_prediction_market_payout'),
      );
    });

    test('changed call type or argument order is incompatible', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final pallet = approved.aiPredictionsPallet!;
      final calls = Map<String, RuntimeCallSignature>.of(pallet.calls);
      final stake = calls['stake_on_prediction_outcome_side']!;
      final arguments = List<RuntimeCallArgumentSignature>.of(stake.arguments);
      arguments[2] = arguments[2].copyWith(
        type: arguments[2].type.copyWith(resolvedScaleType: 'u64'),
      );
      calls[stake.name] = stake.copyWith(arguments: arguments);

      final result = policy.assess(
        approved.copyWith(aiPredictionsPallet: pallet.copyWith(calls: calls)),
      );

      expect(result.signingEnabled, isFalse);
      expect(
        _issueCodes(result),
        contains('call_signature_stake_on_prediction_outcome_side'),
      );
      expect(result.explanation, contains('u128'));
      expect(result.explanation, contains('u64'));
    });

    test('portable type-ID drift is incompatible for the pinned metadata', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final pallet = approved.aiPredictionsPallet!;
      final calls = Map<String, RuntimeCallSignature>.of(pallet.calls);
      final approve = calls['approve_model']!;
      calls[approve.name] = approve.copyWith(
        arguments: [
          approve.arguments.single.copyWith(
            type: approve.arguments.single.type.copyWith(portableTypeId: 999),
          ),
        ],
      );

      final result = policy.assess(
        approved.copyWith(aiPredictionsPallet: pallet.copyWith(calls: calls)),
      );

      expect(result.signingEnabled, isFalse);
      expect(_issueCodes(result), contains('call_signature_approve_model'));
      expect(result.explanation, contains('type 12'));
      expect(result.explanation, contains('type 999'));
    });

    test('storage key/value shape drift disables signing', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final pallet = approved.aiPredictionsPallet!;
      final storage = Map<String, RuntimeStorageSignature>.of(pallet.storage);
      final totals = storage['PredictionTokenSideTotals']!;
      storage[totals.name] = totals.copyWith(
        valueType: totals.valueType.copyWith(resolvedScaleType: 'u64'),
      );

      final result = policy.assess(
        approved.copyWith(
          aiPredictionsPallet: pallet.copyWith(storage: storage),
        ),
      );

      expect(result.signingEnabled, isFalse);
      expect(
        _issueCodes(result),
        contains('storage_signature_PredictionTokenSideTotals'),
      );
      expect(result.explanation, contains('(u64, PredictionOutcomeSide)'));
      expect(result.explanation, contains('u128'));
    });

    test('a newer spec version remains unavailable until reviewed', () {
      final observed = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint
          .copyWith(specVersion: 14);

      final result = policy.assess(observed);

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.metadataDriftDetected, isTrue);
      expect(result.signingEnabled, isFalse);
      expect(_issueCodes(result), contains('spec_version_unsupported'));
      expect(result.explanation, contains('newer than the reviewed'));
    });
  });

  group('legacy Phase 6A structural mode', () {
    test('wrong genesis disables otherwise compatible spec-8 signing', () {
      final observed = _compatibleSpec8Fingerprint().copyWith(
        genesisHash: '0x${List.filled(32, 'ff').join()}',
      );

      final result = policy.assess(observed);

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.signingEnabled, isFalse);
      expect(_issueCodes(result), contains('genesis_hash_mismatch'));
    });

    test(
      'recognizes exact preserved participant calls without operator mode',
      () {
        final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
        final phase6aPallet = RuntimePalletFingerprint.fromSignatures(
          name: 'AiPredictions',
          index: 12,
          storagePrefix: 'AiPredictions',
          calls: Phase6bRuntimeCompatibility.phase6aParticipantCalls,
          storage: Phase6bRuntimeCompatibility.phase6aParticipantStorage,
        );
        final observed = approved.copyWith(
          specVersion: 8,
          metadataHash: 'legacy-spec-8-fingerprint',
          aiPredictionsStorageVersion: 2,
          aiPredictionsPallet: phase6aPallet,
        );

        final result = policy.assess(
          observed,
          flags: const Phase6bBuildFlags(
            testingToolsEnabled: true,
            governanceActionsEnabled: true,
          ),
        );

        expect(result.level, Phase6bCapabilityLevel.phase6aParticipant);
        expect(result.metadataCompatible, isTrue);
        expect(result.participantSigningEnabled, isFalse);
        expect(result.testingToolsEnabled, isFalse);
        expect(result.governanceActionsEnabled, isFalse);
        expect(result.warnings, hasLength(2));
        expect(result.explanation, contains('Signing remains disabled'));
      },
    );

    test('requires exact legacy participant call signatures', () {
      final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
      final calls = {
        for (final call in Phase6bRuntimeCompatibility.phase6aParticipantCalls)
          call.name: call,
      }..remove('unstake_from_prediction_outcome_side');
      final phase6aPallet = RuntimePalletFingerprint(
        name: 'AiPredictions',
        index: 12,
        storagePrefix: 'AiPredictions',
        calls: calls,
        storage: {
          for (final item
              in Phase6bRuntimeCompatibility.phase6aParticipantStorage)
            item.name: item,
        },
      );

      final result = policy.assess(
        approved.copyWith(
          specVersion: 8,
          metadataHash: 'legacy-spec-8-fingerprint',
          aiPredictionsStorageVersion: 2,
          aiPredictionsPallet: phase6aPallet,
        ),
      );

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.signingEnabled, isFalse);
      expect(
        _issueCodes(result),
        contains('missing_call_unstake_from_prediction_outcome_side'),
      );
    });

    test('rejects drift in a preserved legacy storage signature', () {
      final observed = _compatibleSpec8Fingerprint();
      final pallet = observed.aiPredictionsPallet!;
      final storage = Map<String, RuntimeStorageSignature>.of(pallet.storage);
      final totals = storage['PredictionTokenSideTotals']!;
      storage[totals.name] = totals.copyWith(
        hashers: const ['Identity', 'Blake2_128Concat'],
      );

      final result = policy.assess(
        observed.copyWith(
          aiPredictionsPallet: pallet.copyWith(storage: storage),
        ),
      );

      expect(result.level, Phase6bCapabilityLevel.unavailable);
      expect(result.signingEnabled, isFalse);
      expect(
        _issueCodes(result),
        contains('storage_signature_PredictionTokenSideTotals'),
      );
    });
  });
}

Set<String> _issueCodes(RuntimeCompatibilityResult result) =>
    result.issues.map((issue) => issue.code).toSet();

EraRuntimeFingerprint _compatibleSpec8Fingerprint() {
  final approved = Phase6bRuntimeCompatibility.approvedSpec9Fingerprint;
  return approved.copyWith(
    specVersion: 8,
    metadataHash: 'legacy-spec-8-fingerprint',
    aiPredictionsStorageVersion: 2,
    aiPredictionsPallet: RuntimePalletFingerprint.fromSignatures(
      name: 'AiPredictions',
      index: 12,
      storagePrefix: 'AiPredictions',
      calls: Phase6bRuntimeCompatibility.phase6aParticipantCalls,
      storage: Phase6bRuntimeCompatibility.phase6aParticipantStorage,
    ),
  );
}
