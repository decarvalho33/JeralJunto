import 'package:flutter/foundation.dart';

import '../../../../core/utils/input_formatters.dart';
import '../../domain/models/party.dart';
import '../../domain/repositories/party_repository.dart';
import '../../domain/usecases/get_current_party_for_user.dart';
import '../../domain/usecases/get_party_by_code.dart';
import '../../domain/usecases/join_party.dart';
import '../../domain/usecases/switch_to_party.dart';

class JoinPartyController extends ChangeNotifier {
  JoinPartyController({required PartyRepository repository})
    : _getPartyByCode = GetPartyByCode(repository),
      _joinParty = JoinParty(repository),
      _switchToParty = SwitchToParty(repository),
      _getCurrentParty = GetCurrentPartyForUser(repository);

  final GetPartyByCode _getPartyByCode;
  final JoinParty _joinParty;
  final SwitchToParty _switchToParty;
  final GetCurrentPartyForUser _getCurrentParty;

  bool _isLoading = false;
  String? _errorMessage;
  Party? _currentPartyConflict;
  Party? _targetPartyConflict;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Party? get currentPartyConflict => _currentPartyConflict;
  Party? get targetPartyConflict => _targetPartyConflict;
  bool get hasPartyConflict =>
      _currentPartyConflict != null && _targetPartyConflict != null;

  Future<Party?> submit(String code) async {
    final normalized = normalizeJoinCode(code);
    if (normalized.length != 6) {
      _errorMessage = 'Código inválido';
      _clearConflict();
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _clearConflict();
    notifyListeners();

    try {
      final party = await _getPartyByCode(normalized);
      if (party == null) {
        _errorMessage = 'Código inválido';
        return null;
      }
      if (party.requiresApproval) {
        _errorMessage = 'Esta party exige aprovação de um administrador';
        return null;
      }

      final currentParty = await _getCurrentParty();
      if (currentParty != null && currentParty.id != party.id) {
        _currentPartyConflict = currentParty;
        _targetPartyConflict = party;
        _errorMessage = 'Você já está em uma party.';
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

  Future<Party?> confirmSwitchAndJoin() async {
    final targetParty = _targetPartyConflict;
    if (targetParty == null) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _switchToParty(targetParty.id);
      _clearConflict();
      return targetParty;
    } catch (_) {
      _errorMessage = 'Não foi possível trocar de party';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearConflict() {
    _currentPartyConflict = null;
    _targetPartyConflict = null;
  }
}
