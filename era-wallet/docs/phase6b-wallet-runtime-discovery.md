# ERA Phase 6B wallet runtime discovery

## Scope and evidence

This document is the wallet compatibility record for the pinned ERA live-runtime capture in `artifacts/phase6b`. It records metadata facts exactly and keeps inference separate from facts. No transaction was submitted while producing this record.

Primary evidence:

- `artifacts/phase6b/era-spec9-metadata.scale` — SCALE metadata returned by the live node.
- `artifacts/phase6b/era-spec9-metadata.json` — decoded metadata used for the tables below.
- `artifacts/phase6b/era-spec9-runtime-rpc.json` — direct runtime/RPC capture.
- `artifacts/phase6b/era-spec9-runtime.json` — normalized capture plus pallet summary and the AI Predictions storage-version key.

Capture and compatibility identifiers:

| Field | Captured value |
| --- | --- |
| Capture time | `2026-07-16T19:24:56.702Z` |
| Endpoint | `wss://eraprojects.org/` |
| Chain display name | `ERA-MAINNET` |
| Genesis hash | `0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7` |
| Runtime `specName` / `implName` | `era` / `era` |
| Runtime `specVersion` | `9` |
| Authoring / implementation version | `1` / `1` |
| Transaction / system / state version | `1` / `1` / `1` |
| Metadata version | V14 (`14`) |
| Metadata magic number | `1635018093` (`meta`) |
| SCALE metadata size | `108814` bytes |
| SCALE metadata SHA-256 | `26a869e3e621ec0235c4c850ec74a3fe77b9aeedc9cebf12fd566a36402bfc9e` |
| Decoded metadata JSON SHA-256 | `dc55cd21484d38002ed160fa15af6166f8057bf831979c0f833d877e0b7e5ac3` |
| Runtime `:code` size | `713764` bytes (hash evidence only; WASM not stored) |
| Captured finalized head | `0x9bd3c8761bc15cdab3b4d9df69fff58fc24124d0ec31241a80a4360f6e7db992` |
| Node health at capture | `peers=4`, `isSyncing=false`, `shouldHavePeers=true` |
| Native token / decimals | `ETKN` / `18` |
| SS58 prefix | `42` |
| Approved production WASM SHA-256 | `2bb522963e929575483d8d7bc791f236d0ef0db19f83546a6a5d2f766f6ffdf6` |

The production WASM hash is the approved deployment checkpoint supplied for Phase 6B. This audit independently read the live `:code` value through `state_getStorage`, hashed the returned 713,764-byte runtime in memory, and obtained the same SHA-256. The WASM itself is intentionally not stored in this wallet repository.

The raw SCALE metadata file is the reproducible metadata identifier for wallet binding generation. Regeneration must use the pinned file, not an unpinned future response from the live endpoint.

## Reproducible local tooling

Offline verification is the default and validates the metadata byte length and
hash, metadata version, runtime summary, AI storage-version key/raw value, and
the approved WASM length/hash evidence:

```powershell
dart run tool/phase6b_metadata_discovery.dart --offline
```

Normalizing the reviewed local artifacts remains offline:

```powershell
dart run tool/phase6b_metadata_discovery.dart --write-artifacts
```

Network access is never implicit. A deliberate read-only refresh requires an
explicit live flag:

```powershell
node tool/capture_phase6b_metadata.mjs --live
dart run tool/phase6b_metadata_discovery.dart --live
```

The JavaScript capture requires Node.js 22 or newer because it uses Node's
built-in global WebSocket client.

Each live tool first obtains one finalized head and supplies that same block
hash to `state_getRuntimeVersion`, `state_getMetadata`, the AI storage-version
read, and the `:code` read. Artifact writes also require the ERA Wallet package
root. The binding generator accepts only the reviewed local SCALE file and
stages output under the validated project root.

## Runtime and extrinsic identifiers

The runtime-version RPC returned these API ID/version pairs. The RPC response carries IDs and versions, not human-readable API names. Runtime source is unavailable, so names are deliberately not guessed.

| Runtime API ID | Version |
| --- | ---: |
| `0xab3c0572291feb8b` | 1 |
| `0xdf6acb689907609b` | 5 |
| `0x37e397fc7c91f5e4` | 2 |
| `0x40fe3ad401f8959a` | 6 |
| `0xd2bc9897eed08f15` | 3 |
| `0xbc9d89904f5b923f` | 1 |
| `0x37c8bb1350a9a2a8` | 4 |
| `0xcbca25e39f142387` | 2 |
| `0xed99c5acb25eedf5` | 3 |
| `0xfbc577b9d747efd6` | 1 |

Metadata V14 identifies runtime type `259` and an extrinsic format with version `4`, address type `104`, outer call type `114`, signature type `247`, and signed-extra type `249`.

| Signed extension | Extra type | Additional-signed type |
| --- | ---: | ---: |
| `CheckNonZeroSender` | 250 | 37 |
| `CheckSpecVersion` | 251 | 4 |
| `CheckTxVersion` | 252 | 4 |
| `CheckGenesis` | 253 | 13 |
| `CheckMortality` | 254 | 13 |
| `CheckNonce` | 256 | 37 |
| `CheckWeight` | 257 | 37 |
| `ChargeTransactionPayment` | 258 | 37 |

## AI Predictions pallet identity

| Field | Exact metadata value |
| --- | --- |
| Pallet name | `AiPredictions` |
| Pallet index | `12` |
| Storage prefix | `AiPredictions` |
| Call type | `153` (`pallet_ai_predictions::pallet::Call`) |
| Event type | `53` (`pallet_ai_predictions::pallet::Event`) |
| Error type | `245` (`pallet_ai_predictions::pallet::Error`) |

The pallet storage version is FRAME's reserved storage-version value, not one of the 32 declared pallet storage entries:

