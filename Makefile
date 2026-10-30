# Entry point for checking the casks locally and in CI. Run `make` for the targets.

TAP    := kakilangit/tap
CASKS  := $(basename $(notdir $(wildcard Casks/*.rb)))
BREW   ?= brew
# Tap directory Homebrew reads; `make setup` links this checkout there.
TAP_DIR = $(shell $(BREW) --repository)/Library/Taps/kakilangit/homebrew-tap

export HOMEBREW_NO_AUTO_UPDATE := 1
export HOMEBREW_NO_ANALYTICS := 1
export HOMEBREW_NO_INSTALL_FROM_API := 1

.DEFAULT_GOAL := help
.PHONY: help setup lint audit test ci

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "} /^[a-z-]+:.*## / {printf "  %-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Point the kakilangit/tap tap at this checkout, and trust it
	mkdir -p "$(dir $(TAP_DIR))"
	rm -rf "$(TAP_DIR)"
	ln -s "$(CURDIR)" "$(TAP_DIR)"
	@# Homebrew 7 refuses to load casks from a tap that isn't trusted; older ones lack `trust`.
	if $(BREW) trust --help >/dev/null 2>&1; then $(BREW) trust $(TAP); fi

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
