import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/party_invite.dart';
import '../../../../core/utils/pending_party_invite.dart';
import '../../../../app/router/app_routes.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = false;
  bool _didSyncProfile = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      final session = event.session;
      if (session != null && !_didSyncProfile) {
        _didSyncProfile = true;
        _upsertUserProfile().whenComplete(() {
          if (!mounted) {
            return;
          }
          setState(() => _isLoading = false);
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.root,
            (_) => false,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _signUpWithProvider(OAuthProvider provider) async {
    setState(() => _isLoading = true);
    try {
      final pendingCode = PendingPartyInvite.peek();
      final redirectTo = kIsWeb && pendingCode != null
          ? buildPartyInviteLink(pendingCode)
          : null;

      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectTo,
      );
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao cadastrar. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _upsertUserProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      return;
    }

    final metadata = user.userMetadata ?? <String, dynamic>{};
    final fallbackName =
        metadata['full_name'] ??
        metadata['name'] ??
        metadata['preferred_username'];
    final fallbackAvatar =
        metadata['avatar_url'] ??
        metadata['picture'] ??
        metadata['photo_url'] ??
        metadata['avatar'];

    final payload = <String, dynamic>{'id': user.id, 'email': user.email};

    if (fallbackName is String && fallbackName.isNotEmpty) {
      payload['nome'] = fallbackName;
    }
    if (fallbackAvatar is String && fallbackAvatar.isNotEmpty) {
      payload['avatar_url'] = fallbackAvatar;
    }

    try {
      await client.from('Usuario').upsert(payload, onConflict: 'id');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar perfil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildSignup(),
      ),
    );
  }

  List<Widget> _buildSignup() {
    return [
      // const SizedBox(height: 8),
      // Center(
      //   child: Image.asset(
      //     'web/icons/logo_512.png',
      //     width: 200,
      //     height: 200,
      //     fit: BoxFit.contain,
      //     semanticLabel: 'Logo do app',
      //   ),
      // ),
      const SizedBox(height: 16),
      const Text(
        'Crie sua conta',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'Cadastre-se com Google ou email e senha.',
        style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: _isLoading
              ? null
              : () => _signUpWithProvider(OAuthProvider.google),
          style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Entrar com Google'),
        ),
      ),
      const SizedBox(height: 24),
      const AuthDivider(),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pushNamed(context, AppRoutes.emailRegister),
          style: OutlinedButton.styleFrom(backgroundColor: AppColors.surface),
          child: const Text('Cadastrar com email'),
        ),
      ),
      const SizedBox(height: 33),
      Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pushNamed(context, AppRoutes.login),
          child: const Text(
            'Já possuo cadastro',
            style: TextStyle(color: AppColors.ink),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }
}
