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
    "dify-plugin-darwin-amd64" => "31100705895c711a6883672eb83214f9d75e321629c0d42ca87e376a5ffe5bd0",
    "dify-plugin-darwin-arm64" => "0d209baa93ebfee24be4456e141a36663faf4fccf99584754a3da3818760b8f3",
    "dify-plugin-linux-amd64"  => "f8f7a2d97c382a207d79547e52e74fc448ba54ae7193fd99dcde94bcc07a7159",
    "dify-plugin-linux-arm64"  => "e9b6618b8cdcabc5bbae3a255347aad0e8d94df700ed677602579f0fbf31099d",
  }.freeze

  url "#{homepage}/releases/download/0.5.3/#{CLI_BIN_NAME}"
  version "0.5.3"
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
