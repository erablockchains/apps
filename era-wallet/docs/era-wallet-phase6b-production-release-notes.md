# ERA Wallet 1.1.0 Phase 6B production release notes

## Release status

**Channel:** Early Production — Direct Download  
**Official source:** <https://www.eraprojects.io/>  
**Official store listings:** Pending D-U-N-S processing and organization enrollment

## Highlights

- New ERA visual identity throughout the wallet.
- Updated in-app logo, launcher icons, and splash screens.
- Updated Android, iOS, macOS, Windows, and web icon assets.
- Updated Windows executable icon, web favicon, manifest icons, and web theme colors.
- Exact ERA mainnet compatibility for `specName=era`, spec version 9, transaction version 1, and AI Predictions storage version 3.
- Reviewed genesis, Metadata V14/hash, runtime WASM hash, pallet identity, and typed call/storage fingerprint verification.
- Model and prediction discovery with participant market views.
- YES/NO ETKN stake and eligible unstake actions.
- Participant positions, settlement state, payout eligibility, and claims.
- Durable transaction stages from preparation through finalized success/failure.
- Persistent recovery for interrupted or ambiguous submissions with no automatic retry.
- Finalized receipts, dispatch error decoding, canonical post-state checks, and chain reconciliation.
- Production participant isolation: operator/governance tabs are excluded and the transaction runner permits only participant stake/unstake/claim calls.
- Official-endpoint-only WSS policy by default; incompatible runtimes become read-only.
- New PIN strength, throttling, PIN change, Android screenshot protection, Android backup/cleartext blocking, and recovery-phrase clipboard warnings/clearing.
- Dedicated Network & Release screen with runtime identity, compatibility, official links, version, support, scam warning, and risk disclosure.

## Rebuilt release artifacts

- Android direct-download APK: signed with the current local ERA Projects release certificate and verified with APK Signature Scheme v2.
- Android AAB: internal store-submission candidate only; never provide it as an end-user download.
- Windows x64: unsigned complete release-directory ZIP; never distribute the EXE alone.

iOS and macOS are not publicly available. Official Google Play, Apple App Store, and Microsoft Store distribution remains pending.

These logo-updated artifacts and their SHA-256 values supersede all earlier pre-logo production-candidate artifacts and hashes. Do not publish or retain an earlier checksum beside the rebuilt files.

The final website handoff contains only the public Android APK and complete Windows x64 ZIP with their current checksums. It does not contain an AAB, debug APK, bare EXE, internal release archive, or signing material.

## Known limitations

- Physical-device QA and authorized live ETKN lifecycle testing remain pending.
- Google Play signing lineage, trusted Windows signing, and Apple signing/notarization remain pending.
- Legal, compliance, financial-feature, and open-source license reviews remain pending.
- No complete external indexer is bundled; bounded finalized history can be incomplete on a pruned RPC.
- Windows screenshot blocking is not implemented.
- Staking does not expose every lifecycle action such as withdraw-unbonded/rebond/reward claim.
- Runtime versions newer than the exact reviewed spec 9 fail closed until a new compatibility review.
- AI predictions may be incorrect; transactions are irreversible after finality; payouts and profits are not guaranteed.

## Verify a download

1. Download only from <https://www.eraprojects.io/> or a verified official store listing.
2. Compare the file's SHA-256 with the release manifest.
3. On Windows PowerShell:

```powershell
Get-FileHash .\ARTIFACT_NAME -Algorithm SHA256
```

4. Do not install or run a mismatched artifact.
5. For Windows, extract and keep the entire ZIP directory together.

## Support and safety

- Support: <https://www.eraprojects.io/support.html>
- Email: <support@eraprojects.io>
- Privacy: <https://www.eraprojects.io/privacy-policy.html>

ERA support will never ask for a recovery phrase, private key, PIN, or password. Do not retry an uncertain transaction until finalized chain reconciliation is conclusive.
