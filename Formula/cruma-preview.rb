class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.0"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0/aarch64-unknown-linux-musl/cruma"
      sha256 "8bf280b7c95d06b13f1084d6e00255c84ea25756a24b9afcefd9954b28b25598"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0/x86_64-unknown-linux-gnu/cruma"
      sha256 "488a70d01ae56fa3192aa3e0d7ae2aadd36ff46c4d9ccdd8df728b7f889112de"
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
