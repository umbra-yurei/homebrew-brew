class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.0-RC2"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC2/aarch64-unknown-linux-musl/cruma"
      sha256 "bc800c2f4a6e6c8c7832f88e5b19943594f81e97899f8e389008dec15a1144d7"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC2/x86_64-unknown-linux-musl/cruma"
      sha256 "60f646fd7dd462c2b9df6df06bc2f96ee0a5ba8e8cd434f7348c5fb51d231a40"
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
