# Entry point for checking the casks locally and in CI, and for the Flatpak manifests in
# flatpak/. Run `make` for the targets.

TAP    := kakilangit/tap
CASKS  := $(basename $(notdir $(wildcard Casks/*.rb)))
BREW   ?= brew
# Tap directory Homebrew reads; `make setup` links this checkout there.
TAP_DIR = $(shell $(BREW) --repository)/Library/Taps/kakilangit/homebrew-tap

# The Flatpak to build, update, or lint: a folder in flatpak/ named by its app ID.
APP         ?= dev.kakilangit.matcha
FLATPAK_DIR := flatpak/.build/$(APP)
# e.g. FLATPAK_BUILDER_FLAGS=--disable-rofiles-fuse in containers without /dev/fuse.
FLATPAK_BUILDER_FLAGS ?=

export HOMEBREW_NO_AUTO_UPDATE := 1
export HOMEBREW_NO_ANALYTICS := 1
export HOMEBREW_NO_INSTALL_FROM_API := 1

.DEFAULT_GOAL := help
.PHONY: help setup lint audit test ci flatpak flatpak-update flatpak-lint

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "} /^[a-z-]+:.*## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Point the kakilangit/tap tap at this checkout
	mkdir -p "$(dir $(TAP_DIR))"
	rm -rf "$(TAP_DIR)"
	ln -s "$(CURDIR)" "$(TAP_DIR)"

lint: setup ## Check cask style
	$(BREW) style --cask $(addprefix $(TAP)/,$(CASKS))

audit: setup ## Audit casks, including their downloads (macOS)
	$(BREW) audit --cask --strict --online $(addprefix $(TAP)/,$(CASKS))

test: setup ## Install each cask, check its app, and uninstall it (macOS)
	@for cask in $(CASKS); do \
		set -e; \
		$(BREW) install --cask "$(TAP)/$$cask"; \
		app=$$($(BREW) info --cask --json=v2 "$(TAP)/$$cask" | \
			ruby -rjson -e 'puts JSON.parse($$stdin.read)["casks"][0]["artifacts"].find { |a| a["app"] }["app"][0]'); \
		path="/Applications/$$app"; \
		test -d "$$path" || { echo "$$path was not installed" >&2; exit 1; }; \
		codesign --verify --strict "$$path"; \
		if xattr -p com.apple.quarantine "$$path" >/dev/null 2>&1; then \
			echo "$$path is still quarantined" >&2; exit 1; \
		fi; \
		echo "$$cask: $$path installed, signed, and not quarantined"; \
		$(BREW) uninstall --cask --zap "$(TAP)/$$cask"; \
		test ! -e "$$path" || { echo "$$path was not removed" >&2; exit 1; }; \
	done

ci: lint audit test ## Everything CI runs (macOS)

flatpak-update: ## Point APP's Flatpak at release TAG (e.g. TAG=v0.1.4) and refresh its crates
	./flatpak/update.sh $(APP) $(TAG)

# The same flatpak-builder as Flathub, so `make flatpak-lint` sees what Flathub's build would.
flatpak: ## Build APP's Flatpak and install it for this user (Linux)
	flatpak run org.flatpak.Builder --user --install --force-clean --install-deps-from=flathub $(FLATPAK_BUILDER_FLAGS) \
		--state-dir=$(FLATPAK_DIR)/state --repo=$(FLATPAK_DIR)/repo \
		--mirror-screenshots-url=https://dl.flathub.org/media/ \
		$(FLATPAK_DIR)/build flatpak/$(APP)/$(APP).yml

flatpak-lint: ## Lint APP's manifest, and its `make flatpak` build, as Flathub does (Linux)
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest flatpak/$(APP)/$(APP).yml
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo $(FLATPAK_DIR)/repo
