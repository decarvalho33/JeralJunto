import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const List<String> _labels = [
    'Minha party',
    'Blocos',
    'Segurança',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _labels.map((label) {
        final isSelected = selected.contains(label);
        return FilterChip(
          selected: isSelected,
          label: Text(label),
          onSelected: (_) => onToggle(label),
          selectedColor: AppColors.accent.withOpacity(0.12),
          checkmarkColor: AppColors.accent,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(color: AppColors.line),
        );
      }).toList(),
    );
  }
}
