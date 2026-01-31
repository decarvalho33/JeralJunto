import 'package:flutter/material.dart';

import '../../../party/presentation/pages/party_screen.dart';
import '../widgets/header_overlay.dart';
import '../widgets/map_background_placeholder.dart';
import '../widgets/schedule_sheet_placeholder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openParty(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: SafeArea(child: PartyScreen()),
        ),
      ),
    );
  }

  void _openProfileMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Meu perfil'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configurações'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapBackgroundPlaceholder(),
          const Align(
            alignment: Alignment.bottomCenter,
            child: ScheduleSheetPlaceholder(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: HeaderOverlay(
              onPartyTap: () => _openParty(context),
              onAvatarTap: () => _openProfileMenu(context),
            ),
          ),
        ],
      ),
    );
  }
}
