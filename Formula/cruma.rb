class Cruma < Formula
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"
  version "1.0.7"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.7/aarch64-unknown-linux-gnu/cruma"
      sha256 "27c9697f72606ca20130df014893c594336bd7c6591beb15d2c340347d470e1d"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.7/x86_64-unknown-linux-gnu/cruma"
      sha256 "374d68d13def0bd24a476385cc02379381981a7b57e47b556931e18dd9efc8f9"
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
