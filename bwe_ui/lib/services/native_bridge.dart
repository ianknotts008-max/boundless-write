import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';

typedef HelloFunc = Pointer<Utf8> Function();
typedef HelloFuncDart = Pointer<Utf8> Function();

typedef NewDocFunc = Pointer<Utf8> Function();
typedef NewDocFuncDart = Pointer<Utf8> Function();

typedef InsertTextFunc = Pointer<Utf8> Function(
  Pointer<Utf8> text,
  Uint32 position,
);
typedef InsertTextFuncDart = Pointer<Utf8> Function(
  Pointer<Utf8> text,
  int position,
);

typedef DeleteTextFunc = Pointer<Utf8> Function(Uint32 start, Uint32 end);
typedef DeleteTextFuncDart = Pointer<Utf8> Function(int start, int end);

typedef GetDocFunc = Pointer<Utf8> Function();
typedef GetDocFuncDart = Pointer<Utf8> Function();

typedef GetStatsFunc = Pointer<Utf8> Function();
typedef GetStatsFuncDart = Pointer<Utf8> Function();

typedef LoadDocumentFunc = Pointer<Utf8> Function(
  Pointer<Uint8> data,
  Uint32 len,
  Pointer<Utf8> format,
);
typedef LoadDocumentFuncDart = Pointer<Utf8> Function(
  Pointer<Uint8> data,
  int len,
  Pointer<Utf8> format,
);

typedef SaveDocumentFunc = Pointer<Uint8> Function(Pointer<Utf8> format);
typedef SaveDocumentFuncDart = Pointer<Uint8> Function(Pointer<Utf8> format);

typedef GetDocumentSizeFunc = Uint32 Function(Pointer<Utf8> format);
typedef GetDocumentSizeFuncDart = int Function(Pointer<Utf8> format);

typedef FreeStringFunc = Void Function(Pointer<Utf8> ptr);
typedef FreeStringFuncDart = void Function(Pointer<Utf8> ptr);

typedef FreeBufferFunc = Void Function(Pointer<Uint8> ptr, Uint32 len);
typedef FreeBufferFuncDart = void Function(Pointer<Uint8> ptr, int len);

/// Native Bridge for communicating with Rust BWE core
class NativeBridge {
  static late DynamicLibrary _dylib;
  static bool _initialized = false;

  // FFI function references
  late HelloFuncDart _bweHello;
  late NewDocFuncDart _bweNewDocument;
  late InsertTextFuncDart _bweInsertText;
  late DeleteTextFuncDart _bweDeleteText;
  late GetDocFuncDart _bweGetDocument;
  late GetStatsFuncDart _bweGetStats;
  late LoadDocumentFuncDart _bweLoadDocument;
  late SaveDocumentFuncDart _bweSaveDocument;
  late GetDocumentSizeFuncDart _bweGetDocumentSize;
  late FreeStringFuncDart _bweFreeString;
  late FreeBufferFuncDart _bweFreeBuffer;

  static final NativeBridge _instance = NativeBridge._internal();

  factory NativeBridge() {
    return _instance;
  }

  NativeBridge._internal() {
    _initialize();
  }

  static void _initialize() {
    if (_initialized) return;

    try {
      // Load the native library based on platform
      if (Platform.isWindows) {
        _dylib = DynamicLibrary.open('bwe_core.dll');
      } else if (Platform.isMacOS) {
        _dylib = DynamicLibrary.open('libbwe_core.dylib');
      } else if (Platform.isLinux) {
        _dylib = DynamicLibrary.open('libbwe_core.so');
      } else {
        throw UnsupportedError('Platform not supported');
      }
      _initialized = true;
    } catch (e) {
      throw Exception('Failed to load native library: $e');
    }
  }

