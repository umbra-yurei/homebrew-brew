cask "cruma" do
  version "1.0.7"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.7/aarch64-apple-darwin/cruma.dmg"
  sha256 "6722ee4cf5b029e71fe367f165f2077d248d23a1aaae771cf5d1b9bcdc2dcd7c"

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
