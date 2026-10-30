cask "cruma" do
  version "1.0.14"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.14/aarch64-apple-darwin/cruma.dmg"
  sha256 "2835ab799c9910c1a210c7672edb480fc99102d7bfb38df191d8145e11802dc2"

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
