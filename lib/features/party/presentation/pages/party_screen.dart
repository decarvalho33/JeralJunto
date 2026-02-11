import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/party_invite.dart';
import '../../../../core/utils/post_frame_actions.dart';
import '../../data/repositories/party_repository_impl.dart';
import '../../domain/models/party.dart';
import '../../domain/repositories/party_repository.dart';
import '../controllers/party_controller.dart';
import '../widgets/party_members_list.dart';
import '../widgets/party_people_widgets.dart';
import 'party_config_screen.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({
    super.key,
    this.partyId,
    this.party,
    PartyRepository? repository,
  }) : _repository = repository;

  final int? partyId;
  final Party? party;
  final PartyRepository? _repository;

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  late final PartyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PartyController(
      repository: widget._repository ?? PartyRepositoryImpl(),
    );
    _controller.load(partyId: widget.partyId, party: widget.party);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    PostFrameActions.showSnackBar(
      context,
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: cs.inverseSurface,
        showCloseIcon: true,
        closeIconColor: cs.onInverseSurface,
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: cs.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: tt.bodyMedium?.copyWith(color: cs.onInverseSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String text, String feedback) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    HapticFeedback.selectionClick();
    _showSnack(feedback);
  }

  void _openConfig(Party party) {
    PostFrameActions.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PartyConfigScreen(partyId: party.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final party = _controller.party;
        final topPadding =
            MediaQuery.of(context).padding.top + kToolbarHeight + 12;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: cs.surface.withOpacity(0.72),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            leading: IconButton(
              tooltip: 'Voltar ao mapa',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LiveDot(),
                const SizedBox(width: 8),
                Text(
                  'Party',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Configurações',
                onPressed: party == null ? null : () => _openConfig(party),
                icon: const Icon(Icons.settings_outlined),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: cs.surface.withOpacity(0.72)),
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 260,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(0.12),
                          cs.tertiary.withOpacity(0.08),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              if (_controller.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_controller.errorMessage != null)
                _ErrorState(
                  message: _controller.errorMessage!,
                  onRetry: () => _controller.load(
                    partyId: widget.partyId,
                    party: widget.party,
                  ),
                )
              else if (party == null)
                _EmptyState(
                  onRetry: () => _controller.load(
                    partyId: widget.partyId,
                    party: widget.party,
                  ),
                )
              else
                ListView(
                  padding: EdgeInsets.fromLTRB(20, topPadding, 20, 24),
                  children: [
                    Text(
                      party.nome.isNotEmpty ? party.nome : 'Sua party',
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoPill(label: 'ID ${party.id}'),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.onSurfaceVariant.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_controller.members.length} membros',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PartyInviteCodeCard(
                      code: party.joinCode,
                      onCopy: () => _copyToClipboard(
                        party.joinCode,
                        'Código copiado.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    PartyActionRow(
                      onInviteTap: () => _copyToClipboard(
                        party.joinCode,
                        'Código copiado.',
                      ),
                      onCopyLinkTap: () => _copyToClipboard(
                        buildPartyInviteLink(party.joinCode),
                        'Link copiado.',
                      ),
                      onSettingsTap: () => _openConfig(party),
                      showSettings: false,
                    ),
                    const SizedBox(height: 20),
                    const PartyRulesCard(),
                    const SizedBox(height: 16),
                    const SafetyTipsCard(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.group_outlined,
                              color: cs.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Membros (${_controller.members.length})',
                          style: tt.titleSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PartyMembersList(
                      members: _controller.members,
                      currentUserId:
                          Supabase.instance.client.auth.currentUser?.id,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _pulse = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Container(
                width: 12 * _pulse.value,
                height: 12 * _pulse.value,
                decoration: BoxDecoration(
                  color: cs.tertiary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cs.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_off_outlined, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Nenhuma party encontrada.',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Entre em uma party para ver as informações.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Recarregar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
