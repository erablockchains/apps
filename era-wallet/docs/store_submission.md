# ERA Wallet Store Submission Checklist

This project is close to store-ready, but store submission is not just a code build.
There are code-side requirements, packaging requirements, privacy declarations, and console-side forms that must all agree with each other.

## Current code-side status

- App name and branding are set to `ERA Wallet`.
- Custom launcher icons are present for Android, iOS, macOS, and Windows.
- iOS includes `NSFaceIDUsageDescription`.
- Android uses a unique application ID: `com.eraprojects.era_wallet`.
- iOS bundle ID has been aligned to `com.eraprojects.erawallet`.
- Windows executable metadata has product/company strings.
- Phase 6B runtime compatibility, transaction journaling, and participant features are implemented; fresh analyzer, test, and target-build results must still be recorded for the exact release commit.

## Manual blockers before submission

These are still required outside the Flutter codebase:

- Publish a public privacy policy URL.
- Complete Google Play Data safety declarations.
- Complete Apple App Privacy declarations.
- Complete Apple export-compliance review for encryption use.
- Prepare signed release artifacts for each platform.
- Rotate any Android signing secrets that were previously stored in the repo or shared insecurely.
- Run final manual QA on physical devices for login, account creation, send, staking, and biometric auth.
- Verify the final store build omits `ENABLE_PHASE6B_TESTING_TOOLS` and `ENABLE_PHASE6B_GOVERNANCE_ACTIONS`, unless a separate reviewed distribution intentionally includes them.

## Android / Google Play

### Code/package checks

- Confirm release signing uses a private keystore that is **not** committed.
- Confirm `targetSdkVersion` resolves to Android 15 / API 35 or higher at build time.
- Build an Android App Bundle:

```powershell
flutter build appbundle --release
```

### Play Console requirements

- Create the Play Console app entry with the final package name: `com.eraprojects.era_wallet`.
- Upload the `.aab`.
- Complete the Data safety form.
- Add the privacy policy URL in Play Console and inside the app if applicable.
- Provide store listing assets: icon, screenshots, feature graphic, short description, full description.
- If the app offers financial or crypto functionality in specific regions, confirm any jurisdiction-specific policies before rollout.

### Suggested Play Data safety starting point

This is an engineering estimate, not legal advice. Verify against the final release build, RPC provider, platform backup behavior, and any backend services:

- Data transmitted off-device: treat the answer conservatively as likely `Yes`; public wallet addresses, chain and AI Prediction queries, fee requests, and signed transactions go to the configured ERA node/RPC provider, which may also process connection metadata such as an IP address.
- Data stored on-device: PIN verifier, mnemonic material, account list, biometric preference, public-chain activity, and a secure-storage transaction journal. Controlled builds can also create redacted JSON/Markdown reports at the user's request.
- Data shared by the user: copying uses the operating-system clipboard; report sharing hands public-chain-identifying evidence to the operating system and selected destination.
- Backup/sync: the app provides no first-party cloud sync, but secure storage, app documents, reports, or shared copies may be included in operating-system backup or a user-selected synced folder.
- Security practices:
  - Data is stored locally using secure storage mechanisms where supported.
  - Sensitive actions are protected by PIN and/or device authentication.

Do not describe the wallet as purely offline or claim that no data leaves the device. Reconcile the Play form with the final privacy policy and the production RPC provider's behavior.

## iOS / App Store

### Code/package checks

- Confirm the final bundle ID in Apple Developer matches `com.eraprojects.erawallet`.
- Confirm signing team, provisioning profile, and App ID are created in Apple Developer.
- Build an IPA from Xcode or:

```powershell
flutter build ipa --release
```

### App Store Connect requirements

- Add app record in App Store Connect with the exact bundle ID.
- Add Privacy Policy URL.
- Complete App Privacy questionnaire.
- Answer export-compliance questions for encryption use.
- Upload screenshots, subtitle, description, support URL, marketing URL if desired.

### Important note for this wallet

ERA Wallet uses cryptographic functionality beyond basic Apple OS-only APIs. That means you should expect to answer Apple export-compliance questions carefully during submission. Review this with whoever owns compliance for the product before app review.

## Windows / Microsoft Store

### Packaging checks

- Windows Store submission typically uses MSIX / `.msixupload`, not the raw `.exe`.
- Keep company/publisher naming consistent across Partner Center, signing certificate, and package manifest.
- Run the Windows App Certification Kit before submission.

### Suggested packaging flow

You will likely need one of:

- Visual Studio packaging project
- MSIX Packaging Tool
- Windows App SDK / MSIX tooling workflow

The current repo builds a working Windows executable, but Store submission requires a signed Store-compatible package.

## Security and release hygiene

- Do not commit `android/key.properties`, `.keystore`, `.jks`, `.p12`, or provisioning files.
- Rotate Android signing credentials if they were ever exposed in source control, screenshots, or shared chats.
- Keep developer and seller names consistent:
  - Android package / Play Console
  - Apple bundle ID / App Store Connect
  - Windows publisher identity / Partner Center
- Increase the app version before each submission:
  - `version: x.y.z+n` in `pubspec.yaml`

## Manual QA before submitting

Run these flows on real devices or clean simulators/emulators:

1. First launch and splash flow.
2. PIN setup and unlock.
3. Biometric/device-auth enrollment and fallback to PIN.
4. Add account from generated mnemonic.
5. Import account from mnemonic.
6. Account switching.
7. Reveal mnemonic flow.
8. Send validation, fee estimation, and send confirmation.
9. Staking bond / nominate / unbond validation.
10. Background-lock and session re-auth flow.
11. Offline / node-unavailable behavior.
12. AI Predictions model/market discovery, participant staking/unstaking/claim guards, finality, and journal recovery.
13. If testing tools are intentionally included outside a store build, report save/copy/share, redaction review, and platform file-retention behavior.

## Current official references

- Google Play target API requirement:
  https://developer.android.com/google/play/requirements/target-sdk
- Google Play Data safety:
  https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN
- Google Play privacy policy and user data policy:
  https://support.google.com/googleplay/android-developer/answer/10144311?hl=en
- Apple app information and privacy policy URL:
  https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Apple app privacy:
  https://developer.apple.com/help/app-store-connect/reference/app-privacy
- Apple export compliance:
  https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/
- Apple encryption documentation reference:
  https://developer.apple.com/help/app-store-connect/reference/app-information/export-compliance-documentation-for-encryption/
- Microsoft Store MSIX certification:
  https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-certification-process/
- Microsoft MSIX packaging overview:
  https://learn.microsoft.com/en-us/windows/msix/
