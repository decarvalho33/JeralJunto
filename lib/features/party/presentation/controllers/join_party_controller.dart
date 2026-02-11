import 'package:flutter/foundation.dart';

import '../../../../core/utils/input_formatters.dart';
import '../../domain/models/party.dart';
import '../../domain/repositories/party_repository.dart';
import '../../domain/usecases/get_party_by_code.dart';
import '../../domain/usecases/join_party.dart';

class JoinPartyController extends ChangeNotifier {
  JoinPartyController({required PartyRepository repository})
      : _getPartyByCode = GetPartyByCode(repository),
        _joinParty = JoinParty(repository);

  final GetPartyByCode _getPartyByCode;
  final JoinParty _joinParty;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Party?> submit(String code) async {
    final normalized = normalizeJoinCode(code);
    if (normalized.length != 6) {
      _errorMessage = 'Código inválido';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final party = await _getPartyByCode(normalized);
      if (party == null) {
        _errorMessage = 'Código inválido';
        return null;
      }
      await _joinParty(party.id);
      return party;
    } catch (_) {
      _errorMessage = 'Não foi possível entrar na party';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
