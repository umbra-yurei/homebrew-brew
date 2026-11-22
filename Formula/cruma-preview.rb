class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.21"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.21/aarch64-unknown-linux-gnu/cruma"
      sha256 "a7f0ffdbf8494b07f86380e9c8eabd5c54a18e5ac665fa4da86435ba712f622d"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.21/x86_64-unknown-linux-gnu/cruma"
      sha256 "5db0635303856b9c2f24bc4af90377f9a4e1e731c9d3ee16cd3658e1d4bab573"
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
