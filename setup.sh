#!/bin/bash

################################################################################
# BoundlessWrite - Universal Setup Script
################################################################################
# This script detects your platform and runs the appropriate setup script
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
#
################################################################################

set -e

echo ""
echo "================================================================================"
echo "BoundlessWrite - Universal Setup"
echo "================================================================================"
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected: Linux"
    if [ -f "setup-linux.sh" ]; then
        ./setup-linux.sh
    else
        echo "ERROR: setup-linux.sh not found!"
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected: macOS"
    if [ -f "setup-macos.sh" ]; then
        ./setup-macos.sh
    else
        echo "ERROR: setup-macos.sh not found!"
        exit 1
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Detected: Windows"
    if [ -f "setup-windows.bat" ]; then
        # Run the batch file
        cmd.exe /c "setup-windows.bat"
    else
        echo "ERROR: setup-windows.bat not found!"
        exit 1
    fi
else
    echo "ERROR: Unsupported OS: $OSTYPE"
    echo "Please run the appropriate setup script manually:"
    echo "  - Windows: setup-windows.bat"
    echo "  - macOS: ./setup-macos.sh"
    echo "  - Linux: ./setup-linux.sh"
    exit 1
fi
