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
    "dify-plugin-darwin-amd64" => "12398b88ddc42de9d942f74b2b60007b2c611327ed0f801d33ff2cc50f39fed4",
    "dify-plugin-darwin-arm64" => "21a39ad332dc5c1062b09b2fdf507f9d4de355818239c8ff55631efa29eb3e89",
    "dify-plugin-linux-amd64"  => "f6dd9de4ef1d528bdf31bc38911d03c7636a1ba662250013ffd3589566381cf3",
    "dify-plugin-linux-arm64"  => "bd905579bf32254d81587a05ceb4dc5e571dbfb275930e6c160e45642374f11a",
  }.freeze

  url "#{homepage}/releases/download/0.5.2/#{CLI_BIN_NAME}"
  version "0.5.2"
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
