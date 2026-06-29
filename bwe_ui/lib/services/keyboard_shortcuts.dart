import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/document_provider.dart';
import '../providers/formatting_provider.dart';

/// Keyboard shortcut handler for BoundlessWrite
class KeyboardShortcuts {
  static const Map<String, String> shortcuts = {
    // File Operations
    'Ctrl+N': 'New Document',
    'Ctrl+O': 'Open Document',
    'Ctrl+S': 'Save Document',
    'Ctrl+Shift+S': 'Save As',

    // Edit Operations
    'Ctrl+Z': 'Undo',
    'Ctrl+Y': 'Redo',
    'Ctrl+A': 'Select All',
    'Ctrl+X': 'Cut',
    'Ctrl+C': 'Copy',
    'Ctrl+V': 'Paste',

    // Text Formatting
    'Ctrl+B': 'Bold',
    'Ctrl+I': 'Italic',
    'Ctrl+U': 'Underline',
    'Ctrl+Shift+X': 'Strikethrough',

    // Find & Replace
    'Ctrl+F': 'Find',
    'Ctrl+H': 'Find & Replace',

    // View
    'Ctrl+Plus': 'Zoom In',
    'Ctrl+Minus': 'Zoom Out',
    'Ctrl+0': 'Reset Zoom',

    // Misc
    'Ctrl+,': 'Settings',
    'F1': 'Help',
  };

  /// Handle keyboard shortcuts
  static bool handleKeyEvent(
    RawKeyEvent event,
    DocumentProvider documentProvider,
    FormattingProvider formattingProvider,
    Function(String) onAction,
  ) {
    if (event is! RawKeyDownEvent) return false;

    final isCtrlPressed = event.isControlPressed;
    final isShiftPressed = event.isShiftPressed;
    final isAltPressed = event.isAltPressed;
    final logicalKey = event.logicalKey;

    // Ctrl+N - New Document
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyN) {
      documentProvider.createNewDocument();
      onAction('New document created');
      return true;
    }

    // Ctrl+S - Save Document
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyS) {
      onAction('save');
      return true;
    }

    // Ctrl+Shift+S - Save As
    if (isCtrlPressed && isShiftPressed && logicalKey == LogicalKeyboardKey.keyS) {
      onAction('saveAs');
      return true;
    }

    // Ctrl+O - Open Document
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyO) {
      onAction('open');
      return true;
    }

    // Ctrl+B - Bold
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyB) {
      formattingProvider.toggleBold();
      return true;
    }

    // Ctrl+I - Italic
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyI) {
      formattingProvider.toggleItalic();
      return true;
    }

    // Ctrl+U - Underline
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyU) {
      formattingProvider.toggleUnderline();
      return true;
    }

    // Ctrl+Shift+X - Strikethrough
    if (isCtrlPressed && isShiftPressed && logicalKey == LogicalKeyboardKey.keyX) {
      formattingProvider.toggleStrikethrough();
      return true;
    }

    // Ctrl+F - Find
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyF) {
      onAction('find');
      return true;
    }

    // Ctrl+H - Find & Replace
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.keyH) {
      onAction('findReplace');
      return true;
    }

    // Ctrl+Plus/Equal - Zoom In
    if (isCtrlPressed &&
        (logicalKey == LogicalKeyboardKey.equal ||
         logicalKey == LogicalKeyboardKey.add)) {
      onAction('zoomIn');
      return true;
    }

    // Ctrl+Minus - Zoom Out
    if (isCtrlPressed &&
        (logicalKey == LogicalKeyboardKey.minus ||
         logicalKey == LogicalKeyboardKey.subtract)) {
      onAction('zoomOut');
      return true;
    }

    // Ctrl+0 - Reset Zoom
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.digit0) {
      onAction('zoomReset');
      return true;
    }

    // Ctrl+Comma - Settings
    if (isCtrlPressed && logicalKey == LogicalKeyboardKey.comma) {
      onAction('settings');
      return true;
    }

    // F1 - Help
    if (logicalKey == LogicalKeyboardKey.f1) {
      onAction('help');
      return true;
    }

    return false;
  }

  /// Get human-readable shortcut description
  static String getShortcutDescription(String action) {
    for (final entry in shortcuts.entries) {
      if (entry.value.toLowerCase() == action.toLowerCase()) {
        return '${entry.key} - ${entry.value}';
      }
    }
    return action;
  }

  /// Get all shortcuts grouped by category
  static Map<String, List<MapEntry<String, String>>> getGroupedShortcuts() {
    final grouped = <String, List<MapEntry<String, String>>>{};

    const categories = {
      'File Operations': [
        'New Document',
        'Open Document',
        'Save Document',
        'Save As',
      ],
      'Edit Operations': [
        'Undo',
        'Redo',
        'Select All',
        'Cut',
        'Copy',
        'Paste',
      ],
      'Text Formatting': [
        'Bold',
        'Italic',
        'Underline',
        'Strikethrough',
      ],
      'Find & Replace': [
        'Find',
        'Find & Replace',
      ],
      'View': [
        'Zoom In',
        'Zoom Out',
        'Reset Zoom',
      ],
      'Misc': [
        'Settings',
        'Help',
      ],
    };

    for (final entry in categories.entries) {
      grouped[entry.key] = [];
      for (final action in entry.value) {
        for (final shortcutEntry in shortcuts.entries) {
          if (shortcutEntry.value == action) {
            grouped[entry.key]!.add(shortcutEntry);
            break;
          }
        }
      }
    }

    return grouped;
  }
}

/// Widget to display keyboard shortcuts help dialog
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupedShortcuts = KeyboardShortcuts.getGroupedShortcuts();

    return AlertDialog(
      title: const Text('Keyboard Shortcuts'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in groupedShortcuts.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      for (final shortcut in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(shortcut.value),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  shortcut.key,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
