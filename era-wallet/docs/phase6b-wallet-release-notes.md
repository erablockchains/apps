# ERA Wallet Phase 6B release notes

## Release status

This change set upgrades the wallet code and generated bindings for the reviewed ERA spec-9 AI Predictions runtime. It does not modify the live chain and it does not perform live onboarding.

```text
LIVE_ERA_RUNTIME_MODIFIED: NO
LIVE_TRANSACTION_AUTOMATION_ADDED: NO
PRIVATE_KEYS_ADDED_TO_REPOSITORY: NO
NORMAL_RELEASE_OPERATOR_TOOLS_DEFAULT_ENABLED: NO
TRY_RUNTIME_ARTIFACT_USED: NO
PHASE_6B_WALLET_BINDINGS_UPDATED: YES
PHASE_6B_MODEL_ONBOARDING_IMPLEMENTED: YES
PHASE_6B_LIFECYCLE_TEST_MODE_IMPLEMENTED: YES
TRANSACTION_FINALITY_TRACKING_IMPLEMENTED: YES
CHAIN_RECONCILIATION_IMPLEMENTED: YES
LIVE_PHASE6B_LIFECYCLE_EXECUTED: NO
```

Controlled test sessions connect finalized receipts and canonical post-state evidence to the ordered 15-stage report. Incomplete or inconclusive sessions remain `BLOCKED`; no live lifecycle was executed as part of this implementation.

## Runtime and bindings

- Pinned ERA-MAINNET spec 9, transaction version 1, metadata V14.
- Pinned SCALE metadata SHA-256 `26a869e3e621ec0235c4c850ec74a3fe77b9aeedc9cebf12fd566a36402bfc9e`.
- Pinned runtime `:code` evidence at 713,764 bytes with SHA-256 `2bb522963e929575483d8d7bc791f236d0ef0db19f83546a6a5d2f766f6ffdf6`; the WASM itself is not stored.
- Confirmed `AiPredictions` pallet index 12 and storage version 3.
- Generated typed support for 40 calls, 32 storage entries, 42 events, and 76 errors.
- Added a fail-closed V14 adapter over the node's actual metadata bytes, an exact runtime fingerprint, and explicit unavailable/Phase 6A participant/Phase 6B participant/Phase 6B operator capability levels.
- Restricted compatible spec 8 to read-only legacy diagnostics; its unpinned one-shot signer, spec-9 bindings, testing actions, and governance actions are not used there.
- Added explicit-live, finalized-snapshot capture; offline-by-default evidence validation; and hash-gated, project-root-scoped binding generation. Generic unpinned live Polkadart generation is not configured in the pubspec.

## Wallet capabilities added

- Phase 6B workspace with Overview, Models, Predictions, Markets, My Positions, Claims, optional Operator Lab, Diagnostics, and Test Reports.
- Typed paged reads for models, governance, predictions, markets, positions, claims, counters, indexes, configuration, settlement, and accounting.
- Guided model registration and prediction creation.
- Deliberately scoped participant, testing, and governance call factory with encoded index checks.
- Model approve/suspend/reject and submitter set/revoke controls behind both flags.
- Side stake/unstake/claim using canonical token IDs and integer ETKN amounts.
- Small 0.01/0.1/1 ETKN presets; no Max default.
- Persistent live-chain warning and full signer/call/fee confirmation.
- Re-authentication and runtime recheck immediately before signing.
- Versioned secure-storage transaction journal, serialized mutation, restart-safe duplicate protection, inclusion/finality receipts, dispatch/error/event decoding, and required post-state verification.
- Fail-closed journal recovery: corrupt/unsupported data is surfaced, unresolved entries are retained ahead of terminal history, and ambiguous outcomes are never automatically retried.
- Bounded finalized-event reconciliation with Timestamp pallet timestamps and explicit pruning/incompleteness labels.
- Controlled 15-stage session/report domain, recursive secret redaction, deterministic final JSON/Markdown save, summary copy, and platform share support.

