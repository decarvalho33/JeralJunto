import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/party_config.dart';

class PartyConfigService {
  PartyConfigService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<PartyConfigData?> fetchConfig({required int partyId}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }

    final response = await _client.rpc(
      'party_get_config',
      params: {'p_party_id': partyId},
    );

    final row = _extractSingleRow(response);
    if (row == null) {
      return null;
    }
    final data = PartyConfigData.fromRpc(row);
    final creatorName = await _fetchCreatorName(data.creatorId);
    if (creatorName == null || creatorName.isEmpty) {
      return data;
    }
    return data.copyWith(creatorName: creatorName);
  }

  Future<void> updatePartyName({
    required int partyId,
    required String name,
  }) async {
    await _client.rpc(
      'party_update_name',
      params: {
        'p_party_id': partyId,
        'p_name': name,
      },
    );
  }

  Future<void> setRequiresApproval({
    required int partyId,
    required bool requires,
  }) async {
    await _client.rpc(
      'party_set_requires_approval',
      params: {
        'p_party_id': partyId,
        'p_requires': requires,
      },
    );
  }

  Future<void> setLocationSharing({
    required int partyId,
    required bool enabled,
  }) async {
    await _client.rpc(
      'party_set_location_sharing',
      params: {
        'p_party_id': partyId,
        'p_enabled': enabled,
      },
    );
  }

  Future<String> rotateJoinCode({required int partyId}) async {
    final response = await _client.rpc(
      'party_rotate_join_code',
      params: {'p_party_id': partyId},
    );

    final code = _extractString(response);
    if (code.isEmpty) {
      throw StateError('Código inválido');
    }
    return code;
  }

  Future<void> endParty({required int partyId}) async {
    await _client.rpc(
      'party_end',
      params: {'p_party_id': partyId},
    );
  }

  Future<void> setMemberRole({
    required int partyId,
    required String userId,
    required String newRole,
  }) async {
    await _client.rpc(
      'party_set_member_role',
      params: {
        'p_party_id': partyId,
        'p_user_id': userId,
        'p_new_role': newRole,
      },
    );
  }

  Future<void> transferCreator({
    required int partyId,
    required String newCreatorUserId,
  }) async {
    await _client.rpc(
      'party_transfer_creator',
      params: {
        'p_party_id': partyId,
        'p_new_creator': newCreatorUserId,
      },
    );
  }
  Future<String?> _fetchCreatorName(String creatorId) async {
    if (creatorId.isEmpty) {
      return null;
    }
    try {
      final response = await _client
          .from('Usuario')
          .select('nome')
          .eq('id', creatorId)
          .maybeSingle();
      return response?['nome']?.toString();
    } catch (_) {
      return null;
    }
  }
}

Map<String, dynamic>? _extractSingleRow(dynamic response) {
  if (response == null) {
    return null;
  }
  if (response is Map<String, dynamic>) {
    return response;
  }
  if (response is List && response.isNotEmpty) {
    final first = response.first;
    if (first is Map<String, dynamic>) {
      return first;
    }
  }
  return null;
}

String _extractString(dynamic response) {
  if (response == null) {
    return '';
  }
  if (response is String) {
    return response;
  }
  if (response is List && response.isNotEmpty) {
    final first = response.first;
    if (first is String) {
      return first;
    }
    if (first is Map) {
      if (first.values.isNotEmpty) {
        return first.values.first?.toString() ?? '';
      }
    }
  }
  if (response is Map) {
    if (response.values.isNotEmpty) {
      return response.values.first?.toString() ?? '';
    }
  }
  return response.toString();
}
