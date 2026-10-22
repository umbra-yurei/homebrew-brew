cask "cruma" do
  version "1.0.10"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.10/aarch64-apple-darwin/cruma.dmg"
  sha256 "576cb923ff782cee56133cc53069f96389d32b283aef067a6fffb1628f1cc7a8"

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
