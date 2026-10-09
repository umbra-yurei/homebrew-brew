cask "cruma" do
  version "1.0.9"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.9/aarch64-apple-darwin/cruma.dmg"
  sha256 "9e7bbcb2040750b97d3b269d79539f6949a7dae2f2f29a23c98a6d1a1858f529"

  name "Cruma"
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"

  app "Cruma.app"

  # Symlinks the binary into $(brew --prefix)/bin so `cruma` works in the terminal
  binary "#{appdir}/Cruma.app/Contents/MacOS/cruma"

  postflight do
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma.app"]
  end

end
