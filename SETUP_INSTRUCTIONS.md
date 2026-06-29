# BoundlessWrite - Complete Setup Instructions

**Status**: ✅ Ready for Production Setup  
**Date**: 2026-06-29  
**Version**: Phase 1 (95% Complete)

---

## 🚀 Quick Start (Choose Your Platform)

### Windows Users
```batch
setup-windows.bat
```

### macOS Users
```bash
chmod +x setup-macos.sh
./setup-macos.sh
```

### Linux Users
```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

### Or Auto-Detect (All Platforms)
```bash
chmod +x setup.sh
./setup.sh
```

---

## 📋 Prerequisites Checklist

Before running setup, ensure you have:

- [ ] **Rust** installed
  - Download: https://rustup.rs/
  - Verify: `rustc --version` (should be 1.70+)

- [ ] **Flutter** installed
  - Download: https://flutter.dev/docs/get-started/install
  - Verify: `flutter --version` (should be 3.10+)

- [ ] **Dart** installed (comes with Flutter)
  - Verify: `dart --version` (should be 3.10+)

- [ ] **Git** installed (for version control)
  - Verify: `git --version`

### Platform-Specific Requirements

**Windows**:
- [ ] Microsoft Visual Studio Build Tools or Visual Studio Community
- [ ] Windows 10/11 or newer

**macOS**:
- [ ] Xcode Command Line Tools
  - Install: `xcode-select --install`
- [ ] macOS 11 or newer
- [ ] Intel Mac or Apple Silicon (both supported)

**Linux**:
- [ ] Build essentials
  - Ubuntu/Debian: `sudo apt-get install build-essential`
  - Fedora: `sudo dnf install gcc`
  - Arch: `sudo pacman -S base-devel`
- [ ] Python 3 (for Flutter desktop)
- [ ] GTK development files
  - Ubuntu/Debian: `sudo apt-get install libgtk-3-dev`

---

## 📝 Step-by-Step Setup

### Step 1: Prepare Your Environment

```bash
# Navigate to project directory
cd "path/to/WordProcessor"

# Verify directory structure
ls -la bwe_core bwe_ui
# Should see both directories
```

### Step 2: Run the Setup Script

**Option A: Platform-Specific (Recommended)**

Windows:
```batch
setup-windows.bat
```

macOS:
```bash
chmod +x setup-macos.sh && ./setup-macos.sh
```

Linux:
```bash
chmod +x setup-linux.sh && ./setup-linux.sh
```

**Option B: Auto-Detect (All Platforms)**

```bash
chmod +x setup.sh && ./setup.sh
```

### Step 3: What the Script Does

The setup script automatically:

1. **Builds Rust Backend** (~2-3 minutes)
   - Compiles bwe_core in release mode
   - Optimizes for your platform
   - Creates native library (dll/dylib/so)

2. **Copies Library to Flutter** (~5 seconds)
   - Places library in correct Flutter directory
   - Windows: `bwe_ui/windows/runner/Release/bwe_core.dll`
   - macOS: `bwe_ui/macos/Runner/libbwe_core.dylib`
   - Linux: `bwe_ui/linux/bundle/lib/libbwe_core.so`

3. **Updates Flutter** (~1-2 minutes)
   - Runs `flutter pub get`
   - Downloads dependencies
   - Updates pubspec.lock

4. **Verifies Setup** (~10 seconds)
   - Checks library exists
   - Verifies file sizes
   - Shows status

### Step 4: Run the App

After setup completes:

**Windows**:
```batch
cd bwe_ui
flutter run
```

**macOS**:
```bash
cd bwe_ui
flutter run -d macos
```

**Linux**:
```bash
cd bwe_ui
flutter run -d linux
```

Or use the universal command:
```bash
cd bwe_ui
flutter run
```

---

## ✅ Verification

After running setup, verify everything works:

### 1. Check FFI Connection
- [ ] Splash screen appears (6-second animation)
- [ ] Status messages update: "INITIALIZING ENGINE" → "READY"
- [ ] Progress bar fills smoothly
- [ ] Main editor loads after splash

### 2. Test Keyboard Shortcuts
- [ ] Press **F1** → Help dialog appears
- [ ] Press **Ctrl+N** → New document created
- [ ] Press **Ctrl+S** → Save dialog appears
- [ ] Press **Ctrl+O** → Open dialog appears

### 3. Test File Operations
- [ ] Create new document (Ctrl+N)
- [ ] Type some text
- [ ] Save document (Ctrl+S)
- [ ] Open saved document (Ctrl+O)
- [ ] Verify content is preserved

### 4. Check Statistics
- [ ] Word count updates as you type
- [ ] Character count displays correctly
- [ ] Page count is accurate

---

## 🔧 Troubleshooting

### Build Issues

**"Rust not found" or "cargo not found"**
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Update Rust
rustup update
```

**"Command not found: flutter"**
```bash
# Add Flutter to PATH
# macOS/Linux: Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:path/to/flutter/bin"

# Windows: Add flutter\bin to System Environment Variables
```

**Build takes very long or fails**
```bash
# Clean and rebuild
cd bwe_core
cargo clean
cargo build --release
```

### Library Not Found

