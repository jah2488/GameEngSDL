# Project-specific variables
SRC_DIR := /Users/justin/Projects/GameEngSDL/Sources
SDL_DIR := $(SRC_DIR)/SDL3/SDL3-3.1.2-macOS
MODULE_MAP := $(SRC_DIR)/SDL3/module.modulemap
INCLUDE_DIR := $(SDL_DIR)/include/SDL3
LIB_DIR := $(SDL_DIR)/lib
MAIN_SRC := $(SRC_DIR)/Engine/main.swift
OUTPUT := main
APP_NAME := MyApp
BUNDLE_ID := com.jah2488.myapp
APP_DIR := $(APP_NAME).app
# Bundle structure
CONTENTS_DIR := $(APP_DIR)/Contents
MACOS_DIR := $(CONTENTS_DIR)/MacOS
RESOURCES_DIR := $(CONTENTS_DIR)/Resources
FRAMEWORKS_DIR := $(CONTENTS_DIR)/Frameworks
LIBRARIES_DIR := $(CONTENTS_DIR)/Libraries
PLIST := $(CONTENTS_DIR)/Info.plist
SDL_DYLIB := libSDL3.dylib

# Common flags
APP_COMPILE_FLAGS := -D SDL
SWIFT_FLAGS := -I $(INCLUDE_DIR) -Xcc -fmodule-map-file=$(MODULE_MAP) $(APP_COMPILE_FLAGS)
LINK_FLAGS := -L $(LIB_DIR) \
              # -Xlinker -rpath @executable_path/../Frameworks \
              -framework AVFoundation \
              -framework CoreMedia \
              -framework CoreAudio \
              -framework CoreGraphics \
              -framework Cocoa \
              -framework CoreVideo \
              -framework Metal \
              -framework IOKit \
              -framework AppKit \
              -framework AudioToolbox \
              -framework GameController \
              -framework CoreHaptics \
              -framework Carbon \
              -framework ForceFeedback \
              -framework QuartzCore \
              -framework UniformTypeIdentifiers

# Check for DEBUG flag and add verbose flag if present
ifeq ($(DEBUG), 1)
    SWIFT_FLAGS += -v
    LINK_FLAGS += -v
endif

# Default target: dynamic
all: dynamic

# Dynamic compilation
dynamic:
	@echo "Compiling dynamically linked binary..."
	swiftc $(MAIN_SRC) $(SWIFT_FLAGS) $(LINK_FLAGS) -o $(OUTPUT) -lSDL3

# Static compilation
static:
	@echo "Compiling statically linked binary..."
	swiftc $(MAIN_SRC) $(SWIFT_FLAGS) $(LIB_DIR)/libSDL3.a $(LINK_FLAGS) -o $(OUTPUT)

# Create .app bundle
bundle: $(OUTPUT)
	@echo "Creating .app bundle..."
	mkdir -p $(MACOS_DIR) $(RESOURCES_DIR) $(FRAMEWORKS_DIR) $(LIBRARIES_DIR)
	cp $(OUTPUT) $(MACOS_DIR)/$(APP_NAME)
	cp $(LIB_DIR)/$(SDL_DYLIB) $(FRAMEWORKS_DIR)
	@$(call create_plist)
	@$(call set_rpath)

# Create Info.plist for the bundle
define create_plist
	@echo "Creating Info.plist..."
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(PLIST)
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(PLIST)
	@echo '<plist version="1.0">' >> $(PLIST)
	@echo '<dict>' >> $(PLIST)
	@echo '    <key>CFBundleName</key>' >> $(PLIST)
	@echo '    <string>$(APP_NAME)</string>' >> $(PLIST)
	@echo '    <key>CFBundleIdentifier</key>' >> $(PLIST)
	@echo '    <string>$(BUNDLE_ID)</string>' >> $(PLIST)
	@echo '    <key>CFBundleVersion</key>' >> $(PLIST)
	@echo '    <string>1.0</string>' >> $(PLIST)
	@echo '    <key>CFBundleExecutable</key>' >> $(PLIST)
	@echo '    <string>$(APP_NAME)</string>' >> $(PLIST)
	@echo '    <key>CFBundlePackageType</key>' >> $(PLIST)
	@echo '    <string>APPL</string>' >> $(PLIST)
	@echo '    <key>CFBundleShortVersionString</key>' >> $(PLIST)
	@echo '    <string>1.0</string>' >> $(PLIST)
	@echo '    <key>CFBundleInfoDictionaryVersion</key>' >> $(PLIST)
	@echo '    <string>6.0</string>' >> $(PLIST)
	@echo '    <key>LSMinimumSystemVersion</key>' >> $(PLIST)
	@echo '    <string>10.14</string>' >> $(PLIST)
	@echo '    <key>CFBundleIconFile</key>' >> $(PLIST)
	@echo '    <string></string>' >> $(PLIST)
	@echo '</dict>' >> $(PLIST)
	@echo '</plist>' >> $(PLIST)
endef

# Set LC_RPATH for the binary
define set_rpath
	@echo "Setting LC_RPATH for the binary..."
	install_name_tool -add_rpath "@executable_path/../Frameworks" $(MACOS_DIR)/$(APP_NAME)
	install_name_tool -change @rpath/libSDL3.0.dylib @rpath/$(SDL_DYLIB) $(MACOS_DIR)/$(APP_NAME)
endef

# Clean target to remove the output binary and app bundle
clean:
	@echo "Cleaning up..."
	rm -f $(OUTPUT)
	rm -rf $(APP_DIR)

# PHONY targets to avoid conflicts with files
.PHONY: all dynamic static bundle clean
