class Dify < Formula
    desc "Dify"
    homepage "https://github.com/langgenius/dify-plugin-daemon"
    license "MIT"
    url "https://github.com/langgenius/dify-plugin-daemon/archive/refs/tags/0.0.6.tar.gz"
    sha256 "d7109828c5d0e162387a744b33cefbb908f943e5c30e1d95ddd900733ed319d9"

    livecheck do
        url :stable
        strategy :github_latest
    end

    depends_on "go" => :build

    def install
       ldflags = "-X 'main.VersionX=v#{version}'"
       system "go", "build", *std_go_args(ldflags: ldflags), "-o", bin/"dify", "./cmd/commandline"
    end

    test do
        assert_match version.to_s, shell_output("#{bin}/dify version")
    end
end