@echo off
REM ============================================================================
REM BoundlessWrite - Windows Native Library Setup Script
REM ============================================================================
REM This script builds the Rust backend and links it to Flutter on Windows
REM
REM Prerequisites:
REM   - Rust installed (https://rustup.rs/)
REM   - Flutter installed (https://flutter.dev)
REM   - Git installed
REM
REM Usage:
REM   1. Open Command Prompt in the WordProcessor directory
REM   2. Run: setup-windows.bat
REM   3. Wait for completion
REM
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo BoundlessWrite - Windows Setup
echo ============================================================================
echo.

REM Check if we're in the right directory
if not exist "bwe_core" (
    echo ERROR: bwe_core directory not found!
    echo Please run this script from the WordProcessor root directory.
    exit /b 1
)

if not exist "bwe_ui" (
    echo ERROR: bwe_ui directory not found!
    echo Please run this script from the WordProcessor root directory.
    exit /b 1
)

REM Step 1: Build Rust backend
echo [1/4] Building Rust backend...
cd bwe_core
echo Running: cargo build --release
call cargo build --release

if errorlevel 1 (
    echo.
    echo ERROR: Rust build failed!
    echo Please check that Rust is installed and up-to-date.
    echo Run: rustup update
    cd ..
    exit /b 1
)

echo [✓] Rust build successful!
cd ..

REM Step 2: Check if library was created
if not exist "bwe_core\target\release\bwe_core.dll" (
    echo ERROR: bwe_core.dll not found after build!
    exit /b 1
)

echo.
echo [2/4] Copying library to Flutter...

REM Create destination directory if it doesn't exist
if not exist "bwe_ui\windows\runner\Release" (
    mkdir bwe_ui\windows\runner\Release
    echo Created directory: bwe_ui\windows\runner\Release
)

REM Copy the DLL
copy "bwe_core\target\release\bwe_core.dll" "bwe_ui\windows\runner\Release\bwe_core.dll"

if errorlevel 1 (
    echo ERROR: Failed to copy DLL!
    exit /b 1
)

echo [✓] Library copied to Flutter!

REM Step 3: Update Flutter dependencies
echo.
echo [3/4] Updating Flutter dependencies...
cd bwe_ui
call flutter pub get

if errorlevel 1 (
    echo ERROR: Flutter pub get failed!
    cd ..
    exit /b 1
)

echo [✓] Flutter dependencies updated!
cd ..

REM Step 4: Verify setup
echo.
echo [4/4] Verifying setup...

if exist "bwe_ui\windows\runner\Release\bwe_core.dll" (
    echo [✓] Library is in place: bwe_ui\windows\runner\Release\bwe_core.dll
) else (
    echo ERROR: Library not found at expected location!
    exit /b 1
)

if exist "bwe_core\target\release\bwe_core.dll" (
    for /F %%A in ('dir /b "bwe_core\target\release\bwe_core.dll"') do set filesize=%%~zA
    echo [✓] Original library size: !filesize! bytes
)

echo.
echo ============================================================================
echo SUCCESS! Native library setup complete!
echo ============================================================================
echo.
echo Next steps:
echo   1. Open Command Prompt or PowerShell in the bwe_ui directory
echo   2. Run: flutter run
echo   3. The app will launch with the splash screen
echo.
echo To test FFI integration:
echo   - The splash screen should appear for 6 seconds
echo   - Status messages should update smoothly
echo   - Then the main editor screen should load
echo.
echo To see keyboard shortcuts:
echo   - Press F1 to open the shortcuts dialog
echo   - Or click Help → Keyboard Shortcuts
echo.
echo ============================================================================
echo.

pause
