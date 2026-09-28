# ERA Wallet production compliance review

```text
LEGAL_REVIEW: REQUIRED
COMPLIANCE_REVIEW: REQUIRED
```

## Android Data Safety engineering draft

- No advertising, analytics, tracking, or crash-reporting SDK is included.
- The wallet processes account names, public addresses, active-account state, PIN verifier material, biometric preference, mnemonic material, public transaction journal data, and onboarding state locally.
- Public addresses, chain queries, fee requests, and signed extrinsics are sent to the official ERA RPC.
- User-requested external links open in the operating system/browser under that destination's practices.
- Public production builds do not expose controlled report export.
- Final Play Console answers require review against the exact signed artifact and current form wording.

## Apple privacy engineering draft

- No first-party analytics/advertising collection was identified.
- Blockchain/RPC transmissions and public identifiers must be assessed under Apple's current definitions.
- Device authentication is performed by the OS; raw biometric data is not received by the wallet.
- Encryption/export-compliance answers require specialist review.
- iOS is not an artifact target for this Windows release task.

## Windows distribution

- Direct ZIP distribution requires checksum/signature disclosure and a complete folder.
- Public distribution is blocked until code signing and SmartScreen/antivirus QA pass.
- Microsoft Store qualification and MSIX packaging are separate later gates.

## Required decisions

1. Approved countries/regions and participant eligibility.
2. Classification of AI Prediction market participation.
3. Required age/risk/financial-promotion controls.
4. Sanctions and restricted-person obligations.
5. Consumer disclosures, complaint handling, and record retention.
6. Final privacy/data-safety/app-store answers.
7. Open-source license and trademark review.

