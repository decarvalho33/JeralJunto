import '../repositories/party_repository.dart';

class JoinParty {
  const JoinParty(this._repository);

  final PartyRepository _repository;

  Future<void> call(int partyId) {
    return _repository.joinParty(partyId);
  }
}
