# ERA Wallet AI Predictions Phase 6A QA (Historical)

This checklist is retained only as a record of the Phase 6A implementation. **Do not run its former transaction or admin steps against a live runtime.** The minimum-version gate and one-shot spec-8 signer used during that phase have been superseded.

Current behavior is deliberately stricter:

- a structurally compatible spec-8 runtime is read-only and cannot sign stake, unstake, claim, test-session, or governance calls
- Phase 6B signing requires the exact reviewed ERA-MAINNET spec-9 fingerprint, including genesis, runtime/transaction versions, Metadata V14 and runtime-WASM hashes, pallet identity, storage version, and reviewed call/storage shapes
- every controlled transaction uses the persistent submit-once lifecycle, finalized dispatch evidence, bounded reconciliation, and required post-state verification
- governance UI remains hidden unless the separate controlled Phase 6B governance define is enabled in an explicitly approved local build

Use these maintained documents instead:

- [Phase 6B wallet architecture](phase6b-wallet-architecture.md)
- [Phase 6B operator mode](phase6b-wallet-operator-mode.md)
- [Phase 6B controlled live-test plan](phase6b-wallet-live-test-plan.md)
- [Phase 6B security notes](phase6b-wallet-security-notes.md)

The controlled live-test plan is a plan, not evidence that onboarding or live transactions were performed.
