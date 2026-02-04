import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helpers/ui_utils.dart';
import '../../../../app/router/app_routes.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

import 'package:image/image.dart' as img;

Uint8List compressAvatar(
  Uint8List originalBytes, {
  int size = 128,
  int quality = 65,
}) {
  final decoded = img.decodeImage(originalBytes);
  if (decoded == null) {
    throw Exception('Erro ao decodificar imagem');
  }

  // Resize para avatar (quadrado)
  final resized = img.copyResize(
    decoded,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );

  // Converte SEMPRE pra JPEG (compressão garantida)
  final jpg = img.encodeJpg(
    resized,
    quality: quality,
  );

  return Uint8List.fromList(jpg);
}


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

  Uint8List? _avatarBytes;
  String? _avatarExtension;
  String? _avatarContentType;

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
    if (_ageController.text.isNotEmpty) _ageController.clear();
    if (_emailController.text.isNotEmpty) _emailController.clear();
    if (_passwordController.text.isNotEmpty) _passwordController.clear();
    setState(() {
      _ageReady = false;
      _emailReady = false;
      _passwordReady = false;
    });
  }

  void _resetAfterAge() {
    if (_emailController.text.isNotEmpty) _emailController.clear();
    if (_passwordController.text.isNotEmpty) _passwordController.clear();
    setState(() {
      _emailReady = false;
      _passwordReady = false;
    });
  }

  void _resetAfterEmail() {
    if (_passwordController.text.isNotEmpty) _passwordController.clear();
    setState(() => _passwordReady = false);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    final compressed = compressAvatar(
      bytes,
      size: 128,
      quality: 65,
    );

    setState(() {
      _avatarBytes = compressed;
      _avatarExtension = 'jpg'; // força jpg
      _avatarContentType = 'image/jpeg';
    });

    final ext = _extensionFromName(picked.name);

    setState(() {
      _avatarBytes = bytes;
      _avatarExtension = ext;
      _avatarContentType = _contentTypeFromExtension(ext);
    });
  }

  void _clearAvatar() {
    setState(() {
      _avatarBytes = null;
      _avatarExtension = null;
      _avatarContentType = null;
    });
  }

  String _extensionFromName(String name) {
    final parts = name.split('.');
    if (parts.length < 2) return 'jpg';
    final ext = parts.last.toLowerCase().trim();
    if (ext.isEmpty) return 'jpg';
    return ext;
  }

  String _contentTypeFromExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  int? _parseAge() {
    final digits = onlyDigits(_ageController.text);
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  Future<User?> _ensureSignedIn() async {
    final client = Supabase.instance.client;

    final currentUser = client.auth.currentUser;
    final currentSession = client.auth.currentSession;
    if (currentUser != null && currentSession != null) {
      return currentUser;
    }

    final response = await client.auth.signUp(
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
      return null;
    }

    return response.user ?? response.session?.user ?? client.auth.currentUser;
  }

  /// Upload eficiente:
  /// - path fixo: <uid>/avatar.jpg (ou png/webp)
  /// - upsert: true
  /// - retorna URL com cache-busting (?v=timestamp)
  Future<String?> _uploadAvatar(String userId) async {
    if (_avatarBytes == null) return null;

    final client = Supabase.instance.client;

    // Você pode forçar sempre jpg aqui se quiser padronizar.
    final ext = (_avatarExtension ?? 'jpg');
    final safeExt = (ext == 'jpeg') ? 'jpg' : ext;

    // path fixo por usuário (isso casa com suas policies)
    final path = '$userId/avatar.$safeExt';

    await client.storage.from('avatars').uploadBinary(
          path,
          _avatarBytes!,
          fileOptions: FileOptions(
            contentType: _avatarContentType ?? _contentTypeFromExtension(safeExt),
            upsert: true,
          ),
        );

    final publicUrl = client.storage.from('avatars').getPublicUrl(path);

    // cache busting pra evitar foto antiga presa no navegador/CDN
    final version = DateTime.now().millisecondsSinceEpoch;
    return '$publicUrl?v=$version';
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      if (_avatarBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione uma foto de perfil para continuar.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final user = await _ensureSignedIn();
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

      // 1) Faz upload primeiro (se falhar, não grava avatar_url no banco)
      final avatarUrl = await _uploadAvatar(user.id);
      if (avatarUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar a foto. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2) Upsert do usuário já com avatar_url
      final payload = <String, dynamic>{
        'id': user.id,
        'email': user.email,
        'nome': _nameController.text.trim(),
        'idade': _parseAge(),
        'avatar_url': avatarUrl,
      };

      await Supabase.instance.client.from('Usuario').upsert(
            payload,
            onConflict: 'id',
          );

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
    } on PostgrestException catch (error) {
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
          if (_emailReady) ...[
            const SizedBox(height: 18),
            const AuthLabel('Foto de perfil'),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.muted.withOpacity(0.2),
                  backgroundImage:
                      _avatarBytes == null ? null : MemoryImage(_avatarBytes!),
                  child: _avatarBytes == null
                      ? const Icon(Icons.person, color: AppColors.muted)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _pickAvatar,
                    child: Text(
                      _avatarBytes == null ? 'Escolher foto' : 'Trocar foto',
                    ),
                  ),
                ),
                if (_avatarBytes != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _clearAvatar,
                    icon: const Icon(Icons.close, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 20),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _passwordReady && _avatarBytes != null ? 1 : 0.4,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _passwordReady && _avatarBytes != null && !_isLoading
                        ? _submit
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
