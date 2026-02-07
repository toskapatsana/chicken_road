
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';
class GetFavorites {
  final RecipeRepository repository;

  GetFavorites(this.repository);
  Future<List<Recipe>> call() async {
    return await repository.getFavorites();
  }
}
