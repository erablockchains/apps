# ERA Wallet Store Metadata

> **Historical V13/Phase 6B draft — do not submit.** Its AI-market feature claims, publisher shorthand and placeholder contacts are not the V14 store listing. Use [the V14 store-preparation record](store-v14-preparation.md) for current proposed wording and remaining gates.

Last updated: July 17, 2026

This file contains draft submission text for Google Play and App Store Connect.
Review and customize it before publishing.

## Product identity

- App name: `ERA Wallet`
- Android package: `com.eraprojects.era_wallet`
- iOS bundle ID: `com.eraprojects.erawallet`
- Developer / publisher: `ERA Projects`

## Google Play listing draft

### App name

`ERA Wallet`

### Short description

`Self-custody ERA wallet for accounts, transfers, staking, and AI Predictions.`

### Full description

`ERA Wallet helps you create, import, and manage ERA blockchain accounts with a local-first security model.

Use ERA Wallet to:

- create or import ERA accounts
- manage multiple wallet accounts on one device
- protect access with PIN and optional biometric or device authentication
- view balances and account state
- estimate transaction fees
- send ERA to other addresses
- use staking actions from within the wallet
- browse ERA AI Prediction models, predictions, markets, positions, and claims
- stake on supported YES/NO outcome markets and claim eligible payouts

ERA Wallet is designed to keep sensitive wallet information on your device whenever possible. Seed phrases and wallet access controls are intended to stay under your control on the device you use.

Security features include:

- PIN-protected wallet access
- optional biometric or device-authentication unlock
- secure local storage where supported by your platform
- session re-lock after inactivity
- finalized AI Prediction transaction tracking and duplicate-submit protection

Important:

- Blockchain activity may be visible on the public or network-visible ERA ledger.
- The configured ERA node/RPC provider receives wallet queries and signed transactions needed for app functionality.
- Users are responsible for safely backing up their seed phrases.
- Losing your recovery phrase may result in permanent loss of access to your assets.

ERA Wallet does not rely on advertising SDKs or in-app tracking in the current implementation.

Always verify addresses, transaction amounts, and backup phrases carefully before confirming sensitive actions.`

### App category suggestion

- Finance

### Suggested store keywords for your own notes

- ERA wallet
- blockchain wallet
- crypto wallet
- staking
- biometric wallet
- self-custody wallet

### Contact details to fill in

- Support email: `support@example.com`
- Privacy policy URL: `https://example.com/privacy.html`
- Website: `https://example.com`

## App Store Connect draft

### Name

`ERA Wallet`

### Subtitle

`Secure ERA self-custody wallet`

### Promotional text

`Manage ERA accounts, transfers, staking, and AI Prediction markets with PIN and biometric protection.`

### Description

`ERA Wallet is a self-custody wallet for the ERA blockchain.

Create or import accounts, manage balances, estimate fees, send ERA, use staking features, and interact with supported ERA AI Prediction markets from one app.

Features:

- multi-account wallet support
- PIN-protected access
- optional biometric or device-authentication unlock
- local-first handling of sensitive wallet data
- fee estimation before sending
- ERA transfers and staking tools
- AI Prediction model, market, position, and claim views
- supported YES/NO market staking and payout claims
- session lock after inactivity
- finalized AI Prediction transaction tracking and duplicate-submit protection

ERA Wallet is designed to keep sensitive wallet information on your device whenever possible. Public blockchain activity may be visible on-chain and cannot be deleted once submitted.

Users are responsible for safeguarding their recovery phrases and verifying all transaction details before approval.`

### Keywords

`ERA,wallet,crypto,blockchain,staking,self-custody,finance`

### Support URL

`https://example.com/support`

### Marketing URL

`https://example.com`

### Privacy Policy URL

`https://example.com/privacy.html`

## Screenshots to prepare

Prepare clean screenshots for at least these views:

1. First-run splash / unlock screen
2. Home wallet dashboard with balance
3. Accounts management screen
4. Send funds screen
5. Staking screen
6. Security / biometric settings state
7. AI Predictions market or position view from the release-default participant surface

## Review notes draft

Use this in store review notes after customizing:

`ERA Wallet is a self-custody ERA blockchain wallet. Sensitive wallet data is intended to remain on device. The app uses secure local storage, PIN protection, optional biometric/device authentication, and a local transaction journal containing public-chain transaction evidence but no signing material. Network communication sends public-address and chain-state queries, fee requests, and signed transactions to the configured ERA node/RPC provider. Ordinary store builds disable Phase 6B controlled testing, governance, report-export, and operator tools. There is no advertising SDK or user-tracking SDK in the current release build.`

## Final placeholders you must replace

- `support@example.com`
- `https://example.com`
- `https://example.com/support`
- `https://example.com/privacy.html`
- any wording that should reflect your final legal entity or regional compliance posture
