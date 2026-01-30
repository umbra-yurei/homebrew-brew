class CrumaTunnel < Formula
  desc "cruma-tunnel CLI"
  homepage "https://cruma.io"
  version "0.3.0-beta.3"

  url "https://files.cruma.io/files/tunnel-agent%2Fv0.3.0-beta.3%2Faarch64-apple-darwin%2Fcruma"
  sha256 "fad22ce2d3af12258f3cd93250d71a4058a55ade469321ace27aaa15e1eda0d5"

  def install
    bin.install "cruma"
  end
  def post_install
    system "/bin/chmod", "755", bin/"cruma"
    system "/usr/bin/xattr", "-drs", "com.apple.quarantine", bin/"cruma"
    system "/usr/bin/codesign", "--force", "--deep", "-s", "-", bin/"cruma"
  end

  test do
    assert_match "cruma", shell_output("#{bin}/cruma --version")
  end
end
