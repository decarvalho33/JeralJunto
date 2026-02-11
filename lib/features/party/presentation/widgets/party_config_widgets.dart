import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/party_member_item.dart';

class MaxWidthSection extends StatelessWidget {
  const MaxWidthSection({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class PartyConfigHeroCard extends StatelessWidget {
  const PartyConfigHeroCard({
    super.key,
    required this.name,
    required this.roleLabel,
    required this.requiresApproval,
    required this.locationSharingEnabled,
    required this.memberCount,
    required this.createdLabel,
  });

  final String name;
  final String roleLabel;
  final bool requiresApproval;
  final bool locationSharingEnabled;
  final int memberCount;
  final String createdLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isNotEmpty ? name : 'Sua party',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.verified_outlined,
              label: roleLabel,
              background: cs.primary.withOpacity(0.08),
              foreground: cs.primary,
              borderColor: cs.primary.withOpacity(0.2),
            ),
            _InfoChip(
              icon: Icons.lock_outline,
              label: requiresApproval ? 'Fechada' : 'Aberta',
              background: cs.surfaceVariant,
              foreground: cs.onSurfaceVariant,
              borderColor: cs.outlineVariant,
            ),
            _InfoChip(
              icon: Icons.location_on_outlined,
              label:
                  locationSharingEnabled ? 'Localização ativa' : 'Localização inativa',
              background: cs.tertiary.withOpacity(0.1),
              foreground: cs.tertiary,
              borderColor: cs.tertiary.withOpacity(0.2),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Criada em $createdLabel • $memberCount membros',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class PartyInfoSectionCard extends StatelessWidget {
  const PartyInfoSectionCard({
    super.key,
    required this.nameController,
    required this.creatorLabel,
    required this.createdLabel,
  });

  final TextEditingController nameController;
  final String creatorLabel;
  final String createdLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      surfaceTintColor: cs.surfaceTint,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome da party',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              maxLength: 50,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: cs.primary, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Criador',
              value: creatorLabel,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Criada em',
              value: createdLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class InviteCodeSectionCard extends StatelessWidget {
  const InviteCodeSectionCard({
    super.key,
    required this.joinCode,
    required this.onCopyCode,
    required this.onCopyLink,
    required this.onRotate,
    required this.canRotate,
    required this.isRotating,
  });

  final String joinCode;
  final VoidCallback onCopyCode;
  final VoidCallback onCopyLink;
  final VoidCallback onRotate;
  final bool canRotate;
  final bool isRotating;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.18),
            cs.tertiary.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código da party',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    joinCode,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onCopyCode,
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Copiar'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onCopyLink,
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Copiar link'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                if (canRotate)
                  TextButton.icon(
                    onPressed: isRotating ? null : onRotate,
                    icon: isRotating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_outlined, size: 16),
                    label: const Text('Gerar novo'),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'O novo código invalida o anterior.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyAccessSectionCard extends StatelessWidget {
  const PrivacyAccessSectionCard({
    super.key,
    required this.requiresApproval,
    required this.locationSharingEnabled,
    required this.onRequiresApprovalChanged,
    required this.onLocationSharingChanged,
    required this.isSaving,
  });

  final bool requiresApproval;
  final bool locationSharingEnabled;
  final ValueChanged<bool> onRequiresApprovalChanged;
  final ValueChanged<bool> onLocationSharingChanged;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _SwitchRow(
              title: 'Party fechada',
              subtitle: 'Novos membros precisam de aprovação.',
              value: requiresApproval,
              onChanged: isSaving ? null : onRequiresApprovalChanged,
              trailing: isSaving ? const _InlineSpinner() : null,
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _SwitchRow(
              title: 'Compartilhar localização',
              subtitle: 'Permite que membros vejam sua localização.',
              value: locationSharingEnabled,
              onChanged: isSaving ? null : onLocationSharingChanged,
              trailing: isSaving ? const _InlineSpinner() : null,
            ),
          ),
        ],
      ),
    );
  }
}

class MembersRolesSectionCard extends StatelessWidget {
  const MembersRolesSectionCard({
    super.key,
    required this.members,
    required this.isLoading,
    required this.canPromote,
    required this.canDemote,
    required this.isMemberBusy,
    required this.onPromote,
    required this.onDemote,
    this.errorMessage,
    this.onRetry,
    this.transferCreatorButton,
  });

  final List<PartyMemberItem> members;
  final bool isLoading;
  final bool canPromote;
  final bool canDemote;
  final bool Function(String userId) isMemberBusy;
  final ValueChanged<String> onPromote;
  final ValueChanged<String> onDemote;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? transferCreatorButton;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Membros e cargos', style: tt.titleMedium),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.group_outlined, color: cs.primary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Gerencie permissões dos membros ativos.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            _ErrorInline(
              message: errorMessage!,
              onRetry: onRetry,
            )
          else if (members.isEmpty)
            Text(
              'Nenhum membro ativo encontrado.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            )
          else
            Column(
              children: [
                for (final member in members) ...[
                  _MemberTile(
                    member: member,
                    canPromote: canPromote,
                    canDemote: canDemote,
                    isBusy: isMemberBusy(member.userId),
                    onPromote: onPromote,
                    onDemote: onDemote,
                  ),
                  if (member != members.last) const SizedBox(height: 8),
                ],
              ],
            ),
          if (transferCreatorButton != null) ...[
            const SizedBox(height: 12),
            transferCreatorButton!,
          ],
        ],
      ),
    );
  }
}

