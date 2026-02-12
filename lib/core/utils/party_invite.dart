import 'input_formatters.dart';

const String _inviteHost = 'jeraljunto.app.br';
const String _invitePath = '/join';

String buildPartyInviteLink(String joinCode) {
  final normalizedCode = normalizeJoinCode(joinCode);
  final queryParameters = normalizedCode.isEmpty
      ? null
      : <String, String>{'code': normalizedCode};
  return Uri.https(_inviteHost, _invitePath, queryParameters).toString();
}

String? extractJoinCodeFromInviteUri(Uri uri) {
  final code = normalizeJoinCode(uri.queryParameters['code'] ?? '');
  if (code.length != 6) {
    return null;
  }
  return code;
}

bool isJoinPartyUri(Uri uri) {
  final path = _normalizePath(uri.path);
  return path == _invitePath;
}

String _normalizePath(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}