| Field | Value |
| --- | --- |
| Storage-version key | `0x507d4f0bb08b9e2c877acf6d401c17174e7b9012096b41c4eb3aaf947f6ea429` |
| Live raw value | `0x0300` |
| SCALE interpretation | little-endian `u16` value `3` |
| Confirmed pallet storage version | `3` |

## SCALE aliases used below

| Metadata alias | Portable type | Resolved SCALE shape |
| --- | ---: | --- |
| `T::AccountId` / `AccountId` | 0 | `sp_core::crypto::AccountId32` |
| `BalanceOf<T>` / `Balance` | 6 | `u128` |
| `BlockNumberFor<T>` / `BlockNumber` | 4 | `u32` |
| `ModelId` | 12 | `u64` |
| `PredictionId` | 12 | `u64` |
| `PredictionTokenId` | 12 | `u64` |
| `DisputeId` | 12 | `u64` |
| `Vec<u8>` | 14 | `Vec<u8>` |
| `Option<T::AccountId>` | 38 | `Option<AccountId32>` |
| `Option<BlockNumber>` | 48 | `Option<u32>` |
| `u16` | 60 | `u16` |

## Origin and authorization caveat

Metadata V14 does **not** encode dispatch-origin requirements. The AI call variants also have empty metadata documentation. Consequently, the origin column below is conservative and explicitly inferred only from call names, arguments, emitted actor fields, storage records, and error names. It is not proof of Root, sudo, signed, owner, validator, or governance eligibility. Wallet UI must treat every role assessment as informational, submit only after an explicit review, and regard the chain dispatch result as authoritative.

## Calls

All 40 call variants are present and have contiguous call indices `0..39`.

| Index | Exact call | Exact arguments and SCALE types | Origin/authorization evidence |
| ---: | --- | --- | --- |
| 0 | `register_model` | `model_hash: Vec<u8>`; `metadata_uri: Vec<u8>` | Not encoded. A signed owner-like actor is inferred from `ModelRegistered.owner`; public registration may also be gated by onboarding configuration. |
| 1 | `update_model` | `model_id: ModelId (u64)`; `model_hash: Vec<u8>`; `metadata_uri: Vec<u8>` | Not encoded. Model-owner guard is inferred from `NotModelOwner`. |
| 2 | `submit_prediction` | `model_id: ModelId (u64)`; `domain: PredictionDomain`; `category_code: Vec<u8>`; `prediction_hash: Vec<u8>`; `metadata_uri: Vec<u8>`; `confidence: u8`; `expires_at: BlockNumberFor<T> (u32)` | Not encoded. Owner or configured model submitter is inferred from `NotAuthorizedModelSubmitter`. |
| 3 | `validate_prediction` | `prediction_id: PredictionId (u64)`; `outcome: PredictionOutcome` | Not encoded. An authorized-validator guard is inferred from `NotAuthorizedValidator` and the event's `validator`. |
| 4 | `close_prediction` | `prediction_id: PredictionId (u64)` | Not encoded. An owner/control guard is plausible from `NotPredictionOwner`, but the exact accepted origin is unknown. |
| 5 | `authorize_validator` | `account: T::AccountId (AccountId32)` | Not encoded. Privileged/control action inferred from its effect; exact origin unknown. |
| 6 | `remove_validator` | `account: T::AccountId (AccountId32)` | Not encoded. Privileged/control action inferred from its effect; exact origin unknown. |
| 7 | `set_tokenization_config` | `tokenization_enabled: bool`; `transfers_enabled: bool` | Not encoded. Global configuration action; exact privileged origin unknown. |
| 8 | `tokenize_prediction` | `prediction_id: PredictionId (u64)`; `metadata_uri: Vec<u8>`; `transferable: bool` | Not encoded. Prediction-owner/control guard inferred from token owner fields and `NotPredictionOwner`; exact rule unknown. |
| 9 | `approve_prediction_token_transfer` | `token_id: PredictionTokenId (u64)`; `approved: T::AccountId (AccountId32)` | Not encoded. Token-owner authorization inferred from approval storage/event. |
| 10 | `revoke_prediction_token_approval` | `token_id: PredictionTokenId (u64)` | Not encoded. Token-owner authorization inferred from approval storage/event. |
| 11 | `transfer_prediction_token` | `token_id: PredictionTokenId (u64)`; `to: T::AccountId (AccountId32)` | Not encoded. Owner or approved actor inferred from `TransferNotApproved` and token ownership. |
| 12 | `freeze_prediction_token` | `token_id: PredictionTokenId (u64)` | Not encoded. Control action; whether owner, admin, or another role is accepted is unknown. |
| 13 | `unfreeze_prediction_token` | `token_id: PredictionTokenId (u64)` | Not encoded. Control action; whether owner, admin, or another role is accepted is unknown. |
| 14 | `burn_prediction_token` | `token_id: PredictionTokenId (u64)` | Not encoded. Token-owner/control authorization inferred; exact rule unknown. |
| 15 | `update_prediction_token_metadata` | `token_id: PredictionTokenId (u64)`; `metadata_uri: Vec<u8>` | Not encoded. Token-owner/control authorization inferred; exact rule unknown. |
| 16 | `set_staking_config` | `staking_enabled: bool`; `min_stake: BalanceOf<T> (u128)` | Not encoded. Global configuration action; exact privileged origin unknown. |
| 17 | `stake_on_prediction_token` | `token_id: PredictionTokenId (u64)`; `amount: BalanceOf<T> (u128)` | Not encoded. Signed staker inferred from event and `(token_id, account)` position key. |
| 18 | `unstake_prediction_token` | `token_id: PredictionTokenId (u64)`; `amount: BalanceOf<T> (u128)` | Not encoded. Signed position owner inferred from `(token_id, account)` position key. |
| 19 | `lock_prediction_token_stake` | `token_id: PredictionTokenId (u64)` | Not encoded. Control action; exact owner/admin/settlement role unknown. |
| 20 | `release_prediction_token_stake` | `token_id: PredictionTokenId (u64)` | Not encoded. Control action; exact owner/admin/settlement role unknown. |
| 21 | `set_settlement_config` | `settlement_enabled: bool`; `dispute_window_blocks: BlockNumberFor<T> (u32)`; `min_dispute_bond: BalanceOf<T> (u128)` | Not encoded. Global configuration action; exact privileged origin unknown. |
| 22 | `propose_prediction_outcome` | `token_id: PredictionTokenId (u64)`; `proposed_outcome: SettlementOutcome`; `evidence_uri: Vec<u8>` | Not encoded. A settlement-proposer guard is explicit only through `NotAuthorizedSettlementProposer`; exact eligible role unknown. |
| 23 | `dispute_prediction_outcome` | `token_id: PredictionTokenId (u64)`; `reason: DisputeReason`; `evidence_uri: Vec<u8>`; `bond: BalanceOf<T> (u128)` | Not encoded. Signed disputer inferred from event/storage actor and bond. |
| 24 | `admin_finalize_prediction_outcome` | `token_id: PredictionTokenId (u64)`; `final_outcome: SettlementOutcome`; `evidence_uri: Vec<u8>` | Not encoded. Privileged/admin-like origin inferred only from the exact call name. |
| 25 | `finalize_prediction_outcome_after_dispute_window` | `token_id: PredictionTokenId (u64)` | Not encoded. May be permissionless or signed after the window; metadata cannot distinguish. |
| 26 | `cancel_prediction_settlement` | `token_id: PredictionTokenId (u64)`; `evidence_uri: Vec<u8>` | Not encoded. Control action; exact origin unknown. |
| 27 | `set_settlement_economics_config` | `economics_enabled: bool`; `slash_incorrect: bool`; `slash_fraudulent: bool` | Not encoded. Global configuration action; exact privileged origin unknown. |
| 28 | `claim_prediction_token_settlement` | `token_id: PredictionTokenId (u64)` | Not encoded. Signed staker/claimant inferred from event and claim key. |
| 29 | `resolve_prediction_dispute_bond` | `dispute_id: DisputeId (u64)`; `accepted: bool` | Not encoded. Privileged dispute-resolution action inferred; exact origin unknown. |
| 30 | `set_market_economics_config` | `market_enabled: bool`; `allow_unstake_before_settlement: bool` | Not encoded. Global configuration action; exact privileged origin unknown. |
| 31 | `stake_on_prediction_outcome_side` | `token_id: PredictionTokenId (u64)`; `side: PredictionOutcomeSide`; `amount: BalanceOf<T> (u128)` | Not encoded. Signed staker inferred from event and `(token_id, account)` position key. |
| 32 | `unstake_from_prediction_outcome_side` | `token_id: PredictionTokenId (u64)`; `side: PredictionOutcomeSide`; `amount: BalanceOf<T> (u128)` | Not encoded. Signed position owner inferred from event/key; state/config guards also apply. |
| 33 | `claim_prediction_market_payout` | `token_id: PredictionTokenId (u64)` | Not encoded. Signed position owner/claimant inferred from event and claim key. |
| 34 | `set_market_fee_config` | `fees_enabled: bool`; `fee_bps: u16`; `treasury_enabled: bool` | Not encoded. Global configuration action; exact privileged origin unknown. |
| 35 | `set_model_onboarding_config` | `config: ModelOnboardingSettings` | Not encoded. Global Phase 6B onboarding configuration; exact privileged origin unknown. |
| 36 | `approve_model` | `model_id: ModelId (u64)` | Not encoded. Model-admin authorization inferred from `NotAuthorizedModelAdmin`. |
| 37 | `suspend_model` | `model_id: ModelId (u64)` | Not encoded. Model-admin authorization inferred from `NotAuthorizedModelAdmin`. |
| 38 | `reject_model` | `model_id: ModelId (u64)` | Not encoded. Model-admin authorization inferred from `NotAuthorizedModelAdmin`. |
| 39 | `set_model_submitter` | `model_id: ModelId (u64)`; `submitter: Option<T::AccountId> (Option<AccountId32>)` | Not encoded. Model owner/admin-like authorization inferred; exact accepted role unknown. `None` represents revocation/removal of the configured submitter. |

