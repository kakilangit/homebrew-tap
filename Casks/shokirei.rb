cask "shokirei" do
  version "0.5.0"
  sha256 "7cc3f387fd0aac2fb8c35371e25c5881a0647e8fc79a565594dcf7599420baa7"

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
