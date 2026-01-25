/// Data Layer - Recipe Repository Implementation
/// 
/// This is the concrete implementation of the RecipeRepository interface
/// defined in the domain layer. It implements all the data operations
/// by coordinating between different data sources.
/// 
/// The repository pattern provides:
/// - A single source of truth for data operations
/// - Abstraction over data sources (local, remote, cache)
/// - Clean separation between business logic and data access
/// 
/// This implementation uses:
/// - LocalRecipeDataSource for mock recipe data
/// - LocalStorageDataSource for favorites persistence

import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/local_recipe_datasource.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/recipe_model.dart';

/// Concrete implementation of RecipeRepository.
/// 
/// This class coordinates between the mock recipe data source and
/// the local storage for favorites. It combines data from both sources
/// to provide complete recipe information including favorite status.
class RecipeRepositoryImpl implements RecipeRepository {
  final LocalRecipeDataSource _recipeDataSource;
  final LocalStorageDataSource _storageDataSource;

  RecipeRepositoryImpl({
    required LocalRecipeDataSource recipeDataSource,
    required LocalStorageDataSource storageDataSource,
  })  : _recipeDataSource = recipeDataSource,
        _storageDataSource = storageDataSource;

  /// Retrieves all recipes with their current favorite status.
  /// 
  /// This method:
  /// 1. Gets all mock recipes from the recipe data source
  /// 2. Gets the list of favorite IDs from storage
  /// 3. Merges the data to set the correct favorite status
  @override
  Future<List<Recipe>> getRecipes() async {
    // Get mock recipes from local data source
    final recipes = _recipeDataSource.getRecipes();
    
    // Get favorite IDs from local storage
    final favoriteIds = await _storageDataSource.getFavoriteIds();
    
    // Update favorite status for each recipe
    return recipes.map((recipe) {
      final isFavorite = favoriteIds.contains(recipe.id);
      return recipe.copyWith(isFavorite: isFavorite);
    }).toList();
  }

  /// Searches recipes by name (case-insensitive partial match).
  /// 
  /// The search algorithm:
  /// 1. Gets all recipes with favorite status
  /// 2. Filters recipes whose titles contain the query string
  /// 3. Search is case-insensitive (both query and title are lowercased)
  /// 
  /// [query] - The search string to match
  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await getRecipes();
    
    if (query.isEmpty) {
      return recipes;
    }
    
    final lowercaseQuery = query.toLowerCase();
    
    return recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Filters recipes by category.
  /// 
  /// [category] - The RecipeCategory to filter by
  @override
  Future<List<Recipe>> filterByCategory(RecipeCategory category) async {
    final recipes = await getRecipes();
    
    return recipes.where((recipe) {
      return recipe.category == category;
    }).toList();
  }

  /// Toggles the favorite status of a recipe.
  /// 
  /// This method:
  /// 1. Toggles the favorite in local storage
  /// 2. Finds the recipe and returns it with updated status
  /// 
  /// [recipeId] - The ID of the recipe to toggle
  @override
  Future<Recipe> toggleFavorite(String recipeId) async {
    // Toggle in storage and get new status
    final newFavoriteStatus = await _storageDataSource.toggleFavorite(recipeId);
    
    // Find the recipe and return with updated status
    final recipes = _recipeDataSource.getRecipes();
    final recipe = recipes.firstWhere((r) => r.id == recipeId);
    
    return recipe.copyWith(isFavorite: newFavoriteStatus);
  }

  /// Retrieves all favorite recipes.
  /// 
  /// This method:
  /// 1. Gets the list of favorite IDs from storage
  /// 2. Gets all recipes
  /// 3. Filters to only include favorites
  @override
  Future<List<Recipe>> getFavorites() async {
    final favoriteIds = await _storageDataSource.getFavoriteIds();
    final recipes = _recipeDataSource.getRecipes();
    
    return recipes
        .where((recipe) => favoriteIds.contains(recipe.id))
        .map((recipe) => recipe.copyWith(isFavorite: true))
        .toList();
  }
}
