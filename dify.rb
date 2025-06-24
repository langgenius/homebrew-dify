class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.1.2"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-arm64" => "f5b886b9ff4d913067ea88ac495eebe2ccef8eef329cc3ff250f08d7b411d65d",
    "dify-plugin-darwin-amd64" => "cc33ccae38555de9de639e39e8f2809ebb40c21449262a4ffb849ba36981fca0",
    "dify-plugin-linux-arm64" => "b3360126cd79ce1aea12abd1809f25abac17549955b785544c7aa0bc81cd42e4",
    "dify-plugin-linux-amd64" => "ad135e3d62e5f252874b3f5946f40f6e963aee01d06c3b5f48732644e1e50a18",
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
