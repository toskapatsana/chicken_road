/// Data Layer - Local Storage Data Source
/// 
/// This data source handles persistent storage of user preferences,
/// specifically the favorite recipes. It uses SharedPreferences to
/// store data locally on the device.
/// 
/// SharedPreferences provides a simple key-value storage that persists
/// across app restarts. We use it to store a list of favorite recipe IDs.

import 'package:shared_preferences/shared_preferences.dart';

/// Local storage data source for managing favorites persistence.
/// 
/// This class provides methods to:
/// - Get the list of favorite recipe IDs
/// - Add a recipe to favorites
/// - Remove a recipe from favorites
/// - Check if a recipe is a favorite
class LocalStorageDataSource {
  /// The key used to store favorites in SharedPreferences
  static const String _favoritesKey = 'favorite_recipes';

  /// Retrieves the list of favorite recipe IDs from local storage.
  /// 
  /// Returns an empty list if no favorites have been saved yet.
  /// The favorites are stored as a JSON-encoded list of strings.
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey);
    return favorites ?? [];
  }

  /// Adds a recipe ID to the favorites list.
  /// 
  /// [recipeId] - The ID of the recipe to add to favorites.
  /// If the recipe is already a favorite, this is a no-op.
  Future<void> addFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Removes a recipe ID from the favorites list.
  /// 
  /// [recipeId] - The ID of the recipe to remove from favorites.
  /// If the recipe is not a favorite, this is a no-op.
  Future<void> removeFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    if (favorites.contains(recipeId)) {
      favorites.remove(recipeId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Checks if a recipe is in the favorites list.
  /// 
  /// [recipeId] - The ID of the recipe to check.
  /// Returns true if the recipe is a favorite, false otherwise.
  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(recipeId);
  }

  /// Toggles the favorite status of a recipe.
  /// 
  /// [recipeId] - The ID of the recipe to toggle.
  /// Returns true if the recipe is now a favorite, false if removed.
  Future<bool> toggleFavorite(String recipeId) async {
    final isFav = await isFavorite(recipeId);
    
    if (isFav) {
      await removeFavorite(recipeId);
      return false;
    } else {
      await addFavorite(recipeId);
      return true;
    }
  }
}
