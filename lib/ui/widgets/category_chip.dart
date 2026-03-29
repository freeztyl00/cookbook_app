import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isLoading;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  }) : isLoading = false;

  const CategoryChip.skeleton({super.key})
    : label = '               ',
      isSelected = false,
      onTap = null,
      isLoading = true;

  @override
  Widget build(BuildContext context) {
    Widget chip = ChoiceChip.elevated(
      label: Text(label),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      showCheckmark: false,
      selectedColor: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );

    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: chip,
      );
    }

    return chip;
  }
}
