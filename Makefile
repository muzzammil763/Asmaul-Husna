# Release builds for Asmaul Husna. Run `make` or `make help` to see the commands.

VERSION := $(shell sed -n 's/^version: *//p' pubspec.yaml)
NAME    := AsmaulHusna-v$(VERSION)
OUT     := $(HOME)/Documents
BUILD   := build/app/outputs

.DEFAULT_GOAL := help
.PHONY: help apk aab signing

help: ## Show these commands
	@echo "Asmaul Husna $(VERSION)"
	@echo
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-6s %s\n", $$1, $$2}'
	@echo
	@echo "Files are moved to $(OUT). Bump 'version:' in pubspec.yaml before each Play upload."

apk: signing ## Build a signed release APK and move it to ~/Documents
	flutter build apk --release
	mv $(BUILD)/flutter-apk/app-release.apk "$(OUT)/$(NAME).apk"
	@echo "\n✓ $(OUT)/$(NAME).apk"

aab: signing ## Build a signed release App Bundle (for Play Store) and move it to ~/Documents
	flutter build appbundle --release
	mv $(BUILD)/bundle/release/app-release.aab "$(OUT)/$(NAME).aab"
	@echo "\n✓ $(OUT)/$(NAME).aab"

signing:
	@test -f android/key.properties || { \
		echo "android/key.properties is missing, so the build would be signed with the debug key."; \
		echo "Play Store rejects debug-signed builds. Add key.properties and the upload keystore first."; \
		exit 1; }
