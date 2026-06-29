# Boundless Word Engine (BWE) - Project Documentation

## Overview

Boundless Word Engine is a feature-rich, open-source word processor designed to rival Google Docs and Microsoft Word. It combines a Flutter-based frontend with a high-performance Rust backend, providing users with a responsive, secure, and extensible document editing platform.

### Core Philosophy

- **No AI**: This is a pure document editor. No machine learning, generative AI, or intelligence features.
- **User-Friendly**: Familiar UI patterns from Google Docs and Word
- **Secure**: Encrypted storage with AES-256, cryptographic signatures
- **Performant**: Rust backend for speed, Flutter for responsive UI
- **Extensible**: Modular architecture for easy feature additions

---

## Project Structure

```
/media/boundless-ai-dev/onn. Drive/WordProcessor/
├── bwe_core/                    # Rust backend (core engine)
│   ├── src/
│   │   ├── lib.rs              # Main library definition
│   │   ├── doc_graph.rs        # Document structure (nodes/edges)
│   │   ├── arithmetic.rs       # Modular arithmetic operations
│   │   ├── storage.rs          # AES-256 vault storage
│   │   ├── signature.rs        # Signature engine (vector-based)
│   │   ├── parser.rs           # File format parser (.docx, .odt, .rtf, .txt)
│   │   ├── optimizer.rs        # Self-optimization & compression
│   │   ├── ffi.rs              # Dart FFI bridge
│   │   └── [REMOVED] agent_ffi.rs  # AI integration (REMOVED per requirement)
│   └── Cargo.toml              # Rust dependencies
│
├── bwe_ui/                      # Flutter frontend
│   ├── lib/
│   │   ├── main.dart           # App entry point, providers setup
│   │   ├── screens/
│   │   │   └── home_screen.dart # Main editor screen layout
│   │   ├── widgets/
│   │   │   ├── menu_bar.dart           # File, Edit, View, Insert, Format, Tools menus
│   │   │   ├── formatting_toolbar.dart # Bold, italic, font, color, alignment buttons
│   │   │   ├── editor_area.dart        # Main text editor widget
│   │   │   └── sidebar.dart            # Pages, outline, comments sidebar
│   │   └── providers/
│   │       ├── document_provider.dart      # Document state management
│   │       └── formatting_provider.dart    # Text formatting state
│   ├── android/                # Android build config
│   ├── windows/                # Windows build config
│   ├── pubspec.yaml            # Flutter dependencies
│   └── README.md               # Flutter setup instructions
│
├── bwe_parsers/                # (Placeholder) File format parsers
├── bwe_storage/                # (Placeholder) Storage layer
├── bwe_signature/              # (Placeholder) Signature utilities
├── bwe_ffi/                    # (Placeholder) FFI bindings
│
├── BWE_Architecture.mmd        # System architecture diagram (Mermaid)
└── CLAUDE.md                   # This file

```

---

## Architecture

### High-Level Flow

```
User Types/Formats Text
        ↓
    Flutter UI
(main.dart, screens/, widgets/, providers/)
        ↓
    Dart FFI Bridge
(native_bridge.dart - TO CREATE)
        ↓
    Rust Backend (bwe_core)
├── FFI Handler (ffi.rs)
├── Document Graph (doc_graph.rs)
├── File Parser (parser.rs)
├── Storage (storage.rs)
└── Signatures (signature.rs)
```

### Key Components

| Component | Language | Purpose |
|-----------|----------|---------|
| **DocumentProvider** | Dart | Flutter state management for document content |
| **FormattingProvider** | Dart | Tracks active text formatting (bold, color, etc.) |
| **EditorArea** | Dart/Flutter | Main text editing widget, styled text rendering |
| **DocumentGraph** | Rust | In-memory document structure (nodes, edges, relationships) |
| **FileParser** | Rust | Convert between file formats (.txt, .docx, .odt, .rtf) and DocumentGraph |
| **VaultStorage** | Rust | Encrypt/decrypt documents with AES-256 |
| **FFI Bridge** | Rust + Dart | Bidirectional communication between Flutter and Rust |

---

## Development Phases

### PHASE 1: Core Editing & Document Persistence (Weeks 1-4)
**Status**: UI Structure STARTED ✅, Rust Backend TODO

**Milestones**:
- [ ] Complete DocumentGraph implementation (insert/delete nodes, traversal)
- [ ] Implement .txt parser and serializer
- [ ] Expand FFI bridge (bwe_load_document, bwe_save_document, etc.)
- [ ] Create native_bridge.dart for Dart FFI bindings
- [ ] Full edit → save → load workflow functional
- [ ] Status bar with word count, char count, page count

