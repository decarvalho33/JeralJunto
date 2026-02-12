import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/core/utils/party_invite.dart';

void main() {
  test('buildPartyInviteLink cria URL local com código normalizado', () {
    final link = buildPartyInviteLink('ab-12c3');

    expect(link, 'http://localhost:3000/join?code=AB12C3');
  });

  test('extractJoinCodeFromInviteUri retorna null para código inválido', () {
    final uri = Uri.parse('http://localhost:3000/join?code=abc');

    expect(extractJoinCodeFromInviteUri(uri), isNull);
  });

  test('isJoinPartyUri aceita rota com barra final', () {
    final uri = Uri.parse('http://localhost:3000/join/?code=ABC123');

    expect(isJoinPartyUri(uri), isTrue);
  });
}
