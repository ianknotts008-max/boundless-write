# Setting Up the Native Rust Library for Flutter

This guide explains how to properly set up the compiled Rust library (`bwe_core`) for use with Flutter.

---

## Overview

The Flutter app communicates with the Rust backend via FFI (Foreign Function Interface). The Rust code is compiled into a native library (`.dll`, `.dylib`, or `.so`) that Flutter loads at runtime.

**Current Status**: Phase 1 integration requires the native library to be accessible to Flutter.

---

## Platform-Specific Setup

### Windows

#### Step 1: Build the Rust Library
```bash
cd bwe_core
cargo build --release
```

**Output**: `bwe_core/target/release/bwe_core.dll`

#### Step 2: Copy Library to Flutter
Option A: Copy to Windows runner directory
```bash
# From project root
copy "bwe_core\target\release\bwe_core.dll" "bwe_ui\windows\runner\Release\bwe_core.dll"
```

Option B: Copy to app directory (flutter run will look here)
```bash
copy "bwe_core\target\release\bwe_core.dll" "bwe_ui\bwe_core.dll"
```

#### Step 3: Run Flutter
```bash
cd bwe_ui
flutter run
```

#### Troubleshooting
- **"bwe_core.dll not found"**
  - Verify file exists in the location Flutter is looking
  - Check Windows event logs for more details
  - Try rebuilding with `flutter clean && flutter run`

- **"Dynamic library load failed"**
  - Ensure no dependency DLLs are missing (check with Dependency Walker)
  - Try running from command line for verbose output

---

### macOS

#### Step 1: Build the Rust Library
```bash
cd bwe_core
cargo build --release --target=aarch64-apple-darwin  # Apple Silicon
# or
cargo build --release --target=x86_64-apple-darwin   # Intel
```

**Output**: `bwe_core/target/release/libbwe_core.dylib`

#### Step 2: Copy Library to Flutter
```bash
# From project root
cp "bwe_core/target/release/libbwe_core.dylib" "bwe_ui/macos/Runner/libbwe_core.dylib"
```

#### Step 3: Update XCode (if needed)
1. Open `bwe_ui/macos/Runner.xcworkspace` in Xcode
2. In Build Settings, ensure library search path includes the location
3. In Build Phases, add library to "Link Binary With Libraries"

#### Step 4: Run Flutter
```bash
cd bwe_ui
flutter run -d macos
```

#### Troubleshooting
- **"dyld: Library not loaded"**
  - Check library path with `otool -L`
  - Use `install_name_tool` to fix paths if needed
  ```bash
  install_name_tool -change @rpath/libbwe_core.dylib @loader_path/libbwe_core.dylib bwe_ui/macos/Runner/Runner
  ```

- **"Mach-O, 64-bit executable x86_64"**
  - Verify architecture matches (`file` command)
  - Build for correct target (Apple Silicon vs Intel)

---

### Linux

#### Step 1: Install Build Tools
```bash
# Ubuntu/Debian
sudo apt-get install build-essential rustup

# Fedora
sudo dnf install gcc rustup

# Arch
sudo pacman -S rustup
```

#### Step 2: Build the Rust Library
```bash
cd bwe_core
cargo build --release
```

**Output**: `bwe_core/target/release/libbwe_core.so`

#### Step 3: Copy Library to Flutter
```bash
# From project root
mkdir -p bwe_ui/linux/bundle/lib
cp "bwe_core/target/release/libbwe_core.so" "bwe_ui/linux/bundle/lib/libbwe_core.so"
```

Or use CMake (better approach):

1. Create `bwe_ui/linux/CMakeLists.txt` entry:
```cmake
# Link Rust library
find_library(BWE_CORE_LIB NAMES bwe_core PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../../bwe_core/target/release)
target_link_libraries(${BINARY_NAME} PRIVATE ${BWE_CORE_LIB})
```

#### Step 4: Set Library Path
```bash
export LD_LIBRARY_PATH="$PWD/bwe_core/target/release:$LD_LIBRARY_PATH"
cd bwe_ui
flutter run -d linux
```

#### Troubleshooting
- **"cannot open shared object file"**
  - Check `LD_LIBRARY_PATH` environment variable
  - Verify file permissions: `chmod +x libbwe_core.so`
  - Use `ldd` to check dependencies: `ldd libbwe_core.so`

- **"undefined symbol"**
  - Rebuild with `cargo build --release` (clean build if needed)
  - Verify Rust version: `rustc --version`

---

## Automated Setup Script

### create_setup.sh (Linux/macOS)
```bash
#!/bin/bash

echo "🔨 Building Rust backend..."
cd bwe_core
cargo build --release
if [ $? -ne 0 ]; then
    echo "❌ Rust build failed"
    exit 1
fi
cd ..

echo "📋 Copying library to Flutter..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cp "bwe_core/target/release/libbwe_core.dylib" "bwe_ui/macos/Runner/libbwe_core.dylib"
    echo "✅ Library copied to macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    mkdir -p bwe_ui/linux/bundle/lib
    cp "bwe_core/target/release/libbwe_core.so" "bwe_ui/linux/bundle/lib/libbwe_core.so"
    echo "✅ Library copied to Linux"
fi

echo "🎉 Setup complete! Run: cd bwe_ui && flutter run"
```

