/// Domain Layer - User Recipe Data Entity
/// 
/// Stores user-specific data for each recipe:
/// - Personal rating
/// - Notes
/// - Cooking history

class UserRecipeData {
  final String recipeId;
  final int? rating;              // 1-5 stars, null if not rated
  final String? notes;            // User's personal notes
  final List<DateTime> cookingHistory;  // Dates when recipe was cooked
  final int selectedServings;     // User's preferred serving size

  const UserRecipeData({
    required this.recipeId,
    this.rating,
    this.notes,
    this.cookingHistory = const [],
    this.selectedServings = 4,
  });

  /// Number of times the user has cooked this recipe
  int get timesMade => cookingHistory.length;

  /// Last time the recipe was cooked, null if never
  DateTime? get lastCooked => 
      cookingHistory.isEmpty ? null : cookingHistory.last;

  UserRecipeData copyWith({
    String? recipeId,
    int? rating,
    String? notes,
    List<DateTime>? cookingHistory,
    int? selectedServings,
  }) {
    return UserRecipeData(
      recipeId: recipeId ?? this.recipeId,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      cookingHistory: cookingHistory ?? this.cookingHistory,
      selectedServings: selectedServings ?? this.selectedServings,
    );
  }

  /// Add a new cooking entry
  UserRecipeData addCookingEntry() {
    return copyWith(
      cookingHistory: [...cookingHistory, DateTime.now()],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'rating': rating,
      'notes': notes,
      'cookingHistory': cookingHistory.map((d) => d.toIso8601String()).toList(),
      'selectedServings': selectedServings,
    };
  }

  factory UserRecipeData.fromJson(Map<String, dynamic> json) {
    return UserRecipeData(
      recipeId: json['recipeId'] as String,
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
      cookingHistory: (json['cookingHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      selectedServings: json['selectedServings'] as int? ?? 4,
    );
  }
}
