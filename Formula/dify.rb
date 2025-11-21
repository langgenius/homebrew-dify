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
    "dify-plugin-darwin-amd64" => "30c0c3f4e7d7fb416c825d68ec1a084a3ac55f3bcd482d6a61817df64092bd6c",
    "dify-plugin-darwin-arm64" => "c370b2819249f2ea7a663ddaaa046ee52a56c725b98470d23410eef271627ebb",
    "dify-plugin-linux-amd64"  => "5d0e6684ad460c45e8e28b4a84b316c586c3a0fe2edbe1cd5b25a16d8494940b",
    "dify-plugin-linux-arm64"  => "f4c276b6d19cfa32a93576fc0063503d14b4b5871df16d4d50cbdba9d046ee34",
  }.freeze

  url "#{homepage}/releases/download/0.4.1/#{CLI_BIN_NAME}"
  version "0.4.1"
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
