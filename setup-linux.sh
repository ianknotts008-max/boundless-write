#!/bin/bash

################################################################################
# BoundlessWrite - Linux Native Library Setup Script
################################################################################
# This script builds the Rust backend and links it to Flutter on Linux
#
# Prerequisites:
#   - Rust installed (https://rustup.rs/)
#   - Flutter installed (https://flutter.dev)
#   - Build essentials (sudo apt-get install build-essential)
#   - Git installed
#
# Usage:
#   1. Open Terminal in the WordProcessor directory
#   2. Run: chmod +x setup-linux.sh
#   3. Run: ./setup-linux.sh
#   4. Wait for completion
#
################################################################################

set -e  # Exit on error

echo ""
echo "================================================================================"
echo "BoundlessWrite - Linux Setup"
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
if [ "$ARCH" = "x86_64" ]; then
    TARGET="x86_64-unknown-linux-gnu"
    echo "Detected: Linux x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    TARGET="aarch64-unknown-linux-gnu"
    echo "Detected: Linux ARM64 (Raspberry Pi 4)"
elif [ "$ARCH" = "armv7l" ]; then
    TARGET="armv7-unknown-linux-gnueabihf"
    echo "Detected: Linux ARMv7 (Raspberry Pi 3)"
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
if [ ! -f "bwe_core/target/$TARGET/release/libbwe_core.so" ]; then
    echo "ERROR: libbwe_core.so not found after build!"
    exit 1
fi

echo ""
echo "[2/4] Copying library to Flutter..."

# Create destination directory if it doesn't exist
mkdir -p "bwe_ui/linux/bundle/lib"

# Copy the .so file
cp "bwe_core/target/$TARGET/release/libbwe_core.so" "bwe_ui/linux/bundle/lib/libbwe_core.so"

if [ ! $? -eq 0 ]; then
    echo "ERROR: Failed to copy .so file!"
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

if [ -f "bwe_ui/linux/bundle/lib/libbwe_core.so" ]; then
    filesize=$(stat -f%z "bwe_ui/linux/bundle/lib/libbwe_core.so" 2>/dev/null || stat -c%s "bwe_ui/linux/bundle/lib/libbwe_core.so")
    echo "[✓] Library is in place: bwe_ui/linux/bundle/lib/libbwe_core.so"
    echo "[✓] Library size: $filesize bytes"
else
    echo "ERROR: Library not found at expected location!"
    exit 1
fi

# Verify library dependencies
echo ""
echo "Verifying library dependencies..."
ldd "bwe_ui/linux/bundle/lib/libbwe_core.so" | grep -E "(libc|libm|libdl)" || true

echo ""
echo "================================================================================"
echo "SUCCESS! Native library setup complete!"
echo "================================================================================"
echo ""
echo "Next steps:"
echo "  1. Open Terminal in the bwe_ui directory"
echo "  2. Set the library path: export LD_LIBRARY_PATH=\"\$PWD/../bwe_core/target/$TARGET/release:\$LD_LIBRARY_PATH\""
echo "  3. Run: flutter run -d linux"
echo "  4. The app will launch with the splash screen"
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
echo "  If you get 'undefined reference' errors:"
echo "  1. Check that the .so file exists and is executable"
echo "  2. Run: chmod +x bwe_ui/linux/bundle/lib/libbwe_core.so"
echo "  3. Run: ldd bwe_ui/linux/bundle/lib/libbwe_core.so"
echo ""
echo "For Raspberry Pi:"
echo "  - Install build-essential: sudo apt-get install build-essential"
echo "  - Install Flutter for Linux desktop support"
echo "  - The script will automatically build for your ARM architecture"
echo ""
echo "================================================================================"
echo ""
