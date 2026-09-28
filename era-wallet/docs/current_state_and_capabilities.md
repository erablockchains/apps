# ERA Wallet: Current State and Capabilities

> V14 update, 2026-09-25: the Android and Windows targets now use exact spec15 bindings and include verified NFT ownership/metadata, approved NFT market actions, and the custom SecurityBudget reward-claim route. See [ERA V14 native wallet integration](era-v14-native-wallet-integration.md). The detailed V13 assessment below is retained as historical baseline where it has not yet been rewritten.

- **Assessment date:** August 28, 2026
- **Application version:** `1.1.0+2`
- **Project type:** Flutter self-custody wallet
- **Default network endpoint:** `wss://eraprojects.org/`
- **Native token:** ETKN, 18 decimal places

## Executive Summary

ERA Wallet is a functional, local-first wallet for the ERA blockchain. The current application can create and import accounts, display balances, send ETKN, manage basic staking actions, show recent wallet activity, and interact with ERA AI Prediction markets through the exact reviewed spec-13 gate. A structurally compatible spec-8 surface is recognized for read-only legacy diagnostics, but cannot sign.

The wallet is best described as a working pre-release product. Its principal wallet flows are implemented, automated unit tests exist for core account, authentication, amount-formatting, and AI Prediction logic, and release documentation has been prepared. Final production release still depends on physical-device QA, signed release packaging, store configuration, compliance review, and live-network validation.

## Current Status at a Glance

| Area | Status | Summary |
| --- | --- | --- |
| Account management | Implemented | Create, import, switch, display, copy, show as QR, reveal, and locally delete accounts. |
| Wallet security | Implemented with limitations | PIN gate, optional device authentication, secure-storage integration, and background session lock. |
| Balance display | Implemented | Reads the active account's free ETKN balance from the ERA node. |
| Transfers | Implemented | Address validation, QR scan, clipboard helpers, fee estimation, confirmation, signing, and submission. |
| Activity history | Partially implemented | Local submissions plus recent on-chain transfer and staking events; not a complete historical index. |
| Staking | Core flows implemented | Staking status, validator selection, bond, bond-extra, nominate, and unbond. Staking remains active; current validator-era payout is zero. |
| AI Predictions | Controlled beta; exact-runtime gated | Typed spec-13 discovery, participant actions, finalized receipts/reconciliation, and separately gated testing/governance tools. |
| Automated checks | Present; results not asserted here | Focused unit and widget tests are included; use the current implementation report for executed results. |
| Store release | Not complete | Store metadata and checklists exist; signing, packaging, compliance, and manual QA remain. |

## Implemented Capabilities

### 1. Onboarding and Account Management

- First-run branded splash and wallet setup flow.
- PIN creation with a minimum length of four numeric digits and a maximum input length of twelve digits.
- New BIP39 mnemonic generation.
- Import of an existing valid BIP39 mnemonic.
- Multiple locally managed accounts.
- Active-account selection and switching.
- SS58 account-address generation through the Polkadart keyring.
- Address display, clipboard copy, and QR-code display.
- Authenticated mnemonic reveal for the active account.
- Local account deletion with a warning that the on-chain account is unaffected.
- One-time mnemonic reminder immediately after account creation.

Account names, public addresses, the active account ID, and account mnemonics are stored locally through `flutter_secure_storage`.

### 2. Authentication and Local Security

- PIN-protected wallet setup and unlock.
- PIN verification based on PBKDF2-HMAC-SHA256 with 120,000 iterations, a random salt, and an HMAC verifier.
- Optional biometric or device-credential authentication through the operating system.
- PIN fallback when device authentication is unavailable, disabled, cancelled, or fails.
- Re-authentication for sensitive actions such as revealing a mnemonic and signing transactions.
- Automatic wallet lock after the application has remained paused, inactive, or hidden for more than one minute.
- Android encrypted shared preferences and Apple Keychain-backed secure storage configuration.

Important security boundary: the PIN is not stored in plaintext. Account mnemonics are stored through the platform secure-storage plugin, but the current per-account mnemonic records are not additionally encrypted with a PIN-derived application key. Device and secure-storage protection are therefore part of the wallet's security boundary.

### 3. ERA Network Connectivity

- WebSocket connection to the configured ERA endpoint.
- Five-second connection health check using `system_health`.
- Connection state reporting: disconnected, connecting, connected, or error.
- Automatic health verification and reconnection before network-dependent operations.
- Build-time endpoint override with:

