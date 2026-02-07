
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/local_recipe_datasource.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/recipe_model.dart';
class RecipeRepositoryImpl implements RecipeRepository {
  final LocalRecipeDataSource _recipeDataSource;
  final LocalStorageDataSource _storageDataSource;

  RecipeRepositoryImpl({
    required LocalRecipeDataSource recipeDataSource,
    required LocalStorageDataSource storageDataSource,
  })  : _recipeDataSource = recipeDataSource,
        _storageDataSource = storageDataSource;
  @override
  Future<List<Recipe>> getRecipes() async {
    final recipes = _recipeDataSource.getRecipes();
    final favoriteIds = await _storageDataSource.getFavoriteIds();
    return recipes.map((recipe) {
      final isFavorite = favoriteIds.contains(recipe.id);
      return recipe.copyWith(isFavorite: isFavorite);
    }).toList();
  }
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
  @override
  Future<List<Recipe>> filterByCategory(RecipeCategory category) async {
    final recipes = await getRecipes();
    
    return recipes.where((recipe) {
      return recipe.category == category;
    }).toList();
  }
  @override
  Future<Recipe> toggleFavorite(String recipeId) async {
    final newFavoriteStatus = await _storageDataSource.toggleFavorite(recipeId);
    final recipes = _recipeDataSource.getRecipes();
    final recipe = recipes.firstWhere((r) => r.id == recipeId);
    
    return recipe.copyWith(isFavorite: newFavoriteStatus);
  }
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
