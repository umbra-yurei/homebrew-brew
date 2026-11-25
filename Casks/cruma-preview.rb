cask "cruma-preview" do
  version "1.0.22"
  sha256 "be3b354ed1f899c40a433b583d094258e6a2b400ee0645913f12fdc6ce3031b1"

  url "https://files.cruma.io/files/tunnel-agent/v#{version}/aarch64-apple-darwin/cruma-preview.dmg"
  name "Cruma Preview"
  desc "Tunnel agent (preview)"
  homepage "https://cruma.io/"

  livecheck do
    url "https://files.cruma.io/files/tunnel-agent/preview.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on arch: :arm64

  app "Cruma Preview.app"
  # Symlinks the binary into $(brew --prefix)/bin so `cruma-preview` works in the terminal
  binary "#{appdir}/Cruma Preview.app/Contents/MacOS/cruma", target: "cruma-preview"

  postflight_steps do
    run "/System/Library/Frameworks/CoreServices.framework/Frameworks/" \
        "LaunchServices.framework/Support/lsregister",
        args: ["-f", "{{appdir}}/Cruma Preview.app"]
    run "/usr/bin/mdimport",
        args: ["{{appdir}}/Cruma Preview.app"]
  end
end
