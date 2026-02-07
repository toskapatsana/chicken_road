
import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';
class CategoryChips extends StatelessWidget {
  final RecipeCategory? selectedCategory;
  final Function(RecipeCategory?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: selectedCategory == null
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: selectedCategory == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: selectedCategory == null
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ...RecipeCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            final categoryColor = _getCategoryColor(category);
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : categoryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(category.displayName),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(
                  isSelected ? null : category,
                ),
                selectedColor: categoryColor,
                checkmarkColor: Colors.white,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                backgroundColor: colorScheme.surfaceContainerHighest,
                side: BorderSide(
                  color: isSelected
                      ? categoryColor
                      : colorScheme.outline.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  Color _getCategoryColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.soups:
        return Colors.blue;
      case RecipeCategory.mainDishes:
        return Colors.green;
      case RecipeCategory.snacks:
        return Colors.orange;
      case RecipeCategory.spicy:
        return Colors.red;
    }
  }
  IconData _getCategoryIcon(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.soups:
        return Icons.soup_kitchen;
      case RecipeCategory.mainDishes:
        return Icons.dinner_dining;
      case RecipeCategory.snacks:
        return Icons.fastfood;
      case RecipeCategory.spicy:
        return Icons.local_fire_department;
    }
  }
}
