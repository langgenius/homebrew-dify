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
    "dify-plugin-darwin-amd64" => "5f354a0483eeb002ca77486bce3fe2ffa2fdd40a71eae78d55af0cb14aedff9e",
    "dify-plugin-darwin-arm64" => "23627aa076c3420dfc153d48056b5b96a6a73ad005a57d9cbc735b9fd9351a81",
    "dify-plugin-linux-amd64"  => "0cef74bcae375a4337c2ff7d42e4787717981a795e1c23cf56bb27ec07ec8304",
    "dify-plugin-linux-arm64"  => "dfaf4faed2fc5ff3703c8568b7ebc78bca55b90ea8735580edcd068b603a57e1",
  }.freeze

  url "#{homepage}/releases/download/0.6.10/#{CLI_BIN_NAME}"
  version "0.6.10"
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
