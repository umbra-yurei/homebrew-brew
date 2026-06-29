class CrumaPreview < Formula
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"
  version "1.0.3"

  on_linux do
    on_arm do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.3/aarch64-unknown-linux-gnu/cruma"
      sha256 "167c8b80764fa20cb5b68c0617396ab55836795d9aaffd7dbf3497c755547c79"
    end
    on_intel do
      url "https://files.cruma.io/files/tunnel-agent/v1.0.3/x86_64-unknown-linux-gnu/cruma"
      sha256 "b310fd00a8810d82544f76730fce45b533bfdd8aa68a371f057f686faf825f45"
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
