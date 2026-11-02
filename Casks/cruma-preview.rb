cask "cruma-preview" do
  version "1.0.16"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.16/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "0c25cd13685f0ab7ef3bfedd490d54cd39c4c1d245f5417b906dd742ceb21e8e"

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
