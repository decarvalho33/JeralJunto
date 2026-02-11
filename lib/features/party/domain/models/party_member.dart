class PartyMember {
  const PartyMember({
    required this.idUsuario,
    required this.idParty,
    required this.cargo,
    required this.createdAt,
    this.displayName,
    this.avatarUrl,
  });

  final String idUsuario;
  final int idParty;
  final String cargo;
  final DateTime createdAt;
  final String? displayName;
  final String? avatarUrl;

  factory PartyMember.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    final usuario = json['Usuario'] as Map<String, dynamic>?;
    return PartyMember(
      idUsuario: json['idUsuario']?.toString() ?? '',
      idParty: _parseInt(json['idParty']),
      cargo: json['cargo']?.toString() ?? 'user',
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
      displayName: usuario?['nome']?.toString(),
      avatarUrl: usuario?['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'idParty': idParty,
      'cargo': cargo,
      'created_at': createdAt.toIso8601String(),
      'Usuario': {
        'nome': displayName,
        'avatar_url': avatarUrl,
      },
    };
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
