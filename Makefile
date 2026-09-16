# The library's build, test and clean (CONVENTIONS.md → Swift library,
# OPS-12). UIKit-only, so `swift build`/`swift test` build for macOS and fail
# on `import UIKit` — every target goes through xcodebuild and an iOS
# Simulator instead. No Example/Makefile or root `deploy` yet — HorizontalPicker
# has not opted into a try-it build (CONVENTIONS.md → "UI surfaces only").

SCHEME := HorizontalPicker

BUILD_DEST := generic/platform=iOS Simulator

.DEFAULT_GOAL := help
.PHONY: help build test clean

help: ## List the targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-8s %s\n", $$1, $$2}'

build: ## Build the library for iOS Simulator
	xcodebuild build -scheme $(SCHEME) -destination '$(BUILD_DEST)'

test: ## Run the package's unit tests on an iPhone simulator
	@dev="$${TEST_DEVICE:-$$(xcrun simctl list devices available | grep -oE 'iPhone [0-9]+[^(]*' | tail -1 | xargs)}"; \
	dest="$${TEST_DEST:-platform=iOS Simulator,name=$$dev}"; \
	echo "Testing on: $$dest"; \
	xcodebuild test -scheme $(SCHEME) -destination "$$dest"

clean: ## Remove the package's build products
	xcodebuild clean -scheme $(SCHEME)
	rm -rf .build
