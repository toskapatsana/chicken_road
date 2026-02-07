
import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';

class NutritionalInfoCard extends StatelessWidget {
  final NutritionalInfo nutritionalInfo;
  final int originalServings;
  final int currentServings;

  const NutritionalInfoCard({
    super.key,
    required this.nutritionalInfo,
    required this.originalServings,
    required this.currentServings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final adjusted = nutritionalInfo.forServings(originalServings, currentServings);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Nutrition per serving',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (originalServings != currentServings) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Adjusted',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NutrientItem(
                  label: 'Calories',
                  value: '${adjusted.calories}',
                  unit: 'kcal',
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                ),
              ),
              Expanded(
                child: _NutrientItem(
                  label: 'Protein',
                  value: '${adjusted.protein}',
                  unit: 'g',
                  color: Colors.red,
                  icon: Icons.egg_alt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NutrientItem(
                  label: 'Carbs',
                  value: '${adjusted.carbs}',
                  unit: 'g',
                  color: Colors.amber,
                  icon: Icons.grain,
                ),
              ),
              Expanded(
                child: _NutrientItem(
                  label: 'Fat',
                  value: '${adjusted.fat}',
                  unit: 'g',
                  color: Colors.purple,
                  icon: Icons.water_drop,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _NutrientItem(
            label: 'Fiber',
            value: '${adjusted.fiber}',
            unit: 'g',
            color: Colors.green,
            icon: Icons.grass,
          ),
        ],
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _NutrientItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$value $unit',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
