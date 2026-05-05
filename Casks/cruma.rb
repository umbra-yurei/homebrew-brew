cask "cruma" do
  version "1.0.0"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.0/aarch64-apple-darwin/cruma.dmg"
  sha256 "e49653b8dbb33e7d52488cc104b7b6d6a737d12cae44af5ab6fe887fd68d8f4a"

  name "Cruma"
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"

  app "Cruma.app"

  # Symlinks the binary into $(brew --prefix)/bin so `cruma` works in the terminal
  binary "#{appdir}/Cruma.app/Contents/MacOS/cruma"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{appdir}/Cruma.app"]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma.app"]
  end
end
