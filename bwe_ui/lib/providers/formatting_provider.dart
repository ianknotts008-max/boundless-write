import 'package:flutter/material.dart';

class TextFormatting {
  bool bold = false;
  bool italic = false;
  bool underline = false;
  bool strikethrough = false;
  String fontFamily = 'Roboto';
  double fontSize = 12.0;
  Color fontColor = Colors.black;
  Color backgroundColor = Colors.transparent;
  TextAlign alignment = TextAlign.left;
  int headingLevel = 0; // 0 = normal, 1-6 = heading levels

  TextFormatting({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.fontFamily = 'Roboto',
    this.fontSize = 12.0,
    this.fontColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.alignment = TextAlign.left,
    this.headingLevel = 0,
  });

  TextFormatting copy() {
    return TextFormatting(
      bold: bold,
      italic: italic,
      underline: underline,
      strikethrough: strikethrough,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      alignment: alignment,
      headingLevel: headingLevel,
    );
  }

  TextStyle toTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: fontColor,
      backgroundColor: backgroundColor,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: strikethrough ? TextDecoration.lineThrough :
                   underline ? TextDecoration.underline : TextDecoration.none,
    );
  }
}

class FormattingProvider extends ChangeNotifier {
  TextFormatting _currentFormatting = TextFormatting();

  TextFormatting get currentFormatting => _currentFormatting;

  void toggleBold() {
    _currentFormatting.bold = !_currentFormatting.bold;
    notifyListeners();
  }

  void toggleItalic() {
    _currentFormatting.italic = !_currentFormatting.italic;
    notifyListeners();
  }

  void toggleUnderline() {
    _currentFormatting.underline = !_currentFormatting.underline;
    notifyListeners();
  }

  void toggleStrikethrough() {
    _currentFormatting.strikethrough = !_currentFormatting.strikethrough;
    notifyListeners();
  }

  void setFontSize(double size) {
    _currentFormatting.fontSize = size;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _currentFormatting.fontFamily = family;
    notifyListeners();
  }

  void setFontColor(Color color) {
    _currentFormatting.fontColor = color;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _currentFormatting.backgroundColor = color;
    notifyListeners();
  }

  void setAlignment(TextAlign alignment) {
    _currentFormatting.alignment = alignment;
    notifyListeners();
  }

  void setHeadingLevel(int level) {
    _currentFormatting.headingLevel = level;
    if (level > 0) {
      _currentFormatting.fontSize = (24.0 - (level * 2)).clamp(14.0, 32.0);
      _currentFormatting.bold = true;
    } else {
      _currentFormatting.fontSize = 12.0;
      _currentFormatting.bold = false;
    }
    notifyListeners();
  }

  void resetFormatting() {
    _currentFormatting = TextFormatting();
    notifyListeners();
  }
}
