import '../../../../core/utils/input_formatters.dart';
import '../../domain/models/party.dart';
import '../../domain/models/party_member.dart';
import '../../domain/repositories/party_repository.dart';
import '../datasources/party_remote_data_source.dart';

class PartyRepositoryImpl implements PartyRepository {
  PartyRepositoryImpl({PartyRemoteDataSource? remoteDataSource})
      : _remote = remoteDataSource ?? PartyRemoteDataSource();

  final PartyRemoteDataSource _remote;

  @override
  Future<Party> getPartyById(int partyId) async {
    final response = await _remote.fetchPartyById(partyId);
    if (response == null) {
      throw StateError('Party não encontrada');
    }
    return Party.fromJson(response);
  }

  @override
  Future<Party?> getPartyByCode(String code) async {
    final normalized = normalizeJoinCode(code);
    if (normalized.length != 6) {
      return null;
    }
    final response = await _remote.fetchPartyByCode(normalized);
    if (response == null) {
      return null;
    }
    return Party.fromJson(response);
  }

  @override
  Future<void> joinParty(int partyId) {
    return _remote.joinParty(partyId);
  }

  @override
  Future<List<PartyMember>> getMembers(int partyId) async {
    final response = await _remote.fetchMembers(partyId);
    return response.map(PartyMember.fromJson).toList();
  }

  @override
  Future<Party?> getCurrentPartyForUser() async {
    final userId = _remote.getCurrentUserId();
    if (userId == null) {
      throw StateError('Usuário não autenticado');
    }
    final partyId = await _remote.fetchLatestPartyIdForUser(userId);
    if (partyId == null) {
      return null;
    }
    final response = await _remote.fetchPartyById(partyId);
    if (response == null) {
      return null;
    }
    return Party.fromJson(response);
  }
}
