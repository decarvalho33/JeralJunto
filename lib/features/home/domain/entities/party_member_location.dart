class PartyMemberLocation {
  final String userId;
  final String name;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String? avatarUrl;

  const PartyMemberLocation({
    required this.userId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.avatarUrl,
  });

  PartyMemberLocation copyWith({
    String? userId,
    String? name,
    double? lat,
    double? lng,
    DateTime? timestamp,
    String? avatarUrl,
  }) {
    return PartyMemberLocation(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      timestamp: timestamp ?? this.timestamp,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory PartyMemberLocation.fromBroadcast(Map<String, dynamic> payload) {
    final data = payload['payload'] as Map<String, dynamic>? ?? payload;
    return PartyMemberLocation(
      userId: data['user_id'] as String? ?? 'unknown',
      name: data['name'] as String? ?? 'Amigo',
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(data['timestamp'] as String? ?? '') ??
          DateTime.now(),
      avatarUrl: data['avatar_url'] as String?,
    );
  }

  factory PartyMemberLocation.fromDatabase(Map<String, dynamic> data) {
    final posicao = _parsePosition(data['posicao']);
    return PartyMemberLocation(
      userId: data['idusuario'] as String? ?? 'unknown',
      name: data['nome'] as String? ?? 'Amigo',
      lat: posicao?.$1 ?? 0,
      lng: posicao?.$2 ?? 0,
      timestamp: DateTime.tryParse(data['ultimaatt'] as String? ?? '') ??
          DateTime.now(),
      avatarUrl: data['avatar_url'] as String?,
    );
  }

  static (double, double)? _parsePosition(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      final lat = (raw['lat'] as num?)?.toDouble();
      final lng = (raw['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        return (lat, lng);
      }
      if (raw['coordinates'] is List) {
        final coords = raw['coordinates'] as List;
        if (coords.length >= 2) {
          final lng = (coords[0] as num?)?.toDouble();
          final lat = (coords[1] as num?)?.toDouble();
          if (lat != null && lng != null) {
            return (lat, lng);
          }
        }
      }
    }
    if (raw is String) {
      final match = RegExp(r'POINT\((-?\d+(\.\d+)?) (-?\d+(\.\d+)?)\)')
          .firstMatch(raw);
      if (match != null) {
        final lng = double.tryParse(match.group(1) ?? '');
        final lat = double.tryParse(match.group(3) ?? '');
        if (lat != null && lng != null) {
          return (lat, lng);
        }
      }
    }
    return null;
  }
}
