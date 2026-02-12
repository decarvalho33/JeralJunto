import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/party_invite.dart';
import '../../../../core/utils/post_frame_actions.dart';
import '../../domain/models/party_config.dart';
import '../../domain/models/party_member_item.dart';
import '../controllers/party_config_view_model.dart';
import '../widgets/party_config_widgets.dart';

class PartyConfigScreen extends StatefulWidget {
  const PartyConfigScreen({super.key, this.partyId});

  final int? partyId;

  @override
  State<PartyConfigScreen> createState() => _PartyConfigScreenState();
}

class _PartyConfigScreenState extends State<PartyConfigScreen>
    with WidgetsBindingObserver {
  PartyConfigViewModel? _viewModelInstance;
  final TextEditingController _nameController = TextEditingController();
  RealtimeChannel? _partyChannel;
  RealtimeChannel? _membersChannel;
  Timer? _refreshDebounce;

  PartyConfigViewModel get _viewModel {
    return _viewModelInstance ??= PartyConfigViewModel();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nameController.addListener(() {
      _viewModel.updateDraftName(_nameController.text);
    });

    final partyId = widget.partyId;
    if (partyId != null) {
      _setupRealtime(partyId);
      PostFrameActions.run(() => _viewModel.load(partyId));
    }
  }

  @override
  void didUpdateWidget(covariant PartyConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partyId != widget.partyId) {
      _disposeRealtime();
      final partyId = widget.partyId;
      if (partyId != null) {
        _setupRealtime(partyId);
        _viewModel.load(partyId);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final partyId = widget.partyId;
      if (partyId != null) {
        _viewModel.load(partyId);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _viewModelInstance?.dispose();
    _refreshDebounce?.cancel();
    _disposeRealtime();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setupRealtime(int partyId) {
    final client = Supabase.instance.client;
    _partyChannel = client.channel('party-config-$partyId');
    _partyChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Party',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: partyId,
          ),
          callback: (_) => _scheduleRefresh(),
        )
        .subscribe();

    _membersChannel = client.channel('party-members-$partyId');
    _membersChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Party_Usuario',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'idParty',
            value: partyId,
          ),
          callback: (_) => _scheduleRefresh(),
        )
        .subscribe();
  }

  void _disposeRealtime() {
    _partyChannel?.unsubscribe();
    _membersChannel?.unsubscribe();
    _partyChannel = null;
    _membersChannel = null;
  }

  void _scheduleRefresh() {
    _refreshDebounce ??= Timer(const Duration(milliseconds: 400), () {
      _refreshDebounce = null;
      final partyId = widget.partyId;
      if (partyId != null) {
        _viewModel.load(partyId);
      }
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _resolveCreatorLabel(PartyConfigData data) {
    final creatorId = data.creatorId.trim();
    if (creatorId.isEmpty) {
      return '';
    }
    for (final member in _viewModel.members) {
      if (member.userId == creatorId) {
        final name = member.displayName?.trim();
        if (name != null && name.isNotEmpty) {
          return name;
        }
        if (member.displayLabel.trim().isNotEmpty) {
          return member.displayLabel;
        }
      }
    }
    return creatorId;
  }

  Future<void> _applyChanges() async {
    final config = _viewModel.config;
    if (config != null && config.canEditName) {
      if (_viewModel.draftName.trim().isEmpty) {
        _showSnack('Nome da party não pode ficar vazio.');
        return;
      }
    }

    final ok = await _viewModel.applyChanges();
    if (!mounted) {
      return;
    }
    if (ok) {
      _showSnack('Configurações salvas com sucesso.');
    } else {
      _showSnack('Não foi possível salvar as alterações.');
    }
  }

  Future<void> _confirmEndParty() async {
    final data = _viewModel.config;
    if (data == null || !data.canEndParty) {
      return;
    }

    final cs = Theme.of(context).colorScheme;
    final confirmed = await PostFrameActions.showDialogPostFrame<bool>(
      context,
      (context) {
        return AlertDialog(
          title: const Text('Encerrar party?'),
          content: const Text(
            'Todos os membros perderão acesso e os dados serão arquivados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Encerrar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final ok = await _viewModel.endParty();
    if (!mounted) {
      return;
    }
    if (ok) {
      _showSnack('Party encerrada.');
      Navigator.of(context).pop();
    } else {
      _showSnack('Não foi possível encerrar a party.');
    }
  }

  Future<void> _confirmRotateJoinCode() async {
    final data = _viewModel.config;
    if (data == null || !data.canRotateCode || _viewModel.isRotatingCode) {
      return;
    }

    final confirmed = await PostFrameActions.showDialogPostFrame<bool>(context, (
      context,
    ) {
      return AlertDialog(
        title: const Text('Gerar novo código?'),
        content: const Text(
          'O código atual deixará de funcionar. Compartilhe o novo com o grupo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Gerar'),
          ),
        ],
      );
    });

    if (confirmed != true) {
      return;
    }

    final code = await _viewModel.rotateJoinCode();
    if (!mounted) {
      return;
    }
    if (code != null) {
      _showSnack('Novo código gerado.');
    } else {
      final error = _viewModel.lastActionError;
      if (error != null && error.isNotEmpty) {
        _showSnack('Não foi possível gerar outro código. $error');
      } else {
        _showSnack('Não foi possível gerar outro código.');
      }
    }
  }

  Future<void> _promoteMember(String userId) async {
    final ok = await _viewModel.promote(userId);
    if (!mounted) {
      return;
    }
    if (ok) {
      _showSnack('Membro promovido a admin.');
    } else {
      _showSnack('Não foi possível atualizar o cargo.');
    }
  }

  Future<void> _demoteMember(String userId) async {
    final confirmed = await PostFrameActions.showDialogPostFrame<bool>(
      context,
      (context) {
        return AlertDialog(
          title: const Text('Rebaixar membro?'),
          content: const Text('Esse membro voltará a ser usuário comum.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Rebaixar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final ok = await _viewModel.demote(userId);
    if (!mounted) {
      return;
    }
    if (ok) {
      _showSnack('Membro rebaixado para usuário.');
    } else {
      _showSnack('Não foi possível atualizar o cargo.');
    }
  }

  Future<void> _handleTransferCreator() async {
    final data = _viewModel.config;
    if (data == null || !data.canTransferCreator) {
      return;
    }
    final eligible = _viewModel.members
        .where((member) => member.status == 'active' && !member.isMe)
        .toList();
    if (eligible.isEmpty) {
      _showSnack('Não há membros elegíveis para transferir.');
      return;
    }

    final selected = await showModalBottomSheet<PartyMemberItem>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Transferir criador'),
                subtitle: Text('Escolha o novo criador da party'),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: eligible.length,
                  itemBuilder: (context, index) {
                    final member = eligible[index];
                    final avatar =
                        (member.avatarUrl != null &&
                            member.avatarUrl!.isNotEmpty)
                        ? NetworkImage(member.avatarUrl!)
                        : null;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatar,
                        child: avatar == null
                            ? Text(
                                member.displayLabel.isNotEmpty
                                    ? member.displayLabel
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      title: Text(member.displayLabel),
                      subtitle: Text(
                        member.role == 'admin' ? 'Admin' : 'Membro',
                      ),
                      onTap: () => Navigator.of(context).pop(member),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    final confirmed = await PostFrameActions.showDialogPostFrame<bool>(
      context,
      (context) {
        return AlertDialog(
          title: const Text('Transferir criador?'),
          content: const Text(
            'Você vai deixar de ser criador e virar admin. Continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Transferir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final ok = await _viewModel.transferCreator(selected.userId);
    if (!mounted) {
      return;
    }
    if (ok) {
      _showSnack('Criador transferido com sucesso.');
    } else {
      _showSnack('Não foi possível transferir o criador.');
    }
  }

  void _showSnack(String message) {
    final cs = Theme.of(context).colorScheme;
    PostFrameActions.showSnackBar(
      context,
      SnackBar(content: Text(message), backgroundColor: cs.surface),
    );
  }

  Future<void> _copyToClipboard(String text, String feedback) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    _showSnack(feedback);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final data = _viewModel.config;
        final partyId = widget.partyId;
        final canShowActions = data != null;
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        if (_viewModel.consumeShouldSyncName()) {
          _nameController.text = _viewModel.draftName;
          _nameController.selection = TextSelection.collapsed(
            offset: _nameController.text.length,
          );
        }

        return Scaffold(
          bottomNavigationBar: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: PartyConfigSaveBar(
              isVisible: _viewModel.isDirty,
              isSaving: _viewModel.isApplyingChanges,
              onSave: _applyChanges,
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 280,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(0.08),
                          cs.tertiary.withOpacity(0.06),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: cs.surface.withOpacity(0.72),
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    title: Text(
                      'Configurações',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    leading: IconButton(
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Copiar link',
                        onPressed: canShowActions
                            ? () => _copyToClipboard(
                                buildPartyInviteLink(data!.joinCode),
                                'Link copiado.',
                              )
                            : null,
                        icon: const Icon(Icons.link),
                      ),
                      IconButton(
                        tooltip: 'Copiar código',
                        onPressed: canShowActions
                            ? () => _copyToClipboard(
                                data!.joinCode,
                                'Código copiado.',
                              )
                            : null,
                        icon: const Icon(Icons.key_outlined),
                      ),
                      const SizedBox(width: 4),
                    ],
                    flexibleSpace: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(color: cs.surface.withOpacity(0.72)),
                      ),
                    ),
                    shape: Border(
                      bottom: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (partyId == null)
                    SliverToBoxAdapter(
                      child: MaxWidthSection(
                        child: PartyConfigEmptyCard(onRetry: () {}),
                      ),
                    )
                  else if (_viewModel.isLoadingConfig)
                    SliverToBoxAdapter(
                      child: MaxWidthSection(
                        child: const PartyConfigSkeleton(),
                      ),
                    )
                  else if (_viewModel.errorMessage != null)
                    SliverToBoxAdapter(
                      child: MaxWidthSection(
                        child: PartyConfigErrorCard(
                          message: _viewModel.errorMessage!,
                          onRetry: () => _viewModel.load(partyId),
                        ),
                      ),
                    )
                  else if (data == null)
                    SliverToBoxAdapter(
                      child: MaxWidthSection(
                        child: PartyConfigEmptyCard(
                          onRetry: () => _viewModel.load(partyId),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: MaxWidthSection(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: _buildContent(context, data),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, PartyConfigData data) {
    final createdLabel = _formatDate(data.createdAt);
    final creatorLabel = _resolveCreatorLabel(data);
    final roleLabel = data.isCreator
        ? 'Criador'
        : (data.isAdmin ? 'Admin' : 'Membro');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PartyConfigHeroCard(
          name: _viewModel.draftName.isNotEmpty
              ? _viewModel.draftName
              : data.name,
          roleLabel: roleLabel,
          requiresApproval: _viewModel.draftRequiresApproval,
          locationSharingEnabled: _viewModel.draftLocationSharing,
          memberCount: data.memberCount,
          createdLabel: createdLabel,
        ),
        const SizedBox(height: 20),
        if (data.canEditName) ...[
          const SectionHeader(title: 'Informações'),
          PartyInfoSectionCard(
            nameController: _nameController,
            creatorLabel: creatorLabel,
            createdLabel: createdLabel,
          ),
          const SizedBox(height: 20),
        ],
        const SectionHeader(title: 'Convite'),
        InviteCodeSectionCard(
          joinCode: data.joinCode,
          onCopyCode: () => _copyToClipboard(data.joinCode, 'Código copiado.'),
          onCopyLink: () => _copyToClipboard(
            buildPartyInviteLink(data.joinCode),
            'Link copiado.',
          ),
          onRotate: _confirmRotateJoinCode,
          canRotate: data.canRotateCode,
          isRotating: _viewModel.isRotatingCode,
        ),
        if (data.canManageMembers) ...[
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Privacidade e acesso',
            subtitle:
                'Controle como novos membros entram e compartilham localização.',
          ),
          PrivacyAccessSectionCard(
            requiresApproval: _viewModel.draftRequiresApproval,
            locationSharingEnabled: _viewModel.draftLocationSharing,
            onRequiresApprovalChanged: _viewModel.updateDraftRequiresApproval,
            onLocationSharingChanged: _viewModel.updateDraftLocationSharing,
            isSaving: _viewModel.isApplyingChanges,
          ),
        ],
        if (data.canManageMembers || data.canTransferCreator) ...[
          const SizedBox(height: 20),
          MembersRolesSectionCard(
            members: _viewModel.members,
            isLoading: _viewModel.isLoadingMembers,
            canPromote: data.isAdmin || data.isCreator,
            canDemote: data.isCreator,
            isMemberBusy: _viewModel.isMemberBusy,
            onPromote: _promoteMember,
            onDemote: _demoteMember,
            errorMessage: _viewModel.membersError,
            onRetry: _viewModel.refreshMembers,
            transferCreatorButton: data.canTransferCreator
                ? TransferCreatorButton(
                    onPressed: _handleTransferCreator,
                    isLoading: _viewModel.isTransferringCreator,
                  )
                : null,
          ),
        ],
        if (data.canEndParty) ...[
          const SizedBox(height: 24),
          DangerZoneSectionCard(
            onEndPartyPressed: _confirmEndParty,
            isLoading: _viewModel.isApplyingChanges,
          ),
        ],
      ],
    );
  }
}
