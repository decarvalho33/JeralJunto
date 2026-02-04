import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Login com Google via Supabase OAuth
  Future<void> signInWithGoogle() async {
    final redirectTo = kIsWeb ? _webRedirectTo() : null;

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }


  Future<void> signInWithEmailOtp(String email) async {
    final redirectTo = kIsWeb ? _webRedirectTo() : null;

    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: redirectTo,
    );
  }

  /// Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _webRedirectTo() {

    return 'https://jeraljunto.app.br/';
  }
}
