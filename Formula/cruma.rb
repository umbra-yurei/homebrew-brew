class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.0-RC3"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC3/aarch64-unknown-linux-musl/cruma"
      sha256 "70dccf036478d309a4ecf0779cbe0eec9cc22d0968cb18edeaa20a090b2ed2b2"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC3/x86_64-unknown-linux-musl/cruma"
      sha256 "184ac8c2adb12b788e66a430b62935e5249c2d81515d173e5abab743ca676cbe"
    end
  end

  def install
    bin.install "cruma"
  end

  def post_install
    system "/bin/chmod", "755", bin/"cruma"
  end

  test do
    assert_match "cruma", shell_output("#{bin}/cruma --version")
  end
end
