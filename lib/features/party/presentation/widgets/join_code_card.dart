import 'package:flutter/material.dart';

class JoinCodeCard extends StatelessWidget {
  const JoinCodeCard({
    super.key,
    required this.code,
    required this.onCopy,
    this.showCard = true,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 18),
  });

  final String code;
  final VoidCallback onCopy;
  final bool showCard;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código da party', style: tt.labelLarge),
                const SizedBox(height: 8),
                Text(
                  code,
                  style: tt.headlineSmall?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined, size: 18),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );

    if (!showCard) {
      return content;
    }

    return Card(child: content);
  }
}