**Windows: "bwe_core.dll not found"**
- [ ] Check: `dir bwe_ui\windows\runner\Release\bwe_core.dll`
- [ ] If not there, verify build completed: `dir bwe_core\target\release\bwe_core.dll`
- [ ] Copy manually if needed: `copy bwe_core\target\release\bwe_core.dll bwe_ui\windows\runner\Release\`

**macOS: "dyld: Library not loaded"**
```bash
# Check library path
otool -L bwe_ui/macos/Runner/libbwe_core.dylib

# Should show @loader_path references
```

**Linux: "error while loading shared libraries"**
```bash
# Set library path
export LD_LIBRARY_PATH="$PWD/bwe_core/target/release:$LD_LIBRARY_PATH"

# Make executable
chmod +x bwe_ui/linux/bundle/lib/libbwe_core.so

# Check dependencies
ldd bwe_ui/linux/bundle/lib/libbwe_core.so
```

### Flutter Issues

**"Flutter pub get" fails**
```bash
cd bwe_ui
flutter pub upgrade
flutter pub get
```

**App doesn't start after setup**
```bash
# Clean Flutter
flutter clean
flutter pub get

# Rebuild
flutter run -v  # Verbose mode for debugging
```

### Platform-Specific Issues

**macOS: "Xcode Command Line Tools not installed"**
```bash
xcode-select --install
```

**Linux: "GTK development files not found"**
```bash
# Ubuntu/Debian
sudo apt-get install libgtk-3-dev

# Fedora
sudo dnf install gtk3-devel

# Arch
sudo pacman -S gtk3
```

---

## 📊 Expected Output

### Successful Build
```
[1/4] Building Rust backend...
   Compiling bwe_core v0.1.0
    Finished `release` profile [optimized] target(s) in 2m 15s
[✓] Rust build successful!

[2/4] Copying library to Flutter...
[✓] Library copied to Flutter!

[3/4] Updating Flutter dependencies...
Resolving dependencies...
Got dependencies!
[✓] Flutter dependencies updated!

[4/4] Verifying setup...
[✓] Library is in place
[✓] Library size: 4521120 bytes

SUCCESS! Native library setup complete!
```

---

## 🎯 Next Steps

### Immediate
1. [ ] Run setup script
2. [ ] Verify FFI works
3. [ ] Test keyboard shortcuts
4. [ ] Test file operations

### Phase 1 Completion
- [ ] All features working
- [ ] No errors in app
- [ ] FFI communication successful
- [ ] Ready for Phase 2

### Phase 2 (Next 3 Weeks)
- [ ] Rich text formatting
- [ ] HTML export
- [ ] Undo/redo
- [ ] Advanced features

---

## 🆘 Getting Help

### If Setup Fails

1. **Check Prerequisites**
   ```bash
   rustc --version
   flutter --version
   dart --version
   ```

2. **Enable Verbose Output**
   - Windows: Check console output
   - macOS/Linux: Run with `bash -x setup-macos.sh`

3. **Check Logs**
   - Rust build: `bwe_core/target/release/build/*/output`
   - Flutter: `.dart_tool/flutter_build/`

4. **Manual Build**
   ```bash
   # Build Rust manually
   cd bwe_core
   cargo build --release -vv  # Very verbose
   
   # Run Flutter manually
   cd ../bwe_ui
   flutter run -v  # Verbose
   ```

### Common Issues Reference

| Issue | Solution |
|-------|----------|
| "command not found: cargo" | Install Rust from https://rustup.rs/ |
| "command not found: flutter" | Add Flutter to PATH |
| DLL/dylib/so not found | Re-run setup script |
| FFI error on startup | Check library is in correct folder |
| Build hangs | Try `cargo clean` then rebuild |
| Splash screen doesn't appear | Check Flutter build completed |

---

## 📞 Support Resources

- **NATIVE_LIBRARY_SETUP.md** - Detailed platform-specific guide
- **QUICKSTART.md** - General getting started guide
- **CLAUDE.md** - Architecture and technical details
- **KEYBOARD_SHORTCUTS.md** - Available shortcuts after setup

---

## ✨ What Happens After Setup

Once setup completes and you run the app:

1. **Splash Screen** (6 seconds)
   - Beautiful animated introduction
   - Progress bar fills from 0% to 100%
   - Status updates: "INITIALIZING ENGINE" → "READY"

2. **Main Editor** (loads immediately)
   - Professional dark interface
   - Formatting toolbar ready
   - Document sidebar with statistics

3. **Full Functionality**
   - File operations (open/save)
   - Text editing with live stats
   - Keyboard shortcuts (F1 for help)
   - Professional error handling

---

## 🎉 Success Checklist

- [ ] Setup script ran without errors
- [ ] Library file exists in correct location
- [ ] Flutter app starts
- [ ] Splash screen displays
- [ ] Main editor loads
- [ ] Keyboard shortcuts work
- [ ] File operations work
- [ ] No errors in console

If all checkboxes are ✓, **Phase 1 is complete!** 🎉

---

**Status**: ✅ Setup Ready  
**Last Updated**: 2026-06-29  
**Next Phase**: Phase 2 - Rich Text Formatting
