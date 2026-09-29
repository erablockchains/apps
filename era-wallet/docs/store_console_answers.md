# ERA Wallet Store Console Answers

> **Historical V13/Phase 6B draft — do not submit.** Its AI functionality and form answers are not approved V14 declarations. Use [the V14 store-preparation record](store-v14-preparation.md) and review the final store forms at submission time.

Last updated: July 17, 2026

This file is a field-by-field starter for Google Play Console and App Store Connect.
It is based on the current repository behavior and should be reviewed against the final release build.

This is not legal advice. It is an engineering-aligned submission draft.

## Google Play Console

### App content: Data safety

Use these as conservative draft answers.

#### 1. Does your app collect or share any of the required user data types?

Suggested answer: `Yes`

Why:

- The app sends wallet public addresses, chain and AI Prediction queries, transaction-related requests, and signed transaction data to ERA node/RPC infrastructure during normal operation. The provider may also process connection metadata such as an IP address.
- A user can deliberately share a redacted controlled-test report containing public-chain-identifying evidence when those non-default tools are enabled.

#### 2. Is all of the user data collected by your app encrypted in transit?

Suggested answer: `Yes`, if your production endpoint remains secure and all remote traffic uses TLS / WSS.

Current repo evidence:

- The configured endpoint is `wss://eraprojects.org/`

Before answering `Yes`, verify the final release build does not use any insecure HTTP or WS endpoints.

#### 3. Do you provide a way for users to request that their data is deleted?

Suggested answer: `No` in the strict store-form sense, unless you provide an external deletion/contact workflow.

Reasoning:

- Users can delete local app data on-device.
- However, blockchain records and network-visible transaction history are not generally erasable.
- Unless you operate a backend that stores user data and offers deletion, a broad `Yes` may be misleading.

#### 4. Data types likely implicated

These are the categories most likely to matter for this app.

##### Personal info

- Name: `No`
- Email address: `No`
- User IDs: `Review carefully`

Conservative engineering position:

- If you treat wallet public addresses as user identifiers for disclosure purposes, this may be `Yes`.
- If you treat them as public blockchain artifacts rather than app-managed personal identifiers, you may decide `No`.

For consistency and lower policy risk, a conservative disclosure strategy is:

- User IDs: `Yes`

##### Financial info

Conservative draft:

- Financial info: `Yes`

Reasoning:

- The app is a wallet that handles balances, transaction flows, and staking-related financial activity.

##### App activity

- App interactions: `No`
- In-app search history: `No`
- Installed apps: `No`
- Other user-generated content categories: `No`, unless you later add support/contact/profile services

##### Messages

- All: `No`

##### Photos and videos

- All: `No`

##### Audio files

- All: `No`

##### Files and docs

- Review the exact form wording. The app can create JSON/Markdown report files locally and share them only at the user's request in controlled builds; it does not upload them automatically or collect them for an ERA Wallet backend.

##### Calendar

- All: `No`

##### Contacts

- All: `No`

##### Location

- Approximate location: `No`
- Precise location: `No`

##### Web browsing

- Web browsing history: `No`

##### Device or other IDs

- Device or other IDs: `No`

#### 5. For the data types you mark as collected

If you choose the conservative route above, the most likely marked data types are:

- User IDs
- Financial info

Suggested handling answers:

##### User IDs

- Collected: `Yes`
- Shared: `No`, unless you define blockchain node transmission as third-party sharing in your policy posture
- Processed ephemerally: `No`
- Required for app functionality: `Yes`
- Purpose: `App functionality`

##### Financial info

- Collected: `Yes`
- Shared: `No`, unless you define blockchain node transmission as third-party sharing
- Processed ephemerally: `No`
- Required for app functionality: `Yes`
- Purpose: `App functionality`

#### 6. Tracking / advertising declarations

Suggested answers:

- Data is not used for tracking: `Yes`
- No advertising or marketing SDKs: `Yes`

#### 7. Privacy policy

Required:

- Add your public privacy policy URL

Use the final hosted version of [`web/privacy.html`](../web/privacy.html), after replacing every placeholder and verifying that it matches the exact release build.

## Apple App Store Connect

### App Privacy

Apple’s privacy questionnaire is not identical to Play’s form.
Use these as conservative draft answers.

#### 1. Do you or your third-party partners collect data from this app?

Suggested answer: `Yes`

Reasoning:

- The app communicates with ERA node/RPC infrastructure using wallet public addresses, chain queries, and transaction-related requests. The provider may process connection metadata such as an IP address.

#### 2. Do you use data for tracking?

Suggested answer: `No`

Reasoning:

- No advertising or cross-app tracking SDKs were identified in the current codebase.

#### 3. Data types to review conservatively

Suggested conservative selections:

- Identifiers: `Yes`
- Financial Info: `Yes`

Suggested non-selections from the current codebase:

- Contact Info: `No`
- Location: `No`
- Contacts: `No`
- Browsing History: `No`
- Search History: `No`
- Health & Fitness: `No`
- Sensitive Info: `No`
- Purchases: `No`
- Usage Data: `No`
- Diagnostics: `No`

#### 4. For data you declare as collected

Suggested conservative answers:

##### Identifiers

- Linked to the user: `Yes`
- Used for tracking: `No`
- Purpose:
  - App functionality

Rationale:

- Wallet public addresses can function as persistent account-level identifiers in the app and across blockchain interactions.

##### Financial Info

- Linked to the user: `Yes`
- Used for tracking: `No`
- Purpose:
  - App functionality

Rationale:

- The wallet handles balances, transfers, and staking-related financial activity.

### Export compliance

Suggested working expectation:

- You will need to answer encryption questions in App Store Connect.
- Because the app uses wallet and secure-storage cryptography, do not assume the exemption path automatically clears without review.

Before submission:

1. Review the final release build’s cryptography usage.
2. Confirm your Apple Developer account owner is comfortable answering export-compliance questions.
3. Keep your App Privacy answers, privacy policy, and review notes aligned.

## Recommended conservative strategy

If you want the lowest practical store-policy risk:

1. Treat wallet public addresses as identifiers in store disclosures.
2. Treat wallet transaction and balance handling as financial information.
3. Say `No` to tracking.
4. Say `No` to ads, analytics, crash reporting, location, contacts, media, and diagnostics unless you add them later.
5. Keep the privacy policy explicit that data is primarily local, but blockchain interactions necessarily transmit network-visible information.
6. Verify platform backup/sync behavior for secure storage and app-document report files; the app has no first-party cloud-sync service, but the operating system or a user-selected provider may copy local data.

## Final manual checks before submitting forms

1. Confirm the production RPC endpoint is still `wss://` and not downgraded.
2. Confirm no analytics, ad, or crash SDK has been added.
3. Confirm your published privacy policy URL is live and public.
4. Confirm Play Data safety, Apple App Privacy, and your privacy policy say the same thing.
5. Confirm ordinary store builds omit both Phase 6B controlled-tool defines, or update the listing and disclosures if that release decision changes.
