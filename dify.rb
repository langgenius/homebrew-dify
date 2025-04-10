class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.0.9"

  def self.os_name
    OS.mac? ? "darwin" : "linux"
  end

  def self.arch_name
    Hardware::CPU.arm? ? "arm64" : "amd64"
  end

  def self.cli_bin_name
    "dify-plugin-#{os_name}-#{arch_name}"
  end

  SHA256_FILE = "cli_checksums.txt"
  def self.sha256_map
    @sha256_map ||= begin
                      map = {}
                      File.readlines(SHA256_FILE).each do |line|
                        name, sha = line.strip.split
                        map[name] = sha
                      end
                      map
                    rescue Errno::ENOENT
                      raise "Failed to read the SHA256 checksum list file #{SHA256_FILE}"
                    end
  end

  def self.dynamic_sha256
    sha256_map.fetch(cli_bin_name) do |key|
      raise "Failed to look up SHA256 checksum for #{key}"
    end
  end

  # Define the URL and the SHA256 checksum for binary file
  url "#{homepage}/releases/download/#{version}/#{cli_bin_name}"
  sha256 dynamic_sha256

  def install
    # move the binary file to bin directory
    bin.install "#{self.class.cli_bin_name}" => "dify"
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/dify version").strip
  end
end
