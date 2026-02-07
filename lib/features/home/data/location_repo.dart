import 'package:supabase_flutter/supabase_flutter.dart';

import 'map_models.dart';

class LocationRepo {
  LocationRepo({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<MemberLocation>> fetchLocationsForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const [];

    final rows = await _client
        .from('Localizacao_View')
        .select('idUsuario, ultimaAtt, lat, lng, saudeBateria')
        .inFilter('idUsuario', userIds);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(MemberLocation.fromViewRow)
        .toList(growable: false);
  }

  Future<void> setMyLocation({
    required String userId,
    required double lat,
    required double lng,
    required int batteryHealth,
  }) async {
    final payload = <String, dynamic>{
      'ultimaAtt': DateTime.now().toUtc().toIso8601String(),
      'posicao': 'POINT($lng $lat)',
      'saudeBateria': batteryHealth,
    };

    final updatedRows = await _client
        .from('Localizacao')
        .update(payload)
        .eq('idUsuario', userId)
        .select('id')
        .limit(1);

    if ((updatedRows as List).isNotEmpty) return;

    await _client.from('Localizacao').insert({'idUsuario': userId, ...payload});
  }
}
