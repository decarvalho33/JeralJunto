import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/features/party/domain/models/party.dart';
import 'package:jeraljunto/features/party/domain/models/party_member.dart';

void main() {
  test('Party.fromJson parses and normalizes join code', () {
    final party = Party.fromJson({
      'id': 10,
      'nome': 'Bloco',
      'join_code': 'ab12c3',
      'created_at': '2025-01-01T12:00:00Z',
      'idCriador': 'user-1',
    });

    expect(party.id, 10);
    expect(party.nome, 'Bloco');
    expect(party.joinCode, 'AB12C3');
    expect(party.idCriador, 'user-1');
  });

  test('PartyMember.fromJson parses nested user fields', () {
    final member = PartyMember.fromJson({
      'idUsuario': 'user-2',
      'idParty': 5,
      'cargo': 'admin',
      'created_at': '2025-01-02T12:00:00Z',
      'Usuario': {
        'nome': 'Ana',
        'avatar_url': 'https://example.com/avatar.png',
      },
    });

    expect(member.idUsuario, 'user-2');
    expect(member.idParty, 5);
    expect(member.cargo, 'admin');
    expect(member.displayName, 'Ana');
    expect(member.avatarUrl, 'https://example.com/avatar.png');
  });
}
