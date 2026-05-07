APP_NAME := Drowzy
BUILD_DIR := .build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
DESTINATION ?= /Applications

.PHONY: help build test app launch package install clean

help: ## Show available commands.
	@awk 'BEGIN {FS = ":.*## "; printf "Available commands:\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the executable.
	swift build

test: ## Run unit tests.
	swift test

app: ## Build the macOS app bundle at .build/Drowzy.app.
	scripts/build_app.sh

launch: app ## Build and launch the app without blocking the shell.
	open "$(APP_BUNDLE)"

package: ## Create a release zip and checksum in .build/dist.
	scripts/package_release.sh

install: app ## Install the app bundle to DESTINATION, defaulting to /Applications.
	ditto "$(APP_BUNDLE)" "$(DESTINATION)/$(APP_NAME).app"
	@echo "Installed $(APP_NAME) to $(DESTINATION)."

clean: ## Remove SwiftPM and packaged build artifacts.
	swift package clean
	rm -rf "$(BUILD_DIR)/dist" "$(APP_BUNDLE)"
