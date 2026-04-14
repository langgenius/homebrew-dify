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
    "dify-plugin-darwin-amd64" => "c43d35a5c3dcb3e92154f9136f816f681f333fcbab0aeb1588f3f19751879e97",
    "dify-plugin-darwin-arm64" => "d718ea81c033d027edde7bc0340d4a75e127c2575db52aa85f38e257316ec52f",
    "dify-plugin-linux-amd64"  => "c063aa115da7f6291abed8dfde15c046c8148678cfd0086bfab763a4269df1b6",
    "dify-plugin-linux-arm64"  => "a0999e9b9cef0afc67904acebee93ad664eec8c61873cc6fe978a03431dff2f1",
  }.freeze

  url "#{homepage}/releases/download/0.5.7/#{CLI_BIN_NAME}"
  version "0.5.7"
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