  void _loadFunctions() {
    _bweHello = _dylib.lookupFunction<HelloFunc, HelloFuncDart>('bwe_hello');
    _bweNewDocument =
        _dylib.lookupFunction<NewDocFunc, NewDocFuncDart>('bwe_new_document');
    _bweInsertText =
        _dylib.lookupFunction<InsertTextFunc, InsertTextFuncDart>('bwe_insert_text');
    _bweDeleteText =
        _dylib.lookupFunction<DeleteTextFunc, DeleteTextFuncDart>('bwe_delete_text');
    _bweGetDocument =
        _dylib.lookupFunction<GetDocFunc, GetDocFuncDart>('bwe_get_document');
    _bweGetStats =
        _dylib.lookupFunction<GetStatsFunc, GetStatsFuncDart>('bwe_get_stats');
    _bweLoadDocument = _dylib
        .lookupFunction<LoadDocumentFunc, LoadDocumentFuncDart>('bwe_load_document');
    _bweSaveDocument = _dylib
        .lookupFunction<SaveDocumentFunc, SaveDocumentFuncDart>('bwe_save_document');
    _bweGetDocumentSize = _dylib
        .lookupFunction<GetDocumentSizeFunc, GetDocumentSizeFuncDart>(
            'bwe_get_document_size');
    _bweFreeString =
        _dylib.lookupFunction<FreeStringFunc, FreeStringFuncDart>('bwe_free_string');
    _bweFreeBuffer =
        _dylib.lookupFunction<FreeBufferFunc, FreeBufferFuncDart>('bwe_free_buffer');
  }

  /// Test the FFI connection
  String hello() {
    _loadFunctions();
    final result = _bweHello();
    final message = result.toDartString();
    _bweFreeString(result);
    return message;
  }

  /// Create a new document
  Map<String, dynamic> newDocument() {
    _loadFunctions();
    final result = _bweNewDocument();
    final jsonStr = result.toDartString();
    _bweFreeString(result);
    return _parseJson(jsonStr);
  }

  /// Insert text at a position
  Map<String, dynamic> insertText(String text, int position) {
    _loadFunctions();
    final textPtr = text.toNativeUtf8();
    try {
      final result = _bweInsertText(textPtr, position);
      final jsonStr = result.toDartString();
      _bweFreeString(result);
      return _parseJson(jsonStr);
    } finally {
      malloc.free(textPtr);
    }
  }

  /// Delete text from a range
  Map<String, dynamic> deleteText(int start, int end) {
    _loadFunctions();
    final result = _bweDeleteText(start, end);
    final jsonStr = result.toDartString();
    _bweFreeString(result);
    return _parseJson(jsonStr);
  }

  /// Get the current document
  Map<String, dynamic> getDocument() {
    _loadFunctions();
    final result = _bweGetDocument();
    final jsonStr = result.toDartString();
    _bweFreeString(result);
    return _parseJson(jsonStr);
  }

  /// Get document statistics
  Map<String, dynamic> getStats() {
    _loadFunctions();
    final result = _bweGetStats();
    final jsonStr = result.toDartString();
    _bweFreeString(result);
    return _parseJson(jsonStr);
  }

  /// Load a document from bytes
  Map<String, dynamic> loadDocument(Uint8List data, String format) {
    _loadFunctions();
    final dataPtr = malloc<Uint8>(data.length);
    final formatPtr = format.toNativeUtf8();

    try {
      // Copy data to native memory
      dataPtr.asTypedList(data.length).setAll(0, data);

      final result = _bweLoadDocument(dataPtr, data.length, formatPtr);
      final jsonStr = result.toDartString();
      _bweFreeString(result);
      return _parseJson(jsonStr);
    } finally {
      malloc.free(dataPtr);
      malloc.free(formatPtr);
    }
  }

  /// Save the document to bytes
  Uint8List? saveDocument(String format) {
    _loadFunctions();
    final formatPtr = format.toNativeUtf8();

    try {
      final result = _bweSaveDocument(formatPtr);
      if (result == nullptr) {
        return null;
      }

      final size = _bweGetDocumentSize(formatPtr);
      if (size == 0) {
        return null;
      }

      final data = result.asTypedList(size).toList();
      _bweFreeBuffer(result, size);
      return Uint8List.fromList(data);
    } finally {
      malloc.free(formatPtr);
    }
  }

  /// Parse JSON response from Rust
  static Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return {'raw': jsonStr, 'error': 'Expected JSON object'};
    } catch (e) {
      return {'error': 'Failed to parse JSON: $e', 'raw': jsonStr};
    }
  }
}
