class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.19"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.19/aarch64-unknown-linux-gnu/cruma"
      sha256 "15f888293e4575beb1dd4217576bd24e205902e853cc96a539189bdbdf34328d"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.19/x86_64-unknown-linux-gnu/cruma"
      sha256 "61a3503aeab1766a840e04b38d4a7a42c9d2905c93212b9c86122c16d49bd9c3"
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
