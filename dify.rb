class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.1.3"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-arm64" => "b6f960f0dcda37821c67393b9d875530ae6d7d5834f3634272acd717ae84f4a3",
    "dify-plugin-darwin-amd64" => "00447fc270bd941b63be9a1c8d5aef4ef3f5ad89ae5441966943e93c7d1d0709",
    "dify-plugin-linux-arm64" => "bc6894a6b417d8be5c85f6c3bd5e6e5af164bdf28af8947f7d25bcbbb6404163",
    "dify-plugin-linux-amd64" => "1865de865bcbba4992a30b3f54ac23362ef106484f8f83d7832ab05e78a78294",
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
