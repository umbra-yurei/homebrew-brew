class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.0-RC5"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC5/aarch64-unknown-linux-musl/cruma"
      sha256 "b7272734a67c8d5f7d0a90e66d2c808ce7b8aba8b17626b29737165b885d4515"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC5/x86_64-unknown-linux-gnu/cruma"
      sha256 "3ca1e8913b9b777d1644be0dc7b11c64c5f883a35300f221c03e09faeea442f4"
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
