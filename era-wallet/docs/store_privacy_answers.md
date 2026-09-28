# ERA Wallet Store Privacy Answers

This file is a practical starter for Play Console and App Store Connect privacy forms.
It is based on the code in this repository as of July 17, 2026.

This is not legal advice. Review it against the exact release build, your infrastructure, and your legal/compliance requirements before submitting.

Ordinary store builds are expected to omit both Phase 6B controlled-tool defines, which hides governance, controlled-session, and report-export UI. If a release includes those tools, its listing and privacy answers must explicitly cover them.

## Engineering reading of current app behavior

### Local device storage

The app stores data locally for wallet operation, including:

- account names
- public addresses
- active-account selection
- biometric preference
- PIN verification material
- mnemonic / seed phrase material
- onboarding state
- wallet-submitted activity history
- a secure-storage Phase 6B transaction journal containing public signer/call/nonce/hash/block/dispatch/event/verification data, but not signing material
- a secure-storage controlled Phase 6B checkpoint containing public participant addresses, balances, call inputs, fees, transaction/block references, stage evidence, and any completed report snapshot, but not signing material
- redacted JSON and Markdown reports when the user chooses to save or share them

The app does not implement its own cloud backup or cross-device synchronization. Platform secure-storage backup, device backup, app-document backup, and synced-folder behavior still need release-target verification because the operating system or user-selected storage provider may copy local data or reports.

### Off-device communication

The app connects to the ERA network using node / RPC communication for:

- account lookups
- balance queries
- fee estimation
- staking actions
- AI Prediction model, market, position, claim, settlement, and accounting queries
- bounded finalized block/event reconciliation
- transaction submission

That means the app is not purely offline, and some user-related wallet data does leave the device during normal use.
The RPC provider can also receive connection metadata such as an IP address and may retain request logs under its own policies; confirm the production provider's actual behavior before completing either store form.

### Tracking / advertising

No advertising, analytics, or tracking SDKs were identified in the current codebase.

## Google Play Data Safety draft

### Does the app collect or share user data?

Engineering answer: likely `Yes`, because wallet addresses, AI Prediction queries, and transaction-related requests are transmitted off-device to blockchain infrastructure during normal app use. User-initiated report sharing can also disclose public-chain evidence to the selected app, service, or recipient.

### Is all data encrypted in transit?

Needs release verification.

The configured chain endpoint in the repo is:

- `wss://eraprojects.org/`

If release infrastructure remains on secure transport and all relevant remote connections use TLS / WSS, this may be `Yes`.

### Does the app provide a way for users to request deletion?

Suggested answer: `Partially / carefully assess`.

- Local app data on the device can be deleted by the user.
- Blockchain records cannot generally be deleted once submitted.

How you answer depends on the exact Play form wording and whether you treat on-chain data as collected user data under your release setup.

### Likely data types implicated

Review these carefully before submitting:

- Personal info:
  - probably `No` for name, email, phone, address unless you add account/profile services
- Financial info:
  - potentially relevant because the app is a wallet and transaction/AI Prediction activity involves amounts, balances, stakes, and payouts
- App activity:
  - no analytics stream was identified, but assess whether RPC queries, public-chain actions, and user-initiated report sharing fall within the current form's app-activity categories
- Device or other IDs:
  - likely `No` from current app logic
- User IDs:
  - potentially relevant if wallet public addresses are treated as identifiers in your disclosure strategy

### Suggested conservative internal interpretation

- Local-only wallet metadata and secrets are stored on device.
- Wallet public addresses, chain-state queries, and transaction data are transmitted to ERA infrastructure to provide core functionality.
- Phase 6B reports are generated locally and retain public-chain-identifying evidence after secret redaction. Saving creates local files; copying or sharing discloses the selected content to the clipboard, operating system, and user-selected destination, and platform backup/sync behavior must be assessed separately.
- No advertising or analytics SDK data flows were identified.

## Apple App Privacy draft

Apple asks about data collected by the app and third-party partners.

### Likely answers based on current code

- Data Used to Track You:
  - likely `No`
- Data Linked to You:
  - possibly wallet public address, balance/stake/payout information, and transaction-related data, depending on how Apple interprets networked wallet functionality and association with an identifiable account
- Data Not Linked to You:
  - possibly diagnostics `No`
  - identifiers `review carefully`
  - financial info `review carefully`

### Conservative Apple review notes

- The app stores wallet data locally on device.
- The app uses secure storage and OS authentication features.
- The app communicates with blockchain nodes to provide wallet functionality.
- The app stores a local transaction journal and can create redacted reports containing public addresses and public-chain activity.
- Report copy/save/share is user initiated; sharing passes data to the selected destination and should be reflected consistently in all disclosures.
- No ad-tech or cross-app tracking SDKs were identified.

## Apple export compliance draft

The app uses cryptographic functionality, including wallet and secure-storage related cryptography.

Based on Apple's current export-compliance guidance, you should expect to answer encryption questions in App Store Connect and determine whether additional documentation is needed for your distribution footprint.

Official references:

- App privacy:
  https://developer.apple.com/help/app-store-connect/reference/app-privacy
- Export compliance overview:
  https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/
- Encryption documentation reference:
  https://developer.apple.com/help/app-store-connect/reference/app-information/export-compliance-documentation-for-encryption/

## What still needs to be customized before publishing

Replace these placeholders everywhere:

- privacy policy URL
- support URL
- contact email
- legal entity / publisher name
- final infrastructure description, if you use your own RPC, proxy, monitoring, or backend services

## Recommended next pre-submission checks

1. Decide your exact privacy-positioning for wallet public addresses and blockchain transaction data.
2. Decide how the current store forms classify local transaction-journal data and user-initiated sharing of redacted public-chain reports.
3. Verify secure-storage checkpoint and report-file retention, uninstall behavior, platform backup/sync behavior, clipboard behavior, and the share destinations available in each release target.
4. Publish the privacy policy from a real public HTTPS URL.
5. Reconcile Play Data Safety, Apple App Privacy, and the privacy policy so they say the same thing.
6. Recheck the release build for any analytics, crash reporting, or extra SDKs before final submission.
