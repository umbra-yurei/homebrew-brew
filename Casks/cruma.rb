cask "cruma" do
  version "1.0.0-RC5"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC5/aarch64-apple-darwin/cruma.dmg"
  sha256 "ac9c95ca44ea47acf97723dd3069966cfb4cdc7970e1e9b341876949b8f08438"

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
