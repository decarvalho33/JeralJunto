import '../repositories/party_repository.dart';

class SwitchToParty {
  const SwitchToParty(this._repository);

  final PartyRepository _repository;

  Future<void> call(int partyId) {
    return _repository.switchToParty(partyId);
  }
}
