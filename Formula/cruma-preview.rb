class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.14"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.14/aarch64-unknown-linux-gnu/cruma"
      sha256 "534614b315ccf2af197e66502383037bffd8ee71bb29d5a9146c3ede3d13487f"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.14/x86_64-unknown-linux-gnu/cruma"
      sha256 "0f91436baa0fd76acac9b5cf10e1d161fa08ae9dec9e8f66f183d1861622fdd4"
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
