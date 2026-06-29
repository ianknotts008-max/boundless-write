# Phase 1 - Core Editing & Persistence - Completion Checklist

**Status**: 🟡 70% Complete  
**Deadline**: Target 3 days  
**Owner**: Development Team

---

## 🔴 Critical Path (Must Complete First)

### Week 1: Foundation (✅ COMPLETE)

- [x] Set up Rust project structure (Cargo.toml, src/)
- [x] Implement DocumentGraph (nodes, edges, operations)
- [x] Implement FileParser (.txt support)
- [x] Create FFI bridge (Rust → Dart interface)
- [x] Set up Flutter project (pubspec.yaml, main.dart)
- [x] Design UI components (menu, toolbar, editor, sidebar)
- [x] Implement state management (providers)

### Week 2: Integration (🔄 IN PROGRESS)

- [ ] **1. Load native library in Flutter**
  - [ ] Copy compiled Rust library to Flutter assets
  - [ ] Test library loading: `NativeBridge().hello()`
  - [ ] Verify no "library not found" errors
  - [ ] Platform-specific handling (Windows/Mac/Linux)
  
- [ ] **2. Parse JSON responses**
  - [ ] Add `import 'dart:convert'` to native_bridge.dart
  - [ ] Implement `_parseJson()` to return Map<String, dynamic>
  - [ ] Test parsing with sample JSON from Rust
  - [ ] Handle error responses gracefully
  
- [ ] **3. Connect editor to backend**
  - [ ] Modify `EditorArea.onChanged` to call `native_bridge.insertText()`
  - [ ] Update DocumentProvider with Rust response
  - [ ] Real-time sync between UI and Rust document
  - [ ] Test: Type text → verify it's in Rust backend
  
- [ ] **4. Implement save operation**
  - [ ] Add file_picker to pubspec.yaml ✅
  - [ ] Create SaveDialog widget
  - [ ] Call `native_bridge.saveDocument('txt')`
  - [ ] Write bytes to disk using path_provider
  - [ ] Show success/error messages
  - [ ] Test: Type → Save → Verify file exists
  
- [ ] **5. Implement load operation**
  - [ ] Create OpenDialog widget
  - [ ] Read file bytes from disk
  - [ ] Call `native_bridge.loadDocument(bytes, 'txt')`
  - [ ] Update DocumentProvider with loaded content
  - [ ] Display in editor
  - [ ] Test: Load file → Verify content displays
  
- [ ] **6. Complete file operations in menu**
  - [ ] File → New → Call `bwe_new_document()`
  - [ ] File → Open → OpenDialog flow
  - [ ] File → Save → SaveDialog flow (Ctrl+S)
  - [ ] File → Save As → Save with new filename
  - [ ] Update document title on save
  - [ ] Add unsaved indicator (asterisk in title)

### Week 3: Testing & Polish (⏳ NEXT)

- [ ] **7. Integration testing**
  - [ ] Test full edit-save-load cycle
  - [ ] Verify content integrity after save/load
  - [ ] Test word count syncing with Rust
  - [ ] Stress test: 10,000+ word document
  - [ ] Test on multiple platforms
  
- [ ] **8. Error handling**
  - [ ] Handle file not found gracefully
  - [ ] Handle permission errors
  - [ ] Handle invalid file formats
  - [ ] Display user-friendly error messages
  - [ ] Implement retry logic
  
- [ ] **9. Performance optimization**
  - [ ] Profile FFI boundary performance
  - [ ] Optimize JSON serialization
  - [ ] Lazy load large documents
  - [ ] Measure keystroke-to-render latency
  - [ ] Target: < 50ms latency
  
- [ ] **10. UI Polish**
  - [ ] Add loading indicators (save/load)
  - [ ] Show progress for large files
  - [ ] Implement keyboard shortcuts (Ctrl+S, Ctrl+N, Ctrl+O)
  - [ ] Add undo/redo placeholders
  - [ ] Update recent files list
  - [ ] Save recent files to local storage (shared_preferences)

---

## 📋 Detailed Subtasks

### Task 1: Library Loading & FFI Testing

**Files to modify**: `native_bridge.dart`, `main.dart`

**Steps**:
```dart
// Step 1: Initialize in main()
void main() {
  try {
    NativeBridge();  // Initialize native library
    print('✅ Native library loaded');
  } catch (e) {
    print('❌ Failed to load native library: $e');
  }
  runApp(const BWEApp());
}

// Step 2: Test FFI in home_screen.dart
ElevatedButton(
  onPressed: () {
    final bridge = NativeBridge();
    final result = bridge.hello();
    print('Rust says: $result');  // Should print "Hello from BWE core!"
  },
  child: const Text('Test FFI'),
)
```

