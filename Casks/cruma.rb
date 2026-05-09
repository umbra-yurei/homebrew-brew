cask "cruma" do
  version "1.0.2"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.2/aarch64-apple-darwin/cruma.dmg"
  sha256 "ec0e6b31c2b97e2f9a42c656eeae74da6d424e0085c60d267891e9ba3995f6c0"

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
