import 'package:flutter/material.dart';

class SynonymChipCloud extends StatelessWidget {
  final List<String> synonyms;
  final ValueChanged<String>? onSelected;

  const SynonymChipCloud({
    super.key,
    required this.synonyms,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (synonyms.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: synonyms.map((synonym) {
        return ActionChip(
          label: Text(synonym),
          labelStyle: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
          avatar: Icon(Icons.travel_explore_rounded, size: 16, color: colorScheme.primary),
          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.34),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          onPressed: onSelected == null ? null : () => onSelected!(synonym),
        );
      }).toList(growable: false),
    );
  }
}
