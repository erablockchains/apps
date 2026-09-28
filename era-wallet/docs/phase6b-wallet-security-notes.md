# ERA Wallet Phase 6B security notes

## Security posture

Phase 6B preserves the wallet's local self-custody model. It adds no backend custody, hardcoded account, privileged seed, separate governance credential store, or chain/runtime mutation. Public-chain actions remain irreversible and can consume real ETKN.

The main Phase 6B risks are signing against drifted metadata, exposing privileged controls in a normal build, submitting a duplicate after an ambiguous response, misidentifying an account's role, leaking signing material into evidence, and presenting incomplete chain history as complete.

## Build-time separation

- `ENABLE_PHASE6B_TESTING_TOOLS` defaults to `false`.
- `ENABLE_PHASE6B_GOVERNANCE_ACTIONS` defaults to `false` and is ignored unless testing tools are enabled.
- Operator Lab and its permanent live-chain banner are testing-only.
- Governance controls require both flags plus an exact compatible runtime.
- Store/production builds must set neither flag, or set both explicitly to false.

Testing lifecycle actions, Operator Lab, and the local report-session controls are hidden when `ENABLE_PHASE6B_TESTING_TOOLS` is false. Governance controls additionally require `ENABLE_PHASE6B_GOVERNANCE_ACTIONS`; signing policy independently rejects an unavailable audience even if a caller attempts to reach it programmatically.

## Runtime and binding integrity

Before signing, the wallet decodes the connected node's actual V14 metadata and checks the reviewed ERA genesis, `specName`, exact spec and transaction versions, metadata version/hash, AI pallet name/index/prefix, storage version, and typed call/storage signatures. The probe refreshes metadata and runtime immediately before signing. The checked runtime context is carried into the signer, which fetches genesis/spec/transaction identity again and refuses to sign if it changed. Any incompatible drift disables Phase 6B signing.

Only the exact reviewed spec-9 fingerprint enables signing or Phase 6B. A structurally compatible spec-8 runtime is read-only: its legacy one-shot signer is not exposed, it never enables Phase 6B testing or governance, and it is never decoded as spec 9.

The binding generator verifies the pinned metadata SHA-256 and V14/pallet identity before writing. Never regenerate a release directly from an unreviewed live response.

## Authentication and confirmation

Operator submission authenticates before fee estimation and again immediately before signing. Confirmation shows:

- exact `AiPredictions.call_name`;
- decoded argument summary;
- full public signer address and local account label;
- exact ETKN fee estimate;
- expected authorization caveat;
- persistent ERA-MAINNET/real-ETKN warning.

Ordinary actions require an explicit review checkbox. High-impact calls require the exact displayed phrase. The dialog cannot submit when fee estimation is unavailable. Each review authorizes one call only.

The wallet does not claim an account is Root, sudo, validator, model admin, or settlement proposer. Metadata does not encode origins; finalized dispatch is authoritative.

## Signing material

- Mnemonics are loaded from the existing secure account store only for local signing.
- Operator screens do not provide mnemonic clipboard controls.
- No mnemonic or private key belongs in an intent, transaction record, report, diagnostic, screenshot, log, fixture, or CI variable.
- The transaction journal stores public signer, safe argument summaries, nonce, hashes, blocks, dispatch evidence, events, and verification—not signing material.
- App lifecycle handling clears the model search field and removes focus when the workspace becomes inactive/paused/hidden; the wallet's existing session-lock/authentication behavior remains authoritative for app access.

Do not add a new operator key store. Operator actions use ordinary wallet accounts and the same PIN/device-auth controls.

## Duplicate and ambiguous-submission policy

Transaction intents have deterministic non-secret keys. The duplicate guard remains active during preparation, authentication, signing, submission, inclusion, finalization, and unknown verification. Journal mutation is serialized, unresolved records are retained ahead of terminal history, and unresolved records are restored from secure storage after restart. Corrupt, unsupported, or undecodable journal data fails closed; it is never silently replaced with an empty history.

The wallet submits once. Dropped/invalid/usurped results are failures; retraction, finality timeout, watch timeout, lost RPC response, unknown dispatch, or inconclusive required post-state verification becomes `unknownNeedsVerification`.

No automatic retry exists. Retry remains disabled while pending, succeeded, or inconclusive. Bounded verification can permit a fresh human-reviewed submission only after conclusive failure or a conclusive not-found outcome. The current verifier deliberately treats absence from its bounded finalized window, or a pruned gap, as inconclusive.

## Dispatch and post-state evidence

Finalized block events are decoded with spec-9 generated bindings. The lifecycle decoder recognizes `system.ExtrinsicSuccess`, `system.ExtrinsicFailed`, relevant AI events, and nested sudo results when present. AI module errors are resolved for pallet index 12.

Calls marked as requiring post-state proof additionally require canonical storage verification. A missing verifier, verifier error, or inconclusive result cannot promote a finalized successful dispatch to success; the record remains `unknownNeedsVerification`.

## Report redaction

All report exports use the same recursive redaction boundary. Sensitive map keys are redacted at any depth, including maps inside lists. Labelled secret strings, likely mnemonic phrases, and likely raw private hex material are removed. The denied categories include:

- mnemonic, seed, and recovery phrase;
- private/secret key and key material;
- PIN, passcode, password, and passphrase;
- secure-storage contents;
- biometric data/information.

Public addresses, explicitly public keys, transaction/block/genesis hashes, prediction/model hashes, and metadata fingerprints are retained because they are required public evidence. Redaction is a defense in depth, not a guarantee that a report is private. Always inspect exported JSON and Markdown before copying, saving, or sharing.

Saved reports use deterministic session-based filenames in the app documents area and remain there until removed. Copying places a summary on the operating-system clipboard. Sharing passes the final JSON/Markdown pair to the operating system and the user's selected destination. Those files identify public accounts and activity even when all signing material has been removed.

## Chain history and privacy

Account addresses, calls, amounts, and chain events are public once submitted. WSS protects transport, not blockchain confidentiality.

Reconciliation scans finalized blocks and reads Timestamp pallet values. It is bounded and can be incomplete on a pruned RPC. The wallet labels gaps and prefers canonical storage over finalized events over local history. An external indexer is not bundled.

## Incident guidance

If a secret appears in a report or log, stop sharing it, remove the artifact from all distribution locations, rotate/replace the affected wallet account, and treat the key as compromised. Do not rely on deleting a committed secret from the latest Git revision.

If metadata drift or an unknown transaction appears, stop signing, export diagnostics without secrets, preserve the transaction journal, and obtain a reviewed runtime/binding update or conclusive chain evidence before continuing.
