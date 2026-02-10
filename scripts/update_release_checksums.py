import json
import os
import re
import urllib.request
from pathlib import Path


def run_main():
    access_token = os.getenv("GITHUB_TOKEN")
    if not access_token:
        raise ValueError("empty GITHUB_TOKEN, please set it in the environment variable.")

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {access_token}",
    }

    def urlopen_with_headers(url, headers, timeout=10) -> bytes:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.read()

    # Get the latest release information
    latest_release = {}
    try:
        resp_bytes = urlopen_with_headers(
            "https://api.github.com/repos/langgenius/dify-plugin-daemon/releases/latest",
            headers=headers,
            timeout=10
        )
        latest_release = json.loads(resp_bytes.decode("utf-8"))
        assets = latest_release.get("assets", [])
    except Exception as e:
        print(f"Failed to get latest release: {e}")
        return

    # Extract checksums of asset files
    asset_map = {}
    for asset in assets:
        asset_id = asset.get("id")
        asset_url = f"https://api.github.com/repos/langgenius/dify-plugin-daemon/releases/assets/{asset_id}"
        try:
            data = json.loads(urlopen_with_headers(asset_url, headers=headers, timeout=10).decode("utf-8"))
            checksum_sha256 = data.get("digest").removeprefix("sha256:")
            name = data.get("name")
            asset_map[name] = checksum_sha256
        except Exception as e:
            print(f"Failed to get asset {asset_id}: {e}")

    # Read dify.rb file
    dify_rb_path = (Path(__file__).resolve().parent.parent / "Formula" / "dify.rb")
    file_txt = dify_rb_path.read_text(encoding="utf-8")

    # Replace checksums in dify.rb file
    for asset_name in [
        "dify-plugin-darwin-arm64",
        "dify-plugin-darwin-amd64",
        "dify-plugin-linux-arm64",
        "dify-plugin-linux-amd64",
    ]:
        pattern = rf'("{asset_name}"\s*=>\s*")[^"]+"'
        replacement = rf'\g<1>{asset_map.get(asset_name)}"'
        file_txt = re.sub(pattern, replacement, file_txt)

    # update the version in dify.rb file
    version_pattern = r'  (version) \"[.\d]+\"'
    version_replacement = rf'  \g<1> "{latest_release.get("name")}"'
    file_txt = re.sub(version_pattern, version_replacement, file_txt)

    # Write the updated content back to dify.rb
    dify_rb_path.write_text(file_txt, encoding="utf-8")


if __name__ == "__main__":
    run_main()
