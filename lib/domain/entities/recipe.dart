enum RecipeCategory {
  soups('Soups'),
  mainDishes('Main Dishes'),
  snacks('Snacks'),
  spicy('Spicy');

  final String displayName;
  const RecipeCategory(this.displayName);
}
enum RecipeDifficulty {
  easy('Easy', 1),
  medium('Medium', 2),
  hard('Hard', 3);

  final String displayName;
  final int level;
  const RecipeDifficulty(this.displayName, this.level);
}
class NutritionalInfo {
  final int calories;   
  final int protein;    
  final int carbs;      
  final int fat;        
  final int fiber;      

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
  });
  NutritionalInfo forServings(int originalServings, int newServings) {
    final multiplier = newServings / originalServings;
    return NutritionalInfo(
      calories: (calories * multiplier).round(),
      protein: (protein * multiplier).round(),
      carbs: (carbs * multiplier).round(),
      fat: (fat * multiplier).round(),
      fiber: (fiber * multiplier).round(),
    );
  }

  NutritionalInfo copyWith({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
  }) {
    return NutritionalInfo(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
    );
  }
}
class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final RecipeCategory category;
  final List<String> ingredients;
  final List<String> steps;
  final bool isFavorite;
  final int prepTime;           
  final int cookTime;           
  final int servings;           
  final RecipeDifficulty difficulty;
  final NutritionalInfo nutritionalInfo;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
    this.prepTime = 15,
    this.cookTime = 30,
    this.servings = 4,
    this.difficulty = RecipeDifficulty.medium,
    this.nutritionalInfo = const NutritionalInfo(
      calories: 350,
      protein: 25,
      carbs: 20,
      fat: 15,
      fiber: 2,
    ),
  });
  int get totalTime => prepTime + cookTime;
  Recipe copyWith({
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
    return Recipe(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
