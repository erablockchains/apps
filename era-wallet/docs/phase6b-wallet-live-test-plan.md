# ERA Wallet Phase 6B live test plan

## Status

```text
LIVE_PHASE6B_TESTS_OPT_IN_ONLY: YES
LIVE_MODEL_ONBOARDING_PERFORMED_BY_THIS_IMPLEMENTATION: NO
LIVE_TRANSACTION_SUBMITTED_BY_THIS_IMPLEMENTATION: NO
AUTOMATIC_LIVE_RETRY_ALLOWED: NO
```

This document is a plan, not a record of a completed test. Discovery used read-only RPC calls. Do not begin live onboarding until a human has explicitly approved the accounts, roles, amounts, and time window and has confirmed the controlled build fingerprint.

There is no live-submission test suite in the repository. The existing Phase 6B integration tests use generated calls and mocks. If a future live suite is added, it must be disabled by default and require:

```text
RUN_ERA_LIVE_PHASE6B_TESTS=true
```

That environment variable is a reserved safety gate, not a currently implemented runner.

## Preconditions

Obtain explicit approval for a single controlled session. Record the approver and test window outside the wallet without storing credentials.

Confirm all of the following:

- use a locally built testing binary, never a store binary;
- use designated public test addresses and tiny, replaceable ETKN balances;
- no seed, mnemonic, private key, PIN, password, or secure-storage value appears in notes, logs, screenshots, shell history, or reports;
- `ENABLE_PHASE6B_TESTING_TOOLS=true` is set;
- set `ENABLE_PHASE6B_GOVERNANCE_ACTIONS=true` only when an explicitly approved governance account and action are in scope;
- endpoint is exactly `wss://eraprojects.org/` and the UI says `ERA-MAINNET`;
- genesis, spec/transaction versions, metadata hash, pallet index, and storage version match the approved fingerprint;
- the node is synchronized and the latest finalized block advances;
- all pending or `unknownNeedsVerification` journal entries are reconciled before a new intent is built;
- chain configuration permits the intended operation; default-encoded configuration values in metadata are not proof of current live values;
- fee estimation succeeds and each account retains enough spendable ETKN for the amount and fee;
- the expected signer role is understood as informational until dispatch;
- a second operator is available to review high-impact governance/settlement calls when required by the test policy.

## Approved fingerprint checklist

| Check | Expected |
| --- | --- |
| Genesis | `0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7` |
| Runtime | `era` spec `9`, transaction `1` |
| Metadata | V14 SHA-256 `26a869e3e621ec0235c4c850ec74a3fe77b9aeedc9cebf12fd566a36402bfc9e` |
| AI pallet | `AiPredictions` index `12` |
| AI storage version | `3` |
| Currency | ETKN, 18 decimals |

Stop immediately on any mismatch. Do not sign against a newer runtime until a new metadata capture, review, binding generation, compatibility pin, and wallet release are complete.

## Controlled sequence

Every numbered transaction below is separately reviewed, authenticated, submitted once, finalized, decoded, and verified from canonical storage. Never combine calls with `Utility.batch*`.

