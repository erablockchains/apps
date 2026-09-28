# ERA Wallet production incident response

## Non-negotiable support rule

> ERA support must never ask for a recovery phrase, private key, PIN, or password.

## First response

1. Stop further signing when the outcome or runtime is uncertain.
2. Do not retry an ambiguous transaction.
3. Preserve the application, public transaction journal, artifact filename/checksum, wallet version, endpoint, UTC time, public address, and transaction hash.
4. Refresh Network & Release diagnostics and reconcile finalized chain state.
5. Share only redacted public evidence through the official support channel.
6. Classify severity, assign an owner, and decide whether rollout must stop.

## Incident playbooks

| Incident | Required response |
| --- | --- |
| Transaction appears stuck | Preserve hash/journal; check finalized chain and pending pool; never auto-retry; mark verification required until conclusive. |
| Duplicate submission concern | Stop signing; compare intent keys, hashes, nonces, finalized events, and canonical state; escalate immediately. |
| Wallet balance mismatch | Refresh finalized account state; compare pending fees/locks; avoid spending until reconciled. |
| Position mismatch | Refresh canonical market/position storage; compare finalized receipt; treat local history as secondary. |
| Payout mismatch | Verify settlement outcome, side, claim record, accounting, dispatch result, and finalized post-state. |
| Runtime metadata incompatibility | Signing must remain blocked; capture redacted fingerprint diagnostics; require reviewed bindings before re-enabling. |
| Endpoint outage | Do not switch automatically; publish status; use a replacement only after identity review and a new approved build. |
| Corrupted local storage | Stop mutation; preserve device/app data where lawful; restore wallet only from user-held recovery phrase on a clean installation. |
| Forgotten PIN | Explain that support cannot bypass it; restore from recovery phrase through an approved clean reset procedure. |
| Lost recovery phrase | Do not claim recoverability; if the unlocked wallet still works, instruct the user to create and verify a new wallet before moving assets. |
| Suspected phishing | Stop communication with the sender; preserve URL/file/hash; use official support; rotate assets to a new wallet if a phrase was exposed. |
| Malicious wallet copy | Publish official warning and hashes; contact host/store; preserve evidence; consider release/signing-key response. |
| Compromised release artifact | Stop distribution, revoke/rotate signing material as applicable, publish incident notice, rebuild from validated source, issue new hashes. |
| Checksum mismatch | Do not install/run; delete the file; re-download only from the official page; report the source and observed hash. |

## Severity and stop conditions

- **Severity 1:** secret/signing-key compromise, malicious artifact, unauthorized transaction, systemic duplicate, or critical vulnerability—stop rollout immediately.
- **Severity 2:** material balance/position/payout mismatch, runtime drift, repeated recovery failure—pause affected features/cohort.
- **Severity 3:** isolated recoverable failure or documentation/support issue—track and resolve before next stage.

No support agent can reverse a finalized blockchain transaction.

