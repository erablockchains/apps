# ERA Wallet Privacy Policy

> **Unpublished historical draft; not a current store privacy policy.** This text predates deployed spec15 and includes controlled AI testing descriptions. Reconcile a wallet-specific V14 notice, final binary data flows and provider practices before submission; see [V14 store preparation](store-v14-preparation.md). The live eraprojects.io privacy page is a general website policy.

Last updated: July 19, 2026

**LEGAL_REVIEW: REQUIRED**
**COMPLIANCE_REVIEW: REQUIRED**

ERA Wallet ("ERA Wallet", "we", "our", or "us") provides software that helps users create, import, manage, and use ERA blockchain wallet accounts.

This Privacy Policy explains what information ERA Wallet processes, how it is used, and what choices users have.

## Summary

ERA Wallet is designed to keep sensitive wallet data on your device whenever possible.

- Your PIN is not stored in plaintext.
- Your mnemonic / seed phrase is intended to remain on your device.
- Biometric or device-authentication checks are handled by the operating system.
- The app connects to ERA blockchain infrastructure to read chain state and submit transactions.
- Public blockchain activity may be visible on-chain and cannot be deleted by ERA Wallet.

## Information We Process

### Information stored locally on your device

Depending on how you use the app, ERA Wallet may store the following on your device:

- wallet account names
- wallet public addresses
- the currently active account selection
- biometric / device-authentication preference
- PIN-related verification material
- mnemonic / seed phrase material needed to restore or use a wallet on that device
- first-run / onboarding state
- locally recorded transfer, staking, and AI Prediction activity
- a secure-storage Phase 6B transaction journal containing public signer addresses, call summaries, nonces, transaction and block hashes, dispatch/events, and verification state
- a secure-storage controlled Phase 6B checkpoint containing public participant addresses, balances, call inputs, fees, transaction/block references, stage evidence, and any completed report snapshot, but not signing material
- redacted JSON and Markdown report files when you choose to save or share a test report

Sensitive local wallet information is intended to be stored using platform secure-storage mechanisms where available.

ERA Wallet does not operate its own cloud-backup or cross-device-sync service. Your operating system, device-backup service, documents provider, or synced folder may nevertheless copy secure-storage data or saved report files according to platform behavior and your settings.

### Information sent off your device

When you use ERA Wallet to interact with the ERA network, the app may send data to ERA node endpoints or other blockchain infrastructure needed to provide wallet functionality. This can include:

- wallet public addresses
- account and balance lookup requests
- staking-related requests
- fee-estimation requests
- signed transaction data
- blockchain metadata and runtime queries
- AI Prediction model, market, position, claim, settlement, and accounting queries
- finalized block, event, and timestamp queries used for bounded transaction reconciliation

The node or RPC provider also receives the network request and may process technical connection information, such as an IP address, under its own logging, security, and retention practices. Verify the final production endpoint and provider disclosures before release.

This information is used so the app can:

- display balances and account state
- estimate fees
- submit transfers
- submit staking actions
- provide AI Prediction participant actions and separately enabled controlled testing/governance actions
- communicate with the ERA blockchain network

### Biometric and device authentication

If you enable biometric or device login, ERA Wallet asks your operating system to perform authentication. ERA Wallet does not receive or store raw fingerprint, face scan, or device-credential secrets.

### Clipboard usage

If you choose wallet features such as copying an address, seed phrase, or Phase 6B report summary, the selected content may be placed on your device clipboard at your request. Other apps or operating-system services may be able to read clipboard contents depending on your platform and settings.

### Phase 6B reports and sharing

When controlled testing tools are enabled, a report can contain participating public addresses, calls, amounts, model/prediction/market identifiers, transaction and block hashes, events, balances, settlement/claim state, and other public-chain evidence. The app applies recursive redaction intended to remove mnemonics, private keys, PIN/password material, secure-storage contents, biometric information, private labels, and likely secret material. Public-chain evidence remains intentionally visible.

