cask "cruma" do
  version "1.0.4"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.4/aarch64-apple-darwin/cruma.dmg"
  sha256 "9c09b5076d812d2a52440c67953daadb4384b0147fc741db0a62e9508aba1a6f"

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
