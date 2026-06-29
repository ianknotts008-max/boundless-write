import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/formatting_provider.dart';

class FormattingToolbar extends StatelessWidget {
  const FormattingToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FormattingProvider>(
      builder: (context, formattingProvider, child) {
        final formatting = formattingProvider.currentFormatting;
        return Container(
          color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.grey[100],
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Font Family Dropdown
                _FontFamilyDropdown(
                  currentFamily: formatting.fontFamily,
                  onChanged: formattingProvider.setFontFamily,
                ),
                const SizedBox(width: 8),

                // Font Size Dropdown
                _FontSizeDropdown(
                  currentSize: formatting.fontSize,
                  onChanged: formattingProvider.setFontSize,
                ),
                const SizedBox(width: 8),

                // Divider
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),

                // Bold Button
                _ToolbarIconButton(
                  icon: Icons.format_bold,
                  isActive: formatting.bold,
                  tooltip: 'Bold (Ctrl+B)',
                  onPressed: formattingProvider.toggleBold,
                ),

                // Italic Button
                _ToolbarIconButton(
                  icon: Icons.format_italic,
                  isActive: formatting.italic,
                  tooltip: 'Italic (Ctrl+I)',
                  onPressed: formattingProvider.toggleItalic,
                ),

                // Underline Button
                _ToolbarIconButton(
                  icon: Icons.format_underlined,
                  isActive: formatting.underline,
                  tooltip: 'Underline (Ctrl+U)',
                  onPressed: formattingProvider.toggleUnderline,
                ),

                // Strikethrough Button
                _ToolbarIconButton(
                  icon: Icons.strikethrough_s,
                  isActive: formatting.strikethrough,
                  tooltip: 'Strikethrough',
                  onPressed: formattingProvider.toggleStrikethrough,
                ),

                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),

                // Font Color Button
                _ColorButton(
                  icon: Icons.format_color_text,
                  tooltip: 'Font Color',
                  currentColor: formatting.fontColor,
                  onColorChanged: formattingProvider.setFontColor,
                ),

                // Background Color Button
                _ColorButton(
                  icon: Icons.format_color_fill,
                  tooltip: 'Highlight Color',
                  currentColor: formatting.backgroundColor,
                  onColorChanged: formattingProvider.setBackgroundColor,
                ),

                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),

                // Alignment Buttons
                _ToolbarIconButton(
                  icon: Icons.format_align_left,
                  isActive: formatting.alignment == TextAlign.left,
                  tooltip: 'Align Left',
                  onPressed: () => formattingProvider.setAlignment(TextAlign.left),
                ),

                _ToolbarIconButton(
                  icon: Icons.format_align_center,
                  isActive: formatting.alignment == TextAlign.center,
                  tooltip: 'Align Center',
                  onPressed: () => formattingProvider.setAlignment(TextAlign.center),
                ),

                _ToolbarIconButton(
                  icon: Icons.format_align_right,
                  isActive: formatting.alignment == TextAlign.right,
                  tooltip: 'Align Right',
                  onPressed: () => formattingProvider.setAlignment(TextAlign.right),
                ),

                _ToolbarIconButton(
                  icon: Icons.format_align_justify,
                  isActive: formatting.alignment == TextAlign.justify,
                  tooltip: 'Justify',
                  onPressed: () => formattingProvider.setAlignment(TextAlign.justify),
                ),

                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),

                // Heading Buttons
                _HeadingButton(
                  label: 'H1',
                  level: 1,
                  isActive: formatting.headingLevel == 1,
                  onPressed: () => formattingProvider.setHeadingLevel(1),
                ),
                _HeadingButton(
                  label: 'H2',
                  level: 2,
                  isActive: formatting.headingLevel == 2,
                  onPressed: () => formattingProvider.setHeadingLevel(2),
                ),
                _HeadingButton(
                  label: 'H3',
                  level: 3,
                  isActive: formatting.headingLevel == 3,
                  onPressed: () => formattingProvider.setHeadingLevel(3),
                ),

                const SizedBox(width: 8),

                // Clear Formatting Button
                _ToolbarIconButton(
                  icon: Icons.clear_all,
                  tooltip: 'Clear Formatting',
                  onPressed: formattingProvider.resetFormatting,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarIconButton({
    required this.icon,
    this.isActive = false,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        isSelected: isActive,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isActive ? Colors.blue.withOpacity(0.2) : null,
          foregroundColor: isActive ? Colors.blue : null,
        ),
      ),
    );
  }
}

class _HeadingButton extends StatelessWidget {
  final String label;
  final int level;
  final bool isActive;
  final VoidCallback onPressed;

  const _HeadingButton({
    required this.label,
    required this.level,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Heading $level',
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.blue.withOpacity(0.2) : null,
          foregroundColor: isActive ? Colors.blue : null,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _FontFamilyDropdown extends StatelessWidget {
  final String currentFamily;
  final Function(String) onChanged;

  const _FontFamilyDropdown({
    required this.currentFamily,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const families = ['Roboto', 'Times New Roman', 'Arial', 'Courier New', 'Georgia'];
    return DropdownButton<String>(
      value: currentFamily,
      items: families.map((family) {
        return DropdownMenuItem(
          value: family,
          child: Text(family),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      underline: Container(),
    );
  }
}

class _FontSizeDropdown extends StatelessWidget {
  final double currentSize;
  final Function(double) onChanged;

  const _FontSizeDropdown({
    required this.currentSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const sizes = [8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0];
    return DropdownButton<double>(
      value: currentSize,
      items: sizes.map((size) {
        return DropdownMenuItem(
          value: size,
          child: Text('${size.toInt()}'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      underline: Container(),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color currentColor;
  final Function(Color) onColorChanged;

  const _ColorButton({
    required this.icon,
    required this.tooltip,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PopupMenuButton<Color>(
        onSelected: onColorChanged,
        itemBuilder: (context) {
          const colors = [
            Colors.black,
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.yellow,
            Colors.orange,
            Colors.purple,
            Colors.pink,
            Colors.cyan,
            Colors.grey,
          ];
          return colors.map((color) {
            return PopupMenuItem(
              value: color,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  border: currentColor == color ? Border.all(width: 2) : null,
                ),
              ),
            );
          }).toList();
        },
        child: Icon(icon),
      ),
    );
  }
}
