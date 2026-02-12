import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/party_member_item.dart';

class PartyMembersService {
  PartyMembersService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<PartyMemberItem>> fetchActiveMembers(int partyId) async {
    final currentUserId = _client.auth.currentUser?.id;

    final response = await _client
        .from('Party_Usuario')
        .select('idUsuario, cargo, status, created_at, Usuario(nome, avatar_url)')
        .eq('idParty', partyId)
        .eq('status', 'active');

    if (response is! List) {
      return [];
    }

    return response.map<PartyMemberItem>((dynamic raw) {
      final map = raw as Map<String, dynamic>;
      final userId = map['idUsuario']?.toString() ?? '';
      final role = map['cargo']?.toString() ?? 'user';
      final status = map['status']?.toString() ?? 'active';
      final usuario = map['Usuario'] as Map<String, dynamic>?;
      final name = usuario?['nome']?.toString();
      final avatarUrl = usuario?['avatar_url']?.toString();
      final displayLabel = _resolveDisplayLabel(userId, name);
      return PartyMemberItem(
        userId: userId,
        displayLabel: displayLabel,
        role: role,
        status: status,
        isMe: userId.isNotEmpty && userId == currentUserId,
        displayName: name,
        avatarUrl: avatarUrl,
      );
    }).toList();
  }
}

String _resolveDisplayLabel(String userId, String? name) {
  final trimmed = name?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  if (userId.length <= 8) {
    return userId;
  }
  return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
}
