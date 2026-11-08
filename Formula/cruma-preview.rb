class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.18"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.18/aarch64-unknown-linux-gnu/cruma"
      sha256 "0e51b6bfcd8f6f1a40bcd5dfd344a17ef7f432d64a4118695fe9c12c6ef3ebc7"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.18/x86_64-unknown-linux-gnu/cruma"
      sha256 "b6facd2cc37053eda0ab58de30067cec8abe62bdf9ecefd2d3efb4c84d1751dd"
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
