# typed: strict
# frozen_string_literal: true

# Dify
class Dify < Formula
  desc "CLI tool for Dify plugin development"
  homepage "https://github.com/langgenius/dify-plugin-daemon"

  os_name=if OS.mac?
    "darwin"
  elsif OS.linux?
    "linux"
  else
    "unknown"
  end

  arch_name=if Hardware::CPU.arm?
    "arm64"
  elsif Hardware::CPU.intel?
    "amd64"
  else
    "unknown"
  end

  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}".freeze

  def self.get_sha256(cli_name)
    CHECKSUM_MAP.fetch(cli_name) do |key|
      raise "Failed to find SHA256 checksum for the file `#{key}`"
    end
  end

  CHECKSUM_MAP = {
    "dify-plugin-darwin-amd64" => "b786ccdf69ddeda354e5c0900024dca9f21cde1a0944163f3c39169c2a47aff3",
    "dify-plugin-darwin-arm64" => "f337a9e54e2c253eedbbada7761b95322b9ab207abec87c62816d0490aec0f6c",
    "dify-plugin-linux-amd64"  => "b9e2440e2cc780683c3ee182e58267472bd40d9db8715893e19206d15e720352",
    "dify-plugin-linux-arm64"  => "141c2b1ef70d9bee11320bebae834a8b3a80fee1917bfdb7018164248bf7b106",
  }.freeze

  url "#{homepage}/releases/download/0.6.0/#{CLI_BIN_NAME}"
  version "0.6.0"
  sha256 get_sha256(CLI_BIN_NAME)

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Define the URL and the SHA256 checksum for binary file

  def install
    # move the binary file to bin directory
    bin.install CLI_BIN_NAME.to_s => "dify"
    chmod("+x", "#{bin}/dify")
    system "#{bin}/dify", "version"
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/dify version").strip
  end
end
