import 'input_formatters.dart';

class PendingPartyInvite {
  PendingPartyInvite._();

  static String? _joinCode;

  static void set(String joinCode) {
    final normalized = normalizeJoinCode(joinCode);
    if (normalized.length != 6) {
      return;
    }
    _joinCode = normalized;
  }

  static String? consume() {
    final code = _joinCode;
    _joinCode = null;
    return code;
  }

  static String? peek() {
    return _joinCode;
  }

  static void clear() {
    _joinCode = null;
  }
}
