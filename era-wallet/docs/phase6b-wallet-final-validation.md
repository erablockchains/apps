# ERA Wallet Phase 6B final validation

Validation was completed locally on Windows on 2026-07-17. No GitHub repository, remote, live ERA transaction, model onboarding, private-key access, or runtime modification was used.

## Repository and toolchain

| Item | Result |
| --- | --- |
| Project root | `C:\Users\drodm\Documents\Wally\era_wallet` |
| Branch | `feature/era-wallet-phase6b-onboarding` |
| Starting HEAD | `15a632a` — Regenerate ERA spec-9 runtime bindings |
| Validated implementation HEAD before this report | `2506963` — Document Phase 6B wallet operation and release safety |
| Final branch HEAD | The commit containing this report; obtain its exact hash with `git rev-parse HEAD`. A Git commit cannot embed its own resulting hash. |
| Flutter | 3.41.9 stable |
| Dart | 3.11.5 |
| Java | OpenJDK 21.0.10 (Android Studio JBR) |

Phase 6B local commits through the validated implementation HEAD:

- `7cbe8c0` — Document ERA spec-9 wallet metadata
- `15a632a` — Regenerate ERA spec-9 runtime bindings
- `26070a0` — Finalize Phase 6B runtime tooling and platform support
- `57a1656` — Add finalized Phase 6B transaction lifecycle and recovery
- `ce1d130` — Add controlled Phase 6B wallet workflow and reporting
- `2506963` — Document Phase 6B wallet operation and release safety
- Final report commit — Add Phase 6B final validation report

## Reviewed runtime identity

| Item | Pinned value |
| --- | --- |
| Endpoint | `wss://eraprojects.org/` |
| Chain | `ERA-MAINNET` |
| Genesis hash | `0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7` |
| Runtime | `specName=era`, `specVersion=9`, `transactionVersion=1` |
| Metadata | V14, 108,814 bytes |
| Metadata SHA-256 | `26a869e3e621ec0235c4c850ec74a3fe77b9aeedc9cebf12fd566a36402bfc9e` |
| Runtime WASM SHA-256 | `2bb522963e929575483d8d7bc791f236d0ef0db19f83546a6a5d2f766f6ffdf6` |
| AI Predictions pallet | `AiPredictions`, index 12, storage version 3 |
| Native token | ETKN, 18 decimals |

The offline discovery tool reproduced the pinned capture. No live metadata capture or live signed operation was performed during finalization.

## Implemented capability review

Source and tests confirm the following implementation:

- exact spec-9 identity, metadata, pallet, call, and storage signature gating;
- structurally compatible spec-8 diagnostics in read-only mode, with signing and operator elevation disabled;
- generated spec-9 bindings and reproducible capture/discovery/generation tooling;
- canonical model discovery, registration/onboarding, approval/governance, and submitter delegation handling;
- prediction creation, tokenization, participant YES/NO stake and unstake flows, settlement, and payout claims;
- one-confirmation/one-transaction safety, fee review, authentication, and default-disabled operator tools;
- finalized inclusion, dispatch-event decoding, post-state verification, persistent lifecycle journaling, durable uncertain-transaction recovery, duplicate-submission prevention, and chain reconciliation;
- ordered controlled test sessions with secure public-evidence checkpoints;
- redacted JSON/Markdown export and platform-specific save/share behavior;
- runtime/account diagnostics and Android minimum API 24 alignment.

The wallet fails closed on incompatible or newer runtime fingerprints. Spec 8 remains read-only until exact metadata/WASM pins and its signing lifecycle are separately reviewed.

## Privacy and recovery behavior

Transaction intent summaries, lifecycle evidence, checkpoints, and reports reject or redact credential-bearing endpoints, authentication material, mnemonic-like text, private-key-like hex outside explicitly public hash/address fields, and sensitive keys. Public transaction, block, genesis, metadata, and runtime hashes remain reportable. No mnemonic, PIN, key, secure-storage export, or designated test-account secret was read or added.

Ambiguous submissions remain duplicate-protected. Restart recovery converts interrupted active submissions into verification-required state, checks finalized canonical blocks and pending-pool evidence, and permits retry only after absence is proven over the full relevant mortal window. Successful calls that require canonical post-state do not become successful without confirmed post-state evidence.