Calls `35..39` are the late call-index range that supplies the Phase 6B onboarding/governance layer while preserving calls `0..34`.

## Storage

There are exactly 32 declared entries. `Optional` is the metadata storage modifier for `OptionQuery`; `Default` returns the encoded default when no value is present. For a multi-key map, V14 represents the key as a tuple plus one hasher per tuple element.

| Storage item | Modifier | Shape | Key SCALE type | Hasher(s) | Value SCALE type |
| --- | --- | --- | --- | --- | --- |
| `NextModelId` | Default | Plain | — | — | `u64` (type 12) |
| `NextPredictionId` | Default | Plain | — | — | `u64` (type 12) |
| `Models` | Optional | Map | `u64` (type 12, `ModelId`) | `Blake2_128Concat` | `pallet_ai_predictions::AiModel` (type 213) |
| `Predictions` | Optional | Map | `u64` (type 12, `PredictionId`) | `Blake2_128Concat` | `pallet_ai_predictions::Prediction` (type 216) |
| `ModelStatsById` | Optional | Map | `u64` (type 12, `ModelId`) | `Blake2_128Concat` | `pallet_ai_predictions::ModelStats` (type 220) |
| `ModelGovernanceById` | Optional | Map | `u64` (type 12, `ModelId`) | `Blake2_128Concat` | `pallet_ai_predictions::ModelGovernance` (type 221) |
| `ModelOnboardingConfig` | Default | Plain | — | — | `pallet_ai_predictions::ModelOnboardingSettings` (type 54) |
| `ModelIdsByOwner` | Default | Map | `AccountId32` (type 0) | `Blake2_128Concat` | `BoundedVec<u64>` (type 223) |
| `PredictionIdsByModel` | Default | Map | `u64` (type 12, `ModelId`) | `Blake2_128Concat` | `BoundedVec<u64>` (type 225) |
| `ActivePredictionCountByModel` | Default | Map | `u64` (type 12, `ModelId`) | `Blake2_128Concat` | `u32` (type 4) |
| `AuthorizedValidators` | Default | Map | `AccountId32` (type 0) | `Blake2_128Concat` | `bool` (type 8) |
| `NextPredictionTokenId` | Default | Plain | — | — | `u64` (type 12) |
| `PredictionTokens` | Optional | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `pallet_ai_predictions::PredictionToken` (type 226) |
| `PredictionTokenByPrediction` | Optional | Map | `u64` (type 12, `PredictionId`) | `Blake2_128Concat` | `u64` (type 12, `PredictionTokenId`) |
| `PredictionTokenApprovals` | Optional | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `AccountId32` (type 0) |
| `TokenizationConfig` | Default | Plain | — | — | `pallet_ai_predictions::TokenizationSettings` (type 227) |
| `StakingConfig` | Default | Plain | — | — | `pallet_ai_predictions::StakingSettings` (type 228) |
| `PredictionTokenStakes` | Optional | Map | `(u64 token_id, AccountId32 account)` (type 229) | `Blake2_128Concat`, `Blake2_128Concat` | `pallet_ai_predictions::PredictionTokenStake` (type 230) |
| `PredictionTokenTotalStake` | Default | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `u128` (type 6) |
| `PredictionTokenStakeLocked` | Default | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `bool` (type 8) |
| `SettlementConfig` | Default | Plain | — | — | `pallet_ai_predictions::SettlementSettings` (type 231) |
| `PredictionTokenSettlements` | Optional | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `pallet_ai_predictions::PredictionTokenSettlement` (type 232) |
| `NextDisputeId` | Default | Plain | — | — | `u64` (type 12) |
| `PredictionTokenDisputes` | Optional | Map | `u64` (type 12, `DisputeId`) | `Blake2_128Concat` | `pallet_ai_predictions::PredictionTokenDispute` (type 236) |
| `SettlementEconomicsConfig` | Default | Plain | — | — | `pallet_ai_predictions::SettlementEconomicsSettings` (type 238) |
| `PredictionTokenSettlementClaims` | Optional | Map | `(u64 token_id, AccountId32 account)` (type 229) | `Blake2_128Concat`, `Blake2_128Concat` | `pallet_ai_predictions::PredictionTokenSettlementClaim` (type 239) |
| `PredictionMarketEconomicsConfig` | Default | Plain | — | — | `pallet_ai_predictions::PredictionMarketEconomicsSettings` (type 240) |
| `PredictionTokenSideStakes` | Optional | Map | `(u64 token_id, AccountId32 account)` (type 229) | `Blake2_128Concat`, `Blake2_128Concat` | `pallet_ai_predictions::PredictionSideStake` (type 241) |
| `PredictionTokenSideTotals` | Default | Map | `(u64 token_id, PredictionOutcomeSide side)` (type 242) | `Blake2_128Concat`, `Blake2_128Concat` | `u128` (type 6) |
| `PredictionTokenSidePayoutClaims` | Optional | Map | `(u64 token_id, AccountId32 account)` (type 229) | `Blake2_128Concat`, `Blake2_128Concat` | `pallet_ai_predictions::PredictionSidePayoutClaim` (type 243) |
| `PredictionTokenMarketLocked` | Default | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `bool` (type 8) |
| `PredictionTokenMarketAccounting` | Default | Map | `u64` (type 12, `PredictionTokenId`) | `Blake2_128Concat` | `pallet_ai_predictions::PredictionMarketAccounting` (type 244) |

