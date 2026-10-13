# kakilangit/homebrew-tap

Homebrew casks for apps by [kakilangit](https://github.com/kakilangit).

## Install

```sh
brew install --cask kakilangit/tap/matcha-app
```

Or tap once, then install by name:

```sh
brew tap kakilangit/tap
brew install --cask matcha-app
```

## Casks

| Cask         | App |
| ------------ | --- |
| `matcha-app` | [Matcha](https://github.com/kakilangit/matcha), a regular expression workbench |

## Notes

The cask is named `matcha-app` because Homebrew already has an unrelated `matcha` formula.


Matcha is not notarized by Apple yet. Its cask clears the macOS quarantine flag after
installing, so the app opens without a Gatekeeper prompt. `brew uninstall --zap matcha-app`
also removes its saved pattern library.

If macOS still says Matcha can't be opened (for example, after installing it from the
`.dmg` instead of Homebrew), clear the quarantine flag yourself:

```sh
xattr -cr /Applications/Matcha.app
```

## Development

```sh
make lint   # cask style
make ci     # style, audit, and a real install/uninstall of every cask (macOS)
```
