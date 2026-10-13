# ERA Wallet

ERA Wallet is the Android, Windows, iOS and Linux Flutter, Material 3, local-first self-custody wallet for ERA accounts, ETKN balances and transfers, staking, verified NFT ownership/metadata and approved NFT market actions, plus the custom V14 SecurityBudget reward claim. Signing stays on the device through Polkadart keyring accounts protected by the wallet's PIN and optional device authentication.

The wallet is a controlled beta. V14 integration is pinned to the deployed production runtime. Automated tests and build validation never submit a production transaction. AI and AMM commissioning remain inactive.

Android and Windows have current build evidence. Windows owner validation passed the requested account, QR, connectivity and read-only checks. Earlier Android QR/scanner and read-only reward checks remain accepted within their tested scope. The owner reports that Play Internal build5 updated build4 in place on Samsung with accounts/settings preserved, showed ERA/spec16 and loaded commissioned collection 1/items 1–3 and the read-only reward page. This is owner-performed validation, not an independently audited claim, reward payment or spec16 signing test. iOS and Linux are unverified source targets; they add no V14 acceptance gate.

## Live ERA compatibility

| Field | Reviewed value |
| --- | --- |
| Endpoint | `wss://eraprojects.org/` |
| Chain (`system_chain`) | `ERA` |
| Genesis | `0x0abc2c3d8db5815541050b73da4d81267ebf14d90dbee8d7258155b667ea112e` |
| Runtime | `era` spec 16, transaction version 1 |
| Metadata | V14 SHA-256 `574931f693241cb62e1ad2990eda55e2250c36c9c0de852b0380eac480c8496a` |
| Runtime Wasm | SHA-256 `bc0085ce268f447760403a3049c9e9e64b0150bdd79c0ee20490f6fab36b2b85` |
| AI pallet | `AiPredictions` index 12, storage version 3 |
| Token | ETKN, 18 decimals, SS58 prefix 42 |

Wallet transaction construction is fail closed: chain identity and properties, exact spec/transaction versions, metadata version/hash, required pallet calls/storage, runtime Wasm hash, preserved AI storage version, endpoint health, and fee RPC availability must match the reviewed V14 fingerprint. A later or different runtime is disabled until it is captured, reviewed, regenerated, and pinned.

ERA staking, nomination and validator selection are active. The V14 minimum validator bond is `10,000 ETKN`. Standard staking era payout remains zero; approved rewards use `SecurityBudget.claim_reward_page` after finalized eligibility checks.

## V14 native assets and rewards

The V14 screen reads NFT collection/item ownership and metadata at one finalized head. Collection 1/items 1–3, their metadata, a restricted sale and a priced swap are accepted on chain. Metadata retrieval accepts only the four approved `ipfs://` references and uses `https://metadata.eraprojects.org` with redirects disabled, exact length limits, strict UTF-8 JSON parsing and pinned SHA-256 hashes. The app exposes reviewed `Nfts.set_price`, `buy_item`, `create_swap` and `claim_swap` calls under the spec16 gate; production app signing remains untested.

The rewards route uses `SecurityBudget.claim_reward_page`; it never substitutes `Staking.payout_stakers` and never allows a caller-selected recipient. It checks active/unpaused allocation, completed and eligible era, points, budget/liability, exposure page, expiry and duplicate-claim state at a finalized head. Before any submission, the app shows the purpose, decoded arguments, signer, exact call bytes, fresh estimated fee and zero tip; it reauthenticates, rechecks V14, signs once, watches finalization and verifies post-state. Unknown outcomes remain duplicate protected for reconciliation.

The historical Phase 6B AI workspace remains in the source tree but its exact spec-13 signing gate fails closed on spec16. No AI or AMM commissioning is enabled by this V14 work.

## AI Predictions workspace

The workspace includes Overview, Models, Predictions, Markets, My Positions, Claims, and Diagnostics. Controlled builds additionally expose Operator Lab and Test Reports. It reads typed canonical model/governance, prediction, token, side-position, settlement, claim, counter, index, configuration, and accounting storage.

Normal participant mode supports chain-derived discovery, YES/NO staking, permitted unstaking, payout claims, finalized receipts, and bounded reconciliation. Operator actions are not proof of authorization: runtime metadata does not encode dispatch origins, so the live chain response is authoritative.

