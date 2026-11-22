cask "cruma-preview" do
  version "1.0.20"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.20/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "e7ff533a216922b7d16441b34a8773309d6539344fcccf1f1116c89a6e2a60cd"

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
