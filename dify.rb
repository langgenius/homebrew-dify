class Dify < Formula
    desc "Dify"
    homepage "https://github.com/langgenius/dify-plugin-daemon"
    license "MIT"
    url "https://github.com/langgenius/dify-plugin-daemon/archive/refs/tags/0.0.9.tar.gz"
    sha256 "2e3e28bad84517406333180e101468c0640186ec59a0682d86f71af68a10eee3"

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
