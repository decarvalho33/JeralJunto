import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/models/party_member_battery.dart';
import 'party_shared_widgets.dart';

class PartyPeopleHeader extends StatelessWidget {
  const PartyPeopleHeader({
    super.key,
    required this.partyName,
    required this.subtitle,
    required this.memberCount,
    required this.members,
  });

  final String partyName;
  final String subtitle;
  final int memberCount;
  final List<PartyMemberBattery> members;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final average = members.isEmpty
        ? 0
        : (members.fold<int>(0, (sum, member) => sum + member.batteryLevel) /
                  members.length)
              .round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withOpacity(0.85),
            AppSemanticColors.highlight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusPill(label: 'AO VIVO'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.battery_full, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Média $average%',
                        style: tt.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              partyName,
              style: tt.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: tt.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(label: 'Membros', value: memberCount.toString()),
              ],
            ),
            const SizedBox(height: 16),
            PartyAvatarStack(members: members),
          ],
        ),
      ),
    );
  }
}

class PartyActionRow extends StatelessWidget {
  const PartyActionRow({
    super.key,
    required this.onInviteTap,
    required this.onCopyLinkTap,
    required this.onSettingsTap,
    this.showSettings = true,
  });

  final VoidCallback onInviteTap;
  final VoidCallback onCopyLinkTap;
  final VoidCallback onSettingsTap;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onInviteTap,
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
            label: const Text('Convidar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCopyLinkTap,
            icon: const Icon(Icons.link, size: 18),
            label: const Text('Copiar link'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        if (showSettings) ...[
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ],
    );
  }
}

class PartyInviteCodeCard extends StatelessWidget {
  const PartyInviteCodeCard({
    super.key,
    required this.code,
    required this.onCopy,
  });

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.2),
            cs.tertiary.withOpacity(0.12),
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
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Row(
          children: [
            Expanded(
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
                  const SizedBox(height: 6),
                  Text(
                    code,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Copiar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartyRulesCard extends StatelessWidget {
  const PartyRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.tertiary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: cs.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Regras da party', style: tt.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Configurações ativas',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RuleRow(
            icon: Icons.place_outlined,
            text: 'Localização é opcional',
            boxed: true,
          ),
          _RuleRow(
            icon: Icons.lock_outline,
            text: 'Só membros veem os dados',
            boxed: true,
          ),
          _RuleRow(
            icon: Icons.link_outlined,
            text: 'Acesso apenas por convite',
            boxed: true,
          ),
        ],
      ),
    );
  }
}

class SafetyTipsCard extends StatelessWidget {
  const SafetyTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flash_on, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dicas de segurança', style: tt.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Para sua tranquilidade',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _TipItem(
            index: 1,
            text: 'Combine um ponto de encontro fixo com o grupo',
          ),
          const _TipItem(
            index: 2,
            text: 'Mantenha a bateria do celular carregada',
          ),
          const _TipItem(
            index: 3,
            text: 'Compartilhe sua localização com alguém de confiança',
          ),
        ],
      ),
    );
  }
}

class PartyMemberBatteryCard extends StatelessWidget {
  const PartyMemberBatteryCard({super.key, required this.members});

  final List<PartyMemberBattery> members;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final total = members.fold<int>(
      0,
      (sum, member) => sum + member.batteryLevel,
    );
    final average = members.isEmpty ? 0 : (total / members.length).round();
    final lowCount = members.where((member) => member.batteryLevel < 25).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.battery_full, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bateria do grupo', style: tt.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Status do aparelho dos membros conectados',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Média $average%',
                  style: tt.labelLarge?.copyWith(color: cs.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _BatteryPill(
                  label: 'Baixas',
                  value: lowCount.toString(),
                  color: cs.error,
                ),
                const SizedBox(width: 8),
                _BatteryPill(
                  label: 'Conectados',
                  value: members.length.toString(),
                  color: AppSemanticColors.live,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PartyMemberCard extends StatelessWidget {
  const PartyMemberCard({
    super.key,
    required this.member,
    required this.isCurrentUser,
    required this.onViewOnMap,
    required this.onNavigateTo,
    required this.onPromote,
    required this.onRemove,
  });

  final PartyMemberBattery member;
  final bool isCurrentUser;
  final ValueChanged<PartyMemberBattery> onViewOnMap;
  final ValueChanged<PartyMemberBattery> onNavigateTo;
  final ValueChanged<PartyMemberBattery> onPromote;
  final ValueChanged<PartyMemberBattery> onRemove;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final avatarColor = member.accentColor ?? cs.primaryContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: avatarColor,
                      child: Text(
                        member.name.isNotEmpty ? member.name[0] : '?',
                        style: tt.titleMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: member.isOnline
                              ? AppSemanticColors.live
                              : cs.outline,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(member.name, style: tt.titleSmall),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            _PillLabel(text: 'Você', color: cs.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.role,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: member.batteryLevel.clamp(0, 100) / 100,
                          minHeight: 6,
                          color: batteryColor(member.batteryLevel, cs),
                          backgroundColor: cs.surfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Atualizado ${member.lastUpdate}',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                BatteryIndicator(
                  percentage: member.batteryLevel,
                  isCharging: member.isCharging,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionChip(
                  icon: Icons.map_outlined,
                  label: 'Mapa',
                  color: cs.primary,
                  onPressed: () => onViewOnMap(member),
                ),
                _ActionChip(
                  icon: Icons.navigation_outlined,
                  label: 'Navegar',
                  color: cs.secondary,
                  onPressed: () => onNavigateTo(member),
                ),
                _ActionChip(
                  icon: Icons.shield_outlined,
                  label: 'Promover',
                  color: cs.tertiary,
                  onPressed: () => onPromote(member),
                ),
                if (!isCurrentUser)
                  _ActionChip(
                    icon: Icons.person_remove_outlined,
                    label: 'Remover',
                    color: cs.error,
                    onPressed: () => onRemove(member),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PartyAvatarStack extends StatelessWidget {
  const PartyAvatarStack({super.key, required this.members, this.maxCount = 4});

  final List<PartyMemberBattery> members;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = members.length;
    final display = members.take(maxCount).toList();
    final remaining = count - display.length;

    return Row(
      children: [
        SizedBox(
          height: 36,
          width: display.length * 22.0 + 36,
          child: Stack(
            children: [
              for (var i = 0; i < display.length; i++)
                Positioned(
                  left: i * 22,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        display[i].accentColor ?? cs.primaryContainer,
                    child: Text(
                      display[i].name.isNotEmpty ? display[i].name[0] : '?',
                      style: TextStyle(color: cs.onPrimaryContainer),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          remaining > 0 ? '+$remaining membros' : 'Todos juntos',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppSemanticColors.live,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelSmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: tt.titleSmall?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text, this.boxed = false});

  final IconData icon;
  final String text;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final iconWidget = boxed
        ? Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
          )
        : Icon(icon, size: 18, color: cs.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              index.toString(),
              style: tt.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
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

class _BatteryPill extends StatelessWidget {
  const _BatteryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(label, style: tt.labelSmall?.copyWith(color: color)),
          const SizedBox(width: 6),
          Text(value, style: tt.labelLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: tt.labelLarge?.copyWith(color: color)),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.5))),
      backgroundColor: color.withOpacity(0.08),
      onPressed: onPressed,
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: tt.labelSmall?.copyWith(color: color)),
    );
  }
}
