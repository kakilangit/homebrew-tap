# kakilangit/homebrew-tap

Homebrew casks for apps by [kakilangit](https://github.com/kakilangit).

## Install

```sh
brew install --cask kakilangit/tap/matcha-app
brew install --cask kakilangit/tap/shokirei
```

Or tap once, then install by name:

```sh
brew tap kakilangit/tap
brew install --cask matcha-app shokirei
```

## Casks

| Cask         | App |
| ------------ | --- |
| `matcha-app` | [Matcha](https://github.com/kakilangit/matcha), a regular expression workbench |
| `shokirei`   | [Shokirei](https://github.com/kakilangit/shokirei), a screenshot beautifier |

## Notes

The Matcha cask is named `matcha-app` because Homebrew already has an unrelated `matcha` formula.

Matcha and Shokirei are not notarized by Apple yet. Their casks clear the macOS quarantine
flag after installing, so the apps open without a Gatekeeper prompt. `brew uninstall --zap`
also removes what they keep: Matcha's saved pattern library, and Shokirei's saved styles,
settings, and recent screenshots.

If macOS still says an app can't be opened (for example, after installing it from the
`.dmg` instead of Homebrew), clear the quarantine flag yourself:

```sh
xattr -cr /Applications/Matcha.app
xattr -cr /Applications/Shokirei.app
```

Shokirei asks for the Screen Recording permission the first time it captures. From 0.3.1,
updates keep it, because every release is signed with the same certificate. Coming from 0.3.0
or earlier, grant it once more; if captures still fail, remove the old Shokirei entry in
System Settings → Privacy & Security → Screen Recording first.

## Development

```sh
make lint   # cask style
make ci     # style, audit, and a real install/uninstall of every cask (macOS)
```
