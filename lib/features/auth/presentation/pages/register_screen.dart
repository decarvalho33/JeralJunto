import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helpers/ui_utils.dart';
import '../../../../app/router/app_routes.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

enum RegisterStep { signup, profile }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _ageFocus = FocusNode();

  StreamSubscription<AuthState>? _authSubscription;
  RegisterStep _step = RegisterStep.signup;
  bool _isLoading = false;
  bool _nameReady = false;
  bool _nameConfirmed = false;
  bool _ageReady = false;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null && mounted && _step == RegisterStep.signup) {
        setState(() {
          _step = RegisterStep.profile;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameController.dispose();
    _ageController.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  void _handleNameChanged(String value) {
    final ready = value.trim().length >= 2;
    if (ready != _nameReady) {
      setState(() => _nameReady = ready);
    }
    if (_nameConfirmed) {
      setState(() {
        _nameConfirmed = false;
        _ageReady = false;
      });
      _ageController.clear();
    }
  }

  void _confirmName() {
    if (!_nameReady) {
      return;
    }
    setState(() => _nameConfirmed = true);
    Future.microtask(() => _ageFocus.requestFocus());
  }

  void _handleAgeChanged(String value) {
    final digits = onlyDigits(value);
    final ready = digits.isNotEmpty;
    if (ready != _ageReady) {
      setState(() => _ageReady = ready);
    }
  }

  int? _parseAge() {
    final digits = onlyDigits(_ageController.text);
    if (digits.isEmpty) {
      return null;
    }
    return int.tryParse(digits);
  }

  Future<void> _signUpWithProvider(OAuthProvider provider) async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(provider);
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

  Future<void> _saveProfileAndGoHome() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão inválida. Faça o cadastro novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final payload = <String, dynamic>{
      'id': user.id,
      'email': user.email,
      'nome': _nameController.text.trim(),
      'idade': _parseAge(),
    };

    try {
      await client.from('Usuario').upsert(payload, onConflict: 'id');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (_) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar perfil.'),
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _step == RegisterStep.signup
            ? _buildSignup()
            : _buildProfile(),
      ),
    );
  }

  List<Widget> _buildSignup() {
    return [
      // const SizedBox(height: 8),
      // Center(
      //   child: Image.asset(
      //     'web/icons/JJ_logo.png',
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
        'Cadastre-se com Google, Apple ou email e senha.',
        style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed:
              _isLoading ? null : () => _signUpWithProvider(OAuthProvider.google),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Entrar com Google'),
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed:
              _isLoading ? null : () => _signUpWithProvider(OAuthProvider.apple),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.apple,
          ),
          icon: const Icon(Icons.apple),
          label: const Text('Entrar com Apple'),
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
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
          ),
          child: const Text('Cadastrar com email'),
        ),
      ),
      const SizedBox(height: 33),
      Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed:
              _isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.login),
          child: const Text(
            'Já possuo cadastro',
            style: TextStyle(color: AppColors.ink),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildProfile() {
    return [
      const SizedBox(height: 8),
      Center(
        child: Image.asset(
          'web/icons/Icon-512.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
          semanticLabel: 'Logo do app',
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Complete seu perfil',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'Só mais alguns dados para personalizar sua experiência.',
        style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
      ),
      const SizedBox(height: 24),
      const AuthLabel('Nome'),
      const SizedBox(height: 8),
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(hintText: 'Maria Silva'),
        textInputAction: TextInputAction.next,
        onChanged: _handleNameChanged,
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _nameReady ? _confirmName : null,
          child: const Text('Confirmar nome'),
        ),
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          );
        },
        child: _nameConfirmed
            ? Column(
                key: const ValueKey('age-section'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  const AuthLabel('Idade'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ageController,
                    focusNode: _ageFocus,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Ex: 29'),
                    onChanged: _handleAgeChanged,
                  ),
                  const SizedBox(height: 20),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    offset: _ageReady ? Offset.zero : const Offset(0, 0.05),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: _ageReady ? 1 : 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _ageReady && !_isLoading
                              ? _saveProfileAndGoHome
                              : null,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Continuar'),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(
                key: ValueKey('age-placeholder'),
                height: 12,
              ),
      ),
      const SizedBox(height: 20),
      Text(
        'Você pode ajustar essas informações depois.',
        style: TextStyle(
          color: Colors.black.withOpacity(0.5),
          fontSize: 12,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 24),
    ];
  }
}
