#!/bin/sh
# Points a Flatpak manifest at a release: sets the git source's tag and commit, and
# regenerates cargo-sources.json from that tag's Cargo.lock, since Flatpak builds have
# no network. Usually run as `make flatpak-update APP=<app id> TAG=vX.Y.Z`.
#
# Needs Python 3 with aiohttp and tomlkit (e.g. apt install python3-aiohttp python3-tomlkit,
# or pip install aiohttp tomlkit).
set -eu

app=${1:?usage: update.sh APP_ID TAG}
tag=${2:?usage: update.sh APP_ID TAG}
dir=flatpak/$app
manifest=$dir/$app.yml
url=$(sed -n 's/^ *url: \(https:\/\/github.com\/.*\.git\)$/\1/p' "$manifest" | head -n 1)
repo=${url#https://github.com/}
repo=${repo%.git}

# An annotated tag also lists `refs/tags/TAG^{}`, its commit, which sorts last.
commit=$(git ls-remote --exit-code "$url" "refs/tags/$tag" "refs/tags/$tag^{}" |
  sort -k 2 | tail -n 1 | cut -f 1)

sed -i.bak \
  -e "s|^\( *tag: \).*|\1$tag|" \
  -e "s|^\( *commit: \).*|\1$commit|" \
  "$manifest"
rm "$manifest.bak"

# flatpak-builder-tools has no releases; pin a commit.
tools_commit=9d86d336a39b9af38b86f114b6ce5820fe260f91
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl --fail --location --silent --show-error --output "$work/flatpak-cargo-generator.py" \
  "https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/$tools_commit/cargo/flatpak-cargo-generator.py"
curl --fail --location --silent --show-error --output "$work/Cargo.lock" \
  "https://raw.githubusercontent.com/$repo/$commit/Cargo.lock"
python3 "$work/flatpak-cargo-generator.py" "$work/Cargo.lock" -o "$dir/cargo-sources.json"

echo "$manifest now builds $tag ($commit)"
