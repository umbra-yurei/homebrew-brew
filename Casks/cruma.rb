cask "cruma" do
  version "1.0.22"
  sha256 "00f461e891202f6120d2db4034d46ddf4ac1ed8edaab93a7c117ad434ac6f27f"

  url "https://files.cruma.io/files/tunnel-agent/v#{version}/aarch64-apple-darwin/cruma.dmg"
  name "Cruma"
  desc "Tunnel agent"
  homepage "https://cruma.io/"

  livecheck do
    url "https://files.cruma.io/files/tunnel-agent/stable.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on arch: :arm64

  app "Cruma.app"
  # Symlinks the binary into $(brew --prefix)/bin so `cruma` works in the terminal
  binary "#{appdir}/Cruma.app/Contents/MacOS/cruma"
end
