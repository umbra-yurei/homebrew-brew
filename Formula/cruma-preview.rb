class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.20"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.20/aarch64-unknown-linux-gnu/cruma"
      sha256 "ac6a3de2248e8e15d15a27eb7a3d0d1810830ab35c1815776d5eaf6dca2cd857"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.20/x86_64-unknown-linux-gnu/cruma"
      sha256 "0d874a558d82b6126d4223063efe301b333c7271b9bc146878a1f1d3b1d13e2e"
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
