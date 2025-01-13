#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install cmake on macOS
install_cmake_macos() {
    if ! command_exists cmake; then
        echo "cmake is not installed. Installing cmake via Homebrew..."
        brew install cmake
    fi
}

# Function to install cmake and mingw64 on Windows
install_cmake_mingw_windows() {
    if ! command_exists cmake; then
        echo "cmake is not installed. Installing cmake via Scoop..."
        scoop install cmake
    fi

    if ! command_exists mingw64; then
        echo "mingw64 is not installed. Installing mingw64 via Scoop..."
        scoop install mingw
    fi
}

# Function to build and install submodules
build_submodules() {
    for submodule in "${submodules[@]}"; do
        echo "Building and installing $submodule..."
        cd "$submodule"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sudo cmake -S . -B build && sudo cmake --build build && sudo cmake --install build
        elif [[ "$OSTYPE" == "msys" ]]; then
            cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=../build-scripts/cmake-toolchain-mingw64-i686.cmake && cmake --build build && cmake --install build
        fi
        cd ..
    done
}

# Detect the operating system and set appropriate commands
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    # Ensure Homebrew is installed
    if ! command_exists brew; then
        echo "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    install_cmake_macos
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "Detected Windows"
    # Ensure Scoop is installed
    if ! command_exists scoop; then
        echo "Scoop is not installed. Please install Scoop first."
        exit 1
    fi
    install_cmake_mingw_windows
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# List of submodules
submodules=("SDL" "SDL_image" "SDL_ttf")

# Build and install submodules
build_submodules

# Build the Swift project
echo "Building the Swift project..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if swift build; then
        echo "Project is ready to use."
    else
        echo "Swift build failed."
        exit 1
    fi
elif [[ "$OSTYPE" == "msys" ]]; then
    if swift build; then
        echo "Project is ready to use."
    else
        echo "Build failed."
        exit 1
    fi
fi
