# ERA Wallet: GitHub-hosted macOS build route

Preparation date: 30 October 2026. This document adds an **unsigned compilation
workflow**, not a signed release or evidence of App Store eligibility.

## Source must be reconciled first

At inspection, public `erablockchains/apps` master was commit
`9595db6bf0610a0dcacf8b7306ea200527caac9c`, declaring `1.2.0+5`.
The owner-reported build9 commit
`ec447f17a1d4f2556c1d5788b9af68c1083a9ba3` and local iOS preparation
commit prefix `4e8904f446` could not be resolved in that GitHub repository.
The local `coord/wallet-ios-release-20261030` branch was not visible there.
This does not establish that local work is missing: it establishes that a hosted
runner cannot yet fetch those commits from this repository.

Local Codex should preserve the existing worktree, verify its full commit SHA and
build9 ancestry, review the diff for secrets/private coordination records, and
publish **only the intended source changes** on an appropriate branch through the
normal PR process. Do not upload coordination folders, credentials or app-signing
material. Do not reconstruct the build9 fixes from the old public build5 source.
If that worktree uses a different repository or rewritten history, reconcile the
provenance explicitly before changing the workflow guard.

## Unsigned validation

The manually dispatched workflow is `.github/workflows/era-wallet-ios-validation.yml`.
It must be available on the default branch for normal manual-dispatch discovery.
It has no push/PR triggers, no signing secrets and no TestFlight/App Review upload.

After source reconciliation and workflow review/merge:

1. Open Actions > ERA Wallet iOS unsigned validation > Run workflow.
2. Supply the **full 40-character reviewed iOS commit SHA**. Do not supply a branch
   name or the old master commit.
3. The Linux preflight checks public visibility, ancestry from the recorded build9
   commit, version 1.2.0 build9-or-later, Apple team `D2F9K652YH`, bundle identifier
   `com.eraprojects.erawallet` and display-name casing before scheduling macOS.
4. The standard `macos-15` job uses Flutter 3.41.9 / Dart 3.11.5. The official
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

Keep Google Play and all production chain/server settings unchanged. Local Codex
should reconcile this public PR into its existing source work and update the
private Apple release register and RPC1 handovers; this GitHub preparation does
not itself synchronize those private records.

Official references:

- https://docs.github.com/en/billing/concepts/product-billing/github-actions
- https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets
- https://docs.flutter.dev/deployment/ios
- https://docs.flutter.dev/install/archive
- https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