Decoded defaults for the six configuration entries are:

| Storage item | Decoded default |
| --- | --- |
| `ModelOnboardingConfig` | registration enabled; prediction submission enabled; market creation enabled; public registration disabled; approval required; maximum 32 active predictions/model |
| `TokenizationConfig` | tokenization disabled; transfers disabled |
| `StakingConfig` | staking disabled; minimum stake `0` |
| `SettlementConfig` | settlement disabled; dispute window `0`; minimum dispute bond `0` |
| `SettlementEconomicsConfig` | economics disabled; incorrect slashing disabled; fraudulent slashing disabled |
| `PredictionMarketEconomicsConfig` | market disabled; pre-settlement unstake allowed; fees disabled; fee `0` bps; treasury enabled |

Counter, total, lock, authorization, and accounting `Default` entries decode to numeric zero, `false`, an empty bounded vector, or an all-zero structure as appropriate. `Optional` map defaults encode `None`.

## Constants

All five pallet constants have portable type `4` (`u32`).

| Constant | Raw little-endian bytes | Decoded value |
| --- | --- | ---: |
| `MaxHashLen` | `80 00 00 00` | 128 |
| `MaxMetadataUriLen` | `00 01 00 00` | 256 |
| `MaxCategoryCodeLen` | `60 00 00 00` | 96 |
| `MaxModelsPerOwner` | `40 00 00 00` | 64 |
| `MaxPredictionsPerModel` | `00 04 00 00` | 1024 |

These constants correspond to the bounded hash, URI, category-code, owner-model index, and model-prediction index fields. Bounds must be checked in bytes before SCALE encoding.

## Enums

Every listed variant is a unit variant with the exact SCALE discriminant/index shown.

### `PredictionDomain` (type 55)

| Index | Variant |
| ---: | --- |
| 0 | `Enterprise` |
| 1 | `Finance` |
| 2 | `Risk` |
| 3 | `Market` |
| 4 | `SupplyChain` |
| 5 | `MediaEntertainment` |
| 6 | `GamingVirtualEconomy` |
| 7 | `AiBenchmark` |
| 8 | `WeatherClimate` |
| 9 | `CommunitySocial` |
| 10 | `SportsEventsPermitted` |
| 11 | `EraEcosystem` |
| 12 | `Other` |

