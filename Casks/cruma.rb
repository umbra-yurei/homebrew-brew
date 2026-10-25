cask "cruma" do
  version "1.0.12"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.12/aarch64-apple-darwin/cruma.dmg"
  sha256 "0adb17ac3fc56b8812fccf9ddf7448ffcb785dd6ae0b4049cc9bfca5052fd06d"

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
