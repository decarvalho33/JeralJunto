import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Placeholder temporário da política de privacidade.\n\n'
          'Substituir este texto com a política oficial quando estiver '
          'disponível.',
          style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
        ),
      ),
    );
  }
}
