
import 'package:flutter/foundation.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_recipes.dart';
import '../../domain/usecases/search_recipes.dart';
import '../../domain/usecases/filter_by_category.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
class RecipeProvider extends ChangeNotifier {
  final GetRecipes _getRecipes;
  final SearchRecipes _searchRecipes;
  final FilterByCategory _filterByCategory;
  final ToggleFavorite _toggleFavorite;
  final GetFavorites _getFavorites;

  RecipeProvider({
    required GetRecipes getRecipes,
    required SearchRecipes searchRecipes,
    required FilterByCategory filterByCategory,
    required ToggleFavorite toggleFavorite,
    required GetFavorites getFavorites,
  })  : _getRecipes = getRecipes,
        _searchRecipes = searchRecipes,
        _filterByCategory = filterByCategory,
        _toggleFavorite = toggleFavorite,
        _getFavorites = getFavorites;
  List<Recipe> _allRecipes = [];
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;
  List<Recipe> _favorites = [];
  List<Recipe> get favorites => _favorites;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  RecipeCategory? _selectedCategory;
  RecipeCategory? get selectedCategory => _selectedCategory;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRecipes = await _getRecipes();
      _recipes = _allRecipes;
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load recipes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadFavorites() async {
    try {
      _favorites = await _getFavorites();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
      notifyListeners();
    }
  }
  Future<void> searchRecipes(String query) async {
    _searchQuery = query;
    await _applyFilters();
  }
  Future<void> filterByCategory(RecipeCategory? category) async {
    _selectedCategory = category;
    await _applyFilters();
  }
  Future<void> toggleFavorite(String recipeId) async {
    try {
      final updatedRecipe = await _toggleFavorite(recipeId);
      _allRecipes = _allRecipes.map((r) {
        if (r.id == recipeId) {
          return updatedRecipe;
        }
        return r;
      }).toList();
      _recipes = _recipes.map((r) {
        if (r.id == recipeId) {
          return updatedRecipe;
        }
        return r;
      }).toList();
      await loadFavorites();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      notifyListeners();
    }
  }
  Recipe? getRecipeById(String recipeId) {
    try {
      return _allRecipes.firstWhere((r) => r.id == recipeId);
    } catch (_) {
      return null;
    }
  }
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _recipes = _allRecipes;
    notifyListeners();
  }
  Future<void> _applyFilters() async {
    List<Recipe> filtered = _allRecipes;
    if (_selectedCategory != null) {
      filtered = filtered
          .where((recipe) => recipe.category == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      filtered = filtered
          .where((recipe) => recipe.title.toLowerCase().contains(lowercaseQuery))
          .toList();
    }

    _recipes = filtered;
    notifyListeners();
  }
}
