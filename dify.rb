class Dify < Formula
    desc "Dify"
    homepage "https://github.com/langgenius/dify-plugin-daemon"
    license "MIT"
    url "https://github.com/langgenius/dify-plugin-daemon/archive/refs/tags/0.0.7.tar.gz"
    sha256 "a277d49127962c6d15fcfb47ad1ea8bc3e2d5bd7045b5c171b36b9cac2d9d2d7"

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
