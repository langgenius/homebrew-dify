class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-arm64" => "e8d22c8860ad837fa3a4641c19abe448b81c134476c2b56b2db4dae691356cd0",
    "dify-plugin-darwin-amd64" => "6a792bb8c683c6ae4c28cdf52ee7ecb8afd2124578f59f9b1bd94d01ca4a0b46",
    "dify-plugin-linux-arm64" => "51686b4e5de785d43d787bc8939f7cfaac5fe1f76aa94b279c5b6a6e6d829ef7",
    "dify-plugin-linux-amd64" => "bdf678de192fc3462e5f3cfd4d8ec8bfe9364a7b444c2120f1764d7c85332264",
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
