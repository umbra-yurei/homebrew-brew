class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.11"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.11/aarch64-unknown-linux-gnu/cruma"
      sha256 "edcd9e3bc94efc02ab96d3b14d22cde77c0465d5bcda543aa2a2a9b13f62fe3e"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.11/x86_64-unknown-linux-gnu/cruma"
      sha256 "25ba1fcf1b208822d119577958d05b83f15ea4bcb907e9411758ca1b27ffeeef"
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
