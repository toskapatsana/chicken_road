
import '../../domain/entities/recipe.dart';
class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.ingredients,
    required super.steps,
    super.isFavorite,
    super.prepTime,
    super.cookTime,
    super.servings,
    super.difficulty,
    super.nutritionalInfo,
  });
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: RecipeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RecipeCategory.mainDishes,
      ),
      ingredients: List<String>.from(json['ingredients'] as List),
      steps: List<String>.from(json['steps'] as List),
      isFavorite: json['isFavorite'] as bool? ?? false,
      prepTime: json['prepTime'] as int? ?? 15,
      cookTime: json['cookTime'] as int? ?? 30,
      servings: json['servings'] as int? ?? 4,
      difficulty: RecipeDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => RecipeDifficulty.medium,
      ),
      nutritionalInfo: json['nutritionalInfo'] != null
          ? NutritionalInfo(
              calories: json['nutritionalInfo']['calories'] as int? ?? 350,
              protein: json['nutritionalInfo']['protein'] as int? ?? 25,
              carbs: json['nutritionalInfo']['carbs'] as int? ?? 20,
              fat: json['nutritionalInfo']['fat'] as int? ?? 15,
              fiber: json['nutritionalInfo']['fiber'] as int? ?? 2,
            )
          : const NutritionalInfo(
              calories: 350,
              protein: 25,
              carbs: 20,
              fat: 15,
              fiber: 2,
            ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.name,
      'ingredients': ingredients,
      'steps': steps,
      'isFavorite': isFavorite,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty.name,
      'nutritionalInfo': {
        'calories': nutritionalInfo.calories,
        'protein': nutritionalInfo.protein,
        'carbs': nutritionalInfo.carbs,
        'fat': nutritionalInfo.fat,
        'fiber': nutritionalInfo.fiber,
      },
    };
  }
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      imageUrl: recipe.imageUrl,
      category: recipe.category,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      isFavorite: recipe.isFavorite,
      prepTime: recipe.prepTime,
      cookTime: recipe.cookTime,
      servings: recipe.servings,
      difficulty: recipe.difficulty,
      nutritionalInfo: recipe.nutritionalInfo,
    );
  }
  Recipe toEntity() {
    return Recipe(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      category: category,
      ingredients: ingredients,
      steps: steps,
      isFavorite: isFavorite,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      difficulty: difficulty,
      nutritionalInfo: nutritionalInfo,
    );
  }
  @override
  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    RecipeCategory? category,
    List<String>? ingredients,
    List<String>? steps,
    bool? isFavorite,
    int? prepTime,
    int? cookTime,
    int? servings,
    RecipeDifficulty? difficulty,
    NutritionalInfo? nutritionalInfo,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }
}
