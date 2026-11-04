import contextlib
import copy
import io
import json
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest.mock import patch

from scripts import update_release_checksums as updater


class ReleaseUpdateTests(unittest.TestCase):
    def setUp(self):
        self.formula = updater.FORMULA_PATH.read_text(encoding="utf-8")
        self.release = {
            "tag_name": "0.7.0",
            "name": "Dify plugin CLI release",
            "assets": [
                {"name": name, "digest": "sha256:" + str(index) * 64}
                for index, name in enumerate(updater.ASSET_NAMES, start=1)
            ],
        }

    def test_updates_url_version_and_all_checksums_from_tag(self):
        for tag in ("0.7.0", "v0.7.0"):
            with self.subTest(tag=tag):
                self.release["tag_name"] = tag
                updated = updater.update_formula(self.formula, self.release)
                self.assertIn(f'/releases/download/{tag}/#{{CLI_BIN_NAME}}', updated)
                self.assertIn('  version "0.7.0"', updated)
                for index, name in enumerate(updater.ASSET_NAMES, start=1):
                    self.assertRegex(updated, f'"{name}"\\s*=>\\s*"{str(index) * 64}"')
                self.assertEqual(updated, updater.update_formula(updated, self.release))

    def test_rejects_missing_or_duplicate_assets(self):
        for name in updater.ASSET_NAMES:
            for duplicate in (False, True):
                with self.subTest(name=name, duplicate=duplicate):
                    release = copy.deepcopy(self.release)
                    asset = next(a for a in release["assets"] if a["name"] == name)
                    if duplicate:
                        release["assets"].append(asset)
                    else:
                        release["assets"].remove(asset)
                    with self.assertRaises(ValueError):
                        updater.update_formula(self.formula, release)

    def test_rejects_missing_or_invalid_digests(self):
        for digest in (None, "", "sha256:bad", "sha256:" + "g" * 64, "sha512:" + "a" * 64):
            with self.subTest(digest=digest):
                self.release["assets"][0]["digest"] = digest
                with self.assertRaises(ValueError):
                    updater.update_formula(self.formula, self.release)

    def test_rejects_invalid_tags(self):
        for tag in (None, "", "Dify 0.7.0", "0.7.0-rc.1"):
            with self.subTest(tag=tag):
                self.release["tag_name"] = tag
                with self.assertRaises(ValueError):
                    updater.update_formula(self.formula, self.release)

    def test_rejects_missing_or_duplicate_formula_fields(self):
        for field in ('  url "', '  version "', f'    "{updater.ASSET_NAMES[0]}"'):
            line = next(
                line for line in self.formula.splitlines(True) if line.startswith(field)
            )
            for replacement in ("", line + line):
                with self.subTest(field=field, replacement=replacement):
                    content = self.formula.replace(line, replacement)
                    with self.assertRaises(ValueError):
                        updater.update_formula(content, self.release)

    def test_failed_update_leaves_formula_unchanged_and_returns_error(self):
        incomplete_release = copy.deepcopy(self.release)
        incomplete_release["assets"].pop()
        failures = (
            urllib.error.URLError("network failure"),
            io.BytesIO(b"invalid JSON"),
            io.BytesIO(json.dumps(incomplete_release).encode()),
        )
        with tempfile.TemporaryDirectory() as directory:
            formula_path = Path(directory) / "dify.rb"
            formula_path.write_text(self.formula, encoding="utf-8")
            for failure in failures:
                with self.subTest(failure=failure), contextlib.ExitStack() as stack:
                    behavior = (
                        {"side_effect": failure} if isinstance(failure, Exception)
                        else {"return_value": failure}
                    )
                    stack.enter_context(patch.object(updater, "FORMULA_PATH", formula_path))
                    stack.enter_context(
                        patch.object(updater.urllib.request, "urlopen", **behavior)
                    )
                    stack.enter_context(contextlib.redirect_stderr(io.StringIO()))
                    self.assertEqual(1, updater.run_main())
                    self.assertEqual(
                        self.formula, formula_path.read_text(encoding="utf-8")
                    )

    def test_public_api_works_with_optional_token(self):
        with tempfile.TemporaryDirectory() as directory:
            formula_path = Path(directory) / "dify.rb"
            for token in ("", "test-token"):
                with self.subTest(authenticated=bool(token)), contextlib.ExitStack() as stack:
                    formula_path.write_text(self.formula, encoding="utf-8")
                    response = io.BytesIO(json.dumps(self.release).encode())
                    stack.enter_context(patch.object(updater, "FORMULA_PATH", formula_path))
                    stack.enter_context(patch.dict(updater.os.environ, {"GITHUB_TOKEN": token}))
                    urlopen = stack.enter_context(
                        patch.object(updater.urllib.request, "urlopen", return_value=response)
                    )
                    stack.enter_context(contextlib.redirect_stdout(io.StringIO()))
                    self.assertEqual(0, updater.run_main())
                    request = urlopen.call_args.args[0]
                    self.assertEqual(
                        "Bearer test-token" if token else None,
                        request.get_header("Authorization"),
                    )
                    self.assertEqual(
                        updater.update_formula(self.formula, self.release),
                        formula_path.read_text(encoding="utf-8"),
                    )


if __name__ == "__main__":
    unittest.main()
