cask "cruma" do
  version "1.0.2"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.2/aarch64-apple-darwin/cruma.dmg"
  sha256 "21b6f629ef1d040053793ac4170c8097ab982c827b31c566682717b96cdbf128"

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
