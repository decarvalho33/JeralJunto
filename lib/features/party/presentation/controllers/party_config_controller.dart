import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';

import '../../data/party_config_service.dart';
import '../../data/party_members_service.dart';
import '../../domain/models/party_config.dart';
import '../../domain/models/party_member_item.dart';

class PartyConfigController extends ChangeNotifier {
  PartyConfigController({
    PartyConfigService? service,
    PartyMembersService? membersService,
  })  : _service = service ?? PartyConfigService(),
        _membersService = membersService ?? PartyMembersService();

  final PartyConfigService _service;
  final PartyMembersService _membersService;

  PartyConfigData? _config;
  List<PartyMemberItem> _members = const [];
  int? _partyId;

  bool _isLoadingConfig = false;
  bool _isLoadingMembers = false;
  bool _isSavingName = false;
  bool _isRotatingCode = false;
  bool _isTogglingRequiresApproval = false;
  bool _isTogglingLocation = false;
  bool _isEndingParty = false;
  bool _isTransferringCreator = false;
  String? _lastActionError;
  String? _errorMessage;
  String? _membersError;
  final Set<String> _memberMutations = <String>{};

  PartyConfigData? get config => _config;
  List<PartyMemberItem> get members => _members;
  bool get isLoadingConfig => _isLoadingConfig;
  bool get isLoadingMembers => _isLoadingMembers;
  bool get isSavingName => _isSavingName;
  bool get isRotatingCode => _isRotatingCode;
  bool get isTogglingRequiresApproval => _isTogglingRequiresApproval;
  bool get isTogglingLocation => _isTogglingLocation;
  bool get isEndingParty => _isEndingParty;
  bool get isTransferringCreator => _isTransferringCreator;
  String? get lastActionError => _lastActionError;
  String? get errorMessage => _errorMessage;
  String? get membersError => _membersError;

  bool isMemberBusy(String userId) => _memberMutations.contains(userId);

  Future<void> load(int partyId) async {
    _partyId = partyId;
    _errorMessage = null;
    _membersError = null;
    _isLoadingConfig = true;
    _isLoadingMembers = true;
    notifyListeners();

    try {
      _config = await _service.fetchConfig(partyId: partyId);
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os dados da party.';
    } finally {
      _isLoadingConfig = false;
      notifyListeners();
    }

    await _loadMembers(partyId);
  }

  Future<void> refreshMembers() async {
    final partyId = _partyId;
    if (partyId == null) {
      return;
    }
    await _loadMembers(partyId);
  }

  Future<void> _loadMembers(int partyId) async {
    _membersError = null;
    _isLoadingMembers = true;
    notifyListeners();

    try {
      _members = await _membersService.fetchActiveMembers(partyId);
    } catch (_) {
      _membersError = 'Não foi possível carregar os membros.';
      _members = const [];
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  Future<bool> updateName(String name) async {
    final config = _config;
    final partyId = _partyId;
    if (config == null || partyId == null || _isSavingName) {
      return false;
    }
    _isSavingName = true;
    notifyListeners();

    try {
      await _service.updatePartyName(partyId: partyId, name: name);
      _config = config.copyWith(name: name);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSavingName = false;
      notifyListeners();
    }
  }

  Future<String?> rotateJoinCode() async {
    final config = _config;
    final partyId = _partyId;
    if (config == null || partyId == null || _isRotatingCode) {
      return null;
    }
    _lastActionError = null;
    _isRotatingCode = true;
    notifyListeners();

    try {
      final code = await _service.rotateJoinCode(partyId: partyId);
      _config = config.copyWith(joinCode: code.toUpperCase());
      return code;
    } catch (error) {
      if (error is PostgrestException) {
        _lastActionError = error.message;
      } else {
        _lastActionError = error.toString();
      }
      return null;
    } finally {
      _isRotatingCode = false;
      notifyListeners();
    }
  }

  Future<bool> setRequiresApproval(bool value) async {
    final config = _config;
    final partyId = _partyId;
    if (config == null || partyId == null || _isTogglingRequiresApproval) {
      return false;
    }

    _isTogglingRequiresApproval = true;
    _config = config.copyWith(requiresApproval: value);
    notifyListeners();

    try {
      await _service.setRequiresApproval(partyId: partyId, requires: value);
      return true;
    } catch (_) {
      _config = config.copyWith(requiresApproval: !value);
      return false;
    } finally {
      _isTogglingRequiresApproval = false;
      notifyListeners();
    }
  }

  Future<bool> setLocationSharing(bool value) async {
    final config = _config;
    final partyId = _partyId;
    if (config == null || partyId == null || _isTogglingLocation) {
      return false;
    }

    _isTogglingLocation = true;
    _config = config.copyWith(locationSharingEnabled: value);
    notifyListeners();

    try {
      await _service.setLocationSharing(partyId: partyId, enabled: value);
      return true;
    } catch (_) {
      _config = config.copyWith(locationSharingEnabled: !value);
      return false;
    } finally {
      _isTogglingLocation = false;
      notifyListeners();
    }
  }

  Future<bool> endParty() async {
    final partyId = _partyId;
    if (partyId == null || _isEndingParty) {
      return false;
    }
    _isEndingParty = true;
    notifyListeners();

    try {
      await _service.endParty(partyId: partyId);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isEndingParty = false;
      notifyListeners();
    }
  }

  Future<bool> promote(String userId) async {
    return _setMemberRole(userId, 'admin');
  }

  Future<bool> demote(String userId) async {
    return _setMemberRole(userId, 'user');
  }

  Future<bool> _setMemberRole(String userId, String role) async {
    final partyId = _partyId;
    if (partyId == null || _memberMutations.contains(userId)) {
      return false;
    }
    _memberMutations.add(userId);
    notifyListeners();

    try {
      await _service.setMemberRole(
        partyId: partyId,
        userId: userId,
        newRole: role,
      );
      _members = _members
          .map(
            (member) => member.userId == userId
                ? member.copyWith(role: role)
                : member,
          )
          .toList();
      return true;
    } catch (_) {
      return false;
    } finally {
      _memberMutations.remove(userId);
      notifyListeners();
    }
  }

  Future<bool> transferCreator(String userId) async {
    final partyId = _partyId;
    if (partyId == null || _isTransferringCreator) {
      return false;
    }
    _isTransferringCreator = true;
    notifyListeners();

    try {
      await _service.transferCreator(
        partyId: partyId,
        newCreatorUserId: userId,
      );
      await load(partyId);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isTransferringCreator = false;
      notifyListeners();
    }
  }
}
