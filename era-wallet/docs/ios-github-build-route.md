# ERA Wallet: GitHub-hosted macOS build route

Preparation date: 30 October 2026. The published source and unsigned CI validate
compilation; they do not qualify a signed release or establish App Store eligibility.

## Reviewed source

At initial inspection, public master was build5 commit
`9595db6bf0610a0dcacf8b7306ea200527caac9c`. The isolated
`coord/wallet-ios-release-20261030` branch was then audited and pushed. Its full
reviewed SHA is `e9828f3a15816d60f73ebd3627109a483d55e8e3`.
GitHub compare confirms direct ancestry from the recorded build9 commit
`ec447f17a1d4f2556c1d5788b9af68c1083a9ba3` and the public build5 commit.
Source PR #3 merged that lineage into master as
`b7b15f5df11abe81d5032c1d5c0f69dff2c58073`. The diff contained only
`era-wallet/` source, tests, dependency metadata and iOS Runner settings; no
private coordination records or signing material. Flutter 3.41.9 lockfile
resolution and analysis passed; all 190 existing synthetic tests passed locally.
These Windows checks do not establish an iOS compilation or signed-app result.

## Unsigned validation

The manually dispatched workflow is `.github/workflows/era-wallet-ios-validation.yml`.
It must be available on the default branch for normal manual-dispatch discovery.
It has no push/PR triggers, no signing secrets and no TestFlight/App Review upload.

Workflow PR #2 merged as `9ce64d8599a17a3e3a373103028bb1c8116b7b30`.
PR #4 moved the standard runner to `macos-26` as
`2a74b7770b18d6e3f57a0bc5d4e8c8d2a2f757a9`. The validated run is
https://github.com/erablockchains/apps/actions/runs/41096913139 : Xcode 26.6,
iOS SDK 26.5, locked dependencies, analysis and tests passed; both unsigned
device release and simulator apps compiled. An earlier run
https://github.com/erablockchains/apps/actions/runs/41076939070 also passed but
used Xcode 16.4, which does not meet Apple's current upload toolchain requirement.
Neither run signed an IPA or uploaded to Apple.

For further unsigned validation:

1. Open Actions > ERA Wallet iOS unsigned validation > Run workflow.
2. Supply the **full 40-character reviewed iOS commit SHA**. Do not supply a branch
   name or the old master commit.
3. The Linux preflight checks public visibility, ancestry from the recorded build9
   commit, version 1.2.0 build9-or-later, Apple team `D2F9K652YH`, bundle identifier
   `com.eraprojects.erawallet` and display-name casing before scheduling macOS.
4. The standard `macos-26` job requires Xcode and iOS SDK 26 or later, as Apple
   currently requires for iOS uploads. It uses Flutter 3.41.9 / Dart 3.11.5. The official
   Intel and Apple Silicon SDK ZIPs are SHA-256 pinned, as is the Flutter Git
   identity. It records Xcode/iOS SDK versions, enforces the Dart lockfile, analyzes,
   runs existing synthetic tests and compiles release and simulator apps.
5. Read the run logs and job summary. A compiler/plugin/Xcode incompatibility is a
   real result to fix; do not describe an unexecuted job as passing.

The workflow does not silently change dependencies, generate replacement iOS
project files, change wallet storage/cryptography or submit production transactions.
A missing Podfile or Swift Package Manager incompatibility must be resolved using
the selected Flutter/toolchain's supported integration, then reviewed and rerun.

Standard hosted compute in a public repository is free under the referenced GitHub
policy. Larger runners are not used. No caches or artifact uploads are configured:
storage allowances and overage billing are separate from compute. Existing unrelated
repository workflows/billing remain outside this change.

## Protected signing and TestFlight

Do not provide Apple credentials in chat, source, PR comments or job inputs. A
separate manual signed workflow is `.github/workflows/era-wallet-ios-testflight.yml`.
The GitHub `apple-release` environment is limited to deployments from `master`
and requires review by the `erablockchains` account. No secrets have been stored
and the signed workflow has not been run. Before dispatching it:

- Determine whether an existing Apple Distribution signing identity/profile can be
  used or whether one must be generated. An App Store Connect API `.p8` key is
  **not** the distribution certificate/private key used to sign the app.
- In GitHub repository Settings > Environments > `apple-release`, store these
  **environment** secrets through the owner's credential workflow:
  `APPLE_DISTRIBUTION_P12_BASE64` (base64 of Apple Distribution PKCS#12 including
  its private key), `APPLE_DISTRIBUTION_P12_PASSWORD`,
  `APPLE_APPSTORE_PROFILE_BASE64` (base64 of the App Store distribution profile),
  `APPLE_ASC_KEY_ID`, `APPLE_ASC_ISSUER_ID`, and `APPLE_ASC_API_KEY_P8_BASE64`
  (base64 of a suitable App Store Connect API key). The first three permit signing;
  the last three are additionally required for upload. Do not place values in this
  document or ask for them in chat. Confirm Team `D2F9K652YH`, bundle
  `com.eraprojects.erawallet` and App Store Connect app `6828776691` agree.
- Use a temporary runner keychain and provisioning installation, remove them in
  an unconditional cleanup step, and exclude all credential material from logs,
  caches and artifacts. Pin any additional actions to reviewed commit SHAs.
- Build/export a signed IPA with a unique iOS build number; validate the archive,
  entitlements and installed signing identity. Upload to TestFlight only through
  that separate, explicitly reviewed stage. Do not automate public App Review
  submission as a side effect of a source push.

The manual dispatch takes a unique numeric build number (10 or higher) and an
`upload_testflight` flag, default false. Check App Store Connect for any already
used build number before dispatch. The workflow pins the reviewed source commit
and uses the same checksum-pinned Flutter toolchain as unsigned CI. The owner
reviews the protected environment job before credentials become accessible.
Successful upload command is not proof of TestFlight processing; verify the build
in App Store Connect separately. A public repository must not publish the IPA as
an Actions artifact. The workflow deliberately does not retain one.

Then qualify the **signed iOS app** on an actual device, including keychain/PIN,
create/import, the corrected crypto work, RPC failures, background/resume and
existing account preservation. Capture genuine iOS screenshots. Simulator builds
and Android's 190-test result do not establish this qualification.

## Release scope and remaining product work

Owner-reported App Store Connect status is Prepare for Submission, version 1.2.0,
175 currently selected territories, future-territory auto-availability off. Those
settings do not establish approval or regional eligibility. Check the actual
signed NFT purchase/swap interface against current Apple rules (including non-US
purchase paths). Resolve App Privacy, Content Rights, export compliance, EU trader
information and reviewer access using the shipping implementation.

Keep Google Play and all production chain/server settings unchanged. Update the
private Apple release register and RPC1 handovers from actual CI and signing
results; this public GitHub workflow does not itself synchronize private records.

Official references:

- https://docs.github.com/en/billing/concepts/product-billing/github-actions
- https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets
- https://docs.flutter.dev/deployment/ios
- https://docs.flutter.dev/install/archive
- https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
