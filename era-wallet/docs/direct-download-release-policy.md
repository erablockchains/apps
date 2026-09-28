# ERA Wallet direct-download release policy

ERA Wallet 1.1.0 is available as a Phase 6B early production release directly from <https://www.eraprojects.io/>. Official application-store distribution remains pending D-U-N-S processing and organization enrollment.

## Publication rules

- Publish only versioned release artifacts listed in the current release manifest.
- Publish the matching SHA-256 checksum beside each public download.
- State the signing status and known limitations next to the download.
- Do not publish debug builds, the Android AAB, a bare Windows EXE, source code, credentials, or build caches.
- Do not authorize mirrors. ERA Wallet downloads are official only when obtained from `eraprojects.io` or a future verified store listing.
- Keep operator and governance tools disabled and use only the reviewed production endpoint.

## Platform guidance

The Android APK is signed with the current local ERA Projects release certificate but is not yet published through Google Play. Android may warn that it is being installed from outside Google Play. Users must verify its SHA-256 before installation.

The Windows build is distributed as a complete unsigned ZIP. Windows Defender SmartScreen may show an unknown-publisher warning. Users must verify the ZIP checksum, extract the complete archive, and run `era_wallet.exe` from the extracted directory. A SmartScreen warning is not, by itself, proof of malware, and users should not disable Windows security permanently.

## Updates and replacement

Each update receives versioned filenames, newly calculated checksums, release notes, manifests, and website metadata. Replacing any artifact requires replacing its checksum and all metadata that names it. Superseded downloads and hashes must be removed together.

Support requests should use <https://www.eraprojects.io/support.html>. ERA support will never request a recovery phrase, private key, PIN, or password.
