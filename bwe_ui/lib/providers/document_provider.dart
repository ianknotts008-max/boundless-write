import 'package:flutter/foundation.dart';
import '../services/native_bridge.dart';

class Document {
  String title;
  String content;
  DateTime lastModified;
  String filePath;
  int wordCount;
  int characterCount;
  int pageCount;

  Document({
    required this.title,
    this.content = '',
    DateTime? lastModified,
    this.filePath = '',
    this.wordCount = 0,
    this.characterCount = 0,
    this.pageCount = 0,
  }) : lastModified = lastModified ?? DateTime.now();

  void updateStats() {
    wordCount = content.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    characterCount = content.length;
    pageCount = (characterCount / 3000).ceil();
  }
}

class DocumentProvider extends ChangeNotifier {
  Document _currentDocument = Document(title: 'Untitled Document');
  List<Document> _recentDocuments = [];
  final NativeBridge _bridge = NativeBridge();
  bool _isSyncing = false;
  String? _error;

  Document get currentDocument => _currentDocument;
  List<Document> get recentDocuments => _recentDocuments;
  bool get isSyncing => _isSyncing;
  String? get error => _error;

  DocumentProvider() {
    _initializeBackend();
  }

  /// Initialize the Rust backend
  void _initializeBackend() {
    try {
      // Verify FFI is working
      final hello = _bridge.hello();
      debugPrint('✅ Native bridge initialized: $hello');
      _createNewDocumentBackend();
    } catch (e) {
      _error = 'Failed to initialize native backend: $e';
      debugPrint('❌ Native bridge error: $_error');
    }
  }

  /// Create new document in Rust backend
  void _createNewDocumentBackend() {
    try {
      final response = _bridge.newDocument();
      if (response['status'] == 'error') {
        _error = response['message'] ?? 'Unknown error';
      }
    } catch (e) {
      _error = 'Error creating document in backend: $e';
    }
  }

  /// Create a new document
  void createNewDocument({String title = 'Untitled Document'}) {
    _currentDocument = Document(title: title);
    _createNewDocumentBackend();
    notifyListeners();
  }

  /// Update content and sync to Rust backend
  void updateContent(String newContent) {
    _currentDocument.content = newContent;
    _currentDocument.lastModified = DateTime.now();
    _currentDocument.updateStats();

    // Sync to Rust backend asynchronously
    _syncToBackend(newContent);

    notifyListeners();
  }

  /// Sync content to Rust backend
  Future<void> _syncToBackend(String content) async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // For Phase 1, insert at position 0 (append mode)
      final response = _bridge.insertText(content, 0);

      if (response['status'] == 'error') {
        _error = response['message'] ?? 'Sync error';
        debugPrint('❌ Sync error: $_error');
      } else {
        _error = null;
        // Get updated stats from backend
        _updateStatsFromBackend();
      }
    } catch (e) {
      _error = 'Backend sync failed: $e';
      debugPrint('❌ Sync exception: $_error');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Update stats from Rust backend
  void _updateStatsFromBackend() {
    try {
      final stats = _bridge.getStats();
      if (stats.containsKey('word_count')) {
        _currentDocument.wordCount = stats['word_count'] ?? 0;
        _currentDocument.characterCount = stats['char_count'] ?? 0;
        _currentDocument.pageCount = stats['page_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting stats: $e');
    }
  }

  /// Update document title
  void updateTitle(String newTitle) {
    _currentDocument.title = newTitle;
    notifyListeners();
  }

  /// Add document to recent list
  void addRecentDocument(Document doc) {
    _recentDocuments.removeWhere((d) => d.title == doc.title);
    _recentDocuments.insert(0, doc);
    if (_recentDocuments.length > 10) {
      _recentDocuments.removeLast();
    }
    notifyListeners();
  }

  /// Load document
  void loadDocument(Document doc) {
    _currentDocument = doc;
    addRecentDocument(doc);
    notifyListeners();
  }

  /// Load document from file
  Future<bool> loadFromFile(List<int> fileBytes, String filename) async {
    try {
      _isSyncing = true;
      final response = _bridge.loadDocument(
        Uint8List.fromList(fileBytes),
        'txt',
      );

      if (response['status'] == 'error') {
        _error = response['message'] ?? 'Failed to load file';
        _isSyncing = false;
        notifyListeners();
        return false;
      }

      _currentDocument = Document(
        title: filename,
        filePath: filename,
      );
      _updateStatsFromBackend();
      _error = null;
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error loading file: $e';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  /// Save document to file
  Future<Uint8List?> saveToFile() async {
    try {
      _isSyncing = true;
      notifyListeners();

      final bytes = _bridge.saveDocument('txt');
      if (bytes == null) {
        _error = 'Failed to save document';
        _isSyncing = false;
        notifyListeners();
        return null;
      }

      _error = null;
      _isSyncing = false;
      notifyListeners();
      return bytes;
    } catch (e) {
      _error = 'Error saving document: $e';
      _isSyncing = false;
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'dart:typed_data';