```powershell
flutter run --dart-define=ERA_WS_ENDPOINT=wss://your-era-endpoint.example/
```

- Runtime reads for chain name, metadata, runtime version, block data, account state, and transaction information.
- Generated, strongly typed ERA runtime bindings for standard pallets.

### 4. Wallet Dashboard and Balances

- Active account name and address display.
- Free ETKN balance query from `System.Account`.
- Manual balance refresh.
- Visible ERA-node connection status.
- Quick navigation to accounts, transfers, staking, and AI Predictions.
- Biometric/device-login preference control where supported.

### 5. Sending ETKN

- Recipient entry by manual input, clipboard paste, or camera QR scan.
- Recipient SS58 address validation.
- ETKN amount parsing with 18-decimal base-unit conversion.
- Zero/invalid amount checks and available-balance validation.
- Fee estimation using the runtime payment RPC.
- Confirmation dialog showing recipient, amount, and estimated fee when available.
- Sensitive-action authentication before signing.
- Local sr25519 transaction signing from the active account mnemonic.
- Submission of `Balances.transfer_allow_death` extrinsics.
- Transaction-hash display and local activity recording after submission.

The wallet returns the submission hash; it does not currently provide a full finalized-success receipt or decoded dispatch-result screen.

### 6. Activity History

- Per-account locally persisted history.
- Immediate recording of wallet-submitted transfers, staking actions, and AI Prediction actions.
- On-chain scanning for recent balance-transfer events.
- On-chain scanning for recent staking `Bonded`, `Unbonded`, and `Withdrawn` events.
- Merging of matching local submissions with discovered on-chain records.
- Sent and received direction labels, counterparties, amounts, transaction hashes where locally available, and block numbers where discovered on-chain.

Current scan limits are the most recent 120 completed blocks and up to 30 discovered events per refresh. Local storage retains up to 100 entries per account. Timestamps reconstructed from block scanning are approximate because they are derived from block distance rather than the chain timestamp for each block.

### 7. Staking

- Reads current bonded and active staking amounts where runtime storage is available.
- Displays unlocking chunks and active nomination targets.
- Loads available validator/session targets.
- Caches nomination target choices locally for resilience.
- Bonds ETKN with `RewardDestination.staked`.
- Uses `bond_extra` when the account is already bonded.
- Nominates one or more selected validator targets.
- Submits unbond transactions.
- Authenticates before signing and records submitted staking actions in local history.

The wallet does not currently expose the full staking lifecycle. Dedicated UI flows for `withdraw_unbonded`, rebonding, chilling, reward payout/claiming, validator operation, staking analytics, or slashing history are not implemented.

ERA staking, nomination and validator selection are active. Current validator-era payout is configured to zero, so no staking reward should be expected until ERA's capped reward mechanism is separately activated. The `10,000 ETKN` validator eligibility threshold is planned for V14 and is not currently enforced; eligibility will not guarantee an active seat.

### 8. ERA AI Predictions

Phase 6B is not enabled by a minimum runtime version. Signing requires the exact reviewed ERA-MAINNET fingerprint: the approved genesis hash, `specName=era`, spec version 13, transaction version 1, Metadata V14 hash, runtime WASM hash, `AiPredictions` pallet identity/index, storage version 3, and reviewed call/storage signatures. Any mismatch fails closed. A compatible spec-8 runtime is read-only; all signing, Phase 6B testing, and governance remain unavailable there.

Implemented capabilities include:

- Exportable runtime diagnostics covering endpoint, chain identity, metadata fingerprint, finalized head, health, account nonce, and balance.
- Typed, paged canonical reads for configuration, models and governance, predictions, markets, tokenization, participant positions, claims, counters, settlement, and accounting.
- Model, prediction, market, position, claim, and diagnostics views in the Phase 6B workspace.
- Participant YES/NO staking, permitted unstaking, and payout claims using canonical token IDs and integer ETKN amounts.
- Fee estimation, explicit single-call confirmation, authentication, a final compatibility/state recheck, local signing, and submit-once behavior.
- A persistent secure-storage transaction journal with duplicate protection, inclusion/finality tracking, dispatch/error/event decoding, restart recovery, and required post-state verification.
- Bounded finalized-chain reconciliation with explicit pruning/event-limit incompleteness labels; no complete history is inferred from a bounded scan.
- Optional controlled model onboarding and prediction lifecycle tools with a fixed 15-stage local evidence report.
- Governance actions only when both controls are enabled:

