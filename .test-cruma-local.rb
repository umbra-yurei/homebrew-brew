cask "test-cruma-local" do
  version "local"

  url "file:///Users/olof/repos/uy/homebrew-brew/../cruma-sdk/release-v0.3.0-beta.3/aarch64-apple-darwin/cruma.dmg"
  sha256 "0a319b21066dc1be39071dba880eebbfa738b10b08c4458e76d9b9bf31c850e8"

  name "Cruma"
  desc "Cruma tunnel agent (local test)"
  homepage "https://cruma.io"

  app "Cruma.app"
  binary "Cruma.app/Contents/MacOS/cruma"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{appdir}/Cruma.app"]
    system_command "/usr/bin/codesign",
                   args: ["--force", "--deep", "-s", "-", "#{appdir}/Cruma.app"]
  end
end
