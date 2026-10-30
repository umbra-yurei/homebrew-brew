cask "cruma-preview" do
  version "1.0.14"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.14/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "9b9a75a254415690fedc5e582990b726d6dd1436a9e92a8eb90417269e41574f"

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