## Validation results

| Check | Result |
| --- | --- |
| `flutter pub get` | PASS |
| Changed/untracked Dart files formatted (40 files) | PASS — 0 changes required |
| Repository-wide Dart 3.11 non-writing format check | KNOWN BASELINE LIMITATION — 181 pre-existing generated/baseline files would be reformatted; no such unrelated rewrite was retained |
| `git diff --check` | PASS |
| Recursive JSON parse | PASS — 981 files, 0 failures |
| Markdown relative links | PASS — 17 files and 28 relative links, 0 failures |
| Node capture syntax | PASS |
| Live-capture default guard | PASS — refuses to run without the exact `--live` opt-in |
| Offline metadata discovery | PASS |
| `flutter analyze` | PASS — no issues |
| `flutter test` | PASS — 150 tests |
| Android debug APK | PASS — `build\app\outputs\flutter-apk\app-debug.apk` |
| Windows release build | PASS — `build\windows\x64\runner\Release\era_wallet.exe` |
| iOS build | BLOCKED_BY_PLATFORM — requires macOS/Xcode |
| macOS build | BLOCKED_BY_PLATFORM — requires macOS/Xcode |

The Android build emitted only Java 8 source/target deprecation warnings. Android configuration remains `minSdk = maxOf(flutter.minSdkVersion, 24)`.

Local evidence is retained under ignored `evidence\phase6b-final-validation\`. The logs contain command results and test names only; secret-pattern matches were reviewed and were references to redaction/security tests or source filenames, not secret values.

## Process and limitations

PID 25024 was found to be the orphaned Dart validation process described in the handoff and only that confirmed orphan was terminated. No unrelated Dart, Flutter, Java, IDE, or Gradle process was stopped.

Known limitations:

- The controlled live ERA lifecycle has not been executed; this task intentionally performed no live transaction or live model onboarding.
- Operator/testing tools require both explicit compile-time flags and are disabled by default in ordinary/release builds.
- Runtime drift or any runtime newer than the reviewed spec 9 remains unavailable until captured, reviewed, regenerated, tested, and pinned.
- iOS and macOS builds were not available on this Windows host; Chrome was also unavailable, so no Chrome-specific validation is claimed.
- The current Dart formatter differs from pre-existing generated/baseline formatting. Phase 6B changed Dart files are clean, while a repository-wide reformat should be handled separately as an intentional generated-code/baseline change.

## Final status

```text
LOCAL_WORKSPACE_ONLY: YES
GITHUB_REPOSITORY_USED: NO
REMOTE_REPOSITORY_CONFIGURED: NO
SOURCE_CODE_PUSHED: NO

PHASE_6B_WALLET_BINDINGS_UPDATED: YES
PHASE_6B_RUNTIME_GATING_IMPLEMENTED: YES
PHASE_6B_SPEC8_READ_ONLY_COMPATIBILITY: YES
PHASE_6B_MODEL_ONBOARDING_IMPLEMENTED: YES
PHASE_6B_LIFECYCLE_TEST_MODE_IMPLEMENTED: YES
TRANSACTION_FINALITY_TRACKING_IMPLEMENTED: YES
DURABLE_TRANSACTION_RECOVERY_IMPLEMENTED: YES
CHAIN_RECONCILIATION_IMPLEMENTED: YES
REPORT_PRIVACY_REDACTION_IMPLEMENTED: YES
ANDROID_MIN_API_24_CONFIRMED: YES

FLUTTER_ANALYZE: PASS
FLUTTER_TEST: PASS
ANDROID_DEBUG_BUILD: PASS
WINDOWS_BUILD: PASS

LIVE_ERA_RUNTIME_MODIFIED: NO
LIVE_ERA_TRANSACTION_SUBMITTED: NO
LIVE_MODEL_ONBOARDING_PERFORMED: NO
PRIVATE_KEYS_ADDED_TO_PROJECT: NO
OPERATOR_TOOLS_DEFAULT_ENABLED_IN_RELEASE: NO
```
