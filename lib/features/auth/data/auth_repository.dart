import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Login com Google via Supabase OAuth (recomendado para Flutter Web)
  Future<void> signInWithGoogle() async {
    // No Web, é importante passar redirectTo (e ele precisa estar allowlisted no Supabase)
    final redirectTo = kIsWeb ? _webRedirectTo() : null;

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  /// Opcional (robusto e grátis): login por email OTP como fallback
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

  /// Ajuste aqui para o seu domínio/rota de callback no Flutter Web.
  /// Se você usa hash routing (/#/), mantenha assim.
  /// Se você usa path normal, troque para /auth/callback.
  String _webRedirectTo() {
    // MVP: se quiser, pode deixar só o domínio sem rota e tratar no AuthGate,
    // mas o ideal é ter uma rota dedicada.
    return 'https://SEU-PROJETO.vercel.app/#/auth/callback';
  }
}
