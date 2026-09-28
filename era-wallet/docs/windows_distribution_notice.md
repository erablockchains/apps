# ERA Wallet Windows distribution notice

ERA Wallet for Windows must be distributed as the complete versioned x64 ZIP. Do not distribute or move only `era_wallet.exe`; the adjacent DLLs and `data` directory are required.

1. Download only from an official ERA Projects page.
2. Verify the ZIP SHA-256 against the signed/published manifest.
3. Extract the full ZIP before launch.
4. Keep the executable, DLL files, and `data` directory together.
5. Unsigned builds can trigger SmartScreen/antivirus warnings and are not approved for public rollout.
6. User wallet secrets are stored separately through the Windows secure-storage plugin; replacing the application folder must not be treated as a wallet backup or deletion procedure.

```text
WINDOWS_PRODUCTION_SIGNING: PENDING_HUMAN_CREDENTIALS
MICROSOFT_STORE_PACKAGE: NOT_INCLUDED
```

