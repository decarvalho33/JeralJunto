import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/features/party/domain/models/party.dart';
import 'package:jeraljunto/features/party/domain/models/party_member.dart';
import 'package:jeraljunto/features/party/domain/repositories/party_repository.dart';
import 'package:jeraljunto/features/party/presentation/controllers/join_party_controller.dart';

class _FakePartyRepository implements PartyRepository {
  _FakePartyRepository({this.partyByCode, this.currentParty});

  Party? partyByCode;
  Party? currentParty;
  int joinCalls = 0;
  int switchCalls = 0;

  @override
  Future<Party?> getPartyByCode(String code) async => partyByCode;

  @override
  Future<Party> getPartyById(int partyId) {
    throw UnimplementedError();
  }

  @override
  Future<Party?> getCurrentPartyForUser() {
    return Future.value(currentParty);
  }

  @override
  Future<List<PartyMember>> getMembers(int partyId) async => const [];

  @override
  Future<void> joinParty(int partyId) async {
    joinCalls += 1;
  }

  @override
  Future<void> switchToParty(int partyId) async {
    switchCalls += 1;
  }
}

Party _party({required bool requiresApproval, int id = 12}) {
  return Party(
    id: id,
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

  test('pede confirmação quando usuário já está em outra party', () async {
    final repository = _FakePartyRepository(
      partyByCode: _party(requiresApproval: false),
      currentParty: _party(requiresApproval: false, id: 99),
    );
    final controller = JoinPartyController(repository: repository);

    final result = await controller.submit('abc123');

    expect(result, isNull);
    expect(controller.hasPartyConflict, isTrue);
    expect(controller.currentPartyConflict?.id, 99);
    expect(controller.targetPartyConflict?.id, 12);
    expect(repository.joinCalls, 0);
  });

  test('troca de party quando confirmação é aceita', () async {
    final repository = _FakePartyRepository(
      partyByCode: _party(requiresApproval: false),
      currentParty: _party(requiresApproval: false, id: 99),
    );
    final controller = JoinPartyController(repository: repository);

    await controller.submit('abc123');
    final result = await controller.confirmSwitchAndJoin();

    expect(result, isNotNull);
    expect(result?.id, 12);
    expect(controller.hasPartyConflict, isFalse);
    expect(repository.switchCalls, 1);
    expect(repository.joinCalls, 0);
  });
}
