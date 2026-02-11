import 'package:flutter/foundation.dart';

import '../../domain/models/party_config.dart';
import '../../domain/models/party_member_item.dart';
import 'party_config_controller.dart';

class PartyConfigViewModel extends ChangeNotifier {
  PartyConfigViewModel({PartyConfigController? controller})
      : _controller = controller ?? PartyConfigController() {
    _controller.addListener(_handleControllerChange);
  }

  final PartyConfigController _controller;

  PartyConfigData? _baseConfig;
  String _draftName = '';
  bool _draftRequiresApproval = false;
  bool _draftLocationSharing = false;
  bool _isApplyingChanges = false;
  bool _shouldSyncName = false;

  PartyConfigData? get config => _controller.config;
  List<PartyMemberItem> get members => _controller.members;
  bool get isLoadingConfig => _controller.isLoadingConfig;
  bool get isLoadingMembers => _controller.isLoadingMembers;
  bool get isRotatingCode => _controller.isRotatingCode;
  bool get isTransferringCreator => _controller.isTransferringCreator;
  String? get lastActionError => _controller.lastActionError;
  String? get errorMessage => _controller.errorMessage;
  String? get membersError => _controller.membersError;

  bool get isApplyingChanges => _isApplyingChanges;

  String get draftName => _draftName;
  bool get draftRequiresApproval => _draftRequiresApproval;
  bool get draftLocationSharing => _draftLocationSharing;

  bool get isDirty {
    final base = _baseConfig;
    if (base == null) {
      return false;
    }
    return _draftName.trim() != base.name.trim() ||
        _draftRequiresApproval != base.requiresApproval ||
        _draftLocationSharing != base.locationSharingEnabled;
  }

  bool consumeShouldSyncName() {
    if (_shouldSyncName) {
      _shouldSyncName = false;
      return true;
    }
    return false;
  }

  bool isMemberBusy(String userId) => _controller.isMemberBusy(userId);

  Future<void> load(int partyId) async {
    await _controller.load(partyId);
  }

  Future<void> refreshMembers() => _controller.refreshMembers();

  void updateDraftName(String value) {
    _draftName = value;
    notifyListeners();
  }

  void updateDraftRequiresApproval(bool value) {
    _draftRequiresApproval = value;
    notifyListeners();
  }

  void updateDraftLocationSharing(bool value) {
    _draftLocationSharing = value;
    notifyListeners();
  }

  Future<bool> applyChanges() async {
    final base = _baseConfig;
    if (base == null || _isApplyingChanges) {
      return false;
    }

    _isApplyingChanges = true;
    notifyListeners();

    var ok = true;
    final trimmedName = _draftName.trim();

    if (trimmedName.isNotEmpty && trimmedName != base.name.trim()) {
      final nameOk = await _controller.updateName(trimmedName);
      ok = ok && nameOk;
    }

    if (_draftRequiresApproval != base.requiresApproval) {
      final toggleOk =
          await _controller.setRequiresApproval(_draftRequiresApproval);
      ok = ok && toggleOk;
    }

    if (_draftLocationSharing != base.locationSharingEnabled) {
      final toggleOk =
          await _controller.setLocationSharing(_draftLocationSharing);
      ok = ok && toggleOk;
    }

    if (ok) {
      final updated = _controller.config;
      if (updated != null) {
        _baseConfig = updated;
        _draftName = updated.name;
        _draftRequiresApproval = updated.requiresApproval;
        _draftLocationSharing = updated.locationSharingEnabled;
        _shouldSyncName = true;
      }
    }

    _isApplyingChanges = false;
    notifyListeners();
    return ok;
  }

  Future<String?> rotateJoinCode() => _controller.rotateJoinCode();

  Future<bool> endParty() => _controller.endParty();

  Future<bool> promote(String userId) => _controller.promote(userId);

  Future<bool> demote(String userId) => _controller.demote(userId);

  Future<bool> transferCreator(String userId) =>
      _controller.transferCreator(userId);

  void _handleControllerChange() {
    final config = _controller.config;
    if (config == null) {
      _baseConfig = null;
    } else {
      final wasDirty = isDirty;
      _baseConfig = config;
      if (!wasDirty) {
        _draftName = config.name;
        _draftRequiresApproval = config.requiresApproval;
        _draftLocationSharing = config.locationSharingEnabled;
        _shouldSyncName = true;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    super.dispose();
  }
}
