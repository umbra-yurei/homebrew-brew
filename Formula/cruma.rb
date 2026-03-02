class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.0-RC1"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC1/aarch64-unknown-linux-musl/cruma"
      sha256 "37a5f76a1c2fa7fc76f9c2e3f781a2e2afc15707d2c8c2cf1856e38622c74d8b"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC1/x86_64-unknown-linux-musl/cruma"
      sha256 "c0684a00db9db663003bfeaab77430688be8860b08ccb3ff9a6d462e0c10da9c"
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
