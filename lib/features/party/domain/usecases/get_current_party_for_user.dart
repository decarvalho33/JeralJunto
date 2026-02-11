import '../models/party.dart';
import '../repositories/party_repository.dart';

class GetCurrentPartyForUser {
  const GetCurrentPartyForUser(this._repository);

  final PartyRepository _repository;

  Future<Party?> call() {
    return _repository.getCurrentPartyForUser();
  }
}
