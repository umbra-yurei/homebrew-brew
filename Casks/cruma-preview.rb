cask "cruma-preview" do
  version "1.0.15"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.15/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "592d5891daf2f0a47509544a6e6cb7ab8d5ab9fb3255841bf4142213725ba3eb"

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
