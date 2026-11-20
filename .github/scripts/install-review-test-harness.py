#!/usr/bin/env python3
"""Install only reviewed UI tests over an exact release checkout, never app code."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

ALLOWED = (
    'era-wallet/integration_test/review_access_actions.dart',
    'era-wallet/integration_test/review_access_test.dart',
    'era-wallet/test/review_access_action_test.dart',
)

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def install(source, harness, source_sha, harness_sha):
    source, harness = Path(source).resolve(), Path(harness).resolve()
    for value in (source_sha, harness_sha):
        if not re.fullmatch(r'[0-9a-f]{40}', value):
            raise ValueError('Full reviewed SHA required')
    actual = subprocess.check_output(['git', '-C', str(source), 'rev-parse', 'HEAD'], text=True).strip()
    if actual != source_sha:
        raise ValueError('Release checkout does not match provenance output')
    actual_harness = subprocess.check_output(['git', '-C', str(harness), 'rev-parse', 'HEAD'], text=True).strip()
    if actual_harness != harness_sha:
        raise ValueError('Harness checkout does not match workflow SHA')
    tracked = subprocess.check_output(['git', '-C', str(source), 'ls-files', '-z']).decode().split('\0')
    protected = [p for p in tracked if p and p not in ALLOWED]
    before = {p: digest(source / p) for p in protected}
    installed = {}
    for relative in ALLOWED:
        src, dst = harness / relative, source / relative
        if not src.is_file() or src.is_symlink():
            raise ValueError('Missing or symlinked reviewed test: ' + relative)
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst)
        installed[relative] = digest(dst)
    after = {p: digest(source / p) for p in protected}
    if before != after:
        raise ValueError('Overlay changed a protected release file')
    identity = {
        'release_source': source_sha, 'test_harness_commit': harness_sha,
        'test_files_sha256': installed, 'protected_tracked_files': len(protected),
        'protected_files_unchanged': True,
        'scope': 'Reviewed UI tests only; no app, iOS, assets or dependencies changed',
    }
    output = source / 'era-wallet/build/review-access-captures/harness.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(identity, indent=2) + '\n')
    print(json.dumps(identity, indent=2))
    return identity

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True)
    parser.add_argument('--harness', required=True)
    parser.add_argument('--source-sha', required=True)
    parser.add_argument('--harness-sha', required=True)
    args = parser.parse_args()
    install(args.source, args.harness, args.source_sha, args.harness_sha)
