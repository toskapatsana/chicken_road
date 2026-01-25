/// Domain Layer - FilterByCategory Use Case
/// 
/// This use case handles filtering recipes by their category.
/// Categories help users find specific types of chicken recipes.

import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for filtering recipes by category.
/// 
/// Categories include: Soups, Main Dishes, Snacks, and Spicy.
/// This allows users to browse recipes by their preferred type.
class FilterByCategory {
  final RecipeRepository repository;

  FilterByCategory(this.repository);

  /// Executes the filter use case.
  /// 
  /// [category] - The RecipeCategory to filter by.
  /// Returns only recipes that belong to the specified category.
  Future<List<Recipe>> call(RecipeCategory category) async {
    return await repository.filterByCategory(category);
  }
}
