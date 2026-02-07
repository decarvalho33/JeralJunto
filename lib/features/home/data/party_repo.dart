import 'package:supabase_flutter/supabase_flutter.dart';

import 'map_models.dart';

class PartyRepo {
  PartyRepo({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<String>> fetchMemberUserIds(int partyId) async {
    final rows = await _client
        .from('Party_Usuario')
        .select('idUsuario')
        .eq('idParty', partyId);

    return (rows as List)
        .map((item) => item['idUsuario'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
  }

  Future<List<MemberInfo>> fetchUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return const [];

    final rows = await _client
        .from('Usuario')
        .select('id, nome, avatar_url')
        .inFilter('id', userIds);

    final users = (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(MemberInfo.fromUsuarioRow)
        .toList(growable: false);

    final byId = {for (final user in users) user.id: user};
    return userIds
        .map((id) => byId[id])
        .whereType<MemberInfo>()
        .toList(growable: false);
  }
}
