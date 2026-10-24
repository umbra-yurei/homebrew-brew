cask "cruma" do
  version "1.0.11"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.11/aarch64-apple-darwin/cruma.dmg"
  sha256 "ad48f6d03df6211ba9da225cc98c60ff2d4960407794a38f9228372553bde1f2"

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
