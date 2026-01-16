class CrumaTunnel < Formula
  desc "cruma-tunnel CLI"
  homepage "https://example.com"
  version "0.3.0-alpha.10"

  url "https://files.cruma.io/files/tunnel-agent%2Fv0.3.0-alpha.10%2Faarch64-apple-darwin%2Fcruma-tunnel"
  sha256 "2a3f50947832d24b97837a098627d1a30199b82ce775dcc46175f048e5fc3f62"

  def install
    bin.install "cruma-tunnel"
  end
  test do
    assert_match "cruma-tunnel", shell_output("#{bin}/cruma-tunnel --version")
  end
end
