cask "cruma" do
  version "1.0.13"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.13/aarch64-apple-darwin/cruma.dmg"
  sha256 "eb0040e3b627fc7590b05a1ce1e5301cd2e7af13d2044089757b076616e1b212"

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
