import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/input_formatters.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../party/data/repositories/party_repository_impl.dart';
import '../../../party/presentation/controllers/join_party_controller.dart';

class NoPartyOverlay extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onAvatarTap;

  const NoPartyOverlay({super.key, required this.onRefresh, this.onAvatarTap});

  void _showCreatePartyDialog(BuildContext context) {
    final supabase = Supabase.instance.client;
    final nameController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Criar party'),
        content: TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          maxLength: 40,
          decoration: const InputDecoration(
            hintText: 'Nome da party (opcional)',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () async {
              if (isSubmitting) {
                return;
              }
              isSubmitting = true;

              final user = supabase.auth.currentUser;
              if (user == null) {
                isSubmitting = false;
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuário não autenticado.')),
                );
                return;
              }

              final partyName = nameController.text.trim().isEmpty
                  ? 'Minha Party'
                  : nameController.text.trim();

              try {
                final createdParty = await supabase
                    .from('Party')
                    .insert({'nome': partyName, 'idCriador': user.id})
                    .select('id')
                    .single();

                final partyId = _parseInt(createdParty['id']);
                if (partyId <= 0) {
                  throw StateError('Party inválida');
                }

                await supabase
                    .from('Party_Usuario')
                    .upsert(
                      {
                        'idParty': partyId,
                        'idUsuario': user.id,
                        'cargo': 'admin',
                        'status': 'active',
                      },
                      onConflict: 'idParty,idUsuario',
                      ignoreDuplicates: true,
                    );

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      onRefresh();
                    }
                  });
                }
              } catch (_) {
                isSubmitting = false;
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não foi possível criar a party.'),
                  ),
                );
              }
            },
            child: const Text('Criar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).whenComplete(nameController.dispose);
  }

  // mostrar o diálogo de entrada
  void _showJoinDialog(BuildContext context) {
    final codeController = TextEditingController();
    final joinController = JoinPartyController(
      repository: PartyRepositoryImpl(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Entrar em uma Party"),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: const [JoinCodeInputFormatter()],
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: "Ex: ABC123",
            border: OutlineInputBorder(),
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () async {
              final party = await joinController.submit(codeController.text);
              if (!context.mounted) {
                return;
              }

              if (party == null) {
                final errorMessage =
                    joinController.errorMessage ??
                    'Código inválido ou erro de conexão.';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorMessage)));
                return;
              }

              Navigator.pop(context);
              onRefresh();
            },
            child: const Text(
              "Confirmar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).whenComplete(() {
      codeController.dispose();
      joinController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            if (onAvatarTap != null)
              Positioned(
                top: 10,
                right: 16,
                child: InkResponse(
                  onTap: onAvatarTap,
                  radius: 30,
                  child: const UserAvatar(
                    radius: 27,
                    backgroundColor: Color(0xFFCBD5E1),
                    iconColor: Colors.white,
                    iconSize: 28,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.group_add_outlined,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Jeral Junto",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Você ainda não faz parte de nenhum grupo. Comece criando o seu ou entre no de seus amigos.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _showCreatePartyDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Criar Minha Party",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => _showJoinDialog(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Tenho um Código",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
