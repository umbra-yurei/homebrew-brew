cask "cruma" do
  version "1.0.15"

  url "https://files.cruma.io/files/tunnel-agent/v1.0.15/aarch64-apple-darwin/cruma.dmg"
  sha256 "b57f25ac5bdfab18156f57a1fd2c76c9ba5f3ea4f2ae8ca549ca80d111cef709"

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
