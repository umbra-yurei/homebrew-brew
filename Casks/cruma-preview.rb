cask "cruma-preview" do
  version "1.0.17"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.17/aarch64-apple-darwin/cruma-preview.dmg"
  sha256 "b1183170dc8ae0c6979aea6da49eac9681797de84cc2001255ee9a564fd7b9e7"

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
