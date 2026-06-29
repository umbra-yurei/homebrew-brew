cask "cruma" do
  version "1.0.3"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.3/aarch64-apple-darwin/cruma.dmg"
  sha256 "8f2e1f7e83e40559b02516a47c7c1854f34c5dc8bc5df68aff60001941bfa2d4"

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
