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
    "dify-plugin-darwin-amd64" => "98fa240fdc6115fa51b1120cd9f6ffc1fa690dc09fe169771f7a804956e2f235",
    "dify-plugin-darwin-arm64" => "6965c428a9954dc75df25eded4b0c7f0a407c6cafa13b4746f94d734130600a1",
    "dify-plugin-linux-amd64"  => "9e820e5c674a409ecce930c5a5eb6d54b3ae957e6efa85d65e1c81113e8d856f",
    "dify-plugin-linux-arm64"  => "6f3601937289376b9585c19165bfa53c70e30657813d58c122ce6ba916b3c277",
  }.freeze

  url "#{homepage}/releases/download/0.6.2/#{CLI_BIN_NAME}"
  version "0.6.2"
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