**Critical Files**:
- `bwe_core/src/doc_graph.rs` - Needs: node insertion/deletion, edge management, JSON serialization
- `bwe_core/src/ffi.rs` - Needs: bwe_new_document, bwe_insert_text, bwe_delete_text, bwe_save_document, bwe_load_document
- `bwe_ui/lib/providers/document_provider.dart` - DONE ✅
- `bwe_ui/lib/widgets/editor_area.dart` - DONE (basic version) ✅

### PHASE 2: Rich Text Formatting (Weeks 5-7)
**Status**: TODO

**Milestones**:
- [ ] Extend Formatting struct in doc_graph.rs (font, size, color, underline, strikethrough, etc.)
- [ ] Format application logic (select text, apply formatting)
- [ ] Keyboard shortcuts (Ctrl+B, Ctrl+I, Ctrl+U)
- [ ] HTML export with formatting preserved
- [ ] Save/load formatted documents

**Critical Files**:
- `bwe_core/src/doc_graph.rs` - Extend Formatting struct, implement format range logic
- `bwe_ui/lib/widgets/formatting_toolbar.dart` - DONE ✅

### PHASE 3: Document Structure & Lists (Weeks 8-10)
**Status**: TODO

**Milestones**:
- [ ] Heading styles (H1-H6)
- [ ] Paragraph blocks with spacing and indentation
- [ ] Ordered and unordered lists (nested)
- [ ] Document outline in sidebar
- [ ] Styles system (predefined + custom)

**Critical Files**:
- `bwe_core/src/doc_graph.rs` - Add heading/list/paragraph nodes

### PHASE 4: Tables & Images (Weeks 11-13)
**Status**: TODO

**Milestones**:
- [ ] Table insertion and editing
- [ ] Image support with captions
- [ ] Content wrapping
- [ ] Table of contents (auto-generated)

**Critical Files**:
- `bwe_core/src/doc_graph.rs` - Add TableNode, CellNode, ImageNode

### PHASE 5: Collaboration & Export (Weeks 14-18)
**Status**: TODO

**Milestones**:
- [ ] Comments and replies
- [ ] Version history
- [ ] PDF export
- [ ] DOCX/ODT export
- [ ] Signatures (vector-based)
- [ ] Templates system

**Critical Files**:
- `bwe_core/src/parser.rs` - Full DOCX/ODT parser, PDF generation
- Collaboration framework (new modules)

---

## Quick Start

### Prerequisites

- Rust 1.70+ (`rustup install`)
- Flutter 3.10+ (`flutter upgrade`)
- Dart 3.10+ (included with Flutter)
- Android Studio (for Android emulator, optional)

### Building Locally

```bash
# Build Rust backend
cd bwe_core
cargo build --release

# Set up Flutter
cd ../bwe_ui
flutter pub get

# Run on desktop (Windows/macOS/Linux) or emulator
flutter run -d windows    # or 'macos', 'linux', or device name
```

### Testing

```bash
# Rust tests
cd bwe_core
cargo test

# Flutter tests
cd ../bwe_ui
flutter test
```

---

## Key Implementation Notes

### FFI Bridge Design

The Rust FFI exposes functions callable from Dart:

```rust
// FFI function signature example
#[no_mangle]
pub extern "C" fn bwe_insert_text(
    doc_json: *const c_char,      // Current document as JSON
    text: *const c_char,           // Text to insert
    position: c_uint,              // Insert position
) -> *mut c_char {                 // Returns updated doc as JSON
    // Implementation
}
```

Dart calls it via:

```dart
final dylib = DynamicLibrary.open('libbwe_core.so');
final insertText = dylib.lookupFunction<...>('bwe_insert_text');
```

**Key Principle**: All data flows through JSON serialization (DocumentGraph ↔ Dart).

### Document Graph Model

The DocumentGraph is an in-memory representation of the document:

```rust
pub struct DocumentGraph {
    pub nodes: Vec<DocNode>,       // Text, heading, list, table, image
    pub edges: Vec<DocEdge>,       // Relationships (next, parent, child, ref)
}

pub struct DocNode {
    pub id: u64,                   // Unique ID
    pub text: String,              // Content (if text node)
    pub formatting: Formatting,    // Style info
}
```

**Graph Invariants**:
- Node IDs are unique
- Edges reference valid node IDs
- Graph is acyclic (except for reference edges)

### Storage & Encryption

Documents are encrypted with AES-256 before saving to disk:

