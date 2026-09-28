# ERA Wallet V14 source provenance

This subtree was prepared from the authenticated native-wallet workspace commit `0f4f415966a0225739f8ec9fb66b2fd9b9c15db8` on branch `dev/v14-native-wallet-reward-r4-20260928`.

It includes the Flutter application and locked dependencies for Android, Windows, iOS and Linux. The local `macos/` and `web/` runners, private build evidence, release handoff folders and compiled artifacts are outside this integration. The existing Polkadot.js applications in the repository remain in place and are not replaced by this subtree.

## Runtime binding

- Chain: `ERA`
- Genesis: `0x0abc2c3d8db5815541050b73da4d81267ebf14d90dbee8d7258155b667ea112e`
- Runtime: `era`, specVersion 15, transactionVersion 1
- Runtime Wasm SHA-256: `122af167022227c46b2b74d99f5d3a73f41f8d65bb4a8a1de7b88b6e986de2af`
- Metadata SHA-256: `c188b00f3589677fe7ecfa833d92d884858ad642a6d231d52696298edbe91d40`

## Artifact binding and acceptance

The website-published Android prerelease is version 1.2.0, versionCode 3, SHA-256 `d4e1a0bb9e57813508954cc59e994ee4274d629868a7a62353947d9a71bc1cb5`. It remains published while a separate website update is held.

The corrected Android build4 artifact is `era-wallet-1.2.0-build4-android-universal-prerelease.apk`, 98,627,233 bytes, SHA-256 `b0bd46a8a02a0eb5bd04f3eb1a09aca403a837b899d49b3e2133d255638e16cc`. Its package is `com.eraprojects.era_wallet`, versionCode 4, and signing-certificate SHA-256 is `19292f4dda5e588c389dcc03697e600481a0b20318d1092deaf66eec17c49e14`, identical to build3. The APK is not stored in this source subtree and is awaiting the targeted owner reward-inspection retest.

The Windows build passed the recorded automated checks and owner validation. iOS and Linux source targets are included, but no current iOS/Linux release artifact or platform acceptance is claimed.

## Publication boundary

`erablockchains/apps` is public. This integration branch must be reviewed locally before any push because a push publishes the source bytes and the existing `master` workflow can publish the Polkadot.js application. No push, merge, tag or release is part of source preparation.

The repository root Apache-2.0 license applies to this subtree. Dependency source is not vendored here; dependency versions are locked in `pubspec.lock` and retain their own licenses.
