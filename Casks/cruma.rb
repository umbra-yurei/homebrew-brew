cask "cruma" do
  version "1.0.8"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.8/aarch64-apple-darwin/cruma.dmg"
  sha256 "fe7572929a84f8b96c4c203a37c65b3e6d513561497a75dc24eb4fa14f2a74a1"

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
