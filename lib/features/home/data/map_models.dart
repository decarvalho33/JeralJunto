import 'package:flutter/foundation.dart';

@immutable
class MemberInfo {
  const MemberInfo({required this.id, required this.name, this.avatarUrl});

  final String id;
  final String name;
  final String? avatarUrl;

  factory MemberInfo.fromUsuarioRow(Map<String, dynamic> row) {
    final avatar = (row['avatar_url'] as String?)?.trim();
    return MemberInfo(
      id: (row['id'] as String?) ?? '',
      name: (row['nome'] as String?) ?? 'Sem nome',
      avatarUrl: (avatar == null || avatar.isEmpty) ? null : avatar,
    );
  }
}

@immutable
class MemberLocation {
  const MemberLocation({
    required this.userId,
    required this.lat,
    required this.lng,
    required this.updatedAt,
    this.batteryHealth,
  });

  final String userId;
  final double lat;
  final double lng;
  final DateTime updatedAt;
  final int? batteryHealth;

  factory MemberLocation.fromViewRow(Map<String, dynamic> row) {
    final rawUpdatedAt = row['ultimaAtt'] ?? row['ultimaatt'];
    final rawUserId = row['idUsuario'] ?? row['idusuario'];
    final rawBattery = row['saudeBateria'] ?? row['saudebateria'];
    final updatedAtText = rawUpdatedAt is String
        ? rawUpdatedAt
        : '$rawUpdatedAt';
    return MemberLocation(
      userId: (rawUserId as String?) ?? '',
      lat: (row['lat'] as num?)?.toDouble() ?? 0,
      lng: (row['lng'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.tryParse(updatedAtText)?.toLocal() ?? DateTime.now(),
      batteryHealth: (rawBattery as num?)?.toInt(),
    );
  }
}

enum LocationPermissionUiState {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
