import 'package:flutter/services.dart';

class CardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    var newText = "";
    for (var i = 0; i < text.length; i++) {
      newText += text[i];
      if ((i + 1) % 4 == 0 && (i + 1) != text.length) {
        newText += " ";
      }
    }
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}