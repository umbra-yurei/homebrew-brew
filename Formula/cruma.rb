class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.13"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.13/aarch64-unknown-linux-gnu/cruma"
      sha256 "8da32374b9ae9d78c08413cfa1f3d81db75ae43b57a8efa0cb25017e34c50a24"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.13/x86_64-unknown-linux-gnu/cruma"
      sha256 "ec4eceed9f3f11d92070152d2e9ab6773c2b3fea4d94b1747b68197f1ab919ee"
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
