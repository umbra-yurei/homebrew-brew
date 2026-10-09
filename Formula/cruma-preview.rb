class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.9"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.9/aarch64-unknown-linux-gnu/cruma"
      sha256 "5b3037d341c705099130dd99c595f3cfdc7a316da06b7a5e6c8641316983bbb3"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.9/x86_64-unknown-linux-gnu/cruma"
      sha256 "1c9b296aedadf800f824a47772aa0a38733fa58f03e5f860172a3887275574dd"
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
