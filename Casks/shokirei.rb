cask "shokirei" do
  version "0.2.0"
  sha256 "230f04b9818f4c7401b666c2c1a1fa8b4b2fd44fc105c0c0f1e342ff46c4a1d6"

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

  zap trash: "~/Library/Application Support/Shokirei"

  caveats <<~EOS
    Shokirei is not notarized by Apple yet. This cask removes the quarantine
    flag from Shokirei.app so that it opens without a Gatekeeper prompt.

    The first capture asks for the Screen Recording permission, in
    System Settings → Privacy & Security → Screen Recording.
  EOS
end
