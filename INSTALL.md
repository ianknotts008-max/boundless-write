# BoundlessWrite Installation Guide

Choose your operating system below to get started.

## 🪟 Windows

```batch
setup-windows.bat
```

**What it does:**
1. Builds Rust backend (release mode)
2. Copies library to Flutter
3. Updates Flutter dependencies
4. Verifies setup

**Then run:**
```batch
cd bwe_ui
flutter run
```

See [setup-windows.bat](setup-windows.bat) for details.

---

## 🍎 macOS

```bash
chmod +x setup-macos.sh
./setup-macos.sh
```

**What it does:**
1. Detects your architecture (Intel/Apple Silicon)
2. Builds Rust backend for your CPU
3. Copies library to Flutter
4. Updates Flutter dependencies
5. Verifies setup

**Then run:**
```bash
cd bwe_ui
flutter run -d macos
```

See [setup-macos.sh](setup-macos.sh) for details.

---

## 🐧 Linux

```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

**What it does:**
1. Detects your architecture (x86_64/ARM64/ARMv7)
2. Builds Rust backend for your CPU
3. Copies library to Flutter
4. Updates Flutter dependencies
5. Verifies setup

**Then run:**
```bash
cd bwe_ui
flutter run -d linux
```

See [setup-linux.sh](setup-linux.sh) for details.

---

## 🤖 Automatic Detection (All Platforms)

```bash
chmod +x setup.sh
./setup.sh
```

The script automatically detects your OS and runs the appropriate setup.

**Then run:**
```bash
cd bwe_ui
flutter run
```

---

## 📋 Prerequisites

Before running setup, ensure you have:

- **Rust** (https://rustup.rs/)
  - Check: `rustc --version`
- **Flutter** (https://flutter.dev)
  - Check: `flutter --version`
- **Dart** (comes with Flutter)
  - Check: `dart --version`
- **Git** (for version control)
  - Check: `git --version`

### Platform-Specific Requirements

**Windows:**
- Visual Studio Build Tools or Community Edition

**macOS:**
- Xcode Command Line Tools: `xcode-select --install`
- macOS 11 or newer

**Linux:**
- Build essentials: `sudo apt-get install build-essential`
- GTK dev files: `sudo apt-get install libgtk-3-dev`

---

## ✅ What to Expect

After setup completes and you run the app:

1. **Splash Screen** (6 seconds)
   - Animated introduction
   - Progress bar animation
   - Status updates

2. **Main Editor**
   - Full-featured word processor
   - Professional UI
   - File operations ready

3. **Ready to Use**
   - Press F1 for keyboard shortcuts
   - Ctrl+N for new document
   - Ctrl+S to save

---

## 🆘 Troubleshooting

See [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) for:
- Common issues and solutions
- Platform-specific troubleshooting
- Debug procedures
- Manual build steps

---

## 📖 Additional Resources

- **QUICKSTART.md** - Quick start guide
- **CLAUDE.md** - Architecture details
- **KEYBOARD_SHORTCUTS.md** - Available shortcuts
- **FEATURES.md** - Complete feature list

---

**Ready to install? Pick your platform above and run the setup script!** 🚀
