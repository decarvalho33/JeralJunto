import 'package:flutter/foundation.dart';

import '../../domain/models/party.dart';
import '../../domain/models/party_member.dart';
import '../../domain/usecases/get_current_party_for_user.dart';
import '../../domain/usecases/get_party_by_id.dart';
import '../../domain/usecases/get_party_members.dart';
import '../../domain/repositories/party_repository.dart';

class PartyController extends ChangeNotifier {
  PartyController({required PartyRepository repository})
      : _getPartyById = GetPartyById(repository),
        _getCurrentParty = GetCurrentPartyForUser(repository),
        _getMembers = GetPartyMembers(repository);

  final GetPartyById _getPartyById;
  final GetCurrentPartyForUser _getCurrentParty;
  final GetPartyMembers _getMembers;

  Party? _party;
  List<PartyMember> _members = const [];
  bool _isLoading = false;
  String? _errorMessage;

  Party? get party => _party;
  List<PartyMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({int? partyId, Party? party}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (party != null) {
        _party = party;
      } else if (partyId != null) {
        _party = await _getPartyById(partyId);
      } else {
        _party = await _getCurrentParty();
      }

      if (_party != null) {
        _members = await _getMembers(_party!.id);
      } else {
        _members = const [];
      }
    } catch (error) {
      _errorMessage = 'Não foi possível carregar a party.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMembers() async {
    final party = _party;
    if (party == null) {
      return;
    }
    try {
      _members = await _getMembers(party.id);
      notifyListeners();
    } catch (_) {
      // keep existing members
    }
  }
}
