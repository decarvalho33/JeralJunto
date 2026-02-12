import 'package:flutter/services.dart';

String normalizeJoinCode(String input) {
  final upper = input.toUpperCase();
  final filtered = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (filtered.length <= 6) {
    return filtered;
  }
  return filtered.substring(0, 6);
}

class JoinCodeInputFormatter extends TextInputFormatter {
  const JoinCodeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeJoinCode(newValue.text);
    final selectionIndex = normalized.length;
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty,
    );
  }
}
