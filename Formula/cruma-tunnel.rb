class CrumaTunnel < Formula
  desc "cruma-tunnel CLI"
  homepage "https://cruma.io"
  version "0.3.0-beta.2"

  url "https://files.cruma.io/files/tunnel-agent%2Fv0.3.0-beta.2%2Faarch64-apple-darwin%2Fcruma-tunnel"
  sha256 "1ba9269ba2ebea37f752a97e5be918ffecd84c8a551aa87c13fa100110f8403a"

  def install
    bin.install "cruma-tunnel"
  end
  def post_install
    system "/bin/chmod", "755", bin/"cruma-tunnel"
    system "/usr/bin/xattr", "-drs", "com.apple.quarantine", bin/"cruma-tunnel"
    system "/usr/bin/codesign", "--force", "--deep", "-s", "-", bin/"cruma-tunnel"
  end

  test do
    assert_match "cruma-tunnel", shell_output("#{bin}/cruma-tunnel --version")
  end
end
