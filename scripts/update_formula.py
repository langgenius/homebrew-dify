#!/usr/bin/env python3
"""
Update dify.rb with the latest release version and checksums.

Usage:
    python scripts/update_formula.py         # rewrites dify.rb in place
    python scripts/update_formula.py --dry-run
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

REPO = "langgenius/dify-plugin-daemon"
REQUIRED_ASSETS = (
    "dify-plugin-darwin-amd64",
    "dify-plugin-darwin-arm64",
    "dify-plugin-linux-amd64",
    "dify-plugin-linux-arm64",
)
FORMULA_PATH = Path(__file__).resolve().parent.parent / "dify.rb"


def build_headers(accept: Optional[str] = "application/vnd.github+json") -> Dict[str, str]:
    headers = {
        "User-Agent": "homebrew-dify-updater",
    }
    if accept:
        headers["Accept"] = accept
    token = os.getenv("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers


def build_curl_command(url: str, headers: Dict[str, str]) -> List[str]:
    cmd = ["curl", "--fail", "--silent", "--show-error", "--location", url]
    for key, value in headers.items():
        cmd.extend(["-H", f"{key}: {value}"])
    return cmd


def curl_bytes(url: str, headers: Dict[str, str]) -> bytes:
    result = subprocess.run(
        build_curl_command(url, headers),
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        stderr = result.stderr.decode("utf-8", "replace").strip()
        raise RuntimeError(f"curl failed for {url}: {stderr or result.stdout.decode('utf-8', 'replace')}")
    return bytes(result.stdout)


def fetch_release() -> Dict:
    payload = curl_bytes(
        f"https://api.github.com/repos/{REPO}/releases/latest",
        build_headers(),
    )
    return json.loads(payload.decode("utf-8"))


def download_and_hash(url: str, headers: Dict[str, str]) -> str:
    data = curl_bytes(url, headers)
    digest = hashlib.sha256()
    digest.update(data)
    return digest.hexdigest()


def extract_checksums(release: Dict) -> Dict[str, str]:
    checksums: Dict[str, str] = {}
    download_headers = build_headers(accept=None)
    for asset in release.get("assets", []):
        name = asset.get("name")
        if name not in REQUIRED_ASSETS:
            continue
        digest_field = asset.get("digest") or ""
        if digest_field.startswith("sha256:"):
            checksums[name] = digest_field.split("sha256:", 1)[1]
            continue
        download_url = asset.get("browser_download_url")
        if download_url:
            print(f"Digest not provided for {name}, downloading to compute SHA256...")
            checksums[name] = download_and_hash(download_url, download_headers)
    missing = tuple(asset for asset in REQUIRED_ASSETS if asset not in checksums)
    if missing:
        raise RuntimeError(f"Missing checksums for: {', '.join(missing)}")
    return checksums


def normalize_version(tag_name: str, fallback_name: str) -> str:
    raw_version = tag_name or fallback_name
    if not raw_version:
        raise RuntimeError("Release response missing tag name.")
    return raw_version[1:] if raw_version.startswith("v") else raw_version


def replace_version(text: str, version: str) -> Tuple[str, bool]:
    pattern = re.compile(r'(?m)^(  version\s+")([^"]+)(")')

    def _sub(match: re.Match) -> str:
        return f'{match.group(1)}{version}{match.group(3)}'

    new_text, count = pattern.subn(_sub, text, count=1)
    if count == 0:
        raise RuntimeError("Failed to locate version declaration in dify.rb")
    return new_text, count > 0


def replace_checksums(text: str, checksums: Dict[str, str]) -> Tuple[str, bool]:
    changed = False
    for asset, checksum in checksums.items():
        pattern = re.compile(rf'("{re.escape(asset)}"\s*=> ")([^"]+)(")')

        def _sub(match: re.Match) -> str:
            nonlocal changed
            old = match.group(2)
            if old != checksum:
                changed = True
            return f'{match.group(1)}{checksum}{match.group(3)}'

        text, count = pattern.subn(_sub, text, count=1)
        if count == 0:
            raise RuntimeError(f"Failed to locate checksum entry for {asset}")
    return text, changed


def ensure_required_assets_present(asset_names: Iterable[str]) -> None:
    available = set(asset_names)
    missing = [name for name in REQUIRED_ASSETS if name not in available]
    if missing:
        raise RuntimeError(f"Release is missing required assets: {', '.join(missing)}")


def run(dry_run: bool, formula_path: Path) -> None:
    release = fetch_release()
    assets = release.get("assets", [])
    ensure_required_assets_present(asset.get("name") for asset in assets)
    version = normalize_version(release.get("tag_name"), release.get("name"))
    checksums = extract_checksums(release)
    original_text = formula_path.read_text(encoding="utf-8")
    updated_text, _ = replace_version(original_text, version)
    updated_text, _ = replace_checksums(updated_text, checksums)

    if original_text == updated_text:
        print(f"{formula_path} already targets version {version}")
        return

    if dry_run:
        sys.stdout.write(updated_text)
        return

    formula_path.write_text(updated_text, encoding="utf-8")
    print(f"Updated {formula_path} to version {version}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the would-be result to STDOUT instead of modifying dify.rb",
    )
    parser.add_argument(
        "--formula",
        type=Path,
        default=FORMULA_PATH,
        help="Path to the Homebrew formula (defaults to dify.rb)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        run(args.dry_run, args.formula)
    except Exception as exc:  # pragma: no cover - convenience for CLI usage
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
