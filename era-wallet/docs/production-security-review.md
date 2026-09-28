# ERA Wallet production security review

**Engineering review:** July 19, 2026  
**Scope:** ERA Wallet 1.1.0+2 participant release  
**Independent security audit:** Not performed

## Security changes in this release

- New PINs must contain 6–12 digits; legacy shorter PINs remain unlock-compatible so existing users are not locked out.
- Failed PIN verification is persisted in secure storage. Five failures trigger a 30-second delay; repeated failures increase the delay up to 15 minutes.
- Users can change the wallet PIN only after current-PIN verification.
- The one-minute background session lock remains enabled.
- Seed reveal and transaction signing require device authentication or PIN fallback.
- Recovery-phrase clipboard copy now requires an explicit risk/backup acknowledgement and attempts to clear the unchanged clipboard value after 60 seconds.
- Android sets `FLAG_SECURE` for the wallet window to block screenshots and non-secure display capture.
- Android disables cleartext traffic and platform application backup.
- The official WSS endpoint is enforced unless a non-production build explicitly opts into another secure endpoint.
- Runtime compatibility, canonical preflight, duplicate protection, durable journaling, finality, dispatch decoding, and post-state verification remain fail-closed.
- The legacy dormant admin screen was removed and the transaction runner enforces a participant-call allow-list.

## Local secret handling

- PINs are never stored in plaintext. PBKDF2-HMAC-SHA256 uses 120,000 iterations and a random 16-byte salt; an HMAC verifier is stored.
- Mnemonics remain in platform secure storage and are loaded only for local signing or authenticated reveal.
- The mnemonic records are not additionally wrapped with the PIN-derived key. Platform secure-storage and device security are therefore part of the threat boundary.
- No cloud seed storage, analytics, tracking, advertising, or first-party remote backup was added.
- The transaction journal stores public chain evidence and state, not signing material.

## Logging review

Debug output contains connection errors and public transaction context, but no intentional mnemonic, PIN, password, or private-key logging path was found. Release builds compile out Flutter `debugPrint` calls under normal release behavior. Crash-reporting and analytics SDKs are absent. Any future logging or telemetry addition requires a fresh privacy and secret-leak review.

## Secure-storage configuration

- Android: encrypted shared preferences, minimum API 24, backup disabled.
- iOS: Keychain accessibility `first_unlock`; iOS release remains outside this Windows release scope.
- Windows: `flutter_secure_storage_windows` is registered and must be tested on the target Windows account.
- Web/Linux/macOS are not production-qualified by this release.

## Residual risks

- A numeric PIN can still be weak; users should choose a unique value and enable device authentication.
- Platform clipboard history, keyboards, accessibility tools, rooted/jailbroken devices, malware, and OS backups can bypass application expectations.
- Windows has no application-level screenshot block in this release.
- A forgotten PIN has no bypass. Recovery requires the recovery phrase and a clean reinstall/reset workflow; support cannot recover it.
- A lost recovery phrase cannot be reconstructed by ERA Projects.
- Release signing and physical-device QA remain human gates.
- This engineering review is not a penetration test or independent cryptographic audit.

## Required follow-up

1. Independent mobile/desktop security review.
2. Android physical-device verification of `FLAG_SECURE`, biometric fallback, lockout, clipboard clearing, upgrade behavior, and secure-storage persistence.
3. Windows secure-storage, Windows Hello, malware/SmartScreen, and local-user separation tests.
4. Formal incident exercise for compromised artifacts and leaked recovery phrases.

```text
SECURITY_ENGINEERING_REVIEW: COMPLETE
INDEPENDENT_SECURITY_AUDIT: REQUIRED
PHYSICAL_DEVICE_SECURITY_QA: PENDING
```

