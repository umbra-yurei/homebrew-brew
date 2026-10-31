class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.15"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.15/aarch64-unknown-linux-gnu/cruma"
      sha256 "a0bc7b9b749570b3d0437a62e3f54be3017b0188034549ee8d3beb7887ecd2a7"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.15/x86_64-unknown-linux-gnu/cruma"
      sha256 "8579c83471e417fedb1d7c898505d907b290f0af3e9437d375a2a0f0c73a299f"
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