```powershell
flutter run `
  --dart-define=ENABLE_PHASE6B_TESTING_TOOLS=true `
  --dart-define=ENABLE_PHASE6B_GOVERNANCE_ACTIONS=true
```

Both controls default to false, and governance is ignored unless testing tools are enabled. Runtime metadata describes call shapes but not dispatch origins, so labels such as operator or governance do not prove that an account is authorized; finalized dispatch remains authoritative.

## Architecture and Technology

| Layer | Current implementation |
| --- | --- |
| User interface | Flutter with Material 3 and Provider state management |
| Chain integration | Polkadart and generated ERA runtime bindings |
| Key derivation/signing | BIP39 mnemonics and sr25519 key pairs through `polkadart_keyring` |
| Local secrets | `flutter_secure_storage` |
| PIN cryptography | PBKDF2-HMAC-SHA256 and HMAC verification through `cryptography` |
| Device authentication | `local_auth` |
| QR support | `qr_flutter` and `mobile_scanner` |
| Local state/history | Secure-storage JSON records, including the Phase 6B transaction journal |
| Network transport | ERA WebSocket JSON-RPC |

The application is self-custodial: transaction signing happens locally and only signed extrinsics are submitted to the ERA node. The repository does not include analytics, advertising, user-tracking, or crash-reporting SDKs.

## Platform State

Flutter project scaffolding is present for Android, iOS, Windows, macOS, Linux, and web.

| Platform | Current repository state |
| --- | --- |
| Android | Configured with package ID `com.eraprojects.era_wallet`, minimum API 24 (aligned with the resolved `local_auth_android` dependency), camera/biometric permissions, launcher assets, and release-signing hooks. |
| iOS | Configured with bundle ID `com.eraprojects.erawallet`, Face ID and camera usage descriptions, launcher assets, and native project files. Final signing must be completed on macOS. |
| Windows | Desktop runner, secure-storage/device-auth plugin registration, icons, and executable metadata are present. Store submission still requires signed MSIX-compatible packaging. |
| Linux | Desktop runner and a packaged `era-wallet-linux-x64.tar.gz` artifact are present. The artifact was not rebuilt or validated during this assessment. |
| macOS | Native project and application icons are present, but release qualification is not documented as complete. |
| Web | Web manifest and application shell are present. Secure-storage, biometric/device-auth, camera, and browser security behavior require dedicated validation before treating web as a supported production target. |

The release documentation currently concentrates on Android, iOS, and Windows.

## Automated Test Coverage

The repository includes focused tests covering:

- ETKN formatting and base-unit parsing.
- PIN-verifier generation and verification.
- Legacy mnemonic decryption compatibility.
- PIN setup and wallet-state initialization.
- Biometric preference persistence.
- Account creation, mnemonic storage, active-account persistence, import, and generation.
- AI Prediction runtime compatibility and drift handling.
- Generated call indices, typed validation, and integer amount handling.
- Transaction lifecycle policy, dispatch/error/event decoding, duplicate protection, reconciliation, and evidence precedence.
- Controlled-session aggregation, report redaction, and export behavior.

This document records coverage present in the repository, not an execution result. Live-node lifecycle execution, physical-device biometric behavior, and store artifact validation require separate, explicitly approved QA and are not established by these tests alone.

## Known Limitations and Risks

### Product limitations

- No complete chain indexer or explorer integration.
- Activity history is recent and partial rather than authoritative for the account's lifetime.
- Legacy transfer and staking flows do not use the full Phase 6B finalized-receipt lifecycle.
- No address book, contact management, or recipient allow-list.
- No watch-only, hardware-wallet, multisig, or external-signer support.
- No token portfolio beyond the native ETKN balance.
- No swap, bridge, NFT, governance, or general dApp browser.
- No wallet backup/export workflow beyond authenticated seed-phrase reveal and clipboard copy.
- No cloud backup or cross-device synchronization.
- No PIN change/recovery flow or failed-attempt lockout is evident in the current implementation.
- Account deletion removes the local record but cannot affect on-chain state.

### Staking limitations

- No withdraw-unbonded, rebond, chill, or reward-claim UI.
- No projected rewards, performance history, commission analysis, or validator-risk scoring.
- Staking availability and storage decoding remain dependent on the connected runtime.

### AI Predictions limitations

