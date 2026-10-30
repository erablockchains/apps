# ERA Wallet: GitHub-hosted macOS build route

Preparation date: 30 October 2026. This document adds an **unsigned compilation
workflow**, not a signed release or evidence of App Store eligibility.

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

After workflow review/merge:

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

## Protected signing and TestFlight: next stage

Do not provide Apple credentials in chat, source, PR comments or job inputs. Before
adding a separate signed workflow:

- Configure a protected `apple-release` environment restricted to the reviewed
  release branch/tag, with owner approval for access to credentials.
- Determine whether an existing Apple Distribution signing identity/profile can be
  used or whether one must be generated. An App Store Connect API `.p8` key is
  **not** the distribution certificate/private key used to sign the app.
- Supply the minimally scoped App Store Connect API key, Key ID and Issuer ID
  through protected environment secrets. Supply the distribution `.p12`, its
  password and matching provisioning profile through protected secrets when using
  manual signing. Confirm Team `D2F9K652YH`, bundle `com.eraprojects.erawallet` and
  App Store Connect app `6828776691` agree.
- Use a temporary runner keychain and provisioning installation, remove them in
  an unconditional cleanup step, and exclude all credential material from logs,
  caches and artifacts. Pin any additional actions to reviewed commit SHAs.
- Build/export a signed IPA with a unique iOS build number; validate the archive,
  entitlements and installed signing identity. Upload to TestFlight only through
  that separate, explicitly reviewed stage. Do not automate public App Review
  submission as a side effect of a source push.

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