**Acceptance Criteria**:
- ✅ App starts without crashes
- ✅ `bridge.hello()` returns "Hello from BWE core!"
- ✅ Works on Windows, Mac, Linux
- ✅ No "native library not found" errors

---

### Task 2: JSON Parsing

**Files to modify**: `native_bridge.dart`

**Current**:
```dart
static Map<String, dynamic> _parseJson(String jsonStr) {
  try {
    return {'raw': jsonStr};  // ❌ Not parsed
  } catch (e) {
    return {'error': 'Failed to parse JSON: $e'};
  }
}
```

**New**:
```dart
import 'dart:convert';

static Map<String, dynamic> _parseJson(String jsonStr) {
  try {
    return jsonDecode(jsonStr) as Map<String, dynamic>;  // ✅ Parsed
  } catch (e) {
    return {'error': 'Failed to parse JSON: $e'};
  }
}
```

**Test**:
```dart
final response = bridge.getStats();
print('Words: ${response['word_count']}');
print('Chars: ${response['char_count']}');
```

**Acceptance Criteria**:
- ✅ JSON parsed correctly
- ✅ Field access works: `response['word_count']`
- ✅ Error handling for invalid JSON
- ✅ Type safety maintained

---

### Task 3: Editor ↔ Backend Connection

**Files to modify**: `editor_area.dart`, `document_provider.dart`, `native_bridge.dart`

**Current Flow** (broken):
```
User types → TextField.onChanged → DocumentProvider.updateContent → (nowhere)
```

**New Flow** (working):
```
User types → TextField.onChanged → DocumentProvider.updateContent 
           → native_bridge.insertText() → Rust backend → JSON response
           → Update DocumentProvider → UI re-renders
```

**Implementation**:

1. **In DocumentProvider**:
```dart
void updateContent(String newContent) {
  _currentDocument.content = newContent;
  _currentDocument.lastModified = DateTime.now();
  
  // NEW: Send to Rust backend
  _syncWithBackend(newContent);
  
  notifyListeners();
}

Future<void> _syncWithBackend(String content) async {
  final bridge = NativeBridge();
  try {
    final response = bridge.insertText(content, 0);
    if (response['status'] == 'error') {
      print('Error: ${response['message']}');
    }
  } catch (e) {
    print('Sync error: $e');
  }
}
```

2. **In EditorArea**:
```dart
TextField(
  onChanged: (value) {
    docProvider.updateContent(value);  // Already implemented ✅
  },
)
```

**Test**:
```
1. Type "Hello" in editor
2. Check Rust backend has stored it
3. Restart app and reload
4. Verify "Hello" is still there (Phase 2)
```

**Acceptance Criteria**:
- ✅ Text reaches Rust backend
- ✅ Rust responds with updated document JSON
- ✅ No latency/freezing (async operation)
- ✅ Error handling for connection failures

---

### Task 4: Save to File

**Files to modify**: `menu_bar.dart`, new `widgets/dialogs.dart`

**Implementation**:

```dart
// Step 1: Create save dialog
static void _saveDocument(BuildContext context) async {
  final bridge = NativeBridge();
  
  // Get the document bytes
  final bytes = bridge.saveDocument('txt');
  if (bytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Save failed')),
    );
    return;
  }
  
  // Show save dialog
  final result = await FilePicker.platform.saveFile(
    allowedExtensions: ['txt'],
    type: FileType.custom,
  );
  
  if (result != null) {
    // Write to file
    final file = File(result);
    await file.writeAsBytes(bytes);
    
    // Update DocumentProvider
    context.read<DocumentProvider>().currentDocument.filePath = result;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Saved to $result')),
    );
  }
}
```

**Test**:
```
1. Type "Test Document"
2. File → Save
3. Choose location and filename
4. Verify file exists with correct content
```

**Acceptance Criteria**:
- ✅ File dialog opens
- ✅ File written to disk
- ✅ Content is correct (.txt format)
- ✅ Success message shown
- ✅ Error handling for permission issues

---

### Task 5: Load from File

**Files to modify**: `menu_bar.dart`

**Implementation**:

```dart
static void _openDocument(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    allowedExtensions: ['txt', 'bwe'],
    type: FileType.custom,
  );
  
  if (result != null && result.files.isNotEmpty) {
    final filePath = result.files.first.path!;
    final file = File(filePath);
    
    // Read file bytes
    final bytes = await file.readAsBytes();
    
    // Parse with Rust backend
    final bridge = NativeBridge();
    final response = bridge.loadDocument(bytes, 'txt');
    
    if (response['status'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${response['message']}')),
      );
      return;
    }
    
    // Update DocumentProvider
    context.read<DocumentProvider>().updateTitle(
      path.basename(filePath),  // Use filename as title
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Loaded successfully')),
    );
  }
}
```

