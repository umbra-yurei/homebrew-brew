cask "cruma" do
  version "1.0.6"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.6/aarch64-apple-darwin/cruma.dmg"
  sha256 "80d381e5afdc64710be696fbccba008c104cea6f539034bd8d1b6f43065d0010"

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
