class Dify < Formula
  desc "Dify is a cli tool to help you develop your Dify projects."
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.0.10"

  livecheck do
    url :stable
    strategy :github_latest
  end

  os_name = OS.mac? ? "darwin" : (OS.linux? ? "linux" : "unknown")
  arch_name = Hardware::CPU.arm? ? "arm64" : (Hardware::CPU.intel? ? "amd64" : "unknown")
  CLI_BIN_NAME = "dify-plugin-#{os_name}-#{arch_name}"

  CHECKSUM_MAP = {
    "dify-plugin-darwin-arm64" => "005986e9067a8044cce32038ca671911603189361229e85d3f7b58cf6bc9d9ee",
    "dify-plugin-darwin-amd64" => "78cdeadf2ad4c89f0ac81293355017df9b97e7b360076802703655059b6d5125",
    "dify-plugin-linux-arm64" => "45de2f6c23dfdacefdc90822e0719942cd5ba89daf96ce467b32bb9670c6371c",
    "dify-plugin-linux-amd64" => "cf1cc8f43483eccfab992086ec295c15d3f4acf6249c9882438782d6a5349db6",
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
