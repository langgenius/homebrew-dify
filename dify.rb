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
    "dify-plugin-darwin-amd64" => "57c8d2a65580bf3e7dd7bdf04b5e54b11eb9aa19f06df61beeba70f75f2d6d0a",
    "dify-plugin-darwin-arm64" => "a3df2c1606eb631edb1c931ca8b944d337f370d2042607853156a585b68d2e4e",
    "dify-plugin-linux-amd64" => "69b0f0d00c34ffccf8031ddb18f872a54e31035938f727379130c6423727507f",
    "dify-plugin-linux-arm64" => "19e0c2c4eb982520eed4cf8394a9787bf23087419d40048e8c0566fdbf65e67c",
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
