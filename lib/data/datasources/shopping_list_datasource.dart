
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/shopping_item.dart';

class ShoppingListDataSource {
  static const String _shoppingListKey = 'shopping_list';
  
  Future<List<ShoppingItem>> getShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shoppingListKey);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ShoppingItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
  
  Future<void> saveShoppingList(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_shoppingListKey, jsonString);
  }
  
  Future<void> addItem(ShoppingItem item) async {
    final items = await getShoppingList();
    items.add(item);
    await saveShoppingList(items);
  }
  
  Future<void> removeItem(String itemId) async {
    final items = await getShoppingList();
    items.removeWhere((item) => item.id == itemId);
    await saveShoppingList(items);
  }
  
  Future<void> toggleItemChecked(String itemId) async {
    final items = await getShoppingList();
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      items[index] = items[index].copyWith(isChecked: !items[index].isChecked);
      await saveShoppingList(items);
    }
  }
  
  Future<void> clearCheckedItems() async {
    final items = await getShoppingList();
    items.removeWhere((item) => item.isChecked);
    await saveShoppingList(items);
  }
  
  Future<void> clearAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shoppingListKey);
  }
}
