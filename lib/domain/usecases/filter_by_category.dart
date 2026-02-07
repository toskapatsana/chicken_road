
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';
class FilterByCategory {
  final RecipeRepository repository;

  FilterByCategory(this.repository);
  Future<List<Recipe>> call(RecipeCategory category) async {
    return await repository.filterByCategory(category);
  }
}
