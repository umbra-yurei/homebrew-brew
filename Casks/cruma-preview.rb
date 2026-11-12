cask "cruma-preview" do
  version "1.0.19"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.19/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "461ffe6bb6f8a50b09c686796b3480a3fe8d0c6827a2126ea41e85a8aa95073a"

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