Transaction handling records preparation, authentication, signing, submission, inclusion, finality, dispatch result, decoded errors/events, and post-state verification in a secure-storage journal. Unresolved intents survive restart and stay duplicate-protected; a corrupt or unsupported journal fails closed instead of being treated as empty. Ambiguous outcomes are marked `unknownNeedsVerification` and are never automatically retried. Finalized history is bounded and can be incomplete on a pruned RPC node. No ERA indexer is bundled.

## Controlled testing and governance

Both compile-time controls default to false:

```text
ENABLE_PHASE6B_TESTING_TOOLS=false
ENABLE_PHASE6B_GOVERNANCE_ACTIONS=false
```

Testing build:

```powershell
flutter run --dart-define=ENABLE_PHASE6B_TESTING_TOOLS=true
```

Testing plus governance build:

```powershell
flutter run `
  --dart-define=ENABLE_PHASE6B_TESTING_TOOLS=true `
  --dart-define=ENABLE_PHASE6B_GOVERNANCE_ACTIONS=true
```

Governance is ignored unless testing tools are also enabled. The old `ENABLE_AI_PREDICTION_ADMIN_TOOLS` flag is not the Phase 6B control.

Controlled mode displays a permanent ERA-MAINNET/real-ETKN warning, estimates the fee, shows the exact call and full signer, requires authentication and review for every action, rechecks compatibility immediately before signing, and submits once. High-impact calls require exact typed confirmation. `Utility.batch*` and multi-transaction confirmation are forbidden for controlled sessions.

Ordinary store builds must omit both defines or set both to false. In that mode operator actions, controlled lifecycle controls, and Test Reports remain hidden. See [operator-mode guidance](docs/phase6b-wallet-operator-mode.md).

## Test reports

The report domain models a fixed 15-stage lifecycle and exports redacted JSON, Markdown, and a copyable summary. A completed save uses a deterministic session-based filename under the app documents directory; sharing uses the same final report where the platform supports a share sheet. Recursive redaction removes mnemonics, seeds, private keys, PINs, passwords, secure-storage content, biometric information, and likely secret material while preserving required public addresses and chain hashes.

Controlled sessions record each matching finalized transaction, fee estimate, confirmation, dispatch evidence, and canonical post-state into the current stage. Read-only checkpoints capture public-account balances and market accounting; report export finishes the ordered session only after all prerequisites pass and the requested save or share operation succeeds. Incomplete or inconclusive sessions export as `BLOCKED`, never as proof of a completed lifecycle. Reports contain public-chain evidence and can identify participating addresses and activity; inspect them before copying, saving, or sharing.

## Pinned metadata and bindings

The V14 reproducible source is `artifacts/v14/era-spec16-metadata.scale`, not an unpinned future response. `tool/generate_v14_bindings.dart` refuses a different SHA-256, non-V14 metadata, or wrong required pallet identities. Historical Phase 6B artifacts remain for audit and legacy tests.

Regenerate and install only from that authenticated local artifact:

```powershell
dart run tool/generate_v14_bindings.dart --install --verbose
```

The pubspec deliberately contains no live Polkadart chain-generation endpoint.
Do not use generic live generation for a release without first pinning and
reviewing the new metadata.

## Development

The recorded local toolchain is Flutter 3.41.9 stable and Dart 3.11.5. Dependencies are locked in `pubspec.lock`; Polkadart and `polkadart_cli` are 0.7.1.

Common verification commands:

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
dart run tool/era_v14_live_gate.dart --live
flutter run -d windows
flutter build apk --debug
flutter build windows --release
```

Run Linux, iOS, and macOS builds only where their native toolchains are available, and do not report an unavailable build as passing. Live tests are a separate, explicitly approved activity; no live submission suite runs in normal CI.

## Documentation

- [Live V13 compatibility and staking payout status](docs/era-v13-wallet-compatibility.md)
- [V14 native wallet integration](docs/era-v14-native-wallet-integration.md)
- [Live runtime discovery](docs/phase6b-wallet-runtime-discovery.md)
- [Architecture and compatibility](docs/phase6b-wallet-architecture.md)
- [Controlled operator mode](docs/phase6b-wallet-operator-mode.md)
- [Test-session evidence model](docs/phase6b-wallet-test-session.md)
- [Opt-in live test plan](docs/phase6b-wallet-live-test-plan.md)
- [Security notes](docs/phase6b-wallet-security-notes.md)
- [Phase 6B release notes](docs/phase6b-wallet-release-notes.md)
- [Store submission checklist](docs/store_submission.md)
- [Release packaging](docs/release_builds.md)
- [Legacy Phase 6A manual QA](docs/era-wallet-ai-predictions-phase6a-qa.md)
