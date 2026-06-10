cask "pytrack" do
  version "1.0.1"
  sha256 "dad8ab24eb99403e788797b43f784d6c5651f236da10c667bdae3707012943b5"

  url "https://github.com/estevam5s/pytrack-desktop/releases/download/desktop-v#{version}/PyTrack_#{version}_universal.dmg"
  name "PyTrack"
  desc "App desktop oficial da PyTrack — domine Python"
  homepage "https://www.pytrack.com.br"

  app "PyTrack.app"

  zap trash: [
    "~/Library/Application Support/com.pytrack.app",
    "~/Library/Preferences/com.pytrack.app.plist",
  ]
end