### `PredictionOutcome` (type 56)

| Index | Variant |
| ---: | --- |
| 0 | `Successful` |
| 1 | `Failed` |
| 2 | `Inconclusive` |

### `SettlementOutcome` (type 57)

| Index | Variant |
| ---: | --- |
| 0 | `Correct` |
| 1 | `Incorrect` |
| 2 | `Inconclusive` |
| 3 | `Cancelled` |
| 4 | `Fraudulent` |

### `DisputeReason` (type 58)

| Index | Variant |
| ---: | --- |
| 0 | `WrongOutcome` |
| 1 | `InvalidSource` |
| 2 | `SourceUnavailable` |
| 3 | `AmbiguousPrediction` |
| 4 | `MarketManipulation` |
| 5 | `DuplicateOrFraudulentPrediction` |
| 6 | `TechnicalError` |
| 7 | `Other` |

### `PredictionOutcomeSide` (type 59)

| Index | Variant |
| ---: | --- |
| 0 | `Yes` |
| 1 | `No` |

### `PredictionStatus` (type 218)

| Index | Variant |
| ---: | --- |
| 0 | `Open` |
| 1 | `Validated` |
| 2 | `Closed` |
| 3 | `Expired` |

### `ModelStatus` (type 222)

| Index | Variant |
| ---: | --- |
| 0 | `Pending` |
| 1 | `Approved` |
| 2 | `Suspended` |
| 3 | `Rejected` |

### `SettlementStatus` (type 233)

| Index | Variant |
| ---: | --- |
| 0 | `NotStarted` |
| 1 | `OutcomeProposed` |
| 2 | `DisputeWindowOpen` |
| 3 | `Disputed` |
| 4 | `Finalized` |
| 5 | `Cancelled` |

There is no separate token-status or market-status enum in the metadata. Token state is represented by `transferable`, `frozen`, and `burned` booleans; market locking is a separate boolean storage entry; market outcome derives from the settlement record.

## Canonical structures

### Model and governance

`ModelOnboardingSettings` (type 54):

| Field | SCALE type |
| --- | --- |
| `model_registration_enabled` | `bool` |
| `prediction_submission_enabled` | `bool` |
| `market_creation_enabled` | `bool` |
| `public_model_registration_enabled` | `bool` |
| `require_model_approval` | `bool` |
| `max_active_predictions_per_model` | `u32` |

`AiModel` (type 213):

| Field | SCALE type |
| --- | --- |
| `owner` | `AccountId32` |
| `model_hash` | `BoundedHash` = `BoundedVec<u8>` |
| `metadata_uri` | `BoundedUri` = `BoundedVec<u8>` |
| `registered_at` | `u32` block number |
| `updated_at` | `Option<u32>` block number |
| `active` | `bool` |

`ModelStats` (type 220) contains five `u64` fields: `total_predictions`, `validated_predictions`, `successful_predictions`, `failed_predictions`, and `inconclusive_predictions`.

`ModelGovernance` (type 221):

| Field | SCALE type |
| --- | --- |
| `status` | `ModelStatus` |
| `authorized_submitter` | `Option<AccountId32>` |
| `updated_at` | `u32` block number |

The live metadata exposes one optional authorized submitter per model. It does not expose a separate multi-delegate collection, scope enum, expiry, or delegation status record. Wallet delegation UI must therefore model only this exact optional submitter unless a future compatible metadata fingerprint proves more fields.

### Prediction

`Prediction` (type 216):

| Field | SCALE type |
| --- | --- |
| `model_id` | `u64` |
| `submitter` | `AccountId32` |
| `domain` | `PredictionDomain` |
| `category_code` | `BoundedCategoryCode` = `BoundedVec<u8>` |
| `prediction_hash` | `BoundedHash` = `BoundedVec<u8>` |
| `metadata_uri` | `BoundedUri` = `BoundedVec<u8>` |
| `confidence` | `u8` |
| `created_at` | `u32` block number |
| `expires_at` | `u32` block number |
| `status` | `PredictionStatus` |
| `outcome` | `Option<PredictionOutcome>` |
| `validator` | `Option<AccountId32>` |
| `validated_at` | `Option<u32>` block number |

### Tokenization and staking

`PredictionToken` (type 226):

| Field | SCALE type |
| --- | --- |
| `prediction_id` | `u64` |
| `owner` | `AccountId32` |
| `metadata_uri` | `BoundedUri` = `BoundedVec<u8>` |
| `created_at` | `u32` block number |
| `updated_at` | `Option<u32>` block number |
| `transferable` | `bool` |
| `frozen` | `bool` |
| `burned` | `bool` |

`TokenizationSettings` (type 227) contains `tokenization_enabled: bool` and `transfers_enabled: bool`.

`StakingSettings` (type 228) contains `staking_enabled: bool` and `min_stake: u128`.

`PredictionTokenStake` (type 230) contains `amount: u128`, `created_at: u32`, and `updated_at: Option<u32>`.

### Settlement and dispute

`SettlementSettings` (type 231) contains `settlement_enabled: bool`, `dispute_window_blocks: u32`, and `min_dispute_bond: u128`.

`PredictionTokenSettlement` (type 232):

| Field | SCALE type |
| --- | --- |
| `token_id` | `u64` |
| `status` | `SettlementStatus` |
| `proposed_outcome` | `Option<SettlementOutcome>` |
| `final_outcome` | `Option<SettlementOutcome>` |
| `proposed_by` | `Option<AccountId32>` |
| `finalized_by` | `Option<AccountId32>` |
| `proposed_at` | `Option<u32>` block number |
| `dispute_until` | `Option<u32>` block number |
| `finalized_at` | `Option<u32>` block number |
| `evidence_uri` | `Option<BoundedUri>` |
| `total_stake_at_finalization` | `u128` |
| `dispute_count` | `u32` |

