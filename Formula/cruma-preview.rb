class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.17"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.17/aarch64-unknown-linux-gnu/cruma"
      sha256 "2f7b6b7df08cdbed15a130e4db990155ed7790e95d9eab42e96f70f180a7322a"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.17/x86_64-unknown-linux-gnu/cruma"
      sha256 "d9ae7e6c426ddbbb533d6f3bb10069b691d2122aba86cad1da8c38ee60f96bd4"
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
