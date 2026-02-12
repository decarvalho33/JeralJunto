import 'input_formatters.dart';

const String _inviteScheme = 'http';
const String _inviteHost = 'localhost';
const int _invitePort = 3000;
const String _invitePath = '/join';

String buildPartyInviteLink(String joinCode) {
  final normalizedCode = normalizeJoinCode(joinCode);
  final queryParameters = normalizedCode.isEmpty
      ? null
      : <String, String>{'code': normalizedCode};
  return Uri(
    scheme: _inviteScheme,
    host: _inviteHost,
    port: _invitePort,
    path: _invitePath,
    queryParameters: queryParameters,
  ).toString();
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
