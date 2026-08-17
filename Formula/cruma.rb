class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.5"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.5/aarch64-unknown-linux-gnu/cruma"
      sha256 "860d4284107fb444e80be83a9a9e629550113b7c12ebbe5831f6c5da23a1f84c"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.5/x86_64-unknown-linux-gnu/cruma"
      sha256 "0211bdc6cbb446110c536a86d1eb2b66c5fdac3fd5715bd83da6a6713135e2b3"
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
