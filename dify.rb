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
    "dify-plugin-darwin-amd64" => "55ec70958cb313e9026c8969f35c5de4c50e044102816f84450de5edeae70d0a",
    "dify-plugin-darwin-arm64" => "95dd55c2e949eaf716a5574121f6d86c80afbf1abbc552e8d4ddceb5a0f8028b",
    "dify-plugin-linux-amd64"  => "f26e5e5faae3d3931979798932aa6542c71de827b470132f385a95e0d74c5dcf",
    "dify-plugin-linux-arm64"  => "078149cf70cd3f1fdee11b733c1f1e49e594628f69c22a60a1ca0abeabe3569d",
  }.freeze

  url "#{homepage}/releases/download/0.3.2/#{CLI_BIN_NAME}"
  version "0.3.2"
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
