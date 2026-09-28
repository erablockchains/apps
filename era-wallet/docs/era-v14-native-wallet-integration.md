# ERA V14 native wallet integration

**Scope date:** 2026-09-25  
**Native targets:** Android package `com.eraprojects.era_wallet`; Windows x64 `era_wallet.exe`  
**Development branch:** `dev/v14-native-wallet-20260925`

## Scope correction

The Android and Windows applications in this repository are the V14 wallet targets. The disconnected Telegram wallet at `wallet.eraprojects.io` is excluded. The separately deployed web service at `https://wallet.eraprojects.org/wallet/` is preserved as evidence but further web-wallet deployment is paused; browser-extension checks do not qualify these native applications.

No account, mnemonic, key, secure-storage record or user data is migrated or modified by this integration. Build and test workflows do not submit production transactions. Publication remains separately held.

## Exact production binding

| Field | Required value |
| --- | --- |
| Endpoint | `wss://eraprojects.org/` |
| `system_chain` | `ERA` |
| Genesis | `0x0abc2c3d8db5815541050b73da4d81267ebf14d90dbee8d7258155b667ea112e` |
| Runtime | `era` spec 15, transaction version 1 |
| Metadata | V14, SHA-256 `c188b00f3589677fe7ecfa833d92d884858ad642a6d231d52696298edbe91d40` |
| Runtime Wasm | SHA-256 `122af167022227c46b2b74d99f5d3a73f41f8d65bb4a8a1de7b88b6e986de2af` |
| Token | ETKN, 18 decimals, SS58 prefix 42 |

Every V14 signing route rechecks the exact identity, metadata and required pallet surface, verifies a healthy nonsyncing endpoint, hashes the deployed `:code`, and checks preserved AI storage version 3. Drift stops the operation before signing.

## Implemented native capabilities

- Existing account creation/import, secure-storage, PIN/device authentication, selected-account checks and on-device signing remain in place.
- The generated runtime API now comes from the authenticated spec15 metadata artifact at `artifacts/v14/era-spec15-metadata.scale`.
- NFT collection and item ownership are read at a single finalized head and compared with the selected account.
- NFT metadata accepts exactly four approved `ipfs://` CIDs. Native HTTPS retrieval uses `metadata.eraprojects.org`, refuses redirects, limits and checks exact byte length, verifies SHA-256, and requires strict UTF-8 JSON object content.
- The native review flow supports `Nfts.set_price`, `Nfts.buy_item`, `Nfts.create_swap`, and `Nfts.claim_swap` with exact typed spec15 calls and finalized post-state checks.
- The reward flow uses only `SecurityBudget.claim_reward_page`. It validates activation, pause state, completed/eligible era, reward points, budget, liability, historical exposure/page, expiry and prior-claim state before review.
- Transaction review shows the purpose, pallet/call, decoded arguments, signer, exact call bytes, estimated native ETKN fee and zero tip. Submission requires a second local authentication, a fresh runtime and fee check, one signed submission, finalization, decoded dispatch success, and post-state verification.
- The existing secure transaction journal keeps unresolved outcomes duplicate protected. An uncertain result must be reconciled before another submission.

## Approved metadata objects

| Object | CID | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| Collection | `bafkreigneb4mdfbsrjf764whskvoo2pqsl5d2kjc6kyxsnyz5ikxcede6m` | 594 | `cd2078c194328a4bff72c792aae769f092fa3d2922f2b1793719ea15711064f3` |
| Item 1 | `bafkreifnjhrm572sicfwfx6wurmavad4vkab3tdfk4btxob43shh6qhiey` | 542 | `ad49e2ceff52408b62dfd6a4580a807caa801dcc6557033bb83cdc8e7f40e826` |
| Item 2 | `bafkreiby6jtpx5bdtosvclzjssu4rze37w7ehdlluilefjadhs737mwonu` | 558 | `38f266fbf4239ba5512f2994a9c8e49bfdbe438d6ba21642a4033cbfbfb2ce6d` |
| Item 3 | `bafkreihxzvde4g7s2p6c3k7rkdtbumeobgtfe6fgp2dca7cugc3mns6noq` | 558 | `f7cd464e1bf2d3fc2dabf150e61a308e09a65278a67e86207c5430b6c6cbcd74` |

## Controls retained

AMM and AI commissioning remain inactive. The historical AI workspace retains its spec13 gate and therefore cannot sign against spec15. Sentry storage is outside wallet scope. The native wallet does not expose allocator administration, Sudo, penalty-policy activation, or runtime-upgrade calls.

The fixed `0.000000005 ETKN` per-operation ceiling reflects the settled individual signer allowance for the approved NFT workflow and the separately approved reward-claim ceiling; equality of the numeric values does not combine their budgets. No tip is used. A fresh quote above the relevant ceiling stops the action.

## Validation boundary

Automated validation covers static analysis, the full Flutter test suite, exact metadata hashes and call indices, negative compatibility checks, reward eligibility rejection, the native V14 screen, and a read-only live spec15 gate. Android and Windows release builds prove compilation and packaging on the recorded workstation toolchains.

Production acceptance still requires installation and manual UI/device QA on the intended Android device and Windows environment. Android production signing credentials and any Windows Authenticode credential remain owner-controlled and are not copied into this branch or its review artifacts. No production transaction is used as an app test.
