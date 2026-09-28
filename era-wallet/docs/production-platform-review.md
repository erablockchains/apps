# ERA Wallet Android and Windows production review

## Android

| Item | Result |
| --- | --- |
| Application ID | `com.eraprojects.era_wallet` |
| Minimum API | 24 |
| Compile/target SDK | Flutter toolchain resolved values; validate in build log |
| Internet permission | Required for ERA WSS RPC |
| Camera permission | Required only for user-invoked recipient QR scan |
| Biometric permissions | Required for device authentication |
| Cleartext traffic | Disabled |
| Application backup | Disabled to reduce wallet-secret migration risk |
| Screenshot capture | Blocked with Android `FLAG_SECURE` |
| Minification/shrinking | Disabled pending dedicated plugin/R8 regression testing |
| Signing source | Local ignored `android/key.properties` and referenced keystore only |
| Embedded signing credential | None |

When `android/key.properties` is absent, the project remains release-buildable but not production-signed.

```text
ANDROID_PRODUCTION_SIGNING: BLOCKED_PENDING_HUMAN_CREDENTIALS
```

## Windows x64

| Item | Result |
| --- | --- |
| Product / description | ERA Wallet |
| Company | ERA Projects |
| Version source | Flutter `1.1.0+2` macros |
| Icon | `windows/runner/resources/app_icon.ico` |
| OS manifest | Windows 10/11, PerMonitorV2 DPI awareness |
| Entrypoint | GUI `wWinMain`; console only attaches under debugger/parent console conditions |
| Secure storage | Windows secure-storage plugin registered |
| Device authentication | Windows local-auth plugin registered; physical QA pending |
| Architecture | x64 release output |
| Distribution | Complete release directory ZIP, never EXE alone |
| Code signing | Human certificate required; pending |

The package must retain `era_wallet.exe`, Flutter/plugin DLLs, and the complete `data` directory.

