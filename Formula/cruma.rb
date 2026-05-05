class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.0"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0/aarch64-unknown-linux-musl/cruma"
      sha256 "8bf280b7c95d06b13f1084d6e00255c84ea25756a24b9afcefd9954b28b25598"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0/x86_64-unknown-linux-gnu/cruma"
      sha256 "7b00c905d335c98c5650c428dd2d368849ca0aee3aaf70c52ff6d269269465cc"
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
