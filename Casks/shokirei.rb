cask "shokirei" do
  version "0.4.1"
  sha256 "6020934b294b79f44bcbc4a22aa805fe6f60882fb1eb331e3add1474bee62fea"

  url "https://github.com/kakilangit/shokirei/releases/download/v#{version}/Shokirei-#{version}-universal.dmg"
  name "Shokirei"
  desc "Screenshot beautifier"
  homepage "https://github.com/kakilangit/shokirei"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Shokirei.app"

  # Shokirei is not notarized yet, so Gatekeeper would block the first launch.
  # Clearing the quarantine flag lets it open normally after installation.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Shokirei.app"]
  end

  # Quits the app before an upgrade or uninstall; `brew upgrade` reopens it afterwards.
  uninstall quit: "dev.kakilangit.shokirei"

  zap trash: "~/Library/Application Support/Shokirei"

  caveats <<~EOS
    Shokirei is not notarized by Apple yet. This cask removes the quarantine
    flag from Shokirei.app so that it opens without a Gatekeeper prompt.

    The first capture asks for the Screen Recording permission, in
    System Settings → Privacy & Security → Screen Recording. From 0.3.2,
    updates keep it. Coming from 0.3.1 or earlier, grant it once more:
    remove the old Shokirei entry there first if captures still fail.
  EOS
end
