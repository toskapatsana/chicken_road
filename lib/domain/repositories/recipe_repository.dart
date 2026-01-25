/// Domain Layer - Recipe Repository Interface
/// 
/// This is the repository interface (abstract class) that defines the contract
/// for data operations. In Clean Architecture, the domain layer defines
/// interfaces that the data layer must implement.
/// 
/// This follows the Dependency Inversion Principle (DIP):
/// - High-level modules (domain) should not depend on low-level modules (data)
/// - Both should depend on abstractions
/// 
/// The domain layer knows WHAT operations are available, but doesn't know
/// HOW they are implemented. The data layer provides the implementation.

import '../entities/recipe.dart';

/// Abstract repository defining the contract for recipe data operations.
/// 
/// This interface is implemented by RecipeRepositoryImpl in the data layer.
/// Use cases depend on this interface, not the concrete implementation,
/// making the domain layer independent of data source details.
abstract class RecipeRepository {
  /// Retrieves all recipes from the data source.
  /// Returns a list of Recipe entities with their favorite status.
  Future<List<Recipe>> getRecipes();

  /// Searches recipes by name.
  /// [query] - The search string to match against recipe titles.
  /// Returns recipes whose titles contain the query (case-insensitive).
  Future<List<Recipe>> searchRecipes(String query);

  /// Filters recipes by category.
  /// [category] - The category to filter by.
  /// Returns recipes that belong to the specified category.
  Future<List<Recipe>> filterByCategory(RecipeCategory category);

  /// Toggles the favorite status of a recipe.
  /// [recipeId] - The ID of the recipe to toggle.
  /// Returns the updated recipe with the new favorite status.
  Future<Recipe> toggleFavorite(String recipeId);

  /// Retrieves all favorite recipes.
  /// Returns a list of recipes marked as favorites.
  Future<List<Recipe>> getFavorites();
}
