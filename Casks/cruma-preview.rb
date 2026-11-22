cask "cruma-preview" do
  version "1.0.21"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.21/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "6df2c5bfbc0e07da871cf3a300252155d6fe4878a3e564e28ae869a1439305a8"

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
