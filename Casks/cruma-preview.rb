cask "cruma-preview" do
  version "1.0.5"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.5/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "d1adcc7417fcac44ca8df2722f8c50cb343d981e492a340f3e5df8c2052b7181"

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
