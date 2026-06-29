#!/bin/bash

################################################################################
# BoundlessWrite - macOS Native Library Setup Script
################################################################################
# This script builds the Rust backend and links it to Flutter on macOS
#
# Prerequisites:
#   - Rust installed (https://rustup.rs/)
#   - Flutter installed (https://flutter.dev)
#   - Xcode Command Line Tools installed
#   - Git installed
#
# Usage:
#   1. Open Terminal in the WordProcessor directory
#   2. Run: chmod +x setup-macos.sh
#   3. Run: ./setup-macos.sh
#   4. Wait for completion
#
################################################################################

set -e  # Exit on error

echo ""
echo "================================================================================"
echo "BoundlessWrite - macOS Setup"
echo "================================================================================"
echo ""

# Check if we're in the right directory
if [ ! -d "bwe_core" ]; then
    echo "ERROR: bwe_core directory not found!"
    echo "Please run this script from the WordProcessor root directory."
    exit 1
fi

if [ ! -d "bwe_ui" ]; then
    echo "ERROR: bwe_ui directory not found!"
    echo "Please run this script from the WordProcessor root directory."
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    TARGET="aarch64-apple-darwin"
    echo "Detected: Apple Silicon (ARM64)"
elif [ "$ARCH" = "x86_64" ]; then
    TARGET="x86_64-apple-darwin"
    echo "Detected: Intel Mac (x86_64)"
else
    echo "ERROR: Unknown architecture: $ARCH"
    exit 1
fi

# Step 1: Build Rust backend
echo ""
echo "[1/4] Building Rust backend for $TARGET..."
cd bwe_core
echo "Running: cargo build --release --target=$TARGET"
cargo build --release --target="$TARGET"

if [ ! $? -eq 0 ]; then
    echo ""
    echo "ERROR: Rust build failed!"
    echo "Please check that Rust is installed and targets are available."
    echo "Run: rustup target add $TARGET"
    cd ..
    exit 1
fi

echo "[✓] Rust build successful!"
cd ..

# Step 2: Check if library was created
if [ ! -f "bwe_core/target/$TARGET/release/libbwe_core.dylib" ]; then
    echo "ERROR: libbwe_core.dylib not found after build!"
    exit 1
fi

echo ""
echo "[2/4] Copying library to Flutter..."

# Create destination directory if it doesn't exist
mkdir -p "bwe_ui/macos/Runner"

# Copy the dylib
cp "bwe_core/target/$TARGET/release/libbwe_core.dylib" "bwe_ui/macos/Runner/libbwe_core.dylib"

if [ ! $? -eq 0 ]; then
    echo "ERROR: Failed to copy dylib!"
    exit 1
fi

echo "[✓] Library copied to Flutter!"

# Step 3: Update Flutter dependencies
echo ""
echo "[3/4] Updating Flutter dependencies..."
cd bwe_ui
flutter pub get

if [ ! $? -eq 0 ]; then
    echo "ERROR: Flutter pub get failed!"
    cd ..
    exit 1
fi

echo "[✓] Flutter dependencies updated!"
cd ..

# Step 4: Verify setup
echo ""
echo "[4/4] Verifying setup..."

if [ -f "bwe_ui/macos/Runner/libbwe_core.dylib" ]; then
    filesize=$(stat -f%z "bwe_ui/macos/Runner/libbwe_core.dylib")
    echo "[✓] Library is in place: bwe_ui/macos/Runner/libbwe_core.dylib"
    echo "[✓] Library size: $filesize bytes"
else
    echo "ERROR: Library not found at expected location!"
    exit 1
fi

# Verify library architecture
echo ""
echo "Verifying library architecture..."
file "bwe_ui/macos/Runner/libbwe_core.dylib"

echo ""
echo "================================================================================"
echo "SUCCESS! Native library setup complete!"
echo "================================================================================"
echo ""
echo "Next steps:"
echo "  1. Open Terminal in the bwe_ui directory"
echo "  2. Run: flutter run -d macos"
echo "  3. The app will launch with the splash screen"
echo ""
echo "To test FFI integration:"
echo "  - The splash screen should appear for 6 seconds"
echo "  - Status messages should update smoothly"
echo "  - Then the main editor screen should load"
echo ""
echo "To see keyboard shortcuts:"
echo "  - Press F1 to open the shortcuts dialog"
echo "  - Or click Help → Keyboard Shortcuts"
echo ""
echo "Troubleshooting:"
echo "  If you get 'dyld: Library not loaded' errors:"
echo "  1. Check that the .dylib file is in the correct location"
echo "  2. Run: otool -L bwe_ui/macos/Runner/libbwe_core.dylib"
echo "  3. The path should start with @loader_path"
echo ""
echo "================================================================================"
echo ""
