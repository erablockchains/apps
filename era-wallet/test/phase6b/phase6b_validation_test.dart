import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:era_wallet/era_chain.dart' show kEraUnit;
import 'package:era_wallet/phase6b/phase6b_validation.dart';

void main() {
  group('model onboarding validation', () {
    test('accepts values at the runtime bounds', () {
      final input = ModelRegistrationInput(
        modelHash: List.filled(ModelRegistrationInput.maxHashBytes, 1),
        metadataUri: List.filled(ModelRegistrationInput.maxMetadataUriBytes, 2),
      );

      expect(input.validate, returnsNormally);
      expect(input.preview()['model_hash_bytes'], 128);
    });

    test('rejects an oversized SCALE input before encoding', () {
      final input = ModelRegistrationInput(
        modelHash: List.filled(ModelRegistrationInput.maxHashBytes + 1, 1),
        metadataUri: utf8.encode('ipfs://model'),
      );

      expect(input.validate, throwsA(isA<Phase6bValidationException>()));
    });
  });

  group('prediction creation validation', () {
    PredictionSubmissionInput valid() => PredictionSubmissionInput(
      modelId: BigInt.one,
      modelStatus: 'Approved',
      modelActive: true,
      signerAuthorized: true,
      categoryCode: utf8.encode('WEATHER'),
      predictionHash: List.filled(32, 7),
      metadataUri: utf8.encode('ipfs://prediction'),
      confidence: 90,
      expiresAt: 110,
      currentFinalizedBlock: 100,
    );

    test('accepts an approved model and future expiry', () {
      expect(valid().validate, returnsNormally);
    });

    test('accepts an active pending model when approval is not required', () {
      final input = PredictionSubmissionInput(
        modelId: valid().modelId,
        modelStatus: 'Pending',
        modelActive: true,
        signerAuthorized: true,
        requireModelApproval: false,
        categoryCode: valid().categoryCode,
        predictionHash: valid().predictionHash,
        metadataUri: valid().metadataUri,
        confidence: valid().confidence,
        expiresAt: valid().expiresAt,
        currentFinalizedBlock: valid().currentFinalizedBlock,
      );

      expect(input.validate, returnsNormally);
    });

    test('rejects suspended and unauthorized models', () {
      final suspended = PredictionSubmissionInput(
        modelId: BigInt.one,
        modelStatus: 'Suspended',
        modelActive: false,
        signerAuthorized: true,
        categoryCode: utf8.encode('A'),
        predictionHash: [1],
        metadataUri: utf8.encode('x'),
        confidence: 50,
        expiresAt: 110,
        currentFinalizedBlock: 100,
      );
      expect(suspended.validate, throwsA(isA<Phase6bValidationException>()));

      final unauthorized = PredictionSubmissionInput(
        modelId: valid().modelId,
        modelStatus: valid().modelStatus,
        modelActive: valid().modelActive,
        signerAuthorized: false,
        categoryCode: valid().categoryCode,
        predictionHash: valid().predictionHash,
        metadataUri: valid().metadataUri,
        confidence: valid().confidence,
        expiresAt: valid().expiresAt,
        currentFinalizedBlock: valid().currentFinalizedBlock,
      );
      expect(unauthorized.validate, throwsA(isA<Phase6bValidationException>()));
    });

    test('rejects expiry values above the runtime u32 bound', () {
      final input = PredictionSubmissionInput(
        modelId: valid().modelId,
        modelStatus: valid().modelStatus,
        modelActive: valid().modelActive,
        signerAuthorized: valid().signerAuthorized,
        categoryCode: valid().categoryCode,
        predictionHash: valid().predictionHash,
        metadataUri: valid().metadataUri,
        confidence: valid().confidence,
        expiresAt: PredictionSubmissionInput.maxExpiryBlock + 1,
        currentFinalizedBlock: valid().currentFinalizedBlock,
      );

      expect(input.validate, throwsA(isA<Phase6bValidationException>()));
    });
  });

  group('public on-chain input safety', () {
    test('rejects sensitive labels and mnemonic-shaped evidence', () {
      expect(
        () => Phase6bPublicInputSafety.validateEvidenceReference(
          utf8.encode('seed phrase: do not publish this'),
        ),
        throwsA(isA<Phase6bValidationException>()),
      );
      expect(
        () => Phase6bPublicInputSafety.validateEvidenceReference(
          utf8.encode(
            'alpha bravo charlie delta echo foxtrot golf hotel india juliet '
            'kilo lima',
          ),
        ),
        throwsA(isA<Phase6bValidationException>()),
      );
    });

    test('rejects API credentials and credential-bearing endpoints', () {
      for (final value in [
        'api_key=fixture-secret',
        'wss://user:fixture-secret@example.invalid/rpc',
        'https://example.invalid/model?access_token=fixture-secret',
      ]) {
        expect(
          () => Phase6bPublicInputSafety.validateEvidenceReference(
            utf8.encode(value),
          ),
          throwsA(isA<Phase6bValidationException>()),
        );
      }
    });

    test('accepts an ordinary public evidence reference', () {
      expect(
        () => Phase6bPublicInputSafety.validateEvidenceReference(
          utf8.encode('ipfs://bafy-public-evidence'),
        ),
        returnsNormally,
      );
    });
  });

  group('ETKN amount handling', () {
    test('parses exactly 18 decimals', () {
      expect(
        Phase6bAmount.parseStrict('1.000000000000000001'),
        kEraUnit + BigInt.one,
      );
    });

    test('rejects rather than truncating excess decimals', () {
      expect(
        () => Phase6bAmount.parseStrict('0.0000000000000000001'),
        throwsA(isA<Phase6bValidationException>()),
      );
    });

    test('checks fee and reserve before staking', () {
      expect(
        () => Phase6bAmount.validateStake(
          amount: BigInt.from(90),
          minimumStake: BigInt.one,
          freeBalance: BigInt.from(100),
          estimatedFee: BigInt.from(9),
          existentialReserve: BigInt.from(2),
        ),
        throwsA(isA<Phase6bValidationException>()),
      );
    });
  });

  test('payout view never promotes a local estimate to canonical', () {
    final payout = Phase6bPayoutPresentation(
      userWinningStake: BigInt.from(25),
      totalWinningStake: BigInt.from(100),
      payoutPool: BigInt.from(1000),
      chainClaimableAmount: null,
      alreadyClaimed: false,
    );

    expect(payout.nonAuthoritativeEstimate, BigInt.from(250));
    expect(payout.displayedClaimable, isNull);
    expect(payout.qualification, 'Estimate only');
  });
}
