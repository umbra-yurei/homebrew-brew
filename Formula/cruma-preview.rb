class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.16"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.16/aarch64-unknown-linux-gnu/cruma"
      sha256 "7240c8a78d329221f4b356930c7ce9196d138af040461701ad871267e0fab5ad"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.16/x86_64-unknown-linux-gnu/cruma"
      sha256 "516605e5f1032d65f625095be7c227c53912e3584a7d353e6b4333367ab523f0"
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
