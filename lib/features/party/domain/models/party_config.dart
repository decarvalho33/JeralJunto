import '../../../../core/utils/input_formatters.dart';

class PartyConfigData {
  const PartyConfigData({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.createdAt,
    required this.creatorId,
    this.creatorName,
    required this.memberCount,
    required this.requiresApproval,
    required this.locationSharingEnabled,
    required this.myRole,
    required this.myStatus,
    required this.isAdmin,
    required this.isCreator,
    required this.canEditName,
    required this.canEndParty,
    required this.canRotateCode,
    required this.canManageMembers,
    required this.canTransferCreator,
  });

  final int id;
  final String name;
  final String joinCode;
  final DateTime createdAt;
  final String creatorId;
  final String? creatorName;
  final int memberCount;
  final bool requiresApproval;
  final bool locationSharingEnabled;
  final String myRole;
  final String myStatus;
  final bool isAdmin;
  final bool isCreator;
  final bool canEditName;
  final bool canEndParty;
  final bool canRotateCode;
  final bool canManageMembers;
  final bool canTransferCreator;

  factory PartyConfigData.fromRpc(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    return PartyConfigData(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      joinCode: normalizeJoinCode(json['join_code']?.toString() ?? ''),
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
      creatorId: json['creator_id']?.toString() ?? '',
      creatorName: json['creator_name']?.toString(),
      memberCount: _parseInt(json['member_count']),
      requiresApproval: _parseBool(json['requires_approval']),
      locationSharingEnabled: _parseBool(json['location_sharing_enabled']),
      myRole: json['my_role']?.toString() ?? 'user',
      myStatus: json['my_status']?.toString() ?? 'active',
      isAdmin: _parseBool(json['is_admin']),
      isCreator: _parseBool(json['is_creator']),
      canEditName: _parseBool(json['can_edit_name']),
      canEndParty: _parseBool(json['can_end_party']),
      canRotateCode: _parseBool(json['can_rotate_code']),
      canManageMembers: _parseBool(json['can_manage_members']),
      canTransferCreator: _parseBool(json['can_transfer_creator']),
    );
  }

  PartyConfigData copyWith({
    String? name,
    String? joinCode,
    String? creatorName,
    int? memberCount,
    bool? requiresApproval,
    bool? locationSharingEnabled,
    bool? canEditName,
    bool? canEndParty,
    bool? canRotateCode,
    bool? canManageMembers,
    bool? canTransferCreator,
    bool? isAdmin,
    bool? isCreator,
    String? myRole,
    String? myStatus,
  }) {
    return PartyConfigData(
      id: id,
      name: name ?? this.name,
      joinCode: joinCode ?? this.joinCode,
      createdAt: createdAt,
      creatorId: creatorId,
      creatorName: creatorName ?? this.creatorName,
      memberCount: memberCount ?? this.memberCount,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      locationSharingEnabled:
          locationSharingEnabled ?? this.locationSharingEnabled,
      myRole: myRole ?? this.myRole,
      myStatus: myStatus ?? this.myStatus,
      isAdmin: isAdmin ?? this.isAdmin,
      isCreator: isCreator ?? this.isCreator,
      canEditName: canEditName ?? this.canEditName,
      canEndParty: canEndParty ?? this.canEndParty,
      canRotateCode: canRotateCode ?? this.canRotateCode,
      canManageMembers: canManageMembers ?? this.canManageMembers,
      canTransferCreator: canTransferCreator ?? this.canTransferCreator,
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return false;
}