- Spec 13 is intentionally exact and fail-closed; any runtime or metadata upgrade requires a new capture, review, generated bindings, and pinned fingerprint before signing is re-enabled.
- Spec 8 is limited to read-only legacy compatibility diagnostics. Its old stake, unstake, and claim signer is disabled until a fully pinned fingerprint and the persistent finalized lifecycle service are reviewed for it.
- Metadata cannot prove Root, sudo, validator, model-admin, proposer, or other origin authorization; the live dispatch result is authoritative.
- Finalized-event reconciliation is bounded and can be incomplete on a pruned RPC or when the event limit is reached. No ERA indexer is bundled.
- An unresolved or ambiguous transaction remains duplicate-protected and requires conclusive verification; it is not automatically retried.
- Controlled reports contain public addresses, calls, amounts, hashes, blocks, events, and balance/accounting evidence. Redaction removes likely secrets, but users must review report files before sharing them.
- No dedicated notifications, charting, complete settlement history, leaderboard, or model-reputation system is bundled.
- No live Phase 6B model-onboarding or complete lifecycle session was performed as part of the local implementation work.

### Security and operational risks

- Seed phrase security depends heavily on the device and platform secure-storage implementation.
- Copying an address or seed phrase places that data on the operating-system clipboard.
- A four-digit minimum PIN permits weak user-selected PINs, and no retry throttling is currently apparent.
- Network queries reveal public addresses and transaction-related information to the configured ERA node.
- The default endpoint is centralized in the application configuration; there is no in-app endpoint selector or multi-node failover UI.
- Runtime upgrades can require regenerated bindings or compatibility work, particularly for staking and AI Prediction decoding.

## Release Readiness

### Completed or prepared

- Product name and core branding.
- Android and iOS application identifiers.
- Platform launcher icons and splash assets.
- Android, iOS, Windows, macOS, Linux, and web project scaffolding.
- Privacy-policy draft.
- Store-listing metadata draft.
- Store privacy-answer drafts.
- Release-build instructions and submission checklists.
- Android release-signing configuration template.

### Remaining before production release

1. Run `flutter analyze` and `flutter test` with the recorded Flutter toolchain from a clean checkout and retain the exact results.
2. Run end-to-end QA against the intended production ERA runtime and endpoint.
3. Test account creation/import, recovery, transfers, staking, AI Predictions, offline behavior, and session lock on physical devices.
4. Verify transaction inclusion, dispatch success/failure handling, and balance reconciliation after finality.
5. Perform an independent security review of key storage, authentication, clipboard handling, transaction construction, dependency risk, and logging.
6. Decide whether the current mnemonic-at-rest model and four-digit minimum PIN satisfy the production threat model.
7. Publish a final privacy policy with real support and company contact information.
8. Complete Google Play Data Safety, Apple App Privacy, export-compliance, and any jurisdiction-specific financial/crypto declarations.
9. Create and protect production signing credentials.
10. Produce and validate signed Android App Bundle, iOS IPA, and Windows MSIX-compatible artifacts as applicable.
11. Prepare final screenshots, support URLs, review notes, and store listing content.
12. Define supported platforms explicitly and remove or clearly label unqualified targets.

## Recommended Next Priorities

1. **Release baseline:** restore a reproducible Flutter toolchain, run all checks, and record exact tool and dependency versions.
2. **End-to-end correctness:** extend integration coverage for legacy transfer/staking submission and perform the separately approved Phase 6B live test plan with designated accounts and tiny amounts.
3. **Security hardening:** add PIN retry throttling, PIN change/recovery UX, safer seed-phrase handling, and a documented platform-by-platform secure-storage threat model.
4. **History reliability:** integrate an ERA indexer or explorer API for complete transfers, staking actions, and AI Prediction history.
5. **Staking completion:** add withdraw-unbonded, rebond, chill, rewards, and clearer lifecycle guidance.
6. **AI Predictions stabilization:** review and repin every runtime upgrade, keep bounded-history limitations visible, and keep testing/governance controls isolated from release builds.
7. **Release qualification:** complete physical-device QA, signed packaging, compliance, and staged store rollout.

## Overall Assessment

ERA Wallet already has the main building blocks of a useful ERA self-custody wallet and goes beyond a simple proof of concept: it manages multiple accounts, protects access locally, reads live chain state, signs and submits transfers, provides core staking, and contains a substantial runtime-aware AI Predictions feature.

Its current maturity is best classified as **functional pre-release / controlled beta**. The core implementation is present, while production readiness depends on reproducible verification, deeper security and integration testing, completion of several lifecycle features, signed distribution artifacts, and external store/compliance work.

---

*This document reflects the repository implementation and live read-only V13 compatibility evidence available on August 28, 2026. It does not certify third-party infrastructure, production signing setup, legal compliance, or deployed store artifacts.*
