#!/bin/bash

# Check if the script received an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <AppName>"
    exit 1
fi

# Variables
APP_NAME="$1"
BUILD_DIR=".build/release"
EXECUTABLE_PATH="$BUILD_DIR/$APP_NAME"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLIST_FILE="$CONTENTS_DIR/Info.plist"

# Check if the executable exists
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "Executable not found at $EXECUTABLE_PATH"
    exit 1
fi

# Create the .app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$RESOURCES_DIR/Assets"

# Copy the executable to the .app bundle
cp "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"

cp -r "$BUILD_DIR/$1_$1.bundle" "$RESOURCES_DIR"

# Create the Info.plist file
cat <<EOL > "$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourdomain.$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
</dict>
</plist>
EOL

# Make the executable runnable
chmod +x "$MACOS_DIR/$APP_NAME"

# Print success message
echo "$APP_NAME.app bundle has been created successfully."

