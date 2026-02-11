import '../models/party_member.dart';
import '../repositories/party_repository.dart';

class GetPartyMembers {
  const GetPartyMembers(this._repository);

  final PartyRepository _repository;

  Future<List<PartyMember>> call(int partyId) {
    return _repository.getMembers(partyId);
  }
}
