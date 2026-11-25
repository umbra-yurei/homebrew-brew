class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.22"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.22/aarch64-unknown-linux-gnu/cruma"
      sha256 "1bb095f9a258c5371e16dbc54bb3f687959318d053ca9845e027f622af6424ae"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.22/x86_64-unknown-linux-gnu/cruma"
      sha256 "4cd3440fdca09d7b0c32da91e230540906401bd7bfa25d940cec0ff21a57afa7"
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
