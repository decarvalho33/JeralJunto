import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/core/utils/pending_party_invite.dart';

void main() {
  tearDown(PendingPartyInvite.clear);

  test('guarda apenas código válido e normalizado', () {
    PendingPartyInvite.set('ab-12c3');

    expect(PendingPartyInvite.consume(), 'AB12C3');
  });

  test('ignora código inválido', () {
    PendingPartyInvite.set('abc');

    expect(PendingPartyInvite.consume(), isNull);
  });
}
