import 'package:cookbook_app/data/models/category_model.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        return ChoiceChip.elevated(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (value) => onSelect(value),
          showCheckmark: false,
          selectedColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(15),
          ),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      },
    );
  }
}
