
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';
class ToggleFavorite {
  final RecipeRepository repository;

  ToggleFavorite(this.repository);
  Future<Recipe> call(String recipeId) async {
    return await repository.toggleFavorite(recipeId);
  }
}
