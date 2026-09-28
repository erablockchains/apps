# ERA Wallet production user support

## Official channels

- Support: <https://www.eraprojects.io/support.html>
- Email: <support@eraprojects.io>
- Website: <https://www.eraprojects.io/>
- Privacy: <https://www.eraprojects.io/privacy-policy.html>

## Safety rule

ERA support must never ask for a recovery phrase, private key, PIN, password, biometric data, or secure-storage content. Do not send screenshots that show a recovery phrase. Support cannot reverse finalized transactions or recover a lost phrase.

## Information users may provide

- ERA Wallet version/build and platform/OS;
- artifact filename and SHA-256;
- public wallet address;
- transaction hash and block number;
- model/prediction/market ID;
- UTC time and steps to reproduce;
- exact user-visible error;
- redacted report from an approved internal test build.

## Standard troubleshooting

1. Confirm the app came from the official website/store and its checksum matches.
2. Open Network & Release; confirm endpoint, genesis, `era` spec 13, storage v3, and compatible status.
3. Refresh once. Do not resubmit if the transaction outcome is unknown.
4. Preserve the public transaction hash and wait for reconciliation/finality.
5. For a forgotten PIN, use only a documented clean recovery with the user's own recovery phrase.
6. For lost recovery material, explain limits honestly; never suggest that ERA Projects has a copy.

Support cases involving suspected secret exposure, duplicate transactions, checksum mismatch, malicious copies, or incompatible metadata are security incidents and must follow the incident-response document.
