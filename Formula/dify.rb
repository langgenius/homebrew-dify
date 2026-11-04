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
    "dify-plugin-darwin-amd64" => "25f75196bef0a50b4d5aba1518f120fe496cafb8878bab5582b38c960eccec85",
    "dify-plugin-darwin-arm64" => "b5b2e2b81c6b9130f1d431905a286a4a531e07e4b35cbb5decee126055643ab5",
    "dify-plugin-linux-amd64"  => "c89c4c9c78f9baaad97436e7e033fc96898e57c703be5e0688fc46c2f68e332e",
    "dify-plugin-linux-arm64"  => "85f6a0b7d8adb5b7c4ec9a3676c09890963ffcf31c4103fb91ece3f61268d6b8",
  }.freeze

  url "#{homepage}/releases/download/0.6.14/#{CLI_BIN_NAME}"
  version "0.6.14"
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
