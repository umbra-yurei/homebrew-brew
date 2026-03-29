cask "cruma-preview" do
  version "1.0.0-RC2"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC2/aarch64-apple-darwin/cruma.dmg"
  sha256 "46fa1b4696465d7f6d96b37f72ca3037c8179e16e9cfe971cdf18ad3927c1f17"

  name "Cruma Preview"
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"

  app "Cruma.app", target: "Cruma Preview.app"

  # Symlinks the binary into $(brew --prefix)/bin so `cruma-preview` works in the terminal
  binary "#{appdir}/Cruma Preview.app/Contents/MacOS/cruma", target: "cruma-preview"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{appdir}/Cruma Preview.app"]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma Preview.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma Preview.app"]
  end
end