### create_setup.bat (Windows)
```batch
@echo off
echo 🔨 Building Rust backend...
cd bwe_core
cargo build --release
if errorlevel 1 (
    echo ❌ Rust build failed
    exit /b 1
)
cd ..

echo 📋 Copying library to Flutter...
copy "bwe_core\target\release\bwe_core.dll" "bwe_ui\windows\runner\Release\bwe_core.dll"
if errorlevel 1 (
    echo ❌ Copy failed
    exit /b 1
)

echo ✅ Library copied to Windows
echo 🎉 Setup complete! Run: cd bwe_ui ^&& flutter run
```

---

## Verifying the Setup

### 1. Check Library Exists
```bash
# macOS/Linux
ls -la bwe_core/target/release/libbwe_core.*

# Windows
dir bwe_core\target\release\bwe_core.dll
```

### 2. Test FFI Connection
```dart
// In main.dart or test
try {
  final bridge = NativeBridge();
  final result = bridge.hello();
  print('✅ FFI works: $result');
} catch (e) {
  print('❌ FFI failed: $e');
}
```

### 3. Check Library Dependencies
```bash
# macOS
otool -L bwe_core/target/release/libbwe_core.dylib

# Linux
ldd bwe_core/target/release/libbwe_core.so

# Windows
Dependency Walker (dumpbin /imports)
```

---

## Debugging Library Loading Issues

### Enable Verbose Output
```bash
# Flutter verbose mode
flutter run -v

# This will show:
# - Where Flutter is looking for the library
# - Native error messages
# - FFI function lookups
```

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Library not found | Wrong path | Copy to correct location per platform |
| Cannot open shared object | Missing dependencies | Check with `ldd` (Linux) / `otool` (macOS) |
| Undefined symbol | Version mismatch | Rebuild Rust with `cargo clean` |
| Permission denied | Wrong permissions | `chmod +x libbwe_core.so` |
| Segmentation fault | Memory issue | Use debugger (`lldb`, `gdb`) |

### Using a Debugger

**macOS (lldb)**:
```bash
lldb flutter run
(lldb) run
```

**Linux (gdb)**:
```bash
gdb flutter run
(gdb) run
```

**Windows (WinDbg)**:
```cmd
windbg.exe flutter run
```

---

## Build Configuration Files

### CMakeLists.txt (Linux)
Example addition to link the Rust library:
```cmake
# Find the Rust library
find_library(BWE_CORE 
    NAMES bwe_core 
    PATHS ${CMAKE_SOURCE_DIR}/../../bwe_core/target/release
    NO_DEFAULT_PATH
)

if(NOT BWE_CORE)
    message(FATAL_ERROR "bwe_core library not found")
endif()

# Link it
target_link_libraries(${BINARY_NAME} PRIVATE ${BWE_CORE})
```

### build.gradle (Android - Future)
```gradle
// For Phase 3+ Android support
externalNativeBuild {
    cmake {
        path "CMakeLists.txt"
    }
}
```

### pubspec.yaml (Flutter - iOS/Android)
```yaml
# For Phase 3+ mobile support
ffiPlugin: true
```

---

## Cross-Compilation

### Building for Different Architectures

**Rust targets**:
```bash
# macOS Apple Silicon
cargo build --release --target aarch64-apple-darwin

# macOS Intel
cargo build --release --target x86_64-apple-darwin

# Linux ARM64 (Raspberry Pi)
cargo build --release --target aarch64-unknown-linux-gnu

# Linux ARMv7 (Raspberry Pi)
cargo build --release --target armv7-unknown-linux-gnueabihf
```

**Flutter web (Not supported via FFI)**:
- Phase 3+ will require different approach
- Consider WASM or server-side API

---

## Troubleshooting Checklist

- [ ] Rust compiles: `cargo build --release` succeeds
- [ ] All 9 tests pass: `cargo test`
- [ ] Library file exists in correct location
- [ ] Library file has correct permissions (executable)
- [ ] No missing dependencies
- [ ] Flutter can find the library (`flutter run -v`)
- [ ] `NativeBridge().hello()` returns success message
- [ ] No segmentation faults on startup

---

## Next Steps

Once native library is working:

1. ✅ Library loads successfully
2. ✅ FFI functions callable from Dart
3. ✅ JSON parsing works
4. ✅ Editor syncs with backend
5. ✅ File save/load works
6. ✅ Full Phase 1 integration complete

---

## Support

If issues persist:

1. Check platform-specific section above
2. Enable verbose logging (`flutter run -v`)
3. Try clean build: `cargo clean && cargo build --release`
4. Review [CLAUDE.md](CLAUDE.md) FFI section
5. Check GitHub issues (coming soon)

---

**Reference Documentation**:
- [Dart FFI](https://dart.dev/guides/libraries/c-interop)
- [Rust FFI](https://doc.rust-lang.org/nomicon/ffi.html)
- [Flutter Platform Channels](https://flutter.dev/docs/platform-integration/platform-channels)

**Created**: 2026-06-29  
**Status**: Part of Phase 1 Integration  
**Next Review**: After successful FFI loading
