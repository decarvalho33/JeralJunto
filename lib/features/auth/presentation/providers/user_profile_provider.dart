import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String? name;
  final String? avatarUrl;

  const UserProfile({this.name, this.avatarUrl});
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final data = await Supabase.instance.client
      .from('Usuario')
      .select('nome, avatar_url')
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) return null;

  return UserProfile(
    name: data['nome'] as String?,
    avatarUrl: data['avatar_url'] as String?,
  );
});
