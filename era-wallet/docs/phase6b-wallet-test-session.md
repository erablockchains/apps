# ERA Wallet Phase 6B controlled test sessions

## Safety contract

A Phase 6B test session is a local evidence record for a human-controlled live lifecycle. It never grants authority, never submits a batch, and never authorizes more than one transaction per confirmation.

The intended availability gate is:

```text
ENABLE_PHASE6B_TESTING_TOOLS=true
```

Operator Lab, live testing actions, and Test Reports are all hidden unless `ENABLE_PHASE6B_TESTING_TOOLS=true`. Starting or restarting a session only captures public-account/balance baselines; it never submits a transaction.

## Fixed 15-stage lifecycle

| # | Stage | Expected action kind |
| ---: | --- | --- |
| 1 | Select test accounts | Read-only |
| 2 | Verify balances and runtime | Read-only |
| 3 | Onboard or register model | One signed transaction |
| 4 | Approve model if required | Conditional one signed transaction |
| 5 | Configure delegation if required | Conditional one signed transaction |
| 6 | Create prediction | One signed transaction |
| 7 | Create or tokenize market | One signed transaction |
| 8 | Stake YES from Account A | One signed transaction |
| 9 | Stake NO from Account B | One signed transaction |
| 10 | Refresh and verify accounting | Read-only |
| 11 | Validate or close prediction | One signed transaction selected for the reviewed state transition |
| 12 | Settle market | One signed transaction selected for the reviewed state transition |
| 13 | Claim winning payout | One signed transaction |
| 14 | Verify final balances and treasury effects | Read-only |
| 15 | Export report | Local export |

Stages are ordered. A later stage whose lifecycle prerequisite did not pass must be marked `BLOCKED`.

## Evidence required per stage

Every stage record contains:

- prerequisite checks and evidence;
- the exact intended call or read operation;
- selected public signer where applicable;
- ETKN fee estimate in integer base units and display form;
- independent confirmation statement, signer, and timestamp;
- transaction-receipt reference, transaction hash, inclusion/finality blocks, dispatch result, and relevant events;
- canonical chain-state verification and evidence;
- `PASS`, `FAIL`, or `BLOCKED`;
- notes and warnings;
- completion timestamp.

A signed stage cannot pass without one separately confirmed transaction, a finalized successful receipt, and confirmed post-state. `Utility.batch`, `batch_all`, `force_batch`, multiple transactions under one confirmation, and encoded argument text in place of one exact `pallet.call` path are rejected by the domain policy.

Some live state transitions can require more than one call, for example outcome proposal followed later by finalization, or validation followed by closing. Each call requires its own wallet confirmation and finalized journal record. The ordered stage stores the primary transition receipt, while the session-scoped transaction journal is exported as supplementary evidence so separately confirmed prerequisite calls remain represented. Never compress them into a batch.

## Overall result

Aggregation is deterministic:

1. Any `FAIL` makes the overall result `FAIL`.
2. Otherwise, a `BLOCKED` stage, missing stage, or unfinished report makes the result `BLOCKED`.
3. Only all 15 passing stages with an end timestamp produce overall `PASS`.

## Report contents and redaction

JSON and Markdown exports include the wallet version, platform, network/runtime fingerprint, session ID and times, participating public addresses, model/prediction/market IDs, calls, hashes, blocks, dispatch results, events, balances, YES/NO totals, treasury/fee observations, settlement, claim, post-state evidence, warnings, the session-scoped transaction journal, and overall result.

Export is redacted recursively. Keys or labelled values associated with mnemonics, seeds, recovery phrases, private/secret keys, PINs, passcodes, passwords, passphrases, secure storage, biometrics, or private account labels are replaced with `[REDACTED]`. Likely unlabeled mnemonic phrases and private hex material are also removed. Public addresses, explicitly public keys, transaction/block/genesis hashes, prediction/model hashes, and metadata fingerprints are retained as required public evidence.

The Test Reports screen supports:

- copy summary;
- save one final JSON/Markdown pair under the app documents directory in `ERA Wallet/Phase6B Reports`, using a deterministic session-based file stem;
- share that same final pair through the platform share sheet when supported.

The report records safe artifact names rather than absolute device paths. Report files remain on the device until the user removes them. Copying puts the summary on the operating-system clipboard. Sharing hands the selected files to the operating system and any destination the user selects. Redaction reduces secret-leak risk but does not make a report private: participating addresses, calls, amounts, hashes, blocks, events, and balance/accounting evidence are public-chain-identifying data and must be reviewed before distribution.

## Current wiring status

The workspace calls `recordStage` after a matching separately confirmed transaction reaches a terminal lifecycle result. A stage is `PASS` only after finality, dispatch success, a fee estimate, and canonical post-state confirmation. Read-only stages explicitly refresh chain data. Save/share builds a prospective report containing stage 15, performs the requested export, and only after success records the export stage and finishes the session. Identifiers, public-account balance deltas, YES/NO totals, fee observations, settlement/claim state, and the session journal are included. Any missing prerequisite or inconclusive evidence keeps the report `BLOCKED`.

No live session was executed during implementation. Run the separate, explicitly approved QA plan in [phase6b-wallet-live-test-plan.md](phase6b-wallet-live-test-plan.md) before relying on a report as live release evidence.
