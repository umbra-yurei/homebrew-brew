cask "cruma" do
  version "1.0.19"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.19/aarch64-apple-darwin/cruma.dmg"
  sha256 "2cca62323deef23f91ed18058e52d74f648c7c99b4cf1c179a8a7dbb6dd529fc"

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
