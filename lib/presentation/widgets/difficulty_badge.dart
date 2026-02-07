
import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';

class DifficultyBadge extends StatelessWidget {
  final RecipeDifficulty difficulty;
  final bool showLabel;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(3, (index) {
            final isActive = index < difficulty.level;
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                isActive ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                size: 14,
                color: isActive ? color : color.withOpacity(0.3),
              ),
            );
          }),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              difficulty.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColor() {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return Colors.green;
      case RecipeDifficulty.medium:
        return Colors.orange;
      case RecipeDifficulty.hard:
        return Colors.red;
    }
  }
}
