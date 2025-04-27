class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.0.9"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-arm64" => "1d205836baa170a88c8d531b6ca7a4cd42d6d7620170064de651162e1f96c95f",
    "dify-plugin-darwin-amd64" => "78e5ee5936ecba26ea647b6f8fcbc73de4fc636372f4a2bcb49052935875576a",
    "dify-plugin-linux-arm64" => "0bd6bb810b1d6e0cfec9e198f0bfdd6364253c22a400969e3bdc99e8112e2bca",
    "dify-plugin-linux-amd64" => "4204bfb415279cadd7462c1ac42c85c27ea08babe65bfdbe9a0bc3d7fe01de0a",
  }

  def self.get_sha256(cli_name)
    CHECKSUM_MAP.fetch(cli_name) do |key|
      raise "Failed to find SHA256 checksum for the file `#{key}`"
    end
  end

  # Define the URL and the SHA256 checksum for binary file
  url "#{homepage}/releases/download/#{version}/#{CLI_BIN_NAME}"
  sha256 get_sha256(CLI_BIN_NAME)

  def install
    # move the binary file to bin directory
    bin.install "#{CLI_BIN_NAME}" => "dify"
    system "chmod +x #{bin}/dify"
    system "#{bin}/dify version"
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/dify version").strip
  end
end
