class Dify < Formula
  desc "Dify"
  homepage "https://github.com/langgenius/dify-plugin-daemon"
  license "MIT"
  version "0.0.7"

  def self.os_name
    OS.mac? ? "darwin" : "linux"
  end

  def self.arch_name
    Hardware::CPU.arm? ? "arm64" : "amd64"
  end

  def self.cli_bin_name
    "dify-plugin-#{self.os_name}-#{self.arch_name}"
  end

  url "https://github.com/langgenius/dify-plugin-daemon/releases/download/#{version}/#{cli_bin_name}"

  on_macos do
    on_arm do
      sha256 "14ac423598bacce44281b5ab5ef59da11d66c39d54e8575da3a7514fe52abd25"
    end
    on_intel do
      sha256 "e2f990be376162bcb4270fd0a35de84f0d0593403e58ecf07335a5c7487313e1"
    end
  end

  on_linux do
    on_arm do
      sha256 "db09d683ceedc754328f8825e2af2a226c7791b2dc2834feb176c2b0c5cbd42a"
    end
    on_intel do
      sha256 "a5fb9dab4d0ab3a55ef786140b41262275650e789d50186783d765620550e4e7"
    end
  end

  def install
    bin.install "#{self.class.cli_bin_name}" => "dify"
  end

  test do
    system "#{bin}/dify", "version"
  end
end
