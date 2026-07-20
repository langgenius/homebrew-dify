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
    "dify-plugin-darwin-amd64" => "1a9f464c84549529477812781cc6e40f6c6749f19ea63b2597af629a704a60bd",
    "dify-plugin-darwin-arm64" => "fd2351cd60e691fdbca80a52aeab2cc01dd69183c521f7de65dcf570f3280aca",
    "dify-plugin-linux-amd64"  => "5c63341c6d466d7126e41a4f39a7e73a54ff7aab0f28463a726590ae5b8d6f1c",
    "dify-plugin-linux-arm64"  => "36802446b7d47c13f1ae88cec87ab55b895466ffeaab0853df27a10dc63658f5",
  }.freeze

  url "#{homepage}/releases/download/0.6.4/#{CLI_BIN_NAME}"
  version "0.6.4"
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
