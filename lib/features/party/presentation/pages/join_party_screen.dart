import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/pending_party_invite.dart';
import '../../../../core/utils/post_frame_actions.dart';
import '../../data/repositories/party_repository_impl.dart';
import '../../domain/repositories/party_repository.dart';
import '../controllers/join_party_controller.dart';

class JoinPartyScreen extends StatefulWidget {
  const JoinPartyScreen({
    super.key,
    this.prefilledCode,
    this.autoJoin = false,
    PartyRepository? repository,
  }) : _repository = repository;

  final String? prefilledCode;
  final bool autoJoin;
  final PartyRepository? _repository;

  @override
  State<JoinPartyScreen> createState() => _JoinPartyScreenState();
}

class _JoinPartyScreenState extends State<JoinPartyScreen> {
  late final TextEditingController _controller;
  late final JoinPartyController _joinController;

  @override
  void initState() {
    super.initState();
    final repo = widget._repository ?? PartyRepositoryImpl();
    _joinController = JoinPartyController(repository: repo);
    _controller = TextEditingController(
      text: widget.prefilledCode != null
          ? normalizeJoinCode(widget.prefilledCode!)
          : '',
    );

    if (widget.autoJoin) {
      PostFrameActions.run(_tryAutoJoin);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _joinController.dispose();
    super.dispose();
  }

  void _tryAutoJoin() {
    if (!mounted) {
      return;
    }
    if (_controller.text.length == 6) {
      _submit();
    }
  }

  Future<void> _submit() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      PendingPartyInvite.set(_controller.text);
      await _showAuthRequiredDialog();
      return;
    }

    final party = await _joinController.submit(_controller.text);
    if (!mounted) {
      return;
    }
    if (party == null) {
      if (_joinController.hasPartyConflict) {
        await _confirmPartySwitch();
      }
      return;
    }
    PendingPartyInvite.clear();
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  Future<void> _showAuthRequiredDialog() async {
    if (!mounted) {
      return;
    }

    await PostFrameActions.showDialogPostFrame<void>(context, (context) {
      return AlertDialog(
        title: const Text('Faça login para continuar'),
        content: const Text(
          'Você precisa entrar ou criar conta para participar da party.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Agora não'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!mounted) {
                return;
              }
              Navigator.of(this.context).pushNamed(AppRoutes.login);
            },
            child: const Text('Entrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!mounted) {
                return;
              }
              Navigator.of(this.context).pushNamed(AppRoutes.register);
            },
            child: const Text('Criar conta'),
          ),
        ],
      );
    });
  }

  Future<void> _confirmPartySwitch() async {
    final currentParty = _joinController.currentPartyConflict;
    final targetParty = _joinController.targetPartyConflict;
    if (currentParty == null || targetParty == null || !mounted) {
      return;
    }

    final currentName = currentParty.nome.trim().isEmpty
        ? 'sua party atual'
        : currentParty.nome.trim();
    final targetName = targetParty.nome.trim().isEmpty
        ? 'nova party'
        : targetParty.nome.trim();

    final confirmed = await PostFrameActions.showDialogPostFrame<bool>(context, (
      context,
    ) {
      return AlertDialog(
        title: const Text('Trocar de party?'),
        content: Text(
          'Você já está em "$currentName". Para entrar em "$targetName", você vai sair das outras parties.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Trocar'),
          ),
        ],
      );
    });

    if (confirmed != true) {
      return;
    }

    final party = await _joinController.confirmSwitchAndJoin();
    if (!mounted || party == null) {
      return;
    }
    PendingPartyInvite.clear();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar na party')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_joinController, _controller]),
          builder: (context, _) {
            final errorMessage = _joinController.errorMessage;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text('Digite o código de convite', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Use o código de 6 caracteres que você recebeu.',
                  style: tt.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [JoinCodeInputFormatter()],
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    counterText: '',
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: tt.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _joinController.isLoading ||
                            _controller.text.length != 6
                        ? null
                        : _submit,
                    child: _joinController.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
