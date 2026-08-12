class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.4"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.4/aarch64-unknown-linux-gnu/cruma"
      sha256 "cdb69546acd49c6f43a559cf5c483d17603d5b7d5abd9b85a7bf6f6fddb54537"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.4/x86_64-unknown-linux-gnu/cruma"
      sha256 "99d6988435087669d7944b2f2aa1c5c10b9575eb25499168ce527395863602bf"
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
