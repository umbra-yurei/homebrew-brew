class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.2"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.2/aarch64-unknown-linux-gnu/cruma"
      sha256 "6940e2c6ebc8a70dd1e3424a3fb5ebf948b3b57efdb2760b79556769377f53c3"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.2/x86_64-unknown-linux-gnu/cruma"
      sha256 "2c8dccb73fade5814815eabbe81774322d884af9900cc1724787adba49c331ca"
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
