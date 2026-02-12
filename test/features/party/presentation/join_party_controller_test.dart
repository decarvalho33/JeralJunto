import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/features/party/domain/models/party.dart';
import 'package:jeraljunto/features/party/domain/models/party_member.dart';
import 'package:jeraljunto/features/party/domain/repositories/party_repository.dart';
import 'package:jeraljunto/features/party/presentation/controllers/join_party_controller.dart';

class _FakePartyRepository implements PartyRepository {
  _FakePartyRepository({this.partyByCode});

  Party? partyByCode;
  int joinCalls = 0;

  @override
  Future<Party?> getPartyByCode(String code) async => partyByCode;

  @override
  Future<Party> getPartyById(int partyId) {
    throw UnimplementedError();
  }

  @override
  Future<Party?> getCurrentPartyForUser() {
    throw UnimplementedError();
  }

  @override
  Future<List<PartyMember>> getMembers(int partyId) async => const [];

  @override
  Future<void> joinParty(int partyId) async {
    joinCalls += 1;
  }
}

Party _party({required bool requiresApproval}) {
  return Party(
    id: 12,
    nome: 'Party Teste',
    joinCode: 'ABC123',
    requiresApproval: requiresApproval,
    createdAt: DateTime.parse('2025-01-01T00:00:00Z'),
    idCriador: 'user-1',
  );
}

void main() {
  test('bloqueia entrada automática quando party exige aprovação', () async {
    final repository = _FakePartyRepository(
      partyByCode: _party(requiresApproval: true),
    );
    final controller = JoinPartyController(repository: repository);

    final result = await controller.submit('abc123');

    expect(result, isNull);
    expect(
      controller.errorMessage,
      'Esta party exige aprovação de um administrador',
    );
    expect(repository.joinCalls, 0);
  });

  test('entra automaticamente quando party não exige aprovação', () async {
    final repository = _FakePartyRepository(
      partyByCode: _party(requiresApproval: false),
    );
    final controller = JoinPartyController(repository: repository);

    final result = await controller.submit('abc123');

    expect(result, isNotNull);
    expect(result!.id, 12);
    expect(controller.errorMessage, isNull);
    expect(repository.joinCalls, 1);
  });
}
