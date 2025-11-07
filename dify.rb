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
    "dify-plugin-darwin-amd64" => "55acebcb31964aad4f97639fbae3685bb6014021d62b13c7e7cafa2bea52485a",
    "dify-plugin-darwin-arm64" => "0a02bb907bcd7083954c162956960b8adc545176b21a41d077c8b43225b19021",
    "dify-plugin-linux-amd64"  => "5f38369f700d73e7115a16bff55c484031f45630cf9c7b61dfcf264323867ac4",
    "dify-plugin-linux-arm64"  => "ebdad4fe3555f597dd1e717021bd7b1c9b745deb2f391f31eef707d6249b5f6e",
  }.freeze

  version "0.4.0"
  url "#{homepage}/releases/download/#{version}/#{CLI_BIN_NAME}"
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
