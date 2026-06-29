import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/document_provider.dart';

class MenuBar extends StatelessWidget {
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _MenuButton(label: 'File', items: [
              ('New', () => _newDocument(context)),
              ('Open', () => _openDocument(context)),
              ('Save', () => _saveDocument(context)),
              ('Save As', () => _saveAsDocument(context)),
              null,
              ('Export as PDF', () => _exportPDF(context)),
              ('Export as DOCX', () => _exportDOCX(context)),
              null,
              ('Exit', () => Navigator.pop(context)),
            ]),
            const SizedBox(width: 8),
            _MenuButton(label: 'Edit', items: [
              ('Undo', () => _undo(context)),
              ('Redo', () => _redo(context)),
              null,
              ('Cut', () => _cut(context)),
              ('Copy', () => _copy(context)),
              ('Paste', () => _paste(context)),
              null,
              ('Find & Replace', () => _findReplace(context)),
            ]),
            const SizedBox(width: 8),
            _MenuButton(label: 'View', items: [
              ('Zoom In', () => _zoomIn(context)),
              ('Zoom Out', () => _zoomOut(context)),
              ('Reset Zoom', () => _resetZoom(context)),
              null,
              ('Show Ruler', () => _toggleRuler(context)),
              ('Show Navigator', () => _toggleNavigator(context)),
            ]),
            const SizedBox(width: 8),
            _MenuButton(label: 'Insert', items: [
              ('Image', () => _insertImage(context)),
              ('Table', () => _insertTable(context)),
              ('Link', () => _insertLink(context)),
              ('Page Break', () => _insertPageBreak(context)),
              ('Footnote', () => _insertFootnote(context)),
            ]),
            const SizedBox(width: 8),
            _MenuButton(label: 'Format', items: [
              ('Clear Formatting', () => _clearFormatting(context)),
              ('Styles', () => _openStyles(context)),
              ('Paragraph', () => _openParagraphSettings(context)),
            ]),
            const SizedBox(width: 8),
            _MenuButton(label: 'Tools', items: [
              ('Spell Check', () => _spellCheck(context)),
              ('Word Count', () => _wordCount(context)),
              ('Settings', () => _openSettings(context)),
            ]),
            const SizedBox(width: 8),
            _MenuButton(label: 'Help', items: [
              ('About', () => _showAbout(context)),
              ('Keyboard Shortcuts', () => _showShortcuts(context)),
            ]),
          ],
        ),
      ),
    );
  }

  static void _newDocument(BuildContext context) {
    context.read<DocumentProvider>().createNewDocument();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ New document created')),
    );
  }

  static void _openDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['txt', 'bwe'],
        type: FileType.custom,
        dialogTitle: 'Open Document',
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path!;
        final file = File(filePath);
        final bytes = await file.readAsBytes();
        final filename = result.files.first.name;

        final provider = context.read<DocumentProvider>();
        final success = await provider.loadFromFile(bytes, filename);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Loaded: $filename')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${provider.error}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error opening file: $e')),
      );
    }
  }

  static void _saveDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.saveFile(
        allowedExtensions: ['txt'],
        type: FileType.custom,
        dialogTitle: 'Save Document',
      );

      if (result != null) {
        final provider = context.read<DocumentProvider>();
        final bytes = await provider.saveToFile();

        if (bytes != null) {
          final file = File(result);
          await file.writeAsBytes(bytes);
          provider.updateTitle(result.split('/').last);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Saved to: ${result.split('/').last}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Save failed: ${provider.error}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving file: $e')),
      );
    }
  }

  static void _saveAsDocument(BuildContext context) async {
    _saveDocument(context);
  }

  static void _exportPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as PDF - Feature coming soon')),
    );
  }

  static void _exportDOCX(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as DOCX - Feature coming soon')),
    );
  }

  static void _undo(BuildContext context) {}
  static void _redo(BuildContext context) {}
  static void _cut(BuildContext context) {}
  static void _copy(BuildContext context) {}
  static void _paste(BuildContext context) {}
  static void _findReplace(BuildContext context) {}
  static void _zoomIn(BuildContext context) {}
  static void _zoomOut(BuildContext context) {}
  static void _resetZoom(BuildContext context) {}
  static void _toggleRuler(BuildContext context) {}
  static void _toggleNavigator(BuildContext context) {}
  static void _insertImage(BuildContext context) {}
  static void _insertTable(BuildContext context) {}
  static void _insertLink(BuildContext context) {}
  static void _insertPageBreak(BuildContext context) {}
  static void _insertFootnote(BuildContext context) {}
  static void _clearFormatting(BuildContext context) {}
  static void _openStyles(BuildContext context) {}
  static void _openParagraphSettings(BuildContext context) {}
  static void _spellCheck(BuildContext context) {}
  static void _wordCount(BuildContext context) {}
  static void _openSettings(BuildContext context) {}
  static void _showAbout(BuildContext context) {}
  static void _showShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final shortcuts = <String, String>{};
        const Map<String, String> allShortcuts = {
          'Ctrl+N': 'New Document',
          'Ctrl+O': 'Open Document',
          'Ctrl+S': 'Save Document',
          'Ctrl+Shift+S': 'Save As',
          'Ctrl+Z': 'Undo',
          'Ctrl+Y': 'Redo',
          'Ctrl+A': 'Select All',
          'Ctrl+X': 'Cut',
          'Ctrl+C': 'Copy',
          'Ctrl+V': 'Paste',
          'Ctrl+B': 'Bold',
          'Ctrl+I': 'Italic',
          'Ctrl+U': 'Underline',
          'Ctrl+Shift+X': 'Strikethrough',
          'Ctrl+F': 'Find',
          'Ctrl+H': 'Find & Replace',
          'Ctrl++': 'Zoom In',
          'Ctrl+-': 'Zoom Out',
          'Ctrl+0': 'Reset Zoom',
          'Ctrl+,': 'Settings',
          'F1': 'Help',
        };

        return AlertDialog(
          title: const Text('⌨️ Keyboard Shortcuts'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'File Operations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildShortcutRow('Ctrl+N', 'New Document'),
                  _buildShortcutRow('Ctrl+O', 'Open Document'),
                  _buildShortcutRow('Ctrl+S', 'Save Document'),
                  _buildShortcutRow('Ctrl+Shift+S', 'Save As'),
                  const SizedBox(height: 16),
                  const Text(
                    'Edit Operations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildShortcutRow('Ctrl+Z', 'Undo'),
                  _buildShortcutRow('Ctrl+Y', 'Redo'),
                  _buildShortcutRow('Ctrl+A', 'Select All'),
                  _buildShortcutRow('Ctrl+X', 'Cut'),
                  _buildShortcutRow('Ctrl+C', 'Copy'),
                  _buildShortcutRow('Ctrl+V', 'Paste'),
                  const SizedBox(height: 16),
                  const Text(
                    'Text Formatting',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildShortcutRow('Ctrl+B', 'Bold'),
                  _buildShortcutRow('Ctrl+I', 'Italic'),
                  _buildShortcutRow('Ctrl+U', 'Underline'),
                  _buildShortcutRow('Ctrl+Shift+X', 'Strikethrough'),
                  const SizedBox(height: 16),
                  const Text(
                    'Other',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildShortcutRow('Ctrl+F', 'Find'),
                  _buildShortcutRow('Ctrl+H', 'Find & Replace'),
                  _buildShortcutRow('F1', 'Help'),
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
      },
    );
  }

  static Widget _buildShortcutRow(String shortcut, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final List<(String, VoidCallback)?> items;

  const _MenuButton({
    required this.label,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (index) {
        if (items[index] != null) {
          items[index]!.$2();
        }
      },
      itemBuilder: (BuildContext context) {
        return items.asMap().entries.map((entry) {
          if (entry.value == null) {
            return const PopupMenuDivider();
          }
          return PopupMenuItem<int>(
            value: entry.key,
            child: Text(entry.value!.$1),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
