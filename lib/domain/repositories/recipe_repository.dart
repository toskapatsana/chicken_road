
import '../entities/recipe.dart';
abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes();
  Future<List<Recipe>> searchRecipes(String query);
  Future<List<Recipe>> filterByCategory(RecipeCategory category);
  Future<Recipe> toggleFavorite(String recipeId);
  Future<List<Recipe>> getFavorites();
}
