import 'package:flutter/material.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  void _showComingSoon(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$label" chegando em breve.'),
        backgroundColor: cs.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: ListView(
        children: [
          Text('Sua party em tempo real', style: tt.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'Gerencie o grupo, veja quem está junto e mantenha todo mundo alinhado.',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Criar nova party'),
              subtitle: const Text('Defina nome, regras e convites'),
              onTap: () => _showComingSoon(context, 'Criar nova party'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_2_outlined),
              title: const Text('Entrar com convite'),
              subtitle: const Text('Use QR ou link compartilhado'),
              onTap: () => _showComingSoon(context, 'Entrar com convite'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Membros da party'),
              subtitle: const Text('Quem está com você agora'),
              onTap: () => _showComingSoon(context, 'Membros da party'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Regras e segurança'),
              subtitle: const Text('Controle de acesso e privacidade'),
              onTap: () => _showComingSoon(context, 'Regras e segurança'),
            ),
          ),
        ],
      ),
    );
  }
}