Reports are not uploaded automatically. If you choose Save, JSON and Markdown files are written to the app's documents area. If you choose Share, the files are handed to your operating system and to any app, service, or recipient you select. Redaction reduces risk but does not make a report anonymous or private; review it before distribution.

## What We Do Not Intend To Collect

Based on the current app implementation, ERA Wallet is not designed to include:

- third-party advertising SDKs
- analytics SDKs
- crash-reporting SDKs
- user-tracking SDKs
- background location collection
- contact-list collection
- photo-library collection

If these features are added in a future version, this Privacy Policy should be updated before release.

## How We Use Information

We use processed information to:

- create and import wallet accounts
- store local wallet preferences and state
- protect access to the wallet with PIN and/or device authentication
- read blockchain data needed for wallet features
- estimate fees and submit blockchain transactions
- display account, transfer, and staking functionality
- display AI Prediction state, reconcile bounded finalized activity, and recover unresolved transaction status
- create local controlled-test evidence and export it only when requested
- maintain app security and integrity

## Blockchain Transparency

Blockchains are public or semi-public distributed ledgers.

If you use ERA Wallet to query balances, submit transfers, perform staking actions, or interact with AI Predictions, associated wallet addresses, calls, amounts, transaction details, model/prediction/market activity, and other blockchain metadata may become visible to blockchain nodes, infrastructure providers, and other participants in the network.

Public blockchain records generally cannot be changed or deleted by ERA Wallet once submitted.

## Data Sharing

ERA Wallet does not appear to include advertising or marketing-based data sharing in the current implementation.

However, information necessary to operate wallet functionality may be disclosed to third parties in these cases:

- ERA blockchain nodes and infrastructure providers, when the app queries network state or submits transactions
- platform service providers, when operating-system biometric or secure-storage services are used
- apps, services, or recipients you select through the platform share interface when you choose to share a report
- legal or regulatory authorities, if required by applicable law

## Data Retention

Secure-stored wallet data, transaction-journal records, and the latest controlled-test checkpoint remain on your device until replaced through the controlled-session workflow or until the relevant device/app storage is cleared. Platform behavior after uninstall varies, so uninstalling must not be treated as a guaranteed secure-storage deletion mechanism. Saved Phase 6B report files remain in the app documents area until you or the operating system removes them. Copies shared to another app, service, person, backup, or synced folder are controlled by that destination's retention practices.

Blockchain data that is submitted to the network may persist permanently or for extended periods on the ERA blockchain and supporting infrastructure.

## Security

ERA Wallet uses measures intended to reduce risk, including:

- secure local storage where supported by the platform
- PIN-derived verification material rather than plaintext PIN storage
- optional biometric / device-authentication gating
- local validation before sensitive wallet actions
- exact fail-closed Phase 6B runtime/metadata compatibility checks before signing
- submit-once transaction journaling and secret redaction for controlled-test reports

No method of storage, transmission, or computing security is guaranteed to be completely secure, and users are responsible for safeguarding their devices and backup phrases.

## Your Choices

You can:

- choose whether to enable biometric / device login where supported
- delete wallet accounts stored on the device
- remove saved report files using device file-management controls where available
- uninstall the app
- avoid copying sensitive wallet data to the clipboard unless needed
- avoid saving or sharing controlled-test reports

Because blockchain records are generally immutable, ERA Wallet cannot erase data already written to the blockchain.

## Children

ERA Wallet is not intended for children.

## International Use

If you use ERA Wallet from different countries or regions, blockchain requests and supporting infrastructure may process data across jurisdictions.

## Changes to This Policy

We may update this Privacy Policy from time to time. The latest version should be published at the privacy-policy URL used in store listings.

## Contact

- Company / Developer Name: ERA Projects
- Contact Email: support@eraprojects.io
- Privacy URL: https://www.eraprojects.io/privacy-policy.html
- Support URL: https://www.eraprojects.io/support.html

This engineering draft and the public starter policy require legal and compliance review before unrestricted public or store release.
