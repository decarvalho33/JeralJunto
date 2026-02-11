import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
    required this.percentage,
    required this.isCharging,
  });

  final int percentage;
  final bool isCharging;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final level = percentage.clamp(0, 100).toInt();
    final color = batteryColor(level, cs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(
            isCharging ? Icons.bolt : Icons.battery_full,
            size: 18,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '$level%',
            style: tt.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

Color batteryColor(int level, ColorScheme cs) {
  if (level >= 60) {
    return AppSemanticColors.live;
  }
  if (level >= 30) {
    return AppSemanticColors.highlight;
  }
  return cs.error;
}
