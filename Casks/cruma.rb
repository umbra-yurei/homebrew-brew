cask "cruma" do
  version "1.0.5"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.5/aarch64-apple-darwin/cruma.dmg"
  sha256 "a51713eaf8b3af7eb05dc466253b1f02cea13346d2cddace4f9690c08048931b"

  name "Cruma"
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"

  app "Cruma.app"

  # Symlinks the binary into $(brew --prefix)/bin so `cruma` works in the terminal
  binary "#{appdir}/Cruma.app/Contents/MacOS/cruma"

  postflight do
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma.app"]
  end

end