1. **Select accounts.** Record full public addresses and intended roles: model owner/applicant, possible model administrator, authorized validator/lifecycle signer, Account A, Account B, and settlement signer. Do not infer privilege from wallet labels.
2. **Verify runtime and balances.** Export diagnostics and capture finalized block, account nonces, free balances, onboarding/tokenization/staking/settlement/market configuration, and all unresolved warnings.
3. **Register the model.** Review and submit `AiPredictions.register_model` (index 0) from the approved registration account. Record hash/URI byte lengths, fee, finalized receipt, `ModelRegistered`, resulting `ModelId`, `Models`, `ModelGovernanceById`, `ModelStatsById`, `ModelIdsByOwner`, and status.
4. **Approve the model where required.** With governance explicitly enabled and approved, submit `AiPredictions.approve_model` (index 36). Verify the finalized dispatch, model/governance status, update block, and relevant event. If the chain does not require approval, record a read-only PASS with evidence; do not submit an unnecessary call.
5. **Configure submitter/delegation if required.** Submit `AiPredictions.set_model_submitter` (index 39) with `Some(AccountId32)` from the approved role, or use `None` only when intentionally revoking. Reload model governance and verify the authorized submitter. If the owner will submit and no delegate is required, record that fact without a transaction.
6. **Create a prediction.** Select only an active approved model for which the signer is owner or chain-derived authorized submitter. Submit `AiPredictions.submit_prediction` (index 2). Verify `PredictionSubmitted`, `PredictionId`, `Predictions`, `PredictionIdsByModel`, and `ActivePredictionCountByModel`.
7. **Tokenize/create the market.** When current configuration and prediction state permit, submit `AiPredictions.tokenize_prediction` (index 8). Resolve the returned `PredictionTokenId`; never substitute `PredictionId`. Verify `PredictionTokens`, `PredictionTokenByPrediction`, initial totals, lock state, settlement, and accounting.
8. **Stake YES from Account A.** Use `AiPredictions.stake_on_prediction_outcome_side` (index 31) with the canonical token ID, side `Yes`, and the smallest approved amount. The UI presets are 0.01, 0.1, and 1 ETKN; the chosen amount must still satisfy live minimum stake, balance, and fee constraints. Verify Account A balance, `PredictionTokenSideStakes`, YES total, event, and accounting.
9. **Stake NO from Account B.** Repeat index 31 independently with side `No` and Account B. Verify Account B balance, its canonical position, NO total, event, and accounting.
10. **Reconcile accounting.** Read both accounts, both positions, YES/NO totals, total escrow/stake, fees collected, treasury-related observations, lock state, and invariants at a finalized block. Record before/after base units.
11. **Validate and/or close.** If live state requires validation, submit `AiPredictions.validate_prediction` (index 3) using the approved validator and exact `PredictionOutcome`. If closing is a separate required transition, submit `AiPredictions.close_prediction` (index 4) as a second independently confirmed transaction. Do not hide two calls behind one session confirmation or one receipt.
12. **Settle.** Use the state-authorized path. Normally this is `AiPredictions.propose_prediction_outcome` (index 22), wait the on-chain dispute window, then separately submit `AiPredictions.finalize_prediction_outcome_after_dispute_window` (index 25). Use `admin_finalize_prediction_outcome` (index 24) only with separate governance approval. Verify `PredictionTokenSettlements`, final outcome, market lock, payout pool, accounting, and events after each call.
13. **Claim the winning payout.** From the winning position account, submit `AiPredictions.claim_prediction_market_payout` (index 33). Verify the side payout claim record, event, actual account balance change, total paid/claimed, and that a second claim is not available.
14. **Verify final effects.** Re-read model, prediction, token, settlement, positions, claims, counters, indexes, both participant balances, fee observations, and treasury/accounting state at finalized blocks. Reconcile the finalized event window and label any pruning gap.
15. **Export and review.** Finish the session only after every required action has its own receipt and post-state check. Save and independently inspect JSON and Markdown. Confirm no secret is present, all public identifiers and hashes are included, and overall result is correct.

## Stop conditions

Stop without retrying when:

- compatibility changes or metadata refresh fails;
- fee estimation fails;
- signer or current state differs from the reviewed confirmation;
- submission returns an ambiguous timeout or RPC error;
- lifecycle becomes `unknownNeedsVerification`;
- dispatch result or nested sudo result is unknown;
- finalized event and canonical storage disagree;
- a required post-state verification is inconclusive;
- history is pruned where the missing evidence is needed for the test conclusion;
- the intended role is rejected by the chain;
- an amount, URI, category, or hash exceeds its byte bound;
- a report would omit one of multiple independently submitted calls.

For an unknown submission, query pending extrinsics and the bounded finalized window. A not-found result in a bounded/pruned window is inconclusive, not permission to retry. A new submission is considered only after conclusive failure/not-found evidence and a fresh human review.

## Post-session review

- Compare the JSON and Markdown reports with receipts and exported diagnostics.
- Confirm every transaction hash appears once and has inclusion/finality evidence.
- Confirm each successful operator action has canonical post-state evidence.
- Confirm balances and totals use integer base units and reconcile with fees.
- Confirm the report contains no secrets or biometric/secure-storage data.
- Record RPC pruning or event-limit gaps as limitations.
- Revoke a test submitter only through a separately approved `set_model_submitter(None)` action; do not silently clean up live state.
- Disable both build flags for the next normal release build.
