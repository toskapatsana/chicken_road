/// Presentation Layer - Recipe Card Widget
/// 
/// This widget displays a recipe in a card format.
/// It's used in the recipe lists on the Home and Favorites screens.
/// 
/// The card shows:
/// - Recipe image
/// - Title
/// - Short description
/// - Category badge
/// - Favorite button (heart icon)

import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';

/// A card widget that displays recipe information.
/// 
/// [recipe] - The recipe data to display
/// [onTap] - Callback when the card is tapped (navigate to detail)
/// [onFavoriteToggle] - Callback when the favorite button is pressed
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image with gradient overlay
            Stack(
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Gradient overlay for better text visibility
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(recipe.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recipe.category.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withOpacity(0.9),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite
                              ? Colors.red
                              : Colors.grey[600],
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Recipe info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Time and difficulty row
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: _getDifficultyColor(recipe.difficulty),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        recipe.difficulty.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getDifficultyColor(recipe.difficulty),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a color based on the recipe category.
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

  /// Returns a color based on the recipe difficulty.
  Color _getDifficultyColor(RecipeDifficulty difficulty) {
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
