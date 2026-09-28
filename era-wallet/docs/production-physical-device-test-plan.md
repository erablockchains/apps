# ERA Wallet production physical-device test plan

**Release candidate:** 1.1.0+2  
**Status:** PENDING  
**Rule:** No live ETKN transaction may be performed without separate authorization, funded test accounts, recorded limits, and an approved tester.

## Evidence required for every test

Record platform/OS/device, artifact filename and SHA-256, clean or upgrade path, UTC time, expected/actual result, screenshots only where safe, public transaction hash when authorized, and PASS/FAIL/BLOCKED. Never record a recovery phrase, PIN, private key, biometric image, or unredacted secure-storage data.

## Android

| Test | Type | Result |
| --- | --- | --- |
| Clean install of checksum-verified APK/AAB | Offline/manual | PENDING |
| Upgrade from prior beta while retaining accounts and secure storage | Manual | PENDING |
| New wallet, 6-digit PIN, backup acknowledgement | Manual | PENDING |
| Valid 12/24-word mnemonic import using tester-owned fixture wallet | Manual | PENDING |
| Incorrect PIN and progressive lockout | Manual | PENDING |
| PIN change and old-PIN rejection | Manual | PENDING |
| Biometric/device-auth success, cancel, failure, and PIN fallback | Manual | PENDING |
| Background for over one minute and confirm lock | Manual | PENDING |
| Address display/copy and receive QR | Manual | PENDING |
| Recipient QR scan and camera denial recovery | Manual | PENDING |
| ETKN transfer, fee review, finality, receipt, balance reconciliation | **Live ETKN—separate authorization** | PENDING |
| Restart/kill app while an authorized transaction is pending | **Live ETKN—separate authorization** | PENDING |
| Confirm no automatic retry after ambiguous outcome | **Live ETKN—separate authorization** | PENDING |
| Staking status, bond/nominate/unbond | **Live ETKN—separate authorization** | PENDING |
| Model and prediction discovery | Read-only live network | PENDING |
| YES stake | **Live ETKN—separate authorization** | PENDING |
| NO stake from a second authorized account/device | **Live ETKN—separate authorization** | PENDING |
| Settlement observation and payout claim | **Live ETKN—separate authorization** | PENDING |
| Offline start and recovery after network returns | Manual | PENDING |
| Network loss during read and before/after submission | Manual/live as authorized | PENDING |
| Metadata/genesis mismatch blocks signing but retains diagnostics | Controlled mock endpoint; no live signing | PENDING |
| Internal report export/redaction in a separate testing-tools build | Internal build only | PENDING |
| Account deletion warnings and recovery confirmation | Manual | PENDING |
| Authenticated seed reveal | Manual | PENDING |
| Screenshot block on all wallet screens | Manual | PENDING |
| Recovery-phrase copy warning and best-effort 60-second clear | Manual | PENDING |
| Verify cleartext traffic and Android backup remain disabled | Static/device tooling | PENDING |

## Windows x64

| Test | Type | Result |
| --- | --- | --- |
| Extract the versioned ZIP into a clean folder | Manual | PENDING |
| Launch from extracted folder with EXE, DLLs, and `data` intact | Manual | PENDING |
| Confirm no console window in normal release launch | Manual | PENDING |
| Create/import wallet and persist secure storage across restart | Manual | PENDING |
| PIN lockout/change and Windows Hello/device-auth behavior | Manual | PENDING |
| Transfer/finality/reconciliation | **Live ETKN—separate authorization** | PENDING |
| Model/prediction discovery and participant lifecycle | Read-only plus separately authorized live ETKN | PENDING |
| Restart recovery during pending transaction | **Live ETKN—separate authorization** | PENDING |
| Replace application folder with a newer version without deleting user secrets | Manual | PENDING |
| Antivirus and SmartScreen behavior for signed/unsigned package | Manual | PENDING |
| Launch on a clean supported Windows machine and prevent missing-DLL errors | Manual | PENDING |
| Verify checksum before extraction and after transfer | Offline/manual | PENDING |

## Exit gate

All non-live tests must pass. Every authorized live flow must have finality and canonical state evidence. Any secret leak, duplicate submission, incorrect dispatch result, unrecoverable journal, mismatched balance/position, or signing on incompatible metadata blocks rollout.

