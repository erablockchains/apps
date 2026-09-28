# ERA Wallet live V13 compatibility

**Verified:** August 28, 2026

**Endpoint:** `wss://eraprojects.org/`
**Operation:** public read-only RPC queries only; no account was loaded or unlocked and no transaction was signed or submitted.

## Reviewed live identity

| Field | V13 value |
| --- | --- |
| Public network name | ERA |
| RPC chain display | `ERA-MAINNET` |
| Genesis hash | `0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7` |
| Runtime | `specName=era`, `specVersion=13`, `transactionVersion=1` |
| Token | ETKN, 18 decimals |
| SS58 prefix | 42 |
| Metadata | V14, 209,828 bytes, SHA-256 `5c3715502b0f4cd3c3bc124f13f7f153cd3486e0c3877dc1d685335e57ed4c3f` |
| Runtime code | 997,122 bytes, SHA-256 `ecca5baddc60d4e8522c8ea6206fec0c29175d59ddf2359e6d43201f1faa44a2` |
| AI Predictions | pallet index 12, storage version 3 |

The guarded capture reads one finalized head and pins runtime, metadata, pallet storage version, and runtime code reads to that snapshot. Generated bindings are bundled from the reviewed `era-spec13-metadata.scale` artifact; the wallet does not generate transaction bindings from an unreviewed live response.

Before balance transfers or staking transactions are constructed, the wallet refreshes chain identity, properties, runtime version, metadata and fee-RPC availability. It requires the exact metadata hash and checks the System, Balances, TransactionPayment, Session, Staking, and AI Predictions surfaces used by the wallet. Any mismatch produces an explicit compatibility error before signing. AI Prediction actions retain their additional full 40-call/32-storage typed fingerprint and runtime-WASM gate.

## Staking status and payout disclosure

The read-only gate observed:

- configured validator count: 4;
- selected session validators: 4;
- current and active era progression: active;
- authored reward points: 12,000 in each sampled completed era;
- completed-era validator rewards: zero for eras 2612 through 2615;
- on-chain `MinValidatorBond`: 0.

The wallet therefore displays this exact notice wherever the user manages staking:

> ERA staking, nomination and validator selection are active. Current validator-era payout is configured to zero, so no staking reward should be expected until ERA's capped reward mechanism is separately activated.

The future minimum validator eligibility threshold is `10,000 ETKN`, planned for V14. It is not currently enforced, and meeting it will not guarantee an active validator seat.

## Metadata and historical evidence

Current V13 artifacts use `era-spec13-*` names. Older `era-spec9-*` artifacts and Phase 6B discovery/release documents remain in the repository as historical evidence; they are not the current generation or signing pin.

## Platform model

The repository contains Android, iOS, Windows, macOS, Linux, and web Flutter targets. Windows can build Windows, Android, and web artifacts with the installed local toolchains. iOS and macOS release builds require macOS with Xcode; Linux desktop requires a Linux host with the Flutter Linux desktop toolchain.
