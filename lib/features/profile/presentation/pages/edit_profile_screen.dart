import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialAvatarUrl,
  });

  final String initialName;
  final String? initialAvatarUrl;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _client = Supabase.instance.client;
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Uint8List? _selectedAvatarBytes;
  bool _removeAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final compressed = _compressAvatar(bytes);

    if (!mounted) return;
    setState(() {
      _selectedAvatarBytes = compressed;
      _removeAvatar = false;
    });
  }

  Uint8List _compressAvatar(Uint8List originalBytes) {
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      return originalBytes;
    }

    final resized = img.copyResize(
      decoded,
      width: 256,
      height: 256,
      interpolation: img.Interpolation.average,
    );

    final jpg = img.encodeJpg(resized, quality: 75);
    return Uint8List.fromList(jpg);
  }

  Future<String> _uploadAvatar(String userId) async {
    final path = '$userId/avatar.jpg';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          _selectedAvatarBytes!,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    final version = DateTime.now().millisecondsSinceEpoch;
    return '$publicUrl?v=$version';
  }

  Future<void> _removeAvatarFromStorage(String userId) async {
    try {
      await _client.storage.from('avatars').remove(['$userId/avatar.jpg']);
    } catch (_) {
      // Remocao de storage e best-effort. O estado no banco e a fonte da verdade.
    }
  }

  Future<void> _save() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final initialName = widget.initialName.trim();
    final hadAvatar =
        widget.initialAvatarUrl != null &&
        widget.initialAvatarUrl!.trim().isNotEmpty;

    final nameChanged = name != initialName;
    final avatarChanged =
        _selectedAvatarBytes != null || (_removeAvatar && hadAvatar);
    final passwordChanged = password.isNotEmpty;

    if (!nameChanged && !avatarChanged && !passwordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma alteração para salvar.')),
      );
      return;
    }

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um nome com pelo menos 2 caracteres.'),
          backgroundColor: AppSemanticColors.danger,
        ),
      );
      return;
    }

    if (passwordChanged) {
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A senha deve ter pelo menos 6 caracteres.'),
            backgroundColor: AppSemanticColors.danger,
          ),
        );
        return;
      }
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A confirmação de senha não confere.'),
            backgroundColor: AppSemanticColors.danger,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      String? avatarUrl = widget.initialAvatarUrl;

      if (_selectedAvatarBytes != null) {
        avatarUrl = await _uploadAvatar(user.id);
      } else if (_removeAvatar) {
        await _removeAvatarFromStorage(user.id);
        avatarUrl = null;
      }

      final userPayload = <String, dynamic>{'id': user.id, 'email': user.email};

      if (nameChanged) {
        userPayload['nome'] = name;
      }
      if (avatarChanged) {
        userPayload['avatar_url'] = avatarUrl;
      }

      await _client.from('Usuario').upsert(userPayload, onConflict: 'id');

      if (passwordChanged || nameChanged) {
        await _client.auth.updateUser(
          UserAttributes(
            password: passwordChanged ? password : null,
            data: nameChanged ? {'full_name': name, 'name': name} : null,
          ),
        );
      }

      ref.invalidate(userProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
      Navigator.of(context).pop(true);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppSemanticColors.danger,
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppSemanticColors.danger,
        ),
      );
    } on StorageException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppSemanticColors.danger,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar o perfil.'),
          backgroundColor: AppSemanticColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasInitialAvatar =
        widget.initialAvatarUrl != null &&
        widget.initialAvatarUrl!.trim().isNotEmpty;

    final ImageProvider<Object>? avatarImage;
    if (_selectedAvatarBytes != null) {
      avatarImage = MemoryImage(_selectedAvatarBytes!);
    } else if (_removeAvatar || !hasInitialAvatar) {
      avatarImage = null;
    } else {
      avatarImage = NetworkImage(widget.initialAvatarUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.14),
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? const Icon(
                          Icons.person,
                          size: 38,
                          color: AppColors.muted,
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _pickAvatar,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        _selectedAvatarBytes == null
                            ? 'Trocar foto'
                            : 'Foto selecionada',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _isSaving || (!_hasAvatarOnScreen(hasInitialAvatar))
                          ? null
                          : () {
                              setState(() {
                                _selectedAvatarBytes = null;
                                _removeAvatar = true;
                              });
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remover foto'),
                    ),
                  ],
                ),
                if (_removeAvatar) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'A foto será removida quando você salvar.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nome',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Seu nome'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trocar senha',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  enabled: !_isSaving,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Nova senha (opcional)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !_isSaving,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirmar nova senha',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Salvar alterações'),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAvatarOnScreen(bool hasInitialAvatar) {
    if (_selectedAvatarBytes != null) return true;
    if (_removeAvatar) return false;
    return hasInitialAvatar;
  }
}
