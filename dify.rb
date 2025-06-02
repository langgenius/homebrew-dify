class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.1.1"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-arm64" => "388e4928ea4d6d596a1f64840a6339982dc954d7a0320fa194615013daa7db6c",
    "dify-plugin-darwin-amd64" => "c913ee6ce7fd7c1ba79e86ed08544bb3d989b68cc2c090ccd0dbd3f7afda549b",
    "dify-plugin-linux-arm64" => "9979fcd5c4dcb65158e168c1cb4648ea2ca76b5bee5a7ab91a3d42157a132c76",
    "dify-plugin-linux-amd64" => "4d547cb29af5a3890c2d047d92947b2dd86e884db7ce946535ba4e3fed817bb2",
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
