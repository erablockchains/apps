# ERA Wallet Phase 6B architecture

## Scope

ERA Wallet is a local-first, self-custody Flutter application. The Phase 6B implementation adds typed access to the live ERA AI Predictions runtime without changing the chain, runtime, node configuration, or production infrastructure.

The compatibility source of truth is the pinned capture described in [phase6b-wallet-runtime-discovery.md](phase6b-wallet-runtime-discovery.md). Runtime source was not available, so this wallet does not claim to know an account's dispatch origin or governance eligibility before the chain accepts a call.

## Approved live runtime

| Field | Approved value |
| --- | --- |
| Endpoint | `wss://eraprojects.org/` |
| Chain display name | `ERA-MAINNET` |
| Genesis hash | `0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7` |
| Runtime | `specName=era`, `specVersion=9`, `transactionVersion=1` |
| Metadata | V14, 108,814 bytes |
| Metadata SCALE SHA-256 | `26a869e3e621ec0235c4c850ec74a3fe77b9aeedc9cebf12fd566a36402bfc9e` |
| AI pallet | `AiPredictions`, index `12`, storage prefix `AiPredictions` |
| AI pallet storage version | `3` |
| Native currency | ETKN, 18 decimals |
| SS58 prefix | `42` |

Spec 9 is fail-closed. The probe decodes the metadata bytes returned by the connected node through the V14 runtime adapter; it does not substitute a synthetic approved pallet description. The signing gate compares the genesis hash, runtime and transaction versions, metadata version and hash, AI pallet identity, storage version, all 40 call signatures, and all 32 storage signatures with the reviewed fingerprint. A newer spec version is not accepted merely because its number is greater.

Spec 8 can be recognized only as a legacy Phase 6A shape when the preserved calls `31..33` and their canonical storage signatures match. The Phase 6B workspace is not decoded with spec-9 bindings in this mode, and the legacy signer is not exposed. Spec-8 signing, Phase 6B testing, and governance remain disabled until a separate exact fingerprint and lifecycle-runner review exists.

## Capability modes

| Mode | Conditions | Signing surface |
| --- | --- | --- |
| Unavailable | Pallet absent, runtime identity mismatch, metadata drift, incompatible call/storage types, or unsupported spec version | Phase 6B signing disabled; read-only diagnostics may explain the mismatch |
| Phase 6A legacy shape | Compatible legacy spec 8 calls/storage | Read-only compatibility diagnostics; signing disabled |
| Phase 6B participant | Exact reviewed spec 9 fingerprint | Ordinary participant actions |
| Phase 6B testing | Exact spec 9 plus `ENABLE_PHASE6B_TESTING_TOOLS=true` | Participant actions plus controlled onboarding/lifecycle actions |
| Phase 6B operator | Exact spec 9 plus both testing and governance flags | Testing surface plus the deliberately exposed governance actions |

Both build flags default to `false`. The governance flag has no effect unless testing tools are also enabled.

## Components and responsibilities

| Component | Responsibility |
| --- | --- |
| `runtime_probe.dart` | Reads chain name, genesis, runtime version, metadata, FRAME storage version, heads, health, account nonce, and balance. Produces exportable diagnostics. |
| `runtime_compatibility.dart` | Applies the reviewed fingerprint and capability policy. It is the pre-signing fail-closed gate. |
| `lib/generated/era` | Polkadart bindings generated from the pinned metadata, including all AI calls, storage, records, events, and errors. |
| `phase6b_data.dart` | Reads typed chain configuration, models, predictions, markets, positions, counters, and bounded indexes. Pages are explicit rather than silently capped. |
| `phase6b_validation.dart` | Validates model and prediction input bounds and parses ETKN amounts without floating-point arithmetic. |
| `phase6b_actions.dart` | Constructs the deliberately supported typed calls, verifies encoded pallet/call bytes, assigns participant/testing/governance audiences, and supplies confirmation text. |
| `transaction_lifecycle.dart` | Models transaction state, dispatch evidence, errors, required post-state verification, versioned persistence encoding, duplicate protection, and restart policy. |
| `transaction_runner.dart` | Serializes journal mutation, rechecks runtime compatibility, authenticates, signs locally against the checked runtime context, submits once, watches inclusion/finality, decodes events, and performs post-state verification. |
| `chain_reconciliation.dart` | Scans a bounded finalized-block window, uses Timestamp pallet values, decodes typed AI events, and marks pruning gaps as incomplete. |
| `finalized_receipt.dart` | Displays the persisted signer, call, nonce, hash, blocks, dispatch result, events, and post-state result. |
| `test_session.dart` / `test_report.dart` | Defines the controlled 15-stage evidence model, single-action policy, aggregation, recursive redaction, JSON, Markdown, and copy summary. |
| `report_export.dart` | Writes one final redacted JSON/Markdown pair with deterministic session-based names in the app documents area and shares that same pair when supported. |
| `phase6b_workspace.dart` | Presents Overview, Models, Predictions, Markets, My Positions, Claims, optional Operator Lab, Diagnostics, and Test Reports. |

