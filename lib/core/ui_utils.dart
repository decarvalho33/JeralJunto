bool isValidEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) {
    return false;
  }
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}

String onlyDigits(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}
