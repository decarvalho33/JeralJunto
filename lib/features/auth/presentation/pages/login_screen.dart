import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../app/router/app_routes.dart';
import '../../domain/entities/register_args.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  RegisterArgs? _registerArgs;
  StreamSubscription<AuthState>? _authSubscription;
  bool _didSyncProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerArgs ??= ModalRoute.of(context)?.settings.arguments as RegisterArgs?;
  }

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null && !_didSyncProfile) {
        _didSyncProfile = true;
        _upsertUserProfile();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _didSyncProfile = true;
      await _upsertUserProfile();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.root,
          (_) => false,
        );
      }
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
            content: Text('Erro ao entrar. Tente novamente.'),
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
    final fallbackName = metadata['full_name'] ??
        metadata['name'] ??
        metadata['preferred_username'];

    final name = (_registerArgs?.name.trim().isNotEmpty ?? false)
        ? _registerArgs!.name.trim()
        : (fallbackName is String ? fallbackName : null);

    final payload = <String, dynamic>{
      'id': user.id,
      'email': user.email,
    };

    if (name != null && name.isNotEmpty) {
      payload['nome'] = name;
    }
    if (_registerArgs?.age != null) {
      payload['idade'] = _registerArgs!.age;
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
        children: [
          const SizedBox(height: 12),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          const Text(
            'Entrar',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use seu email e senha para acessar.',
            style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const AuthLabel('Email'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const AuthLabel('Senha'),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Esqueci minha senha',
                style: TextStyle(color: AppColors.ink),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Entrar com email'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