`PredictionTokenDispute` (type 236):

| Field | SCALE type |
| --- | --- |
| `dispute_id` | `u64` |
| `token_id` | `u64` |
| `disputed_by` | `AccountId32` |
| `reason` | `DisputeReason` |
| `evidence_uri` | `BoundedUri` |
| `bond` | `u128` |
| `submitted_at` | `u32` block number |
| `resolved` | `bool` |
| `accepted` | `Option<bool>` |

`SettlementEconomicsSettings` (type 238) contains `economics_enabled: bool`, `slash_incorrect: bool`, and `slash_fraudulent: bool`.

`PredictionTokenSettlementClaim` (type 239) contains `claimed_at: u32`, `refunded: u128`, and `slashed: u128`.

### YES/NO market and accounting

`PredictionMarketEconomicsSettings` (type 240):

| Field | SCALE type |
| --- | --- |
| `market_enabled` | `bool` |
| `allow_unstake_before_settlement` | `bool` |
| `fees_enabled` | `bool` |
| `fee_bps` | `u16` |
| `treasury_enabled` | `bool` |

`PredictionSideStake` (type 241) contains `side: PredictionOutcomeSide`, `amount: u128`, `staked_at: u32`, and `updated_at: Option<u32>`.

`PredictionSidePayoutClaim` (type 243) contains `claimed_at: u32`, `stake_returned: u128`, `reward_paid: u128`, and `slashed: u128`.

`PredictionMarketAccounting` (type 244) contains five `u128` fields: `fees_collected`, `remainders_collected`, `total_paid`, `total_refunded`, and `total_slashed`.

No treasury account address or treasury balance is stored in this pallet metadata. `treasury_enabled` and accounting totals are observable here; an exact treasury destination/effect must be derived from finalized balance events or other runtime configuration, not invented by the wallet.

## Events

All 42 events are listed with exact event indices and fields.

| Index | Exact event | Exact fields and SCALE types |
| ---: | --- | --- |
| 0 | `ModelRegistered` | `model_id: u64`; `owner: AccountId32` |
| 1 | `ModelUpdated` | `model_id: u64`; `owner: AccountId32` |
| 2 | `ModelApproved` | `model_id: u64` |
| 3 | `ModelSuspended` | `model_id: u64` |
| 4 | `ModelRejected` | `model_id: u64` |
| 5 | `ModelSubmitterUpdated` | `model_id: u64`; `submitter: Option<AccountId32>` |
| 6 | `ModelOnboardingConfigUpdated` | `config: ModelOnboardingSettings` |
| 7 | `PredictionOpened` | `prediction_id: u64`; `model_id: u64` |
| 8 | `PredictionSubmitted` | `prediction_id: u64`; `model_id: u64`; `submitter: AccountId32`; `domain: PredictionDomain` |
| 9 | `PredictionValidated` | `prediction_id: u64`; `model_id: u64`; `validator: AccountId32`; `outcome: PredictionOutcome` |
| 10 | `PredictionClosed` | `prediction_id: u64` |
| 11 | `TokenizationConfigUpdated` | `tokenization_enabled: bool`; `transfers_enabled: bool` |
| 12 | `PredictionTokenized` | `prediction_id: u64`; `token_id: u64`; `owner: AccountId32` |
| 13 | `PredictionTokenTransferred` | `token_id: u64`; `from: AccountId32`; `to: AccountId32` |
| 14 | `PredictionTokenTransferApproved` | `token_id: u64`; `owner: AccountId32`; `approved: AccountId32` |
| 15 | `PredictionTokenApprovalRevoked` | `token_id: u64`; `owner: AccountId32` |
| 16 | `PredictionTokenFrozen` | `token_id: u64` |
| 17 | `PredictionTokenUnfrozen` | `token_id: u64` |
| 18 | `PredictionTokenBurned` | `token_id: u64` |
| 19 | `PredictionTokenMetadataUpdated` | `token_id: u64`; `owner: AccountId32` |
| 20 | `StakingConfigUpdated` | `staking_enabled: bool`; `min_stake: u128` |
| 21 | `PredictionTokenStakeAdded` | `token_id: u64`; `staker: AccountId32`; `amount: u128`; `total_stake: u128` |
| 22 | `PredictionTokenStakeRemoved` | `token_id: u64`; `staker: AccountId32`; `amount: u128`; `remaining_stake: u128` |
| 23 | `PredictionTokenStakeLocked` | `token_id: u64` |
| 24 | `PredictionTokenStakeReleased` | `token_id: u64` |
| 25 | `SettlementConfigUpdated` | `settlement_enabled: bool`; `dispute_window_blocks: u32`; `min_dispute_bond: u128` |
| 26 | `PredictionOutcomeProposed` | `token_id: u64`; `proposed_outcome: SettlementOutcome`; `proposed_by: Option<AccountId32>`; `dispute_until: u32` |
| 27 | `PredictionOutcomeDisputed` | `token_id: u64`; `dispute_id: u64`; `disputed_by: AccountId32`; `reason: DisputeReason`; `bond: u128` |
| 28 | `PredictionOutcomeFinalized` | `token_id: u64`; `final_outcome: SettlementOutcome`; `finalized_by: Option<AccountId32>` |
| 29 | `PredictionSettlementCancelled` | `token_id: u64` |
| 30 | `ValidatorAuthorized` | `account: AccountId32` |
| 31 | `ValidatorRemoved` | `account: AccountId32` |
| 32 | `SettlementEconomicsConfigUpdated` | `economics_enabled: bool`; `slash_incorrect: bool`; `slash_fraudulent: bool` |
| 33 | `PredictionTokenSettlementClaimed` | `token_id: u64`; `staker: AccountId32`; `refunded: u128`; `slashed: u128` |
| 34 | `PredictionDisputeBondResolved` | `dispute_id: u64`; `token_id: u64`; `disputed_by: AccountId32`; `accepted: bool`; `bond: u128` |
| 35 | `PredictionMarketEconomicsConfigUpdated` | `market_enabled: bool`; `allow_unstake_before_settlement: bool` |
| 36 | `PredictionOutcomeSideStaked` | `token_id: u64`; `staker: AccountId32`; `side: PredictionOutcomeSide`; `amount: u128`; `total_for_side: u128` |
| 37 | `PredictionOutcomeSideUnstaked` | `token_id: u64`; `staker: AccountId32`; `side: PredictionOutcomeSide`; `amount: u128`; `remaining_stake: u128` |
| 38 | `PredictionTokenMarketLocked` | `token_id: u64` |
| 39 | `PredictionMarketPayoutClaimed` | `token_id: u64`; `staker: AccountId32`; `side: PredictionOutcomeSide`; `stake_returned: u128`; `reward_paid: u128`; `slashed: u128` |
| 40 | `PredictionMarketFeeConfigUpdated` | `fees_enabled: bool`; `fee_bps: u16`; `treasury_enabled: bool` |
| 41 | `PredictionMarketAccountingUpdated` | `token_id: u64`; `fees_collected: u128`; `remainders_collected: u128`; `total_paid: u128`; `total_refunded: u128`; `total_slashed: u128` |

