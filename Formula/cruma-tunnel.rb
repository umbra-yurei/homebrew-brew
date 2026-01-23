class CrumaTunnel < Formula
  desc "cruma-tunnel CLI"
  homepage "cruma.io"
  version "0.3.0-beta.1"

  url "https://files.cruma.io/files/tunnel-agent%2Fv0.3.0-beta.1%2Faarch64-apple-darwin%2Fcruma-tunnel"
  sha256 "0f05dacc474df183d0f277a7351d8390158867ca74b1bc28c8f1e479d15ac380"

  def install
    bin.install "cruma-tunnel"
  end
  test do
    assert_match "cruma-tunnel", shell_output("#{bin}/cruma-tunnel --version")
  end
end
