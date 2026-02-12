import 'package:supabase_flutter/supabase_flutter.dart';

class PartyQueries {
  static const String partyFields =
      'id, nome, idCriador, join_code, requires_approval, created_at';
  static const String memberFields =
      'idParty, idUsuario, cargo, created_at, Usuario(nome, avatar_url)';
}

class PartyRemoteDataSource {
  PartyRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? getCurrentUserId() => _client.auth.currentUser?.id;

  Future<Map<String, dynamic>?> fetchPartyById(int partyId) async {
    final response = await _client
        .from('Party')
        .select(PartyQueries.partyFields)
        .eq('id', partyId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>?> fetchPartyByCode(String codeUpper) async {
    final response = await _client
        .from('Party')
        .select(PartyQueries.partyFields)
        .eq('join_code', codeUpper)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchMembers(int partyId) async {
    final response = await _client
        .from('Party_Usuario')
        .select(PartyQueries.memberFields)
        .eq('idParty', partyId);
    return response.cast<Map<String, dynamic>>();
  }

  Future<int?> fetchLatestPartyIdForUser(String userId) async {
    try {
      final membership = await _client
          .from('Party_Usuario')
          .select('idParty, created_at')
          .eq('idUsuario', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if (membership.isNotEmpty) {
        return _parseInt(membership.first['idParty']);
      }
    } catch (_) {
      // fallback below
    }

    final ownerParty = await _client
        .from('Party')
        .select('id, created_at')
        .eq('idCriador', userId)
        .order('created_at', ascending: false)
        .limit(1);

    if (ownerParty.isNotEmpty) {
      return _parseInt(ownerParty.first['id']);
    }

    return null;
  }

  Future<void> joinParty(int partyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }

    await _client
        .from('Party_Usuario')
        .upsert(
          {'idParty': partyId, 'idUsuario': user.id, 'cargo': 'user'},
          onConflict: 'idParty,idUsuario',
          ignoreDuplicates: true,
        );
  }

  Future<void> leaveAllPartiesExcept(int keepPartyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }

    await _client
        .from('Party_Usuario')
        .delete()
        .eq('idUsuario', user.id)
        .neq('idParty', keepPartyId);
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