## Errors

The pallet error metadata contains 76 unit variants and no error documentation. The numeric value is the pallet-local module-error index; a complete dispatch decoder must combine pallet index `12` with this local index.

| Index | Exact error | Index | Exact error |
| ---: | --- | ---: | --- |
| 0 | `ModelNotFound` | 38 | `DisputeWindowStillOpen` |
| 1 | `PredictionNotFound` | 39 | `DisputeBondBelowMinimum` |
| 2 | `NotModelOwner` | 40 | `InvalidSettlementEvidence` |
| 3 | `InvalidConfidence` | 41 | `OutcomeNotProposed` |
| 4 | `PredictionExpired` | 42 | `CannotDisputeFinalizedSettlement` |
| 5 | `PredictionAlreadyValidated` | 43 | `NotAuthorizedSettlementProposer` |
| 6 | `PredictionAlreadyClosed` | 44 | `SettlementEconomicsDisabled` |
| 7 | `NotAuthorizedValidator` | 45 | `SettlementNotFinalized` |
| 8 | `InvalidMetadata` | 46 | `SettlementAlreadyClaimed` |
| 9 | `InvalidModelHash` | 47 | `SettlementClaimNotAvailable` |
| 10 | `InvalidPredictionHash` | 48 | `DisputeNotFound` |
| 11 | `InvalidCategoryCode` | 49 | `DisputeAlreadyResolved` |
| 12 | `ModelInactive` | 50 | `MarketEconomicsDisabled` |
| 13 | `Overflow` | 51 | `MarketAlreadyLocked` |
| 14 | `TokenizationDisabled` | 52 | `MarketStakeAmountZero` |
| 15 | `TransfersDisabled` | 53 | `MarketStakeNotFound` |
| 16 | `PredictionAlreadyTokenized` | 54 | `MarketStakeSideMismatch` |
| 17 | `PredictionTokenNotFound` | 55 | `MarketUnstakeDisabled` |
| 18 | `NotPredictionOwner` | 56 | `MarketPayoutAlreadyClaimed` |
| 19 | `NotPredictionTokenOwner` | 57 | `MarketPayoutNotAvailable` |
| 20 | `TokenFrozen` | 58 | `MarketNoWinningStake` |
| 21 | `TokenBurned` | 59 | `MarketLosingSideCannotClaim` |
| 22 | `TokenNotTransferable` | 60 | `MarketFeeBpsTooHigh` |
| 23 | `TransferNotApproved` | 61 | `InvalidMarketOutcome` |
| 24 | `CannotTransferToSelf` | 62 | `NotPermitted` |
| 25 | `StakingDisabled` | 63 | `ModelRegistrationDisabled` |
| 26 | `StakeAmountZero` | 64 | `PublicModelRegistrationDisabled` |
| 27 | `StakeBelowMinimum` | 65 | `PredictionSubmissionDisabled` |
| 28 | `StakeNotFound` | 66 | `MarketCreationDisabled` |
| 29 | `InsufficientStake` | 67 | `ModelNotApproved` |
| 30 | `StakeLocked` | 68 | `ModelSuspended` |
| 31 | `SettlementDisabled` | 69 | `ModelRejected` |
| 32 | `SettlementAlreadyStarted` | 70 | `NotAuthorizedModelAdmin` |
| 33 | `SettlementNotFound` | 71 | `NotAuthorizedModelSubmitter` |
| 34 | `SettlementAlreadyFinalized` | 72 | `ModelOwnerIndexFull` |
| 35 | `SettlementNotFinalizable` | 73 | `PredictionModelIndexFull` |
| 36 | `SettlementNotDisputable` | 74 | `TooManyActivePredictions` |
| 37 | `DisputeWindowClosed` | 75 | `PredictionNotOpen` |

## Lifecycle relationships established by metadata

The canonical identifiers are distinct:

1. `ModelId` indexes `Models`, governance, stats, and per-model prediction indexes.
2. `PredictionId` indexes `Predictions` and maps to at most one token through `PredictionTokenByPrediction`.
3. `PredictionTokenId` indexes the token, token stakes, settlement, YES/NO positions/totals/claims, lock state, and accounting.
4. `DisputeId` indexes dispute records.

The exact metadata-supported sequence is therefore model registration/governance, prediction submission/validation/closing, prediction tokenization, optional token-level staking and/or YES/NO side staking, settlement proposal/dispute/finalization, and the corresponding claim path. Metadata alone does not prove every state-transition prerequisite; storage must be refreshed and dispatch results decoded after every call.

## Spec-8 wallet expectations versus live spec 9

