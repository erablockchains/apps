# ERA Wallet production report privacy review

**Reviewed:** July 19, 2026

## Production exposure

Controlled Test Reports are compile-time excluded from the public participant UI because `ENABLE_PHASE6B_TESTING_TOOLS=false`. Report code remains available for separately built internal QA variants, but ordinary participants cannot navigate to it.

## Redaction boundary

All JSON and Markdown exports pass through one recursive redactor. It processes nested maps, lists, JSON-shaped strings, labelled secret text, mnemonic-like word sequences, and private-key-like hexadecimal material.

The following must never be exported:

- mnemonic, seed, or recovery phrase;
- PIN, passcode, password, or passphrase;
- private/secret key or signing material;
- biometric data;
- secure-storage contents;
- authentication tokens or credentials;
- full unredacted local debug logs.

The following public-chain evidence may be exported:

- public address;
- transaction/extrinsic hash;
- block number and hash;
- model, prediction, market, or token ID;
- public amount and balance changes;
- finalized lifecycle status;
- decoded dispatch result and public runtime event evidence;
- reviewed genesis/metadata/runtime hashes.

## Automated coverage

`test/phase6b/test_report_test.dart` and `test/phase6b/report_export_test.dart` cover recursive key redaction, sensitive labels, mnemonic-shaped values, private hexadecimal material, nested values, JSON/Markdown generation, and file export behavior. Production-mode tests confirm the report route is absent.

## Retention and sharing

Reports are never uploaded automatically. Internal QA builds save them to the application documents area or pass them to a user-selected share destination. Public addresses and activity remain identifying even after secret redaction. Review every report before sharing and remove local copies when no longer needed.

```text
REPORT_PRIVACY_REDACTION_ENABLED: YES
PUBLIC_REPORT_UI_ENABLED: NO
AUTOMATIC_REPORT_UPLOAD: NO
```