## Implemented transaction surface

The generated binding covers all 40 live calls. The wallet call factory intentionally exposes only these calls:

| Index | Call | Audience |
| ---: | --- | --- |
| 0 | `register_model` | Controlled testing |
| 2 | `submit_prediction` | Controlled testing |
| 3 | `validate_prediction` | Controlled testing |
| 4 | `close_prediction` | Controlled testing |
| 8 | `tokenize_prediction` | Controlled testing |
| 22 | `propose_prediction_outcome` | Controlled testing |
| 24 | `admin_finalize_prediction_outcome` | Governance |
| 25 | `finalize_prediction_outcome_after_dispute_window` | Controlled testing |
| 31 | `stake_on_prediction_outcome_side` | Participant |
| 32 | `unstake_from_prediction_outcome_side` | Participant |
| 33 | `claim_prediction_market_payout` | Participant |
| 36 | `approve_model` | Governance |
| 37 | `suspend_model` | Governance |
| 38 | `reject_model` | Governance |
| 39 | `set_model_submitter` | Governance |

The remaining generated calls are not automatically exposed. Adding one requires an explicit audience decision, state policy, confirmation language, post-state verifier, and tests.

## Read and signing flows

### Refresh

1. Connect to the configured WSS endpoint.
2. Probe live runtime identity and metadata.
3. Assess the exact compatibility fingerprint.
4. Read typed canonical configuration and paged records.
5. Load and decode the versioned transaction journal and identify unresolved submissions. Corrupt or unsupported data fails closed rather than becoming an empty journal.
6. Reconcile a bounded finalized-event window.
7. Label incomplete history when blocks are pruned or the event bound is reached.

### Signed action

1. Build a generated typed call and verify encoded bytes begin with pallet index `12` and the expected call index.
2. Apply audience, build-flag, runtime, account, and state policy.
3. Authenticate before fee estimation and refresh runtime compatibility.
4. Show the exact call path, arguments, full public signer address, account label, expected authorization, and fee.
5. Require an explicit checkbox or exact typed high-impact confirmation.
6. Authenticate again immediately before signing and recheck runtime compatibility and action-specific canonical state.
7. Carry the checked genesis/spec/transaction/metadata context into signing. The signer fetches runtime identity again and refuses to sign if that context changed.
8. Sign locally, persist the intent, and submit exactly once.
9. Watch inclusion and finality; decode `system.ExtrinsicSuccess`, `system.ExtrinsicFailed`, relevant AI events, and nested sudo evidence where present.
10. Reload canonical storage for calls that require post-state proof. An absent, failed, or inconclusive required verifier becomes `unknownNeedsVerification`, not success.
11. Persist and display a finalized receipt.

No ambiguous submission is automatically retried. Journal access is serialized, unresolved entries are retained ahead of terminal history when enforcing the bound, and an unresolved intent remains duplicate-protected across restart until bounded chain verification conclusively resolves it. Absence from a bounded or pruned history is not proof that it is safe to retry.

## Evidence precedence and history limits

Data precedence is canonical storage, then finalized chain events, then local records as supplementary evidence. Finalized scanning defaults to a bounded window and is capped by the implementation at 512 blocks; the workspace currently requests 60 blocks and at most 150 events. Timestamps come from the Timestamp pallet.

The connected RPC may prune old block bodies, events, or hashes. The wallet records unavailable blocks, labels the result incomplete, and does not present local history as canonical. There is no bundled ERA indexer, so the wallet cannot claim complete historical discovery.

## Current implementation boundary

The test-session/report domain, exporter, 15-stage UI, and redaction policy are connected to the finalized lifecycle service. Matching calls produce `Phase6bStageRecord` entries containing the signer, fee estimate, confirmation, receipt, dispatch events, and post-state verification. Read-only checkpoints capture balance and market-accounting evidence; identifiers are derived from finalized events or exact call arguments. A save or share builds the final stage into one prospective report, performs the requested export, and only then finishes the in-memory session. Deterministic filenames avoid a stale preliminary artifact, and report evidence uses safe artifact names rather than absolute local paths. Incomplete or inconclusive exports remain `BLOCKED`. An explicitly approved manual live session remains operational work and was not performed during implementation.

See [phase6b-wallet-test-session.md](phase6b-wallet-test-session.md) and [phase6b-wallet-live-test-plan.md](phase6b-wallet-live-test-plan.md) before conducting any live-chain test.
