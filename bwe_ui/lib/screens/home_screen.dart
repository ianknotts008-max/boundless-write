import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/document_provider.dart';
import '../providers/formatting_provider.dart';
import '../widgets/menu_bar.dart';
import '../widgets/formatting_toolbar.dart';
import '../widgets/editor_area.dart';
import '../widgets/sidebar.dart';
import '../services/keyboard_shortcuts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSidebar = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyboardAction(String action) {
    final docProvider = context.read<DocumentProvider>();

    switch (action) {
      case 'save':
        _saveDocument();
        break;
      case 'saveAs':
        _saveAsDocument();
        break;
      case 'open':
        _openDocument();
        break;
      case 'find':
        _showFindDialog();
        break;
      case 'findReplace':
        _showFindReplaceDialog();
        break;
      case 'zoomIn':
        _zoomIn();
        break;
      case 'zoomOut':
        _zoomOut();
        break;
      case 'zoomReset':
        _zoomReset();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'help':
        _showKeyboardShortcuts();
        break;
      default:
        break;
    }
  }

  Future<void> _saveDocument() async {
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
            SnackBar(
              content: Text('✅ Saved to: ${result.split('/').last}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving file: $e')),
      );
    }
  }

  Future<void> _saveAsDocument() async {
    _saveDocument();
  }

  Future<void> _openDocument() async {
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
            SnackBar(
              content: Text('✅ Loaded: $filename'),
              duration: const Duration(seconds: 2),
            ),
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

  void _showFindDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter text to find...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // TODO: Implement find functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFindReplaceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find & Replace'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Find',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Replace with',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Zoom In (Coming in Phase 2)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _zoomOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Zoom Out (Coming in Phase 2)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _zoomReset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Zoom Reset (Coming in Phase 2)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚙️ Settings (Coming in Phase 2)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showKeyboardShortcuts() {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        final docProvider = context.read<DocumentProvider>();
        final formattingProvider = context.read<FormattingProvider>();

        KeyboardShortcuts.handleKeyEvent(
          event,
          docProvider,
          formattingProvider,
          _handleKeyboardAction,
        );
      },
      child: Scaffold(
        body: Column(
          children: [
            // Menu Bar
            const MenuBar(),

            // Formatting Toolbar
            const FormattingToolbar(),

            // Main Editor Area with Sidebar
            Expanded(
              child: Row(
                children: [
                  // Editor
                  Expanded(
                    child: EditorArea(),
                  ),

                  // Sidebar (Collapsible)
                  if (showSidebar)
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: const Sidebar(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
