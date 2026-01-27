/// Domain Layer - Shopping Item Entity
/// 
/// Represents an item in the user's shopping list.
/// Items can be checked off when purchased.

class ShoppingItem {
  final String id;
  final String name;
  final String? quantity;
  final String? recipeId;      // Reference to recipe it came from
  final String? recipeName;    // Recipe name for display
  final bool isChecked;
  final DateTime addedAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    this.recipeId,
    this.recipeName,
    this.isChecked = false,
    required this.addedAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? recipeId,
    String? recipeName,
    bool? isChecked,
    DateTime? addedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'isChecked': isChecked,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      recipeId: json['recipeId'] as String?,
      recipeName: json['recipeName'] as String?,
      isChecked: json['isChecked'] as bool? ?? false,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
