class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.0-RC1"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC1/aarch64-unknown-linux-musl/cruma"
      sha256 "f85573c29b7a0b9dca382890ad46d403e30836136d2d8300ae91e7ff88fe7c7b"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC1/x86_64-unknown-linux-musl/cruma"
      sha256 "c6af8aeb3b755a862931bcbcda693eb077d6abcab5cc409077958e1345ac9fe4"
    end
  end

  def install
    bin.install "cruma" => "cruma-preview"
  end

  def post_install
    system "/bin/chmod", "755", bin/"cruma-preview"
  end

  test do
    assert_match "cruma", shell_output("#{bin}/cruma-preview --version")
  end
end
