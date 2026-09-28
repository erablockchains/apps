# ERA Wallet Phase 6B operator mode

## Purpose

Operator mode is a controlled beta surface for reviewed model onboarding, prediction lifecycle, settlement, and model-governance testing on ERA-MAINNET. It is not an authorization oracle and it must not be enabled in an ordinary store build.

All live calls use real ETKN. No operator key, seed, mnemonic, PIN, or special credential is compiled into the wallet.

## Build flags

```text
ENABLE_PHASE6B_TESTING_TOOLS=false
ENABLE_PHASE6B_GOVERNANCE_ACTIONS=false
```

These are compile-time Dart defines and both default to `false`.

Controlled testing build:

```powershell
flutter run --dart-define=ENABLE_PHASE6B_TESTING_TOOLS=true
```

Controlled testing plus governance build:

```powershell
flutter run `
  --dart-define=ENABLE_PHASE6B_TESTING_TOOLS=true `
  --dart-define=ENABLE_PHASE6B_GOVERNANCE_ACTIONS=true
```

`ENABLE_PHASE6B_GOVERNANCE_ACTIONS=true` is ignored by compatibility policy unless testing tools are also enabled. The former `ENABLE_AI_PREDICTION_ADMIN_TOOLS` flag is not the Phase 6B control and must not be used for new builds.

## Visibility and audiences

| Surface | Normal build | Testing flag | Both flags |
| --- | --- | --- | --- |
| Models, predictions, markets, positions, claims, diagnostics | Visible | Visible | Visible |
| Participant stake, permitted unstake, payout claim | Available when state and exact runtime permit | Available | Available |
| Controlled-testing banner and Operator Lab | Hidden | Visible | Visible |
| Registration, prediction creation, tokenization, validation/close, settlement proposal/finalization | Blocked by action policy | Available when state permits | Available when state permits |
| Approve/suspend/reject model, set/revoke submitter, admin finalize | Hidden/blocked | Hidden/blocked | Available when state permits |

Prediction lifecycle testing controls (`tokenize_prediction`, `validate_prediction`, and `close_prediction`), Operator Lab, and Test Reports are exposed only in the controlled testing UI path. In an ordinary build they are hidden as well as rejected by the signing policy. Participant staking, permitted unstaking, and claims remain available when canonical state allows them.

## Exact exposed operator calls

Controlled testing exposes:

- `AiPredictions.register_model` (index 0)
- `AiPredictions.submit_prediction` (index 2)
- `AiPredictions.validate_prediction` (index 3)
- `AiPredictions.close_prediction` (index 4)
- `AiPredictions.tokenize_prediction` (index 8)
- `AiPredictions.propose_prediction_outcome` (index 22)
- `AiPredictions.finalize_prediction_outcome_after_dispute_window` (index 25)

Governance additionally exposes:

- `AiPredictions.admin_finalize_prediction_outcome` (index 24)
- `AiPredictions.approve_model` (index 36)
- `AiPredictions.suspend_model` (index 37)
- `AiPredictions.reject_model` (index 38)
- `AiPredictions.set_model_submitter` (index 39); `None` revokes the configured submitter

The bindings contain more calls, but unlisted calls are not automatically made available by enabling a flag.

## Authorization is chain-authoritative

Metadata V14 does not encode dispatch origins and the live AI call documentation is empty. Labels such as owner, authorized submitter, validator, model administrator, settlement proposer, admin, or governance are state-derived hints only.

The wallet must never promise that a selected account is authorized. It shows the full public signer and expected role, submits only after explicit review, decodes the chain dispatch result, and refreshes canonical state. `BadOrigin`, `NotAuthorizedModelAdmin`, `NotAuthorizedModelSubmitter`, `NotAuthorizedValidator`, and other runtime errors are authoritative.

## Per-action safety flow

Every operator or governance action follows an independent flow:

1. Refresh metadata and runtime compatibility.
2. Refresh the affected canonical model, prediction, or market.
3. Check that the selected account and current state make the control plausible.
4. Authenticate before fee estimation.
5. Show exact pallet/call, arguments, full public signer, account label, expected authorization, and exact estimated ETKN fee.
6. Require review. High-impact calls require the exact displayed phrase, such as `I understand this changes live model governance state.`
7. Authenticate again and recheck compatibility immediately before signing.
8. Sign locally and submit once.
9. Wait for finalized dispatch evidence.
10. Reload canonical storage; required operator verification must be confirmed before success is reported.

The transaction journal prevents a second active submission for the same canonical intent. A timeout, retraction, finality timeout, or lost RPC response becomes `unknownNeedsVerification`; the wallet does not resubmit automatically.

## Release build rule

Build ordinary releases without either define, or set both explicitly to false:

```powershell
flutter build appbundle --release `
  --dart-define=ENABLE_PHASE6B_TESTING_TOOLS=false `
  --dart-define=ENABLE_PHASE6B_GOVERNANCE_ACTIONS=false
```

Before release, verify:

- both defines are absent or false in CI/store build configuration;
- Operator Lab and the controlled-testing banner are absent;
- all testing/governance controls are hidden, not merely rejected after tapping;
- no approved test account or operator identity is hardcoded;
- report fixtures, logs, and screenshots contain no secrets;
- the runtime fingerprint still matches the reviewed capture;
- release signing and platform builds are independently validated.
