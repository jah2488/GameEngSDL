#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure Homebrew is installed
if ! command_exists brew; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Ensure cmake is installed
if ! command_exists cmake; then
    echo "cmake is not installed. Installing cmake via Homebrew..."
    brew install cmake
fi

# List of submodules
submodules=("SDL" "SDL_image" "SDL_ttf")

# Build and install each submodule
for submodule in "${submodules[@]}"; do
    echo "Building and installing $submodule..."
    cd "$submodule"
    sudo cmake -S . -B build && sudo cmake --build build && sudo cmake --install build
    cd ..
done

# Build the Swift project
echo "Building the Swift project..."
if swift build; then
    echo "Project is ready to use."
else
    echo "Swift build failed."
    exit 1
fi