## Deliberately exposed calls

Participant: `stake_on_prediction_outcome_side` (31), `unstake_from_prediction_outcome_side` (32), and `claim_prediction_market_payout` (33).

Controlled testing: `register_model` (0), `submit_prediction` (2), `validate_prediction` (3), `close_prediction` (4), `tokenize_prediction` (8), `propose_prediction_outcome` (22), and `finalize_prediction_outcome_after_dispute_window` (25).

Governance: `admin_finalize_prediction_outcome` (24), `approve_model` (36), `suspend_model` (37), `reject_model` (38), and `set_model_submitter` (39).

## Tests added

Focused test files cover runtime compatibility and drift, generated call indices, model/prediction validation, amount handling, lifecycle policies, mocked lifecycle construction, transaction states and duplicate protection, error/event decoding, chain reconciliation and evidence precedence, and report aggregation/redaction/export.

No opt-in live submission suite is implemented or run. A future live suite must require `RUN_ERA_LIVE_PHASE6B_TESTS=true`, designated accounts, tiny amounts, and separate human approval.

## Toolchain record

| Component | Observed/configured value |
| --- | --- |
| Flutter | 3.41.9 stable, revision `00b0c91f06209d9e4a41f71b7a512d6eb3b9c694` |
| Dart | 3.11.5 |
| DevTools | 2.54.2 |
| Polkadart / CLI | 0.7.1 / 0.7.1 |
| Substrate metadata decoder | 1.5.0 |
| Gradle wrapper | 8.12 |
| Android Gradle Plugin | 8.9.1 |
| Kotlin Android plugin | 2.1.0 |
| Android Java target | 11 |
| Dependency lock | `pubspec.lock` present |

Java and Android SDK executables were not available on the documentation shell PATH, so their installed versions are not claimed here.

## Build matrix and verification status

| Target | Project support | Fresh Phase 6B result recorded here |
| --- | --- | --- |
| Android | Configured; minimum API 24 to match `local_auth_android`; app bundle/APK workflows documented | Not run/claimed in this documentation pass |
| Windows | Runner and plugins configured | Not run/claimed in this documentation pass |
| Linux | Runner and plugins configured | Not run/claimed in this documentation pass |
| iOS | Xcode project configured; build/signing requires macOS | Not available on this Windows host |
| macOS | Xcode project configured; build/signing requires macOS | Not available on this Windows host |
| Web | Flutter target exists | Not release-validated for secure wallet/operator use |

An older Android release APK exists under `build`, but it predates these Phase 6B changes and is not evidence of a passing Phase 6B build.

Run and record fresh results before release:

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build windows
```

Run Linux/iOS/macOS builds only on hosts with the required toolchains. Do not convert an unavailable toolchain into a PASS result.

## Known limitations

- Runtime source and exact origin implementations are unavailable. Role labels remain informational until dispatch.
- RPC reconciliation is bounded and may be incomplete because of pruning; no indexer is bundled.
- The wallet observes configured treasury/fee behavior and market fee accounting, but it cannot invent a treasury-account balance when metadata exposes no canonical treasury account.
- Multi-call transitions require separate reviews and receipts. The primary stage receipt advances the ordered session; all session-time journal receipts are also exported as supplementary evidence.
- No live model onboarding, lifecycle, or payout test has been performed by this implementation task.
- Fresh analyzer, unit-test, and platform-build results must be recorded in the final local implementation report; unavailable host toolchains must never be reported as passing.

## Release default

Build store binaries with both flags false. Follow [phase6b-wallet-operator-mode.md](phase6b-wallet-operator-mode.md), [phase6b-wallet-security-notes.md](phase6b-wallet-security-notes.md), and [phase6b-wallet-live-test-plan.md](phase6b-wallet-live-test-plan.md). A controlled live QA session is a separate explicitly approved activity.
