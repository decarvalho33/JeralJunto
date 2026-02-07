import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/auth_repository.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _panicSoundEnabled = true;
  bool _shareLiveLocation = true;

  Future<void> _signOut() async {
    await AuthRepository().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.root, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _SectionTitle('Preferências'),
          _SettingsCard(
            children: [
              SwitchListTile.adaptive(
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
                title: const Text('Notificações'),
                subtitle: const Text('Receber alertas da sua party'),
                secondary: const Icon(Icons.notifications_outlined),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                value: _panicSoundEnabled,
                onChanged: (value) =>
                    setState(() => _panicSoundEnabled = value),
                title: const Text('Som de pânico'),
                subtitle: const Text('Tocar som alto em alertas críticos'),
                secondary: const Icon(Icons.campaign_outlined),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                value: _shareLiveLocation,
                onChanged: (value) =>
                    setState(() => _shareLiveLocation = value),
                title: const Text('Compartilhar localização'),
                subtitle: const Text('Permitir localização ao vivo na party'),
                secondary: const Icon(Icons.my_location_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Conta'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Meu perfil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Termos de Serviço'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.terms),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de Privacidade'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacy),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: AppSemanticColors.danger),
              label: const Text(
                'Sair da conta',
                style: TextStyle(color: AppSemanticColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppSemanticColors.danger,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: children),
    );
  }
}
