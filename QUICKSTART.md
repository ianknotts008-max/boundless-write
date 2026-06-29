# BWE Word Processor - Quick Start Guide

## What is BWE?

Boundless Word Engine (BWE) is a modern, open-source word processor designed to compete with Google Docs and Microsoft Word. It features a Flutter-based user interface with a powerful Rust backend engine.

**Key Features**:
- ✅ Rich text editing (in development)
- ✅ Document formatting (bold, italic, colors, fonts)
- ✅ Save/Load documents
- ✅ Headings, lists, and document structure
- ✅ Tables and images
- ✅ PDF/DOCX export
- ✅ User-friendly interface
- ✅ **NO AI** - Pure document editing

---

## Installation & Setup

### Prerequisites

Install these tools first:

1. **Rust** (for backend)
   ```bash
   # Download from https://rustup.rs/
   # or on Linux/macOS:
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Flutter** (for UI)
   ```bash
   # Download from https://flutter.dev/docs/get-started/install
   # or on Linux/macOS:
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. **Android Studio or XCode** (optional, for mobile development)

### Clone the Repository

```bash
git clone <repository-url>
cd "onn. Drive/WordProcessor"
```

### Verify Installation

```bash
rustc --version      # Should show Rust 1.70+
flutter --version    # Should show Flutter 3.10+
dart --version       # Should show Dart 3.10+
```

---

## Building from Source

### Step 1: Build the Rust Backend

```bash
cd bwe_core
cargo build --release

# On success:
# ✅ Compiled bwe_core v0.1.0 (release)
```

The compiled library will be at:
- **Windows**: `bwe_core/target/release/bwe_core.dll`
- **macOS**: `bwe_core/target/release/libbwe_core.dylib`
- **Linux**: `bwe_core/target/release/libbwe_core.so`

### Step 2: Set Up Flutter

```bash
cd ../bwe_ui
flutter pub get

# This downloads all Dart dependencies:
# ✅ provider
# ✅ ffi
# ✅ file_picker
# ✅ path_provider
# ✅ ... and more
```

### Step 3: Run the App

**On Desktop (Windows, macOS, or Linux)**:

```bash
flutter run

# or with specific target:
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

**On Android**:

```bash
# Start emulator first, or connect device
flutter devices                    # List available devices
flutter run -d <device-id>        # Run on specific device
```

---

## First Time Using BWE

### Main Interface

When you start BWE, you'll see:

```
┌─────────────────────────────────────────────────────────┐
│  File   Edit   View   Insert   Format   Tools   Help    │  ← Menu Bar
├─────────────────────────────────────────────────────────┤
│ [Font]  [Size] [B][I][U] [Color] [Align] [H1][H2][H3]  │  ← Formatting Toolbar
├──────────────────────────┬──────────────────────────────┤
│                          │                              │
│   My Document            │  📄 Pages: 1                 │
│   Last modified: ...     │  📊 Words: 0                 │  ← Sidebar
│                          │  🔤 Characters: 0            │
│   ┌──────────────────┐   │                              │
│   │ Start typing...  │   │  Document Info               │
│   │                  │   │  ──────────────              │
│   │                  │   │  Title: My Document          │
│   │                  │   │  Modified: 6/29/2026        │
│   │                  │   │  File: Not saved             │
│   │                  │   │                              │
│   └──────────────────┘   │                              │
│                          │                              │
└──────────────────────────┴──────────────────────────────┘
```

### Basic Workflow

1. **Type**: Click in the editor area and start typing
2. **Format**: Select text and use toolbar buttons or Format menu
3. **Save**: File → Save (or Ctrl+S when implemented)
4. **Export**: File → Export as PDF/DOCX (Phase 5)

### Example: Bold Text

```
1. Type: "Hello World"
2. Select "World" (click and drag)
3. Click [B] button or press Ctrl+B
4. Result: "Hello World" (World is bold)
```

---

## Common Tasks

### Create a New Document

**Method 1**: File → New
```
File ▼
├─ New           ← Click here
├─ Open
├─ Save
...
```

**Method 2**: Keyboard shortcut (future: Ctrl+N)

### Save Your Document

**Current Status** (Phase 1): Save as .txt files

```
File → Save
File → Save As  (coming in Phase 2)
```

### Add Formatting

**Text Selection**:
1. Click and drag to select text
2. Use toolbar buttons:
   - **[B]** - Bold
   - **[I]** - Italic
   - **[U]** - Underline
   - **[S]** - Strikethrough (coming)

**Paragraph Formatting**:
1. Click in the paragraph
2. Click alignment buttons: ⬅️ 🔲 ➡️ ⇔️

### Use Headings (Phase 3)

```
1. Click in a line
2. Click [H1], [H2], or [H3] button
3. Text becomes a heading with appropriate size/style
```

### Create Lists (Phase 3)

```
Bullet List:
File → Insert → Bullet List
or
Click bullet list button in toolbar

Numbered List:
File → Insert → Numbered List
or
Click numbered list button in toolbar
```

---

## Troubleshooting

### "flutter: command not found"

**Solution**: Add Flutter to your PATH
```bash
export PATH="$PATH:$(pwd)/flutter/bin"
# or permanently add to ~/.bashrc or ~/.zshrc
```

### "error[E0514]: type mismatch: Rust Compiler Error"

**Solution**: Rebuild Rust backend
```bash
cd bwe_core
cargo clean
cargo build --release
cd ../bwe_ui
flutter clean
flutter pub get
flutter run
```

### "Native library not found"

**Solution**: Ensure Rust backend is built before Flutter
```bash
cd bwe_core && cargo build --release && cd ../bwe_ui
flutter run
```

### App crashes on startup

**Solution**: Check system logs
```bash
# On Windows PowerShell:
Get-EventLog -LogName Application -Source "Flutter" -Newest 10

