/// Presentation Layer - Shopping Provider
/// 
/// Manages shopping list state and persistence.

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/shopping_item.dart';
import '../../data/datasources/shopping_list_datasource.dart';

class ShoppingProvider extends ChangeNotifier {
  final ShoppingListDataSource _dataSource;
  final Uuid _uuid = const Uuid();
  
  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => _items;
  
  List<ShoppingItem> get uncheckedItems => 
      _items.where((item) => !item.isChecked).toList();
  
  List<ShoppingItem> get checkedItems => 
      _items.where((item) => item.isChecked).toList();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  ShoppingProvider({ShoppingListDataSource? dataSource})
      : _dataSource = dataSource ?? ShoppingListDataSource();
  
  Future<void> loadShoppingList() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _items = await _dataSource.getShoppingList();
    } catch (_) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addItem({
    required String name,
    String? quantity,
    String? recipeId,
    String? recipeName,
  }) async {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      recipeId: recipeId,
      recipeName: recipeName,
      addedAt: DateTime.now(),
    );
    
    _items.add(item);
    notifyListeners();
    
    await _dataSource.saveShoppingList(_items);
  }
  
  Future<void> addIngredientsFromRecipe({
    required List<String> ingredients,
    required String recipeId,
    required String recipeName,
  }) async {
    for (final ingredient in ingredients) {
      // Parse ingredient to extract quantity and name
      final parsed = _parseIngredient(ingredient);
      
      // Check if item already exists
      final exists = _items.any(
        (item) => item.name.toLowerCase() == parsed['name']!.toLowerCase(),
      );
      
      if (!exists) {
        final item = ShoppingItem(
          id: _uuid.v4(),
          name: parsed['name']!,
          quantity: parsed['quantity'],
          recipeId: recipeId,
          recipeName: recipeName,
          addedAt: DateTime.now(),
        );
        _items.add(item);
      }
    }
    
    notifyListeners();
    await _dataSource.saveShoppingList(_items);
  }
  
  Map<String, String?> _parseIngredient(String ingredient) {
    // Simple parsing: try to extract quantity from the beginning
    final regex = RegExp(r'^([\d\/\s]+(?:cup|cups|tbsp|tsp|lb|lbs|oz|g|kg|ml|l|can|cans|clove|cloves|inch|large|small|medium)?\s*)(.+)$', caseSensitive: false);
    final match = regex.firstMatch(ingredient.trim());
    
    if (match != null) {
      return {
        'quantity': match.group(1)?.trim(),
        'name': match.group(2)?.trim() ?? ingredient,
      };
    }
    
    return {
      'quantity': null,
      'name': ingredient,
    };
  }
  
  Future<void> removeItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
    await _dataSource.saveShoppingList(_items);
  }
  
  Future<void> toggleItemChecked(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        isChecked: !_items[index].isChecked,
      );
      notifyListeners();
      await _dataSource.saveShoppingList(_items);
    }
  }
  
  Future<void> clearCheckedItems() async {
    _items.removeWhere((item) => item.isChecked);
    notifyListeners();
    await _dataSource.saveShoppingList(_items);
  }
  
  Future<void> clearAllItems() async {
    _items.clear();
    notifyListeners();
    await _dataSource.clearAllItems();
  }
  
  bool hasItemsFromRecipe(String recipeId) {
    return _items.any((item) => item.recipeId == recipeId);
  }
}
