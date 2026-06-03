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

To bump the formula to the latest upstream release, run the helper script — it
reads the latest release from the GitHub API and rewrites the version and
checksums in `Formula/dify.rb`:

```bash
export GITHUB_TOKEN=<your-token>
python scripts/update_release_checksums.py
```

Pull requests are validated by [`brew test-bot`](.github/workflows/tests.yml),
which runs the Homebrew tap-syntax and formula checks on macOS and Ubuntu.

## License

Released under the [MIT License](LICENSE).