```rust
let vault = VaultStorage::new("user_passphrase");
let encrypted = vault.encrypt(document_bytes);
// On load:
let decrypted = vault.decrypt(encrypted_bytes);
```

**Note**: Phase 1 uses plaintext .txt format. Encryption added in Phase 2.

### Formatting Persistence

Formatting must survive the save/load cycle:

1. **In Memory**: Formatting stored per node in DocumentGraph
2. **On Save**: Serialize Formatting struct to JSON
3. **On Load**: Deserialize Formatting from JSON, apply to nodes
4. **On Export**: Convert to target format (PDF, DOCX, HTML)

---

## Testing Strategy

### Unit Tests (Rust)

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_insert_node() {
        let mut graph = DocumentGraph::new();
        graph.insert_node(...);
        assert_eq!(graph.nodes.len(), 1);
    }
}
```

### Widget Tests (Flutter)

```dart
testWidgets('Editor accepts text input', (WidgetTester tester) async {
    await tester.pumpWidget(const BWEApp());
    await tester.enterText(find.byType(TextField), 'Hello');
    expect(find.text('Hello'), findsOneWidget);
});
```

### Integration Tests

Test the full FFI boundary:

1. Create document in Rust
2. Send via FFI to Flutter
3. Modify in Flutter, send back
4. Verify changes in Rust

---

## Common Tasks

### Adding a New Feature

1. **Design**: Update DocumentGraph to represent the feature
2. **Backend**: Implement in Rust (parser, storage, FFI)
3. **Frontend**: Add Flutter UI (widget, provider, menu item)
4. **Test**: Unit + integration tests
5. **Export**: Handle in file parsers

### Debugging FFI Issues

- **Null pointer crashes**: Verify C string/buffer lifetimes
- **Serialization mismatches**: Check JSON format consistency between Rust and Dart
- **Memory leaks**: Use `valgrind` (Rust) or Android Profiler (Flutter)

### Performance Optimization

- **Rust**: Use `cargo flamegraph` for profiling
- **Flutter**: Use DevTools Performance timeline
- **Bottleneck**: Usually text rendering; use virtual scrolling for large docs

---

## Dependencies

### Rust (Cargo.toml)

- `serde` - JSON serialization
- `curve25519-dalek` - Cryptography
- `aes` - Encryption
- `sha2` - Hashing
- `rand` - Random numbers
- `thiserror` - Error handling

### Flutter (pubspec.yaml)

- `provider` - State management
- `flutter_quill` - Rich text editing (optional, Phase 2)
- `file_picker` - File selection
- `path_provider` - Safe file storage
- `shared_preferences` - User preferences
- `ffi` - FFI support

---

## Roadmap

| Phase | Focus | Duration | Status |
|-------|-------|----------|--------|
| 1 | Basic editing + persistence | 4 weeks | **IN PROGRESS** ✅ |
| 2 | Rich text formatting | 3 weeks | Blocked on Phase 1 |
| 3 | Document structure (headings, lists) | 3 weeks | Blocked on Phase 2 |
| 4 | Tables & images | 3 weeks | Blocked on Phase 3 |
| 5 | Collaboration & export | 5 weeks | Blocked on Phase 4 |

---

## Contributing

### Code Style

- **Rust**: Follow Rust idioms; use `cargo fmt` for formatting
- **Flutter/Dart**: Follow Flutter style guide; use `dart format` and `flutter analyze`

### Commit Message Format

```
[Phase X] [Component] Brief description

Longer explanation if needed.

Fixes: #123 (if applicable)
```

Example:
```
[Phase 1] doc_graph: implement node insertion and deletion

- Add insert_node() method with unique ID generation
- Add delete_node() with cascade edge cleanup
- Add traversal methods (next_sibling, parent, children)
- Add tests for graph invariants

Fixes: #5
```

### Review Checklist

- [ ] Code compiles without warnings (`cargo build`, `flutter analyze`)
- [ ] Tests pass (`cargo test`, `flutter test`)
- [ ] FFI boundary tested (if touching ffi.rs)
- [ ] User-facing changes documented
- [ ] Backwards-compatible or changelog updated

---

## Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Rust Book**: https://doc.rust-lang.org/book/
- **FFI Guide**: https://docs.flutter.dev/platform-integration/c-interop
- **Google Docs UI Patterns**: https://docs.google.com
- **Architecture Decision Records**: See `.github/adr/` (coming soon)

---

## Support

For questions, bugs, or feature requests, reach out to: `ianknotts008@gmail.com`

---

**Last Updated**: 2026-06-29
**Current Phase**: 1 - Core Editing & Persistence
**Status**: UI Structure Complete, Backend TODO
