import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart';

import 'package:era_wallet/generated/era/era.dart';
import 'package:era_wallet/generated/era/types/pallet_ai_predictions/prediction_domain.dart';
import 'package:era_wallet/generated/era/types/pallet_ai_predictions/prediction_outcome.dart';
import 'package:era_wallet/generated/era/types/pallet_ai_predictions/prediction_outcome_side.dart';
import 'package:era_wallet/phase6b/phase6b_actions.dart';
import 'package:era_wallet/phase6b/phase6b_data.dart';

void main() {
  late Phase6bCallFactory factory;

  setUp(() {
    factory = Phase6bCallFactory(Era(_NoopProvider()));
  });

  test('uses generated spec-13 pallet and exact call indices', () {
    final calls = [
      factory.registerModel(modelHash: [1], metadataUri: [2]),
      factory.submitPrediction(
        modelId: BigInt.one,
        domain: PredictionDomain.weatherClimate,
        categoryCode: [3],
        predictionHash: [4],
        metadataUri: [5],
        confidence: 80,
        expiresAt: 100,
      ),
      factory.stake(
        tokenId: BigInt.two,
        side: PredictionOutcomeSide.yes,
        amount: BigInt.from(10),
      ),
      factory.approveModel(BigInt.one),
      factory.setModelSubmitter(modelId: BigInt.one, submitter: null),
    ];

    expect(calls.map((call) => call.encodedCall[0]).toSet(), {12});
    expect(calls.map((call) => call.encodedCall[1]).toList(), [
      0,
      2,
      31,
      36,
      39,
    ]);
  });

  test('governance actions require both flags', () {
    final intent = factory.approveModel(BigInt.one);
    final disabled = Phase6bActionPolicy.assess(
      intent: intent,
      runtimeCompatible: true,
      testingToolsEnabled: true,
      governanceActionsEnabled: false,
      accountSelected: true,
    );
    final enabled = Phase6bActionPolicy.assess(
      intent: intent,
      runtimeCompatible: true,
      testingToolsEnabled: true,
      governanceActionsEnabled: true,
      accountSelected: true,
    );

    expect(disabled.visible, isFalse);
    expect(enabled.visible, isTrue);
    expect(enabled.enabled, isTrue);
    expect(enabled.originEligibilityIsInformational, isTrue);
    expect(intent.typedConfirmation, contains('live model governance'));
  });

  test('runtime drift disables participant signing too', () {
    final intent = factory.claim(BigInt.one);
    final result = Phase6bActionPolicy.assess(
      intent: intent,
      runtimeCompatible: false,
      testingToolsEnabled: false,
      governanceActionsEnabled: false,
      accountSelected: true,
    );

    expect(result.visible, isTrue);
    expect(result.enabled, isFalse);
    expect(result.reasons.single, contains('approved bindings'));
  });

  test('fresh preflight enforces registration and validator configuration', () {
    final registration = factory.registerModel(
      modelHash: [1],
      metadataUri: [2],
    );
    expect(
      Phase6bActionPreflight.blockingReason(
        intent: registration,
        configuration: _configuration(publicRegistration: false),
        signer: 'validator',
      ),
      contains('public signed'),
    );

    final validation = factory.validatePrediction(
      predictionId: BigInt.one,
      outcome: PredictionOutcome.successful,
    );
    expect(
      Phase6bActionPreflight.blockingReason(
        intent: validation,
        configuration: _configuration(authorizedValidator: false),
        signer: 'validator',
        prediction: _prediction(),
        currentFinalizedBlock: 100,
      ),
      contains('AuthorizedValidators'),
    );
    expect(
      Phase6bActionPreflight.blockingReason(
        intent: validation,
        configuration: _configuration(authorizedValidator: true),
        signer: 'validator',
        prediction: _prediction(),
        currentFinalizedBlock: 100,
      ),
      isNull,
    );
  });

  test('position pages advance by scanned token ids, not sparse results', () {
    const page = Phase6bPage<Phase6bPosition>(
      items: [],
      offset: 25,
      limit: 25,
      totalAvailable: 30,
      scannedCount: 5,
    );

    expect(page.coveredCount, 5);
    expect(page.hasMore, isFalse);
  });
}

Phase6bChainConfiguration _configuration({
  bool publicRegistration = true,
  bool authorizedValidator = true,
}) => Phase6bChainConfiguration(
  modelRegistrationEnabled: true,
  predictionSubmissionEnabled: true,
  marketCreationEnabled: true,
  publicModelRegistrationEnabled: publicRegistration,
  requireModelApproval: true,
  maxActivePredictionsPerModel: 32,
  tokenizationEnabled: true,
  transfersEnabled: false,
  stakingEnabled: true,
  minimumStake: BigInt.one,
  settlementEnabled: true,
  disputeWindowBlocks: 10,
  minimumDisputeBond: BigInt.one,
  settlementEconomicsEnabled: true,
  marketEnabled: true,
  allowUnstakeBeforeSettlement: true,
  feesEnabled: false,
  feeBps: 0,
  treasuryEnabled: true,
  authorizedValidatorAddress: 'validator',
  signerIsAuthorizedValidator: authorizedValidator,
);

Phase6bPrediction _prediction() => Phase6bPrediction(
  id: BigInt.one,
  modelId: BigInt.one,
  submitter: 'owner',
  domain: 'WeatherClimate',
  categoryCode: 'WEATHER',
  predictionHashHex: '0x01',
  metadataReference: 'ipfs://prediction',
  metadataUriBytes: const [1],
  confidence: 90,
  createdAt: 90,
  expiresAt: 110,
  status: 'Open',
  outcome: null,
  validator: null,
  validatedAt: null,
  tokenId: null,
);

class _NoopProvider extends Provider {
  @override
  Future connect() async {}

  @override
  Future disconnect() async {}

  @override
  bool isConnected() => true;

  @override
  Future<RpcResponse> send(String method, List<dynamic> params) =>
      throw UnimplementedError();

  @override
  Future<SubscriptionResponse> subscribe(
    String method,
    List<dynamic> params, {
    FutureOr<void> Function(String subscription)? onCancel,
  }) => throw UnimplementedError();
}
