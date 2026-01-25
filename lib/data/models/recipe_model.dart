/// Data Layer - Recipe Model
/// 
/// Models in the data layer are responsible for data transformation.
/// They handle serialization/deserialization and map between external
/// data formats (JSON, API responses) and domain entities.
/// 
/// RecipeModel extends Recipe entity and adds data-layer specific
/// functionality like JSON conversion. This keeps the domain layer
/// pure and free from serialization concerns.

import '../../domain/entities/recipe.dart';

/// Data model for Recipe with serialization capabilities.
/// 
/// This model extends the domain Recipe entity and provides:
/// - Conversion from JSON (for API responses or local storage)
/// - Conversion to JSON (for persistence)
/// - Mapping to/from domain entities
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
  });

  /// Creates a RecipeModel from a JSON map.
  /// 
  /// This is typically used when:
  /// - Loading data from local storage
  /// - Parsing API responses
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
    );
  }

  /// Converts the model to a JSON map.
  /// 
  /// This is used for:
  /// - Saving data to local storage
  /// - Sending data to an API
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
    };
  }

  /// Creates a RecipeModel from a domain Recipe entity.
  /// 
  /// This is useful when you need to convert a domain entity
  /// to a model for persistence operations.
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
    );
  }

  /// Converts the model to a domain Recipe entity.
  /// 
  /// Since RecipeModel extends Recipe, this is essentially
  /// returning itself, but it makes the intent explicit.
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
    );
  }

  /// Creates a copy with updated favorite status.
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
    );
  }
}
