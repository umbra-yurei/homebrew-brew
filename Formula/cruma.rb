class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.2"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.2/aarch64-unknown-linux-gnu/cruma"
      sha256 "8a1f5d98c246818a8cd9491a21fe2283a9917bb031c689ea3a52e38398762998"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.2/x86_64-unknown-linux-gnu/cruma"
      sha256 "38935b9072c2ba22112843a81f0933b4f09b4fada12e890d067d2a912d14b200"
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
