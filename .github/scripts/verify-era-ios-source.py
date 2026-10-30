"""Read-only provenance gate for manual ERA iOS builds."""

import argparse
import json
import os
import plistlib
import re
import sys
import urllib.error
import urllib.request

REPOSITORY = "erablockchains/apps"
BUILD9 = "ec447f17a1d4f2556c1d5788b9af68c1083a9ba3"
TEAM = "D2F9K652YH"
BUNDLE = "com.eraprojects.erawallet"


def require_sha(value):
    if not re.fullmatch(r"[0-9a-f]{40}", value):
        raise ValueError("Supply a full, lowercase 40-character reviewed commit SHA.")
    return value


def validate_source(pubspec, project, info):
    version = re.search(r"^version:\s*[\"']?(\d+)\.(\d+)\.(\d+)\+(\d+)[\"']?\s*$", pubspec, re.M)
    if not version or tuple(map(int, version.groups()[:3])) != (1, 2, 0) or int(version[4]) < 9:
        raise ValueError("Source must declare the reviewed 1.2.0 build9-or-later lineage; build5 is not eligible.")
    teams = re.findall(r'DEVELOPMENT_TEAM\s*=\s*"?([A-Z0-9]+)"?\s*;', project)
    if not teams or set(teams) != {TEAM}:
        raise ValueError("Configure and review the ERA Apple team in the source before building.")
    identifiers = re.findall(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*"?([^\s";]+)"?\s*;', project)
    if BUNDLE not in identifiers or any(i not in (BUNDLE, BUNDLE + ".RunnerTests") for i in identifiers):
        raise ValueError("Unexpected Runner bundle identifier.")
    display = plistlib.loads(info).get("CFBundleDisplayName", "")
    if display not in ("ERA Wallet", "ERA Blockchain Wallet"):
        raise ValueError("Review the iOS display name and approved branding.")
    return version[0].split(":", 1)[1].strip().strip("\"'")


def read_url(url):
    request = urllib.request.Request(url, headers={"User-Agent": "ERA-iOS-source-preflight", "Accept": "application/vnd.github+json"})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        if error.code in (404, 422):
            raise ValueError("Required source/commit is not public on GitHub. Publish the reviewed build9/iOS branch first.") from None
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-sha", required=True)
    args = parser.parse_args()
    sha = require_sha(args.source_sha)
    repo = json.loads(read_url(f"https://api.github.com/repos/{REPOSITORY}"))
    if repo.get("private") is not False or repo.get("visibility") != "public":
        raise ValueError("This workflow is limited to the verified public repository and standard free compute.")
    compare = json.loads(read_url(f"https://api.github.com/repos/{REPOSITORY}/compare/{BUILD9}...{sha}"))
    if compare.get("status") not in ("ahead", "identical"):
        raise ValueError("Selected commit must contain the recorded build9 commit in its ancestry.")
    base = f"https://raw.githubusercontent.com/{REPOSITORY}/{sha}/era-wallet"
    version = validate_source(
        read_url(base + "/pubspec.yaml").decode("utf-8"),
        read_url(base + "/ios/Runner.xcodeproj/project.pbxproj").decode("utf-8"),
        read_url(base + "/ios/Runner/Info.plist"),
    )
    receipt = {"repository": REPOSITORY, "source_sha": sha, "build9_ancestor": BUILD9,
               "version": version, "team": TEAM, "bundle_id": BUNDLE,
               "scope": "source provenance only; not signed-app or App Review qualification"}
    print(json.dumps(receipt, indent=2))
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
            output.write(f"source_sha={sha}\n")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as summary:
            summary.write("## ERA iOS source provenance\n```json\n" + json.dumps(receipt, indent=2) + "\n```\n")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, json.JSONDecodeError, plistlib.InvalidFileException) as error:
        print(f"SOURCE PREFLIGHT FAILED: {error}", file=sys.stderr)
        sys.exit(1)
