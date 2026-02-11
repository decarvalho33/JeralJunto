import '../../../../core/utils/input_formatters.dart';

class Party {
  const Party({
    required this.id,
    required this.nome,
    required this.joinCode,
    required this.createdAt,
    required this.idCriador,
  });

  final int id;
  final String nome;
  final String joinCode;
  final DateTime createdAt;
  final String idCriador;

  factory Party.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    return Party(
      id: _parseInt(json['id']),
      nome: json['nome']?.toString() ?? '',
      joinCode: normalizeJoinCode(json['join_code']?.toString() ?? ''),
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
