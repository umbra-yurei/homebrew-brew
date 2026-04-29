class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.0-RC7"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC7/aarch64-unknown-linux-musl/cruma"
      sha256 "908c13c1051d86b520e10f430f66df7772b49effd1f5199d466bb8d528533a6f"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC7/x86_64-unknown-linux-gnu/cruma"
      sha256 "308a36a324dd2d36dfaecf7c5ab25be96f4a36dae5fab1ffd4bea7d8fbb36d23"
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
