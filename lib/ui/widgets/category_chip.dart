import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Icon? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isLoading;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  }) : isLoading = false;

  const CategoryChip.skeleton({super.key})
    : label = '                     ',
      isSelected = false,
      onTap = null,
      icon = null,
      isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget chip = ChoiceChip.elevated(
      avatar: icon != null
          ? Icon(
              icon!.icon,
              size: 18,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            )
          : null,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );

    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: chip,
      );
    }

    return chip;
  }
}
