import '../models/party.dart';
import '../repositories/party_repository.dart';

class GetPartyByCode {
  const GetPartyByCode(this._repository);

  final PartyRepository _repository;

  Future<Party?> call(String code) {
    return _repository.getPartyByCode(code);
  }
}
