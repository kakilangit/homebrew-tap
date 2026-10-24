cask "matcha-app" do
  version "0.1.2"
  sha256 "5452b058824c994c242339970b5b06bb607b7c033f214c3ee223f38215315c84"

  url "https://github.com/kakilangit/matcha/releases/download/v#{version}/Matcha-#{version}-universal.dmg"
  name "Matcha"
  desc "Regular expression workbench"
  homepage "https://github.com/kakilangit/matcha"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Matcha.app"

  # Matcha is not notarized yet, so Gatekeeper would block the first launch.
  # Clearing the quarantine flag lets it open normally after installation.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Matcha.app"]
  end

  zap trash: "~/Library/Application Support/Matcha"

  caveats <<~EOS
    Matcha is not notarized by Apple yet. This cask removes the quarantine
    flag from Matcha.app so that it opens without a Gatekeeper prompt.
  EOS
end
