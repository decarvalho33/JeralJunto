import '../models/party.dart';
import '../models/party_member.dart';

abstract class PartyRepository {
  Future<Party> getPartyById(int partyId);
  Future<Party?> getPartyByCode(String code);
  Future<void> joinParty(int partyId);
  Future<List<PartyMember>> getMembers(int partyId);
  Future<Party?> getCurrentPartyForUser();
}
