class CrumaTunnel < Formula
  desc "cruma-tunnel CLI"
  homepage "https://example.com"
  version "0.3.0-alpha.10"

  url "https://files.cruma.io/files/tunnel-agent%2Fv0.3.0-alpha.10%2Faarch64-apple-darwin%2Fcruma-tunnel"
  sha256 "9e8dd454defed6b14647bcff51a51a3be84bfdbe605bdc0ec714c6892f2d4310"

  def install
    bin.install "cruma-tunnel"
  end
  test do
    assert_match "cruma-tunnel", shell_output("#{bin}/cruma-tunnel --version")
  end
end
