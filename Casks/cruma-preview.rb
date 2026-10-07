cask "cruma-preview" do
  version "1.0.8"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.8/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "7ff89df107fc2c529a29d9064343b2aa63a0d105d228a4ff8300cdd81a9403e0"

  name "Cruma Preview"
  desc "Cruma tunnel agent (preview)"
  homepage "https://cruma.io"

  app "Cruma Preview.app"

  # Symlinks the binary into $(brew --prefix)/bin so `cruma-preview` works in the terminal
  binary "#{appdir}/Cruma Preview.app/Contents/MacOS/cruma", target: "cruma-preview"

  postflight do
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma Preview.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma Preview.app"]
  end

end
