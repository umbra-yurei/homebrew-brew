cask "cruma" do
  version "1.0.0-RC7"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC7/aarch64-apple-darwin/cruma.dmg"
  sha256 "dbf4630cbcfcd81979bf8f56e2a1181db4a02d0807a4d9547d739b3a9e2d5a3e"

  name "Cruma"
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"

  app "Cruma.app"

  # Symlinks the binary into $(brew --prefix)/bin so `cruma` works in the terminal
  binary "#{appdir}/Cruma.app/Contents/MacOS/cruma"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{appdir}/Cruma.app"]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma.app"]
  end
end
