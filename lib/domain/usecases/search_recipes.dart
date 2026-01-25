/// Domain Layer - SearchRecipes Use Case
/// 
/// This use case handles the search functionality for recipes.
/// It encapsulates the business logic for searching recipes by name.

import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for searching recipes by name.
/// 
/// This use case takes a search query and returns matching recipes.
/// The search is case-insensitive and matches partial strings.
class SearchRecipes {
  final RecipeRepository repository;

  SearchRecipes(this.repository);

  /// Executes the search use case.
  /// 
  /// [query] - The search string to match against recipe titles.
  /// Returns recipes whose titles contain the query string.
  /// 
  /// Example: query "chicken" would match "Grilled Chicken", "Chicken Soup", etc.
  Future<List<Recipe>> call(String query) async {
    return await repository.searchRecipes(query);
  }
}
