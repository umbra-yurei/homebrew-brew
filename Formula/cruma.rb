class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.12"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.12/aarch64-unknown-linux-gnu/cruma"
      sha256 "df5c349c21a2d06c71efcdc298aa0a8583bc520489602268ad3036645db3d718"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.12/x86_64-unknown-linux-gnu/cruma"
      sha256 "b69f70597f5f94b101a2545d1a108d40653e2eed7750b948a1ad116f646a7cc6"
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
