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
    "dify-plugin-darwin-amd64" => "a401c38848ff064ca17cfe449df298f112f6ea62f9c142f300a64cb7e0b12f5a",
    "dify-plugin-darwin-arm64" => "8664808903661a6d03db8792163301f9046e30aec8399056c757c00bdbef3aed",
    "dify-plugin-linux-amd64"  => "a8495a4392e377737e7166e1f7afb0b40bc8cc5fa4d44eaa65c08e60c679d7d5",
    "dify-plugin-linux-arm64"  => "9c3f9a24cca0498cca95994807f17661bb3b73562fb2114662f4661935978ec4",
  }.freeze

  url "#{homepage}/releases/download/0.6.1/#{CLI_BIN_NAME}"
  version "0.6.1"
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
