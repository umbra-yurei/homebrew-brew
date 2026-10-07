class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.8"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.8/aarch64-unknown-linux-gnu/cruma"
      sha256 "41672739a6662ed4835946a34ede68ba350ebe084ba225a1978c994aed1219a4"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.8/x86_64-unknown-linux-gnu/cruma"
      sha256 "8b186b02c8fa853ec19e854ba43341d68fae99b46dc650ab58b6333d68d75cd1"
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
