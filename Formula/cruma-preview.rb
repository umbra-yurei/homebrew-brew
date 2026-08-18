class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.6"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.6/aarch64-unknown-linux-gnu/cruma"
      sha256 "cb68b138a0fe03467964391be9700ad3e12f3fb7591f97bfacdfc9f58f723b92"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.6/x86_64-unknown-linux-gnu/cruma"
      sha256 "60d27d7f166302a038123313166862afe94587b99292784c36da6ef3ce45311d"
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
