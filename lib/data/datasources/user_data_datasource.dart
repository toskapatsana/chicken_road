
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_recipe_data.dart';

class UserDataDataSource {
  static const String _userDataPrefix = 'user_recipe_data_';
  static const String _allRecipeIdsKey = 'user_recipe_ids';
  
  Future<UserRecipeData?> getUserData(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_userDataPrefix$recipeId');
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserRecipeData.fromJson(json);
    } catch (_) {
      return null;
    }
  }
  
  Future<void> saveUserData(UserRecipeData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString('$_userDataPrefix${data.recipeId}', jsonString);
    final existingIds = prefs.getStringList(_allRecipeIdsKey) ?? [];
    if (!existingIds.contains(data.recipeId)) {
      existingIds.add(data.recipeId);
      await prefs.setStringList(_allRecipeIdsKey, existingIds);
    }
  }
  
  Future<Map<String, UserRecipeData>> getAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final recipeIds = prefs.getStringList(_allRecipeIdsKey) ?? [];
    
    final result = <String, UserRecipeData>{};
    for (final id in recipeIds) {
      final data = await getUserData(id);
      if (data != null) {
        result[id] = data;
      }
    }
    
    return result;
  }
  
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final recipeIds = prefs.getStringList(_allRecipeIdsKey) ?? [];
    
    for (final id in recipeIds) {
      await prefs.remove('$_userDataPrefix$id');
    }
    await prefs.remove(_allRecipeIdsKey);
  }
}
