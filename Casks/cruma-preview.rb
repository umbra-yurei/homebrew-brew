cask "cruma-preview" do
  version "1.0.0-RC7"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.0-RC7/aarch64-apple-darwin/cruma.dmg"
  sha256 "dbf4630cbcfcd81979bf8f56e2a1181db4a02d0807a4d9547d739b3a9e2d5a3e"

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
