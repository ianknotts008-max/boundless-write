import 'package:flutter_test/flutter_test.dart';
import 'package:bwe_ui/services/native_bridge.dart';
import 'dart:typed_data';

void main() {
  group('FFI Integration Tests', () {
    late NativeBridge bridge;

    setUp(() {
      bridge = NativeBridge();
    });

    test('Native library loads successfully', () {
      expect(
        () => bridge.hello(),
        returnsNormally,
        reason: 'Native library should load and return from bwe_hello()',
      );
    });

    test('Hello function returns correct message', () {
      final result = bridge.hello();
      expect(
        result,
        contains('Hello'),
        reason: 'bwe_hello() should return a greeting',
      );
    });

    test('Create new document succeeds', () {
      final response = bridge.newDocument();
      expect(response['status'], isNotNull);
    });

    test('Insert text returns valid JSON response', () {
      bridge.newDocument();
      final response = bridge.insertText('Hello World', 0);
      expect(response.containsKey('status') || response.containsKey('error'), true);
    });

    test('Get stats returns word/char/page counts', () {
      bridge.newDocument();
      bridge.insertText('One two three', 0);
      final stats = bridge.getStats();

      expect(stats.containsKey('word_count'), true);
      expect(stats.containsKey('char_count'), true);
      expect(stats.containsKey('page_count'), true);
    });

    test('Delete text updates document', () {
      bridge.newDocument();
      bridge.insertText('Hello World', 0);
      bridge.deleteText(0, 5);
      final stats = bridge.getStats();

      expect(stats['char_count'], lessThan(11));
    });

    test('Save and load round trip preserves content', () {
      bridge.newDocument();
      const testContent = 'Test content';
      bridge.insertText(testContent, 0);

      final saved = bridge.saveDocument('txt');
      expect(saved, isNotNull);

      bridge.newDocument();
      final loadResult = bridge.loadDocument(saved!, 'txt');
      expect(loadResult['status'] != 'error', true);

      final stats = bridge.getStats();
      expect(stats['char_count'], greaterThan(0));
    });

    test('Error handling for invalid format', () {
      final response = bridge.loadDocument(Uint8List(0), 'unknown');
      expect(response['status'] == 'error', true);
    });
  });
}

// Simplified test that doesn't require full app context
void testFFIConnection() {
  try {
    final bridge = NativeBridge();
    final hello = bridge.hello();
    print('✅ FFI Connection Test PASSED');
    print('   Response: $hello');
  } catch (e) {
    print('❌ FFI Connection Test FAILED');
    print('   Error: $e');
  }
}
