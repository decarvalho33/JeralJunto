import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/party_block.dart';
import '../../domain/entities/party_member_location.dart';

class PartyBottomSheet extends StatelessWidget {
  const PartyBottomSheet._({
    required this.title,
    this.subtitle,
    this.body,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String? subtitle;
  final Widget? body;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  factory PartyBottomSheet.friend({
    required PartyMemberLocation member,
    required double? distanceMeters,
    required VoidCallback onRescue,
  }) {
    final distanceText = distanceMeters == null
        ? 'Distância desconhecida'
        : distanceMeters < 1000
            ? '${distanceMeters.toStringAsFixed(0)} m de você'
            : '${(distanceMeters / 1000).toStringAsFixed(1)} km de você';

    return PartyBottomSheet._(
      title: member.name,
      subtitle: distanceText,
      primaryAction: _PrimaryAction(
        label: 'Resgate',
        onPressed: onRescue,
      ),
    );
  }

  factory PartyBottomSheet.block({
    required PartyBlock block,
    required VoidCallback onGo,
  }) {
    return PartyBottomSheet._(
      title: block.name,
      subtitle: block.status,
      body: _StatusPill(
        label: 'Lotação ${block.occupancyPercent}%',
      ),
      primaryAction: _PrimaryAction(
        label: 'Ir pra lá',
        onPressed: onGo,
      ),
    );
  }

  factory PartyBottomSheet.party({
    required String title,
    required String subtitle,
    required VoidCallback onShare,
  }) {
    return PartyBottomSheet._(
      title: title,
      subtitle: subtitle,
      body: const Text(
        'A galera tá aqui. Marca o ponto de encontro e fica de olho no mapa.',
        style: TextStyle(color: AppColors.muted),
      ),
      primaryAction: _PrimaryAction(
        label: 'Compartilhar código',
        onPressed: onShare,
      ),
    );
  }

  factory PartyBottomSheet.emptyParty({
    required VoidCallback onCreate,
    required VoidCallback onJoin,
  }) {
    return PartyBottomSheet._(
      title: 'Você está sozinho no carnaval?',
      subtitle: 'Crie sua party ou entre com um código.',
      primaryAction: _PrimaryAction(
        label: 'Criar Party',
        onPressed: onCreate,
      ),
      secondaryAction: OutlinedButton(
        onPressed: onJoin,
        child: const Text('Entrar com código'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
          if (body != null) ...[
            const SizedBox(height: 16),
            body!,
          ],
          const SizedBox(height: 20),
          if (primaryAction != null) primaryAction!,
          if (secondaryAction != null) ...[
            const SizedBox(height: 12),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
