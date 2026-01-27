/// Domain Layer - Recipe Entity
/// 
/// This is the core business entity that represents a Recipe in our domain.
/// Entities are the innermost layer in Clean Architecture and contain
/// enterprise-wide business rules. They are independent of any external
/// frameworks or dependencies.
/// 
/// The Recipe entity is immutable and contains only the essential properties
/// that define what a recipe is in our business domain.

/// Enum representing recipe categories
enum RecipeCategory {
  soups('Soups'),
  mainDishes('Main Dishes'),
  snacks('Snacks'),
  spicy('Spicy');

  final String displayName;
  const RecipeCategory(this.displayName);
}

/// Enum representing recipe difficulty levels
enum RecipeDifficulty {
  easy('Easy', 1),
  medium('Medium', 2),
  hard('Hard', 3);

  final String displayName;
  final int level;
  const RecipeDifficulty(this.displayName, this.level);
}

/// Nutritional information per serving
class NutritionalInfo {
  final int calories;   // kcal
  final int protein;    // grams
  final int carbs;      // grams
  final int fat;        // grams
  final int fiber;      // grams

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
  });

  /// Calculate nutritional info for different number of servings
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

/// Recipe Entity - Core business object
/// 
/// This entity is used throughout the domain and presentation layers.
/// It represents the pure business concept of a recipe without any
/// data-layer concerns like JSON serialization.
class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final RecipeCategory category;
  final List<String> ingredients;
  final List<String> steps;
  final bool isFavorite;
  
  // New fields for enhanced functionality
  final int prepTime;           // preparation time in minutes
  final int cookTime;           // cooking time in minutes
  final int servings;           // base number of servings
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

  /// Total time (prep + cook) in minutes
  int get totalTime => prepTime + cookTime;

  /// Creates a copy of the recipe with optional parameter overrides.
  /// This is useful for updating the favorite status without mutating
  /// the original entity.
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
