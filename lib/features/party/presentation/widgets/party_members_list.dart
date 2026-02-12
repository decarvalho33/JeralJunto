import 'package:flutter/material.dart';

import '../../domain/models/party_member.dart';

class PartyMemberListTile extends StatelessWidget {
  const PartyMemberListTile({
    super.key,
    required this.title,
    required this.initialsLabel,
    this.subtitle,
    this.avatarUrl,
    this.isMe = false,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  final Widget title;
  final String initialsLabel;
  final String? subtitle;
  final String? avatarUrl;
  final bool isMe;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final effectiveTrailing = trailing ?? (isMe ? _MeBadge() : null);

    return ListTile(
      onTap: onTap,
      contentPadding: contentPadding,
      leading: CircleAvatar(
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
        child: !hasAvatar
            ? Text(
                _initials(initialsLabel),
                style: tt.labelLarge?.copyWith(color: cs.onSurface),
              )
            : null,
      ),
      title: title,
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: effectiveTrailing,
    );
  }

  String _initials(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class PartyMembersList extends StatelessWidget {
  const PartyMembersList({
    super.key,
    required this.members,
    this.currentUserId,
  });

  final List<PartyMember> members;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        child: Text(
          'Nenhum membro encontrado.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: [
        for (final member in members) ...[
          _MemberCard(
            name: member.displayName ?? member.idUsuario,
            role: _roleLabel(member.cargo),
            avatarUrl: member.avatarUrl,
            isMe: currentUserId != null && member.idUsuario == currentUserId,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  String _roleLabel(String cargo) {
    switch (cargo.toLowerCase()) {
      case 'creator':
        return 'Criador';
      case 'admin':
        return 'Admin';
      default:
        return 'Membro';
    }
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.isMe,
  });

  final String name;
  final String role;
  final String? avatarUrl;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
            child: !hasAvatar
                ? Text(
                    _initials(name),
                    style: tt.labelLarge?.copyWith(color: cs.onSurface),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      _YouBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RoleBadge(role: role),
        ],
      ),
    );
  }

  String _initials(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final colors = _roleColors(role, cs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        role,
        style: tt.labelSmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _RolePalette _roleColors(String role, ColorScheme cs) {
    switch (role) {
      case 'Criador':
        return _RolePalette(
          background: cs.primary.withOpacity(0.12),
          foreground: cs.primary,
          border: cs.primary.withOpacity(0.2),
        );
      case 'Admin':
        return _RolePalette(
          background: cs.tertiary.withOpacity(0.12),
          foreground: cs.tertiary,
          border: cs.tertiary.withOpacity(0.2),
        );
      default:
        return _RolePalette(
          background: cs.surfaceVariant,
          foreground: cs.onSurfaceVariant,
          border: cs.outlineVariant,
        );
    }
  }
}

class _RolePalette {
  const _RolePalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
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

class _MeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Você',
        style: tt.labelSmall?.copyWith(color: cs.primary),
      ),
    );
  }
}
