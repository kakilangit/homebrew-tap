# kakilangit/homebrew-tap

Packages for apps by [kakilangit](https://github.com/kakilangit): Homebrew casks for macOS, and,
for Linux, a Flatpak manifest. The apps' code lives in their own repos.

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

Shokirei asks for the Screen Recording permission the first time it captures.

## Linux

[`flatpak/dev.kakilangit.matcha`](flatpak/dev.kakilangit.matcha) is Matcha's Flatpak manifest for
[Flathub](https://flathub.org). It builds a release tag of Matcha, pinned to its commit, with the
crates vendored in `cargo-sources.json`, since Flatpak builds have no network.

## Development

```sh
make lint                         # cask style
make ci                           # style, audit, and a real install/uninstall of every cask (macOS)
make flatpak-update TAG=v0.1.4    # point the Flatpak at a release and refresh its crates
make flatpak                      # build and install the Flatpak (Linux)
make flatpak-lint                 # lint it as Flathub does (Linux)
```
