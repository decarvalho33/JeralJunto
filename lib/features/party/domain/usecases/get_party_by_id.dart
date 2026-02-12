import '../models/party.dart';
import '../repositories/party_repository.dart';

class GetPartyById {
  const GetPartyById(this._repository);

  final PartyRepository _repository;

  Future<Party> call(int partyId) {
    return _repository.getPartyById(partyId);
  }
}
