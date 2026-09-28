# ERA Wallet production operator-isolation review

**Reviewed:** July 19, 2026  
**Release:** ERA Wallet 1.1.0+2, Phase 6B Controlled Production Release

## Result

The public participant build uses both controls as compile-time constants with safe `false` defaults:

```text
ENABLE_PHASE6B_TESTING_TOOLS=false
ENABLE_PHASE6B_GOVERNANCE_ACTIONS=false
```

Governance cannot be enabled unless testing tools are also enabled. The obsolete `ENABLE_AI_PREDICTION_ADMIN_TOOLS` control is not read by the application. Its dormant legacy admin screen and route were removed for this production release.

## Isolation layers

| Layer | Production behavior |
| --- | --- |
| Navigation | Public tabs are Overview, Models, Predictions, Markets, My Positions, Claims, and Diagnostics. Operator Lab and Test Reports are not constructed. |
| Deep links | `MaterialApp` defines no named routes, route parser, or deep-link handler. There is no external operator route. |
| Controllers | Participant UI constructs stake, unstake, and claim intents only. Testing/governance widgets are compile-time excluded when flags are false. |
| Action policy | Non-participant audiences are invisible and disabled unless their required build flags and runtime compatibility are both present. |
| Transaction runner | A production allow-list rejects every AI Prediction transaction except stake, unstake, and claim, even if a caller bypasses navigation. Governance calls have an independent deny gate. |
| Runtime gate | Signing requires the reviewed genesis, `era` spec 13, transaction version 1, Metadata V14/hash, runtime WASM hash, pallet identity, storage version 3, and exact typed call/storage signatures. |
| Pre-sign refresh | Runtime and canonical action state are refreshed after authentication and immediately before signing. |
| Operator services | Controlled-session/report services are initialized only from compile-time testing-only workspace sections. They are not automatically initialized in the participant build. |
| Reports | Public production UI does not expose controlled test reports. The shared redactor still removes credential categories recursively as defense in depth. |

## Privileged feature inventory

| Feature | Audience | Production disposition |
| --- | --- | --- |
| Model registration/onboarding | Testing operator | UI excluded; runner rejects call. |
| Prediction submission/validation/closing/tokenization | Testing operator | Active controls excluded; runner rejects call. Public read-only discovery remains. |
| Settlement proposal/finalization authority | Testing operator | Active controls excluded; runner rejects call. Settlement status remains readable. |
| Model approve/reject/suspend | Governance | UI excluded; policy and runner reject calls. |
| Submitter/delegation administration | Governance | UI excluded; policy and runner reject calls. |
| Administrative settlement finalization | Governance | UI excluded; policy and runner reject call. |
| Sudo and `system.setCode` | Root/governance | No wallet UI, controller, or signing route. Generated chain bindings alone do not expose an application action. |

## Static and automated checks

- `test/production_mode_test.dart` verifies safe flag defaults, public tab composition, the reviewed endpoint, and runner-level rejection of privileged calls.
- Release validation searches source and packaged artifacts for operator strings and verifies that no public route/action exists.
- Generated runtime bindings contain privileged runtime types by design; they are metadata artifacts, not public application routes.

## Conclusion

`OPERATOR_TOOLS_DISABLED_IN_PUBLIC_BUILD: PASS`, subject to the production-mode tests and final artifact scan passing with both flags explicitly false.
