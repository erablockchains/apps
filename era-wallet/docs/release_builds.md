# ERA Wallet Release Build Guide

Last updated: July 17, 2026

This guide covers the practical release-artifact steps for Android, iOS, and Windows.
Use it alongside:

- [Store submission checklist](store_submission.md)
- [Store metadata](store_metadata.md)
- [Store console answers](store_console_answers.md)

## Before any release build

1. Update the app version in [`pubspec.yaml`](../pubspec.yaml)
   Example:
   - `version: 1.0.1+2`
2. Confirm your privacy policy URL is live.
3. Confirm store metadata text is finalized.
4. Confirm release signing assets are available and not committed to git.
5. Confirm the store build omits both Phase 6B controlled-tool defines (or sets both to `false`).
6. Reconcile the hosted privacy policy and store forms with RPC transmission, the local transaction journal, report save/share if included, and platform backup/sync behavior.
7. Run:

```powershell
flutter analyze
flutter test
```

## Android Release

### 1. Prepare signing config

This project expects `android/key.properties`.

Use the template in:

- [`android/key.properties.example`](../android/key.properties.example)

Create:

- `android/key.properties`

Example:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=my-release-key.keystore
```

Place the referenced keystore file inside:

- `android/app/`

or update `storeFile` accordingly.

### 2. Build the Play Store artifact

Recommended artifact for Google Play:

```powershell
flutter build appbundle --release
```

Output:

- `build\app\outputs\bundle\release\app-release.aab`

### 3. Optional APK for local install testing

```powershell
flutter build apk --release
```

Output:

- `build\app\outputs\flutter-apk\app-release.apk`

### 4. Final Android checks

- package name is `com.eraprojects.era_wallet`
- target SDK resolves correctly for the current Play requirement
- release keystore is private
- Play Console app uses the same package name
- Data safety and privacy policy are completed

## iOS Release

iOS release packaging must be finalized on macOS with Xcode / Apple signing.

### 1. Confirm Apple identifiers

- Bundle ID: `com.eraprojects.erawallet`
- Matching App ID in Apple Developer
- Matching app record in App Store Connect

### 2. Open on macOS

On a Mac with Flutter and Xcode configured:

```bash
flutter clean
flutter pub get
flutter build ipa --release
```

If signing/export options need Xcode handling:

```bash
open ios/Runner.xcworkspace
```

Then archive from Xcode:

- Product
- Archive

### 3. Expected deliverable

- `.ipa` for App Store Connect upload

### 4. Final iOS checks

- Privacy Policy URL added in App Store Connect
- App Privacy answers entered
- Export compliance questions answered
- screenshots and review notes uploaded
- release signing certificate and provisioning profile are valid

## Windows Release

The current repo builds a working Windows desktop executable, but Microsoft Store submission usually requires an MSIX-based package rather than the raw `.exe`.

### 1. Build the release executable

```powershell
flutter build windows --release
```

Output:

- `build\windows\x64\runner\Release\era_wallet.exe`

### 2. For Microsoft Store submission

Typical deliverable:

- `.msix`
- `.msixbundle`
- or `.appxupload` / `.msixupload`, depending on your packaging workflow

### 3. Packaging options

Use one of:

- Visual Studio packaging project
- MSIX Packaging Tool
- another approved MSIX workflow tied to your Microsoft Partner Center identity

### 4. Final Windows checks

- publisher identity matches Partner Center
- package is signed correctly
- Windows App Certification Kit passes
- app name, icon, and company metadata are correct

## Recommended release command sequence

From the repo root:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
flutter build windows --release
```

Then complete iOS on macOS:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ipa --release
```

## Sensitive-material reminders

- Do not commit:
  - `android/key.properties`
  - keystore files
  - `.p12`
  - provisioning profiles
  - MSIX signing certificates
- If Android signing credentials were ever exposed, rotate them before production release.

## Suggested artifact checklist

Before submission, make sure you have:

1. Android `.aab`
2. iOS `.ipa`
3. Windows Store-compatible package if targeting Microsoft Store
4. Privacy policy URL
5. Store screenshots
6. Final descriptions and review notes
7. Signed-off Play / Apple privacy answers