**Test**:
```
1. File → Open
2. Select saved .txt file
3. Verify content appears in editor
4. Verify word count updates
```

**Acceptance Criteria**:
- ✅ File dialog opens
- ✅ Content loaded correctly
- ✅ Title updated with filename
- ✅ Word count reflects loaded content
- ✅ Error handling for invalid files

---

## 🧪 Testing Scenarios

### Manual Test: Type & Save & Load

```
1. Start app → "Untitled Document"
2. Type: "The quick brown fox jumps over the lazy dog"
3. File → Save → "test.txt"
4. Close app (kill process)
5. Open app → "Untitled Document"
6. File → Open → "test.txt"
7. Verify: "The quick brown fox..." appears
8. Verify: Word count = 8 ✅
```

### Manual Test: Multiple Edits

```
1. Type: "Hello"
2. Type: " World" (at end)
3. File → Save → "hello.txt"
4. Verify file contains: "Hello World"
5. Delete " World"
6. File → Save (overwrite)
7. Verify file contains: "Hello"
```

### Automated Test Template

```dart
testWidgets('Edit and save document', (WidgetTester tester) async {
  await tester.pumpWidget(const BWEApp());
  
  // Type text
  await tester.enterText(find.byType(TextField), 'Test');
  await tester.pumpAndSettle();
  
  // Verify word count
  expect(find.text('1'), findsOneWidget);  // 1 word
  
  // Save (mock file picker)
  // await tester.tap(find.text('Save'));
  // (Need to mock FilePicker)
});
```

---

## 📊 Progress Tracking

### Current Progress

| Component | Status | % | Blocker |
|-----------|--------|---|---------|
| Rust backend | ✅ Complete | 100% | None |
| Flutter UI | ✅ Complete | 100% | None |
| FFI loading | ⏳ Started | 20% | Library location |
| JSON parsing | ⏳ TODO | 0% | None |
| Editor sync | ⏳ TODO | 0% | JSON parsing |
| File save | ⏳ TODO | 0% | Editor sync |
| File load | ⏳ TODO | 0% | Editor sync |
| Testing | ⏳ TODO | 0% | All above |

### Timeline

```
Today:   Library loading, JSON parsing
Tomorrow: Editor sync, save/load
Day 3:   Testing, polish, Phase 1 complete ✅
```

---

## 🚨 Potential Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| Library not found | Crash on app start | Copy .so/.dll/.dylib to correct location |
| FFI symbol not found | Runtime error | Verify `#[no_mangle]` on Rust functions |
| Memory leak | App crash after many saves | Call `bwe_free_*()` for all pointers |
| Null pointer | Segmentation fault | Check for null pointers before dereferencing |
| JSON parsing error | "error" in response map | Verify JSON format matches Rust output |
| File permissions | "Permission denied" | Use path_provider, not absolute paths |
| Large file | App freezes during load | Implement streaming (Phase 2) |

---

## 🎯 Definition of Done

Phase 1 is complete when ALL of these pass:

- [ ] App compiles without warnings (Rust & Dart)
- [ ] All 9 Rust unit tests pass
- [ ] App starts and displays UI
- [ ] `NativeBridge().hello()` works
- [ ] User can type text in editor
- [ ] Text syncs to Rust backend (visible in stats)
- [ ] File → Save works (creates file on disk)
- [ ] File → Open works (loads content into editor)
- [ ] File → New works (clears document)
- [ ] Word count updates in real-time
- [ ] Full edit-save-load cycle works
- [ ] No crashes on edge cases (empty file, large file, invalid file)
- [ ] Error messages are user-friendly
- [ ] Keyboard shortcuts work (Ctrl+S, Ctrl+N, Ctrl+O)
- [ ] Works on Windows, Mac, and Linux

---

## 📚 Reference Documentation

- **CLAUDE.md** - Architecture overview
- **FEATURES.md** - Complete feature list
- **QUICKSTART.md** - Setup instructions
- **IMPLEMENTATION_SUMMARY.md** - What's been done
- **This file** - Completion checklist

---

## 📞 Questions & Support

If blocked on any task:

1. Check the "Potential Issues & Solutions" table above
2. Review CLAUDE.md architecture section
3. Check Rust compilation output: `cargo build --verbose`
4. Check Flutter output: `flutter run -v`
5. Enable FFI debugging in native_bridge.dart

---

**Last Updated**: 2026-06-29  
**Next Phase**: Phase 2 - Rich Text Formatting  
**Estimated Completion**: 2026-07-02 (3 days)
