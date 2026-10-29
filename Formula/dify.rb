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
    "dify-plugin-darwin-amd64" => "3161a5cb5048beb252cca76788e7e64148a690745b45a7ead50bee43b4b37b1e",
    "dify-plugin-darwin-arm64" => "c730a27b118d1342ac5650f99155033110f394f5a6dbf3023689328bf921efb6",
    "dify-plugin-linux-amd64"  => "f5190893643492c3f17f12c9752615a5652e47bbf30e84298634e176611aa108",
    "dify-plugin-linux-arm64"  => "db7b7a9bf25c058f5249f5a63b772282f981c049f906eda2dc017c5438b968f5",
  }.freeze

  url "#{homepage}/releases/download/0.6.12/#{CLI_BIN_NAME}"
  version "0.6.12"
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