# On Linux:
journalctl -e -u <app-name>

# On macOS:
log stream --predicate 'process == "Runner"' --level debug
```

---

## Development Tips

### Running Tests

**Rust unit tests**:
```bash
cd bwe_core
cargo test
```

**Flutter widget tests**:
```bash
cd bwe_ui
flutter test
```

### Debugging

**Flutter DevTools** (UI inspector, profiler):
```bash
flutter pub global activate devtools
devtools
# Opens at http://localhost:9100
```

**Rust debugging** (with VS Code):
- Install "CodeLLDB" extension
- Add `.vscode/launch.json` with Rust debugger config

### Code Formatting

**Rust**:
```bash
cd bwe_core
cargo fmt        # Format all code
cargo clippy     # Lint suggestions
```

**Dart/Flutter**:
```bash
cd bwe_ui
dart format .    # Format all files
flutter analyze  # Check for issues
```

---

## Phase Progress

### ✅ Phase 1: Core Editing (In Progress)

- ✅ UI structure complete (menus, toolbar, editor, sidebar)
- ✅ Document state management (providers)
- ⏳ Rust backend (doc_graph, FFI, file parser)

**What's working**:
- Menus and toolbars (visible)
- Document title editing
- Word/character counting UI
- Sidebar with document info

**What's NOT working yet**:
- Text doesn't actually save/load
- Formatting buttons visible but non-functional
- No file I/O (Phase 1, Week 2)

### ⏳ Phase 2: Rich Text (5 weeks away)

- [ ] Full text formatting
- [ ] HTML export
- [ ] Keyboard shortcuts

### ⏳ Phase 3: Document Structure (8 weeks away)

- [ ] Headings (H1-H6)
- [ ] Lists (bullet, numbered)
- [ ] Outline navigation
- [ ] Styles system

### ⏳ Phase 4: Tables & Images (11 weeks away)

- [ ] Table insertion/editing
- [ ] Image support
- [ ] Content wrapping
- [ ] Table of contents

### ⏳ Phase 5: Collaboration (14 weeks away)

- [ ] Multi-user editing
- [ ] Comments & suggestions
- [ ] PDF/DOCX export
- [ ] Version history
- [ ] Signatures

---

## Architecture Overview

```
User Interface (Flutter)
    ↓
Dart FFI Bridge (native C calls)
    ↓
Rust Core Engine
├─ Document Graph (nodes, edges)
├─ File Parser (.txt, .docx, .odt, .rtf)
├─ Storage (AES-256 encryption)
└─ Signature Engine (cryptographic)
    ↓
Files on Disk (encrypted or plain)
```

**Data Flow**:
1. User types in Flutter editor
2. DocumentProvider updates state
3. FFI sends request to Rust backend
4. Rust updates DocumentGraph
5. Response returns to Flutter as JSON
6. UI re-renders with new content

---

## Keyboard Shortcuts (Phase 1-2)

| Shortcut | Action | Status |
|----------|--------|--------|
| Ctrl+A | Select All | ✅ UI ready |
| Ctrl+X | Cut | ✅ UI ready |
| Ctrl+C | Copy | ✅ UI ready |
| Ctrl+V | Paste | ✅ UI ready |
| Ctrl+Z | Undo | ⏳ Phase 2 |
| Ctrl+Y | Redo | ⏳ Phase 2 |
| Ctrl+B | Bold | ⏳ Phase 2 |
| Ctrl+I | Italic | ⏳ Phase 2 |
| Ctrl+U | Underline | ⏳ Phase 2 |
| Ctrl+F | Find & Replace | ⏳ Phase 2 |
| Ctrl+S | Save | ⏳ Phase 1, Week 3 |
| Ctrl+N | New Document | ⏳ Phase 1, Week 1 |

---

## File Formats

### Phase 1 (Current)
- **Read**: .txt (plaintext)
- **Write**: .txt (plaintext)

### Phase 2
- **Read**: .txt, .bwe (encrypted)
- **Write**: .txt, .bwe, .html
- **Export**: HTML

### Phase 3
- **Read/Write**: .docx, .odt, .rtf
- **Export**: .docx, .odt

### Phase 5
- **Export**: PDF, with full formatting
- **Import**: Google Docs, Apple Pages
- **Export**: Markdown

---

## Project Structure

```
~/WordProcessor/
├── bwe_core/               # Rust backend
│   └── src/
│       ├── doc_graph.rs    # Document model
│       ├── parser.rs       # File formats
│       ├── storage.rs      # Encryption
│       ├── signature.rs    # Signatures
│       └── ffi.rs          # Flutter bridge
├── bwe_ui/                 # Flutter frontend
│   └── lib/
│       ├── main.dart       # App entry
│       ├── screens/        # Pages
│       ├── widgets/        # UI components
│       └── providers/      # State mgmt
├── CLAUDE.md               # Architecture guide
├── FEATURES.md             # Feature checklist
└── QUICKSTART.md          # This file
```

---

## Next Steps

1. **Set up environment**: Follow "Installation & Setup"
2. **Build from source**: Follow "Building from Source"
3. **Run the app**: `flutter run` from `bwe_ui/`
4. **Read CLAUDE.md**: For architecture details
5. **Check FEATURES.md**: See what's planned

---

## Getting Help

- **Documentation**: See `CLAUDE.md` for detailed architecture
- **Features**: See `FEATURES.md` for complete checklist
- **Bugs**: Report at GitHub Issues (coming soon)
- **Contact**: `ianknotts008@gmail.com`

---

## License

[Add license here - MIT, GPL, etc.]

---

**Happy writing! 📝**

Last Updated: 2026-06-29
Status: Alpha (Phase 1 in development)
