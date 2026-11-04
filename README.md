# homebrew-dify

A [Homebrew](https://brew.sh/) tap for the [Dify](https://dify.ai/) plugin CLI.

It installs the `dify` command-line tool — the official CLI shipped with
[`dify-plugin-daemon`](https://github.com/langgenius/dify-plugin-daemon?tab=readme-ov-file#cli)
for scaffolding, developing, signing, and packaging Dify plugins. Prebuilt
binaries are provided for macOS and Linux on both `arm64` and `amd64`.

## Prerequisite

- [Homebrew](https://brew.sh/) installed on macOS or Linux

## Install

```bash
brew install langgenius/dify/dify
```

This shorthand automatically taps `langgenius/dify` and installs the formula. If
you prefer to tap explicitly first:

```bash
brew tap langgenius/dify
brew install dify
```

## Verify

```bash
dify version
```

## Upgrade

```bash
brew upgrade dify
```

## Reinstall

```bash
brew reinstall -f dify
```

## Uninstall

```bash
brew uninstall dify
brew untap langgenius/dify
```

## Maintenance

The formula lives in [`Formula/dify.rb`](Formula/dify.rb). It pins a `version`
and the SHA256 checksum for each platform binary published in a
[`dify-plugin-daemon` release](https://github.com/langgenius/dify-plugin-daemon/releases).

To bump the formula to the latest stable upstream release, run the helper script
with Python 3.9 or newer from the repository root. It reads the release tag and
asset digests from the GitHub API and updates the download URL, version, and all
four platform checksums in `Formula/dify.rb`:

```bash
python3 scripts/update_release_checksums.py
```

Authentication is optional for this public repository. Set `GITHUB_TOKEN` in
your environment if you need an authenticated API request, for example to avoid
the unauthenticated rate limit. The script exits with an error without changing
the formula if the API request fails, a required asset or SHA256 digest is
missing or invalid, or the expected formula fields cannot be found uniquely.

Review the diff and run the local checks before opening a pull request:

```bash
git diff -- Formula/dify.rb
python3 -m unittest discover -s tests -v
ruby -c Formula/dify.rb
git diff --check
```

Also verify downloaded release binaries against the updated SHA256 checksums
and confirm that the native binary's `version` command reports the expected
`v<version>`.

The [`brew test-bot` workflow](.github/workflows/tests.yml) defines Homebrew
tap-syntax and formula checks for macOS and Ubuntu, but its job is currently
disabled with `if: false`. Pull requests do not run those checks automatically.

## License

Released under the [MIT License](LICENSE).
