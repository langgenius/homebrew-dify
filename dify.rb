class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.0.9"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def self.os_name
    OS.mac? ? "darwin" : "linux"
  end

  def self.arch_name
    Hardware::CPU.arm? ? "arm64" : "amd64"
  end

  def self.cli_bin_name
    "dify-plugin-#{os_name}-#{arch_name}"
  end

  def self.cli_sha256
    sha256sum_map = {}
    File.readlines("cli_sha256sum_list.txt").each do |line|
      name, sha = line.strip.split
      sha256sum_map[name] = sha
    end

    sha256sum_map.fetch(cli_bin_name) do |key|
      raise "Failed to look up SHA256 checksum for `#{key}`"
    end
  end

  # Define the URL and the SHA256 checksum for binary file
  url "#{homepage}/releases/download/#{version}/#{cli_bin_name}"
  sha256 "#{cli_sha256}"

  def install
    # move the binary file to bin directory
    bin.install "#{self.class.cli_bin_name}" => "dify"
    system "chmod +x #{bin}/dify"
    system "#{bin}/dify version"
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/dify version").strip
  end
end