class TransferCreatorButton extends StatelessWidget {
  const TransferCreatorButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.swap_horiz_outlined, size: 18),
        label: const Text('Transferir criador'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class DangerZoneSectionCard extends StatelessWidget {
  const DangerZoneSectionCard({
    super.key,
    required this.onEndPartyPressed,
    required this.isLoading,
  });

  final VoidCallback onEndPartyPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.errorContainer.withOpacity(0.35),
      surfaceTintColor: cs.errorContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: cs.error, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Encerrar a party remove membros e dados.',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: isLoading ? null : onEndPartyPressed,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Encerrar party'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartyConfigSaveBar extends StatelessWidget {
  const PartyConfigSaveBar({
    super.key,
    required this.isVisible,
    required this.isSaving,
    required this.onSave,
  });

  final bool isVisible;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSaving) const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartyConfigSkeleton extends StatelessWidget {
  const PartyConfigSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SkeletonCard(height: 140),
        SizedBox(height: 16),
        _SkeletonCard(height: 160),
        SizedBox(height: 16),
        _SkeletonCard(height: 140),
        SizedBox(height: 16),
        _SkeletonCard(height: 180),
      ],
    );
  }
}

class PartyConfigErrorCard extends StatelessWidget {
  const PartyConfigErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      surfaceTintColor: cs.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 32),
            const SizedBox(height: 8),
            Text(message, style: tt.bodyMedium, textAlign: TextAlign.center),
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

class PartyConfigEmptyCard extends StatelessWidget {
  const PartyConfigEmptyCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      surfaceTintColor: cs.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.group_off_outlined, color: cs.onSurfaceVariant, size: 32),
            const SizedBox(height: 8),
            Text('Nenhuma party encontrada.', style: tt.bodyMedium),
            const SizedBox(height: 12),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.background,
    this.foreground,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final fg = foreground ?? cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(label, style: tt.labelSmall?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TipBullet extends StatelessWidget {
  const _TipBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: cs.tertiary,
          activeTrackColor: cs.tertiary.withOpacity(0.2),
        ),
      ],
    );
  }
}

class _InlineSpinner extends StatelessWidget {
  const _InlineSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.canPromote,
    required this.canDemote,
    required this.isBusy,
    required this.onPromote,
    required this.onDemote,
  });

  final PartyMemberItem member;
  final bool canPromote;
  final bool canDemote;
  final bool isBusy;
  final ValueChanged<String> onPromote;
  final ValueChanged<String> onDemote;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final actions = _availableActions();
    final hasAvatar = member.avatarUrl != null && member.avatarUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: hasAvatar ? NetworkImage(member.avatarUrl!) : null,
            child: !hasAvatar
                ? Text(
                    _initial(member.displayName ?? member.displayLabel),
                    style: tt.labelMedium?.copyWith(color: cs.onSurface),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.displayLabel,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isMe) ...[
                      const SizedBox(width: 6),
                      _YouBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _roleLabel(member.role),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RoleBadge(role: member.role),
          const SizedBox(width: 6),
          if (isBusy)
            const _InlineSpinner()
          else if (actions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_horiz),
              tooltip: 'Ações',
              onPressed: () => _showActionsSheet(context, actions),
            ),
        ],
      ),
    );
  }

  List<_MemberAction> _availableActions() {
    if (member.isMe || member.status != 'active') {
      return const [];
    }
    if (member.role == 'user' && canPromote) {
      return const [_MemberAction.promote];
    }
    if (member.role == 'admin' && canDemote) {
      return const [_MemberAction.demote];
    }
    return const [];
  }

  Future<void> _showActionsSheet(
    BuildContext context,
    List<_MemberAction> actions,
  ) async {
    final result = await showModalBottomSheet<_MemberAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(member.displayLabel),
                subtitle: Text(_roleLabel(member.role)),
              ),
              for (final action in actions)
                ListTile(
                  leading: Icon(_actionIcon(action)),
                  title: Text(_actionLabel(action)),
                  onTap: () => Navigator.of(context).pop(action),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (result == _MemberAction.promote) {
      onPromote(member.userId);
    } else if (result == _MemberAction.demote) {
      onDemote(member.userId);
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'creator':
        return 'Criador';
      case 'admin':
        return 'Admin';
      default:
        return 'Membro';
    }
  }

  String _initial(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  IconData _actionIcon(_MemberAction action) {
    switch (action) {
      case _MemberAction.promote:
        return Icons.shield_outlined;
      case _MemberAction.demote:
        return Icons.arrow_downward_outlined;
    }
  }

  String _actionLabel(_MemberAction action) {
    switch (action) {
      case _MemberAction.promote:
        return 'Promover a admin';
      case _MemberAction.demote:
        return 'Rebaixar para usuário';
    }
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final label = role == 'creator'
        ? 'Criador'
        : role == 'admin'
            ? 'Admin'
            : 'Membro';
    final color = role == 'creator'
        ? cs.primary
        : role == 'admin'
            ? cs.secondary
            : cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _YouBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Text(
        'Você',
        style: tt.labelSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorInline extends StatelessWidget {
  const _ErrorInline({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: tt.bodySmall?.copyWith(color: cs.error)),
        if (onRetry != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      surfaceTintColor: cs.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

enum _MemberAction { promote, demote }
