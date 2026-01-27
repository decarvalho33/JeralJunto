import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Placeholder temporário dos termos de uso.\n\n'
          'Substituir este texto com os termos oficiais quando estiverem '
          'disponíveis.',
          style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
        ),
      ),
    );
  }
}
