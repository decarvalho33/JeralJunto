import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../party/presentation/pages/party_screen.dart';
import '../widgets/header_overlay.dart';
import '../widgets/map_background_placeholder.dart';
import '../widgets/schedule_sheet_placeholder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('Usuario')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      final url = response?['avatar_url'] as String?;
      if (mounted) {
        setState(() => _avatarUrl = url);
      }
    } catch (_) {
      // silently ignore for MVP
    }
  }

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
    final rootContext = context;
    showModalBottomSheet<void>(
      context: rootContext,
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
                leading: const Icon(Icons.description_outlined),
                title: const Text('Termos de Serviço'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(rootContext).pushNamed(AppRoutes.terms);
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de Privacidade'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(rootContext).pushNamed(AppRoutes.privacy);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await AuthRepository().signOut();
                  if (rootContext.mounted) {
                    Navigator.of(rootContext).pushNamedAndRemoveUntil(
                      AppRoutes.root,
                      (_) => false,
                    );
                  }
                },
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
              avatarUrl: _avatarUrl,
            ),
          ),
        ],
      ),
    );
  }
}
