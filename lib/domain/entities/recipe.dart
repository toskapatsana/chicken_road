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

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
  });

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
