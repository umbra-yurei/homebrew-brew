class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.0-RC1"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC1/aarch64-unknown-linux-musl/cruma"
      sha256 "530d033fb0d5c1bb059224bc557aa8c6ac434378ad15dbb80f15cab4a2525e60"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC1/x86_64-unknown-linux-musl/cruma"
      sha256 "5cb50a5cc215b15ada662f4488bac981392a378e88a073707cbd75607693ea35"
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
