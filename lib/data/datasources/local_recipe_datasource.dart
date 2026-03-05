import '../models/recipe_model.dart';
import 'recipes/soup_recipes.dart';
import 'recipes/main_dish_recipes.dart';
import 'recipes/snack_recipes.dart';
import 'recipes/spicy_recipes.dart';

class LocalRecipeDataSource {
  List<RecipeModel> getRecipes() {
    return [
      ...soupRecipes,
      ...mainDishRecipes,
      ...snackRecipes,
      ...spicyRecipes,
    ];
  }
}
