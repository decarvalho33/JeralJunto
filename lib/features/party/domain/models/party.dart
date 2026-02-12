import '../../../../core/utils/input_formatters.dart';

class Party {
  const Party({
    required this.id,
    required this.nome,
    required this.joinCode,
    required this.requiresApproval,
    required this.createdAt,
    required this.idCriador,
  });

  final int id;
  final String nome;
  final String joinCode;
  final bool requiresApproval;
  final DateTime createdAt;
  final String idCriador;

  factory Party.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    return Party(
      id: _parseInt(json['id']),
      nome: json['nome']?.toString() ?? '',
      joinCode: normalizeJoinCode(json['join_code']?.toString() ?? ''),
      requiresApproval: _parseBool(json['requires_approval']),
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
      idCriador: json['idCriador']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'join_code': joinCode,
      'requires_approval': requiresApproval,
      'created_at': createdAt.toIso8601String(),
      'idCriador': idCriador,
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

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}
