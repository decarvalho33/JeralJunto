import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helpers/ui_utils.dart';
import '../../../../app/router/app_routes.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _ageFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _nameReady = false;
  bool _ageReady = false;
  bool _emailReady = false;
  bool _passwordReady = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleNameChanged(String value) {
    final ready = value.trim().length >= 2;
    if (ready != _nameReady) {
      setState(() => _nameReady = ready);
    }
    if (!ready) {
      _resetAfterName();
    }
  }

  void _handleAgeChanged(String value) {
    final digits = onlyDigits(value);
    final ready = digits.isNotEmpty;
    if (ready != _ageReady) {
      setState(() => _ageReady = ready);
    }
    if (!ready) {
      _resetAfterAge();
    }
  }

  void _handleEmailChanged(String value) {
    final ready = value.trim().isNotEmpty;
    if (ready != _emailReady) {
      setState(() => _emailReady = ready);
    }
    if (!ready) {
      _resetAfterEmail();
    }
  }

  void _handlePasswordChanged(String value) {
    final ready = value.trim().isNotEmpty;
    if (ready != _passwordReady) {
      setState(() => _passwordReady = ready);
    }
  }

  void _resetAfterName() {
    if (_ageController.text.isNotEmpty) {
      _ageController.clear();
    }
    if (_emailController.text.isNotEmpty) {
      _emailController.clear();
    }
    if (_passwordController.text.isNotEmpty) {
      _passwordController.clear();
    }
    setState(() {
      _ageReady = false;
      _emailReady = false;
      _passwordReady = false;
    });
  }

  void _resetAfterAge() {
    if (_emailController.text.isNotEmpty) {
      _emailController.clear();
    }
    if (_passwordController.text.isNotEmpty) {
      _passwordController.clear();
    }
    setState(() {
      _emailReady = false;
      _passwordReady = false;
    });
  }

  void _resetAfterEmail() {
    if (_passwordController.text.isNotEmpty) {
      _passwordController.clear();
    }
    setState(() => _passwordReady = false);
  }

  int? _parseAge() {
    final digits = onlyDigits(_ageController.text);
    if (digits.isEmpty) {
      return null;
    }
    return int.tryParse(digits);
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sessão não iniciada. Desative a confirmação de email no Supabase.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final user = response.user ??
          response.session?.user ??
          Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão inválida. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final payload = <String, dynamic>{
        'id': user.id,
        'email': user.email,
        'nome': _nameController.text.trim(),
        'idade': _parseAge(),
      };

      await Supabase.instance.client.from('Usuario').upsert(
            payload,
            onConflict: 'id',
          );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (_) => false,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
          ),
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
          const SizedBox(height: 8),
          const Text(
            'Cadastro com email',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preencha os campos na sequência para continuar.',
            style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const AuthLabel('Nome'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'Maria Silva'),
            onChanged: _handleNameChanged,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
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
            child: _nameReady
                ? Column(
                    key: const ValueKey('age-field'),
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
                    ],
                  )
                : const SizedBox(
                    key: ValueKey('age-placeholder'),
                    height: 10,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
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
            child: _ageReady
                ? Column(
                    key: const ValueKey('email-field'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      const AuthLabel('Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(hintText: 'voce@empresa.com'),
                        onChanged: _handleEmailChanged,
                      ),
                    ],
                  )
                : const SizedBox(
                    key: ValueKey('email-placeholder'),
                    height: 10,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
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
            child: _emailReady
                ? Column(
                    key: const ValueKey('password-field'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      const AuthLabel('Senha'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: '••••••••'),
                        onChanged: _handlePasswordChanged,
                      ),
                    ],
                  )
                : const SizedBox(
                    key: ValueKey('password-placeholder'),
                    height: 10,
                  ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _passwordReady ? 1 : 0.4,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _passwordReady && !_isLoading ? _submit : null,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Cadastrar'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
