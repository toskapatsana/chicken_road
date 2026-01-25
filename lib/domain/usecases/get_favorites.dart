/// Domain Layer - GetFavorites Use Case
/// 
/// This use case retrieves all recipes that have been marked as favorites.
/// Favorites are persisted locally using SharedPreferences.

import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for retrieving favorite recipes.
/// 
/// This use case returns only the recipes that the user has added
/// to their favorites list.
class GetFavorites {
  final RecipeRepository repository;

  GetFavorites(this.repository);

  /// Executes the get favorites use case.
  /// 
  /// Returns a list of recipes that are marked as favorites.
  /// The list is determined by checking the persisted favorite IDs
  /// against the available recipes.
  Future<List<Recipe>> call() async {
    return await repository.getFavorites();
  }
}
