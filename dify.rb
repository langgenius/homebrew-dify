class Dify < Formula
  desc "Dify"
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  version "0.0.7"

  base_download_url = "https://github.com/langgenius/dify-plugin-daemon/releases/download/#{version}"

  if OS.mac?
    if Hardware::CPU.arm?
      url "#{base_download_url}/dify-plugin-darwin-arm64"
      sha256 "14ac423598bacce44281b5ab5ef59da11d66c39d54e8575da3a7514fe52abd25"
    elsif Hardware::CPU.intel?
      url "#{base_download_url}/dify-plugin-darwin-amd64"
      sha256 "e2f990be376162bcb4270fd0a35de84f0d0593403e58ecf07335a5c7487313e1"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "#{base_download_url}/dify-plugin-linux-arm64"
      sha256 "db09d683ceedc754328f8825e2af2a226c7791b2dc2834feb176c2b0c5cbd42a"
    elsif Hardware::CPU.intel?
      url "#{base_download_url}/dify-plugin-linux-amd64"
      sha256 "a5fb9dab4d0ab3a55ef786140b41262275650e789d50186783d765620550e4e7"
    end
  end

  def install
    if OS.mac?
      if Hardware::CPU.arm?
        bin_name = "dify-plugin-darwin-arm64"
      elsif Hardware::CPU.intel?
        bin_name = "dify-plugin-darwin-amd64"
      end
    elsif OS.linux?
      if Hardware::CPU.arm?
        bin_name = "dify-plugin-linux-arm64"
      elsif Hardware::CPU.intel?
        bin_name = "dify-plugin-linux-amd64"
      end
    end

    bin.install bin_name => "dify"
  end

  test do
    system "#{bin}/dify", "--version"
  end
end
