class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.3.1"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-amd64" => "1b0636f9e106ab71e15c5276d931020b9bd427211fd91c8b7dca22ca243802b8",
    "dify-plugin-darwin-arm64" => "5fece620cb415607b88e1e7628e3c412d6db605a85d50820d1a889631cb7f40e",
    "dify-plugin-linux-amd64" => "d5537d49cab12a61e510071e25efa26aefe969fbcc788e8760eca436b9daeee1",
    "dify-plugin-linux-arm64" => "e82dde9fc1068c8c20478744fb0190f11d9fc5f68d8248e5d84fb36a238bcaf7",
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
