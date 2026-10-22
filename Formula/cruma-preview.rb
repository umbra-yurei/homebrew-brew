class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.10"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.10/aarch64-unknown-linux-gnu/cruma"
      sha256 "50a6f0cd79c9dae52175cc21750693c229216ac4fae61a224890327bd2667f83"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.10/x86_64-unknown-linux-gnu/cruma"
      sha256 "9f56e3fc4f8e39b7ddbb8bbb19db8878906caa122751db6010e6e2bf081e2377"
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