| Existing wallet expectation | Live spec-9 fact | Required compatibility consequence |
| --- | --- | --- |
| Compatibility is `specName == era && specVersion >= 8`. | Live runtime is `era` spec 9, pallet 12, storage version 3, with exact call/storage/type requirements. | Introduce explicit unavailable, Phase 6A participant, Phase 6B participant, and Phase 6B operator levels; never gate only on version. |
| Generated bindings cover only standard pallets and embed runtime spec 1. | AI call/event/error types are 153/53/245 and the outer runtime includes pallet index 12. | Regenerate from the pinned SCALE metadata before decoding live AI events or using typed AI storage/calls. |
| Pallet discovery is heuristic and call indices are discarded. | Exact identity is `AiPredictions` index 12, with call indices 0–39. | Fingerprint pallet name/index, all required call indices, storage signatures, metadata hash, and storage version. |
| Participant calls accept a wallet `predictionId`. | Side stake/unstake/claim calls 31–33 accept `token_id: PredictionTokenId`, not `prediction_id`. | Resolve `PredictionTokenByPrediction` and pass the canonical token ID; do not reuse the prediction ID semantically. |
| The three participant names are stake, unstake, and claim. | Those exact names are preserved at indices 31, 32, and 33. | Legacy name discovery can identify them, but exact indices/types and token semantics must also match. |
| Guessed admin list includes registration, submission, validation, closing, validator authorization, and market config. | Spec 9 exposes 40 calls, including exact Phase 6B calls 35–39 and full token, staking, settlement, dispute, fee, and accounting controls. | Replace the broad guessed admin list with metadata-fingerprinted participant/testing/governance capability sets. |
| Models contain only display title/status/raw data. | Canonical model, stats, governance, owner index, authorized submitter, active count, and bounded indexes are typed storage. | Use typed records and display exact `ModelStatus`, owner, submitter, counters, and index completeness. |
| Prediction/model records are found by field-name heuristics. | Exact types 213 and 216 and their enum layouts are pinned above. | Remove heuristic primary decoding for spec 9; keep raw/debug fallback only behind diagnostics. |
| Lists silently stop at 25. | Bounds are 64 models/owner and 1024 predictions/model, while global counters are `u64`. | Use indexes and bounded pagination with explicit completeness/limit labels. |
| Positions and claim state are reconstructed locally. | Canonical token stakes, side stakes, totals, settlement claims, side payout claims, locks, and accounting all exist in storage. | Make chain storage primary, finalized events secondary, and local history supplementary. |
| Claim submission is locally treated as claimed at hash submission. | Separate canonical claim records and claim events exist; errors distinguish unavailable/already claimed/losing side. | Mark success only after finalized dispatch success plus post-state verification. |
| Market availability is inferred from names. | `PredictionMarketEconomicsConfig`, side totals, locks, claims, accounting, and exact calls 30–34 are present. | Detect all required calls/storage/types and enforce current config/state. |
| Chain display `ERA-MAINNET` is normalized to `ERA`. | Authoritative live display name is `ERA-MAINNET`. | Preserve the live chain name in diagnostics and controlled-testing confirmations. |
| Older static runtime event codecs omit AI events. | AI event variant is at outer pallet index 12 with 42 inner variants. | Old `System.Events` decoding is incompatible and must not be used for spec-9 AI reconciliation. |
| Metadata mismatch produces only missing-call notes. | A reproducible hash, pallet index, call indices, storage version, and signed-extension set are known. | Disable Phase 6B signing on any incompatible fingerprint change and explain the exact mismatch. |

## Source, origin, and pruning limitations

- Live runtime source was not available in the repository or pinned artifacts. This document therefore does not claim exact internal state-transition code, fee routing, slashing formulas, or dispatch-origin implementations.
- Metadata docs for all 40 AI calls, all 42 AI events, and all 76 AI errors are empty. In particular, metadata does not encode Root, sudo, signed, owner, validator, model-admin, or settlement-proposer origins. The origin notes above are explicitly non-authoritative inferences.
- The approved WASM hash and byte length were verified from the live `:code` response and are retained as evidence, but the WASM file is intentionally not stored, so offline source correlation is unavailable.
- The capture proves metadata and runtime values at one finalized-head snapshot. A later runtime upgrade, metadata change, pallet-index change, storage migration, or signed-extension change invalidates this compatibility fingerprint until reviewed.
- `system_health` proves that the queried node was synced at capture; it does not prove archival retention. The capture did not establish the node's pruning horizon or guarantee that historic block bodies, events, timestamps, or state remain queryable.
- Wallet reconciliation must scan finalized blocks only, query `Timestamp.Now` at the corresponding block hash, bound its scan, and label results incomplete when historical data is unavailable. It must not silently treat a pruned RPC result as an empty history.
- No ERA indexer endpoint is pinned here. RPC event scanning can provide bounded evidence, not lifetime-complete account history; the reconciliation interface should allow an indexer to supplement it later.
- Role checks performed locally are advisory. A call is successful only after finalized `System.ExtrinsicSuccess` (and nested `Sudo.Sudid` where applicable), the expected AI event, and verified post-state. Ambiguous submission/finality outcomes must not be retried automatically.

## Binding and signing gate

For this exact capture, a Phase 6B signing gate should require at minimum:

- genesis hash `0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7`;
- `specName=era`, `specVersion=9`, and `transactionVersion=1`;
- metadata V14 SHA-256 `26a869e3e621ec0235c4c850ec74a3fe77b9aeedc9cebf12fd566a36402bfc9e`;
- `AiPredictions` pallet index `12` and storage version `3`;
- exact required call names, indices, arguments, and portable types from this document;
- exact required storage names, modifiers, tuple-key shapes, hashers, and value types;
- compatible extrinsic version and signed extensions.

Any mismatch must disable Phase 6B signing. Read-only diagnostics may remain available, clearly marked incompatible, while a new metadata snapshot is reviewed and bindings are regenerated.
