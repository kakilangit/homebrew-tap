cask "takara" do
  version "0.1.0"
  # Replaced with the DMG's sha256 when the first release is published.
  sha256 :no_check

  url "https://github.com/kakilangit/takara/releases/download/v#{version}/Takara-#{version}-universal.dmg"
  name "Takara"
  desc "S3-compatible object browser, built for Garage"
  homepage "https://github.com/kakilangit/takara"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Takara.app"

  # Takara is not notarized yet, so Gatekeeper would block the first launch.
  # Clearing the quarantine flag lets it open normally after installation.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Takara.app"]
  end

  # Quits the app before an upgrade or uninstall; `brew upgrade` reopens it afterwards.
  uninstall quit: "dev.kakilangit.takara"

  zap trash: "~/Library/Application Support/Takara"

  caveats <<~EOS
    Takara is not notarized by Apple yet. This cask removes the quarantine
    flag from Takara.app so that it opens without a Gatekeeper prompt.

    Connection secrets are kept in your macOS Keychain, and uninstalling
    leaves them there so that reinstalling keeps your connections. To remove
    them, delete the dev.kakilangit.takara items in Keychain Access.
  EOS
end
