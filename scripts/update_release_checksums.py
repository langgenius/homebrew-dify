import json
import os
import re
import sys
import urllib.request
from pathlib import Path


FORMULA_PATH = Path(__file__).resolve().parent.parent / "Formula" / "dify.rb"
RELEASE_URL = "https://api.github.com/repos/langgenius/dify-plugin-daemon/releases/latest"
ASSET_NAMES = (
    "dify-plugin-darwin-amd64",
    "dify-plugin-darwin-arm64",
    "dify-plugin-linux-amd64",
    "dify-plugin-linux-arm64",
)


def update_formula(content, release):
    """Validate the release and return a complete formula update."""
    if not isinstance(release, dict):
        raise ValueError("Expected a release object from GitHub")
    tag = release.get("tag_name")
    if not isinstance(tag, str) or not re.fullmatch(r"v?\d+\.\d+\.\d+", tag):
        raise ValueError(f"Invalid stable release tag: {tag!r}")
    version = tag.removeprefix("v")

    assets = release.get("assets")
    if not isinstance(assets, list) or not all(isinstance(a, dict) for a in assets):
        raise ValueError("Missing or invalid release assets")
    checksums = {}
    for name in ASSET_NAMES:
        matches = [asset for asset in assets if asset.get("name") == name]
        if len(matches) != 1:
            raise ValueError(f"Expected exactly one release asset: {name}")
        digest = matches[0].get("digest")
        if not isinstance(digest, str) or not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
            raise ValueError(f"Missing or invalid SHA256 digest for {name}")
        checksums[name] = digest.removeprefix("sha256:")

    def replace_once(pattern, replacement, field):
        nonlocal content
        content, count = re.subn(pattern, replacement, content, flags=re.MULTILINE)
        if count != 1:
            raise ValueError(f"Expected exactly one {field} in {FORMULA_PATH.name}")

    for name, checksum in checksums.items():
        replace_once(
            rf'("{re.escape(name)}"\s*=>\s*")[^"]*(")',
            rf'\g<1>{checksum}\g<2>',
            f"checksum for {name}",
        )
    replace_once(
        r'^  url "#\{homepage\}/releases/download/[^/"]+/#\{CLI_BIN_NAME\}"$',
        f'  url "#{{homepage}}/releases/download/{tag}/#{{CLI_BIN_NAME}}"',
        "release URL",
    )
    replace_once(r'^  version "[^"]+"$', f'  version "{version}"', "version")
    return content


def run_main():
    headers = {"Accept": "application/vnd.github+json"}
    access_token = os.getenv("GITHUB_TOKEN")
    if access_token:
        headers["Authorization"] = f"Bearer {access_token}"

    try:
        request = urllib.request.Request(RELEASE_URL, headers=headers)
        with urllib.request.urlopen(request, timeout=30) as response:
            release = json.load(response)
        content = update_formula(FORMULA_PATH.read_text(encoding="utf-8"), release)
        FORMULA_PATH.write_text(content, encoding="utf-8")
    except (OSError, ValueError) as error:
        print(f"Failed to update formula: {error}", file=sys.stderr)
        return 1

    print(f"Updated {FORMULA_PATH.name} to {release['tag_name']}")
    return 0


if __name__ == "__main__":
    sys.exit(run_main())
