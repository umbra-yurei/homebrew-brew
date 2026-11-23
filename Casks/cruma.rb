cask "cruma" do
  version "1.0.21"

  url "https://files.cruma.io/files/tunnel-agent/v#{version}/aarch64-apple-darwin/cruma.dmg"
  sha256 "0790b77b1004acbd8c1883e372a319dbbfdd43f98876d2491a25982425d8bfd0"

  name "Cruma"
  desc "Cruma tunnel agent"
  homepage "https://cruma.io"

  depends_on arch: :arm64

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
