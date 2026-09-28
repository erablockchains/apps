import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:polkadart/polkadart.dart';

import 'package:era_wallet/generated/era/era.dart';
import 'package:era_wallet/generated/era/types/pallet_ai_predictions/prediction_domain.dart';
import 'package:era_wallet/generated/era/types/pallet_ai_predictions/prediction_outcome_side.dart';
import 'package:era_wallet/generated/era/types/pallet_ai_predictions/settlement_outcome.dart';
import 'package:era_wallet/phase6b/chain_reconciliation.dart';
import 'package:era_wallet/phase6b/phase6b_actions.dart';
import 'package:era_wallet/phase6b/phase6b_data.dart';
import 'package:era_wallet/phase6b/transaction_lifecycle.dart';

void main() {
  test('mocked Phase 6B lifecycle reaches reconciled finalized claim', () {
    final factory = Phase6bCallFactory(Era(_NoopProvider()));
    final state = _MockPhase6bState();
    final intents = <Phase6bCallIntent>[
      factory.registerModel(modelHash: [1, 2], metadataUri: [3]),
      factory.approveModel(BigInt.zero),
      factory.setModelSubmitter(
        modelId: BigInt.zero,
        submitter: List.filled(32, 4),
      ),
      factory.submitPrediction(
        modelId: BigInt.zero,
        domain: PredictionDomain.weatherClimate,
        categoryCode: [5],
        predictionHash: [6],
        metadataUri: [7],
        confidence: 90,
        expiresAt: 100,
      ),
      factory.tokenizePrediction(
        predictionId: BigInt.zero,
        metadataUri: [8],
        transferable: false,
      ),
      factory.stake(
        tokenId: BigInt.zero,
        side: PredictionOutcomeSide.yes,
        amount: BigInt.from(10),
      ),
      factory.stake(
        tokenId: BigInt.zero,
        side: PredictionOutcomeSide.no,
        amount: BigInt.from(7),
      ),
      factory.closePrediction(BigInt.zero),
      factory.proposeOutcome(
        tokenId: BigInt.zero,
        outcome: SettlementOutcome.correct,
        evidenceUri: [9],
      ),
      factory.finalizeAfterDisputeWindow(BigInt.zero),
      factory.claim(BigInt.zero),
    ];

    final receipts = <TransactionLifecycleRecord>[];
    for (final intent in intents) {
      intent.validateEncoding();
      state.apply(intent);
      receipts.add(_finalizedReceipt(intent));
    }

    expect(intents.map((intent) => intent.callIndex).toList(), [
      0,
      36,
      39,
      2,
      8,
      31,
      31,
      4,
      22,
      25,
      33,
    ]);
    expect(state.modelStatus, 'Approved');
    expect(state.delegated, isTrue);
    expect(state.predictionCreated, isTrue);
    expect(state.marketTokenized, isTrue);
    expect(state.yesTotal, BigInt.from(10));
    expect(state.noTotal, BigInt.from(7));
    expect(state.predictionClosed, isTrue);
    expect(state.settlementFinalized, isTrue);
    expect(state.claimed, isTrue);
    expect(receipts, everyElement(isA<TransactionLifecycleRecord>()));
    expect(receipts.map((receipt) => receipt.state).toSet(), {
      TransactionLifecycleState.succeeded,
    });
    expect(
      receipts.every(
        (receipt) =>
            receipt.finalityBlock != null &&
            receipt.dispatchResult?.status == DispatchResultStatus.success &&
            receipt.postStateVerification.status ==
                PostStateVerificationStatus.confirmed,
      ),
      isTrue,
    );

    const canonicalClaim = Phase6bEvidence(
      value: 'claimed in storage',
      provenance: Phase6bDataProvenance.canonicalStorage,
      complete: true,
    );
    const localClaim = Phase6bEvidence(
      value: 'local optimistic claim',
      provenance: Phase6bDataProvenance.localSupplementary,
      complete: false,
    );
    expect(
      Phase6bEvidenceReconciler.preferCanonical(
        canonical: canonicalClaim,
        local: localClaim,
      )?.value,
      'claimed in storage',
    );
  });
}

TransactionLifecycleRecord _finalizedReceipt(Phase6bCallIntent call) {
  final now = DateTime.utc(2026, 7, 16, 20);
  final intent = TransactionIntent(
    pallet: 'AiPredictions',
    call: call.callName,
    argumentsSummary: call.arguments,
    signer: '5MockPublicAddress',
  );
  final block = BlockReference(number: BigInt.from(42), hash: '0x42');
  var record = TransactionLifecycleRecord.preparing(
    intent: intent,
    createdAt: now,
  );
  record = record
      .transitionTo(TransactionLifecycleState.awaitingAuthentication)
      .transitionTo(TransactionLifecycleState.signing)
      .transitionTo(TransactionLifecycleState.submitting, nonce: BigInt.one)
      .transitionTo(
        TransactionLifecycleState.submitted,
        txHash: '0x${call.callIndex.toRadixString(16).padLeft(64, '0')}',
        submittedAt: now,
      )
      .transitionTo(TransactionLifecycleState.inBlock, inclusionBlock: block)
      .transitionTo(
        TransactionLifecycleState.finalized,
        finalityBlock: block,
        dispatchResult: const TransactionDispatchResult.success(),
        relevantEvents: [
          LifecycleRelevantEvent(
            pallet: 'AiPredictions',
            event: 'Mock${call.callName}',
          ),
          LifecycleRelevantEvent(pallet: 'System', event: 'ExtrinsicSuccess'),
        ],
      )
      .transitionTo(
        TransactionLifecycleState.succeeded,
        postStateVerification: PostStateVerification(
          status: PostStateVerificationStatus.confirmed,
          checkedAt: now,
        ),
      );
  return record;
}

class _MockPhase6bState {
  String modelStatus = 'Missing';
  bool delegated = false;
  bool predictionCreated = false;
  bool marketTokenized = false;
  BigInt yesTotal = BigInt.zero;
  BigInt noTotal = BigInt.zero;
  bool predictionClosed = false;
  bool outcomeProposed = false;
  bool settlementFinalized = false;
  bool claimed = false;

  void apply(Phase6bCallIntent intent) {
    switch (intent.callName) {
      case 'register_model':
        modelStatus = 'Pending';
        break;
      case 'approve_model':
        expect(modelStatus, 'Pending');
        modelStatus = 'Approved';
        break;
      case 'set_model_submitter':
        expect(modelStatus, 'Approved');
        delegated = true;
        break;
      case 'submit_prediction':
        expect(delegated, isTrue);
        predictionCreated = true;
        break;
      case 'tokenize_prediction':
        expect(predictionCreated, isTrue);
        marketTokenized = true;
        break;
      case 'stake_on_prediction_outcome_side':
        expect(marketTokenized, isTrue);
        final side = intent.arguments['side'];
        final amount = BigInt.parse(intent.arguments['amount']! as String);
        if (side == 'Yes') {
          yesTotal += amount;
        } else {
          noTotal += amount;
        }
        break;
      case 'close_prediction':
        expect(yesTotal + noTotal, greaterThan(BigInt.zero));
        predictionClosed = true;
        break;
      case 'propose_prediction_outcome':
        expect(predictionClosed, isTrue);
        outcomeProposed = true;
        break;
      case 'finalize_prediction_outcome_after_dispute_window':
        expect(outcomeProposed, isTrue);
        settlementFinalized = true;
        break;
      case 'claim_prediction_market_payout':
        expect(settlementFinalized, isTrue);
        claimed = true;
        break;
    }
  }
}

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
