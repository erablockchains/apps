# ERA Wallet production versioning

## Decision

| Item | Value |
| --- | --- |
| Previous version | `1.0.0+1` |
| Production version | `1.1.0+2` |
| Android `versionName` | `1.1.0` |
| Android `versionCode` | `2` |
| Windows file version | `1.1.0.2` |
| Windows product version | `1.1.0` / Flutter version string |
| Release channel | Controlled Production Release |

The minor version increment identifies the spec-9 Phase 6B participant capability set and production hardening as a material feature release. Build number 2 distinguishes it from the earlier `1.0.0+1` beta artifact while preserving normal Flutter/Android monotonic versioning.

Windows `Runner.rc` consumes Flutter's generated version macros, so the numeric file version becomes `1,1,0,2` and the displayed product version follows `1.1.0`.

