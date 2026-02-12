import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/features/party/domain/models/party.dart';
import 'package:jeraljunto/features/party/domain/models/party_member.dart';
import 'package:jeraljunto/features/party/domain/repositories/party_repository.dart';
import 'package:jeraljunto/features/party/presentation/pages/join_party_screen.dart';

class FakePartyRepository implements PartyRepository {
  @override
  Future<Party?> getPartyByCode(String code) async {
    return null;
  }

  @override
  Future<Party> getPartyById(int partyId) {
    throw UnimplementedError();
  }

  @override
  Future<Party?> getCurrentPartyForUser() async {
    return null;
  }

  @override
  Future<List<PartyMember>> getMembers(int partyId) async {
    return const [];
  }

  @override
  Future<void> joinParty(int partyId) async {}

  @override
  Future<void> switchToParty(int partyId) async {}
}

void main() {
  testWidgets('Join button enabled only with 6 chars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: JoinPartyScreen(repository: FakePartyRepository())),
    );

    final joinButton = find.widgetWithText(ElevatedButton, 'Entrar');
    ElevatedButton buttonWidget = tester.widget(joinButton);
    expect(buttonWidget.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'abc123');
    await tester.pump();

    buttonWidget = tester.widget(joinButton);
    expect(buttonWidget.onPressed, isNotNull);
  });
}
