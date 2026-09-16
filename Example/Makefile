# The Example app's own Makefile — it owns build, test, archive and deploy for
# the app, while the repository root owns the package's build, test and clean
# (CONVENTIONS.md → Swift library, OPS-12).
#
# The root exposes only `deploy`, delegating here. Work on the app directly
# with `make -C Example build`, `make -C Example test`, and so on.

PROJECT := HorizontalPicker.xcodeproj
SCHEME  := Example

.DEFAULT_GOAL := help
.PHONY: help build test clean archive deploy

help: ## List the targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-8s %s\n", $$1, $$2}'

# --- Build and test: the simulator, no signing --------------------------------

BUILD_DEST := generic/platform=iOS Simulator
NOSIGN     := CODE_SIGNING_ALLOWED=NO

build: ## Compile the Example app for the simulator
	xcodebuild build -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(BUILD_DEST)' $(NOSIGN)

test: ## Run the Example scheme's tests on an iPhone simulator (TEST_DEVICE= picks one)
	@dev="$${TEST_DEVICE:-$$(xcrun simctl list devices available | grep -oE 'iPhone [0-9]+[^(]*' | tail -1 | xargs)}"; \
	dest="$${TEST_DEST:-platform=iOS Simulator,name=$$dev}"; \
	echo "Testing on: $$dest"; \
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) \
		-destination "$$dest" $(NOSIGN)

clean: ## Remove the Example app's build products
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME) || true
	rm -rf build

# --- Archive: a Debug build signed for a real device, exported as an .ipa -----
#
# Debug, not the scheme's Archive configuration (Release): a try-it build
# carries the development identity. See CONVENTIONS.md → "What the try-it
# build is". Signing is the project's own — automatic, team JJC3QT2D2L — with
# the developer account signed in to Xcode.

ARCHIVE_PATH   := build/HorizontalPicker.xcarchive
EXPORT_PATH    := build/export
# Only the export method: the archive supplies the signing style and the
# team, and the default thinning is one universal .ipa.
EXPORT_OPTIONS := Support/ExportOptions.plist

# The one place a version is worked out. Vendored unchanged from laugga/ops
# (CONVENTIONS.md → Versioning); a copy has to stay byte-identical to ops's.
VERSION_SH := Scripts/Version/version.sh

# Nothing writes a version into a tracked file: the version and build number
# are command-line overrides, so the project's own MARKETING_VERSION and
# CURRENT_PROJECT_VERSION stay as checked in and a build never dirties the tree.
archive: ## Build and export a signed Development .ipa into build/export/
	rm -rf "$(ARCHIVE_PATH)" "$(EXPORT_PATH)"
	out=$$($(VERSION_SH)) || exit 1; eval "$$out"; \
	xcodebuild archive \
		-project "$(PROJECT)" -scheme "$(SCHEME)" \
		-configuration Debug \
		-destination 'generic/platform=iOS' \
		-archivePath "$(ARCHIVE_PATH)" \
		-allowProvisioningUpdates \
		MARKETING_VERSION="$$VERSION" \
		CURRENT_PROJECT_VERSION="$$BUILD_NUMBER"
	xcodebuild -exportArchive \
		-archivePath "$(ARCHIVE_PATH)" \
		-exportPath "$(EXPORT_PATH)" \
		-exportOptionsPlist "$(EXPORT_OPTIONS)" \
		-allowProvisioningUpdates

# --- Deploy: a fresh .ipa to Firebase App Distribution ------------------------
#
# The Example app links no Firebase SDK and does nothing with these at
# runtime — there is no GoogleService-Info.plist to read them from, so the
# destination is just named here: the Firebase app registered for
# com.laugga.HorizontalPicker, in the Lightmate Development project, never
# another component's. The internal group has to exist already; deploy never
# creates one, and never changes who is in it.

FIREBASE_PROJECT := lightmate-development-390f6
FIREBASE_APP     := 1:480717957783:ios:2981d35830eb66aa8f97d2
FIREBASE_GROUPS  := internal

# PRODUCT_NAME is HorizontalPicker, so the app is HorizontalPicker.app and the
# export is HorizontalPicker.ipa — the Example target's product, not the
# scheme's name.
IPA           := $(EXPORT_PATH)/HorizontalPicker.ipa
RELEASE_NOTES := build/release-notes.txt
UPLOAD_LOG    := build/upload.log

# One recipe, in order, so nothing races under `make -j`: check the
# configuration, refuse a tree with uncommitted changes or unpushed commits,
# archive exactly once, then upload that archive's own .ipa. Any step failing
# stops the rest, so a failed build can never leave the previous run's link
# looking like the new one.
deploy: ## Build, export and upload a fresh .ipa to the internal group
	$(VERSION_SH) check-deployable
	$(MAKE) archive
	@test -f "$(IPA)" || { echo "deploy: the export produced no $(IPA)"; exit 1; }
	out=$$($(VERSION_SH)) || exit 1; eval "$$out"; \
	printf '%s\n\n%s @ %s\n%s\n' \
		"$$FULL_VERSION ($$BUILD_NUMBER)" \
		"$$(git rev-parse --abbrev-ref HEAD)" "$$COMMIT" \
		"$$(git log -1 --format=%s)" > "$(RELEASE_NOTES)"
	firebase appdistribution:distribute "$(IPA)" \
		--project "$(FIREBASE_PROJECT)" \
		--app "$(FIREBASE_APP)" \
		--groups "$(FIREBASE_GROUPS)" \
		--release-notes-file "$(RELEASE_NOTES)" \
		> "$(UPLOAD_LOG)" 2>&1 || { cat "$(UPLOAD_LOG)"; exit 1; }
	@cat "$(UPLOAD_LOG)"
	@out=$$($(VERSION_SH)) || exit 1; eval "$$out"; \
	uri=$$(grep -oE 'https://appdistribution\.firebase\.(google\.com|dev)/[^[:space:]]+' \
		"$(UPLOAD_LOG)" | tail -1); \
	test -n "$$uri" || { echo "deploy: uploaded, but no tester link in $(UPLOAD_LOG)"; exit 1; }; \
	printf '\n## Try it\n%s\n\n%s (%s)\n' "$$uri" "$$FULL_VERSION" "$$BUILD_NUMBER"
