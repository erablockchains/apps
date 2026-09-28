import 'package:era_wallet/config.dart';
import 'package:era_wallet/phase6b/phase6b_workspace.dart';
import 'package:era_wallet/phase6b/runtime_compatibility.dart';
import 'package:era_wallet/phase6b/transaction_lifecycle.dart';
import 'package:era_wallet/phase6b/transaction_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('production participant build', () {
    test('uses the reviewed secure ERA endpoint', () {
      expect(kDefaultEraWsEndpoint, kOfficialEraWsEndpoint);
      expect(validateEraWsEndpoint(kDefaultEraWsEndpoint).scheme, 'wss');
      expect(kAllowNonProductionEraEndpoint, isFalse);
    });

    test('operator and governance flags default off', () {
      expect(enablePhase6bTestingTools, isFalse);
      expect(enablePhase6bGovernanceActions, isFalse);
    });

    test('public workspace exposes no operator or report routes', () {
      final sections = phase6bWorkspaceSections();
      expect(sections, isNot(contains('Operator Lab')));
      expect(sections, isNot(contains('Test Reports')));
      expect(
        sections,
        containsAll(['Models', 'Markets', 'Claims', 'Diagnostics']),
      );
    });

    test('participant runner rejects operator and governance calls', () {
      for (final call in const [
        'register_model',
        'submit_prediction',
        'approve_model',
        'suspend_model',
        'admin_finalize_prediction_outcome',
      ]) {
        final intent = TransactionIntent(
          pallet: 'AiPredictions',
          call: call,
          argumentsSummary: const {'public_id': '1'},
          signer: '5PublicParticipantAddress',
        );
        expect(
          () => requirePhase6bCallEnabledForBuild(intent),
          throwsStateError,
          reason: call,
        );
      }
    });

    test('participant runner accepts reviewed public calls', () {
      for (final call in phase6bParticipantTransactionCalls) {
        final intent = TransactionIntent(
          pallet: 'AiPredictions',
          call: call,
          argumentsSummary: const {'token_id': '1'},
          signer: '5PublicParticipantAddress',
        );
        expect(
          () => requirePhase6bCallEnabledForBuild(intent),
          returnsNormally,
        );
      }
    });
  });
}
