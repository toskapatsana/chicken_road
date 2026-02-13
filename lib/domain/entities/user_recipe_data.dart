
class UserRecipeData {
  final String recipeId;
  final int? rating;              
  final String? notes;            
  final List<DateTime> cookingHistory;  
  final int selectedServings;     

  const UserRecipeData({
    required this.recipeId,
    this.rating,
    this.notes,
    this.cookingHistory = const [],
    this.selectedServings = 4,
  });
  int get timesMade => cookingHistory.length;
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
