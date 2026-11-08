cask "cruma-preview" do
  version "1.0.18"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.18/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "d10e91316cdaf8b2986713ec46e21d979d2b54e0bf52fd0e24e399385cb4d299"

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
