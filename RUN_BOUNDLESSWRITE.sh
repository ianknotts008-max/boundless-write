#!/bin/bash
################################################################################
# BoundlessWrite Application Launcher
################################################################################
# Starts BoundlessWrite word processor with proper environment setup
# Works on Linux, macOS, and via Android emulator/device
#
# Usage:
#   chmod +x RUN_BOUNDLESSWRITE.sh
#   ./RUN_BOUNDLESSWRITE.sh [platform]
#
# Platforms: linux, android, macos, windows, auto (default)
#
################################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM="${1:-auto}"

echo -e "${BLUE}================================================================================${NC}"
echo -e "${BLUE}BoundlessWrite - Universal Application Launcher${NC}"
echo -e "${BLUE}================================================================================${NC}"
echo ""

# Setup environment
export PATH="$HOME/flutter_sdk/flutter/bin:$HOME/flutter_sdk/flutter/bin/cache/dart-sdk/bin:/home/boundless-ai-dev/.cargo/bin:$PATH"
export LD_LIBRARY_PATH="$SCRIPT_DIR/bwe_core/target/x86_64-unknown-linux-gnu/release:$LD_LIBRARY_PATH"

cd "$SCRIPT_DIR/bwe_ui"

# Detect platform if auto
if [ "$PLATFORM" == "auto" ]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        PLATFORM="windows"
    else
        echo -e "${YELLOW}⚠️  Platform not detected. Using Android.${NC}"
        PLATFORM="android"
    fi
fi

echo -e "${GREEN}Launching on: $PLATFORM${NC}"
echo ""

case "$PLATFORM" in
    linux)
        echo "Starting BoundlessWrite for Linux..."
        if [ -f "build/linux/x64/release/bundle/bwe_ui" ]; then
            # Run pre-built binary
            exec "./build/linux/x64/release/bundle/bwe_ui"
        else
            # Build and run
            echo "Building Linux application..."
            flutter build linux --release
            exec "./build/linux/x64/release/bundle/bwe_ui"
        fi
        ;;

    android)
        echo "Starting BoundlessWrite on Android..."
        if [ -f "build/app/outputs/apk/release/app-release.apk" ]; then
            echo "Installing APK..."
            adb install -r build/app/outputs/apk/release/app-release.apk
        else
            echo "Building Android APK..."
            flutter build apk --release
            echo "Installing APK..."
            adb install -r build/app/outputs/apk/release/app-release.apk
        fi
        echo "Launching app..."
        adb shell am start -n com.example.bwe_ui/com.example.bwe_ui.MainActivity
        ;;

    macos)
        echo "Starting BoundlessWrite for macOS..."
        if [ -f "build/macos/Build/Products/Release/bwe_ui.app/Contents/MacOS/bwe_ui" ]; then
            exec "./build/macos/Build/Products/Release/bwe_ui.app/Contents/MacOS/bwe_ui"
        else
            echo "Building macOS application..."
            flutter build macos --release
            exec "./build/macos/Build/Products/Release/bwe_ui.app/Contents/MacOS/bwe_ui"
        fi
        ;;

    windows)
        echo "Starting BoundlessWrite for Windows..."
        if [ -f "build/windows/x64/runner/Release/bwe_ui.exe" ]; then
            exec "./build/windows/x64/runner/Release/bwe_ui.exe"
        else
            echo "Building Windows application..."
            flutter build windows --release
            exec "./build/windows/x64/runner/Release/bwe_ui.exe"
        fi
        ;;

    *)
        echo -e "${YELLOW}Unknown platform: $PLATFORM${NC}"
        echo "Valid options: linux, android, macos, windows, auto"
        exit 1
        ;;
esac
