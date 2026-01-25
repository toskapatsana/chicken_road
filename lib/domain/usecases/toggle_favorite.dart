/// Domain Layer - ToggleFavorite Use Case
/// 
/// This use case handles adding/removing recipes from favorites.
/// It's a toggle operation - if the recipe is a favorite, it removes it;
/// if it's not a favorite, it adds it.

import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for toggling the favorite status of a recipe.
/// 
/// This use case persists the favorite status change and returns
/// the updated recipe with the new favorite status.
class ToggleFavorite {
  final RecipeRepository repository;

  ToggleFavorite(this.repository);

  /// Executes the toggle favorite use case.
  /// 
  /// [recipeId] - The unique identifier of the recipe to toggle.
  /// Returns the recipe with its updated favorite status.
  /// 
  /// The actual persistence of favorites is handled by the repository
  /// implementation using SharedPreferences.
  Future<Recipe> call(String recipeId) async {
    return await repository.toggleFavorite(recipeId);
  }
}
