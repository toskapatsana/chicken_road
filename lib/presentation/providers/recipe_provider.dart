/// Presentation Layer - Recipe Provider
/// 
/// This provider manages the state for recipe-related UI components.
/// It extends ChangeNotifier to enable reactive UI updates through
/// Provider's state management system.
/// 
/// The provider:
/// - Holds the current state (recipes, search query, selected category)
/// - Exposes methods to interact with use cases
/// - Notifies listeners (widgets) when state changes
/// 
/// Data flow:
/// UI -> Provider -> Use Case -> Repository -> Data Source
/// Data Source -> Repository -> Use Case -> Provider -> UI

import 'package:flutter/foundation.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_recipes.dart';
import '../../domain/usecases/search_recipes.dart';
import '../../domain/usecases/filter_by_category.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/get_favorites.dart';

/// Provider that manages recipe-related state and business logic.
/// 
/// This class serves as the bridge between the UI (screens/widgets)
/// and the domain layer (use cases). It maintains:
/// - The list of recipes to display
/// - The current search query
/// - The selected category filter
/// - Loading and error states
class RecipeProvider extends ChangeNotifier {
  // Use cases - injected via constructor for testability
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

  // ==================== State Variables ====================

  /// All recipes (unfiltered, used as base for filtering)
  List<Recipe> _allRecipes = [];

  /// Currently displayed recipes (after search/filter)
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  /// Favorite recipes
  List<Recipe> _favorites = [];
  List<Recipe> get favorites => _favorites;

  /// Current search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Currently selected category (null means all categories)
  RecipeCategory? _selectedCategory;
  RecipeCategory? get selectedCategory => _selectedCategory;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message (null if no error)
  String? _error;
  String? get error => _error;

  // ==================== Public Methods ====================

  /// Loads all recipes from the repository.
  /// 
  /// This should be called when the app starts or when
  /// a full refresh is needed.
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

  /// Loads favorite recipes from the repository.
  /// 
  /// Called when navigating to the Favorites screen or
  /// after toggling a favorite.
  Future<void> loadFavorites() async {
    try {
      _favorites = await _getFavorites();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
      notifyListeners();
    }
  }

  /// Searches recipes by name.
  /// 
  /// [query] - The search string. Empty string shows all recipes.
  /// 
  /// The search is performed in real-time as the user types.
  /// It filters the current category selection (if any).
  Future<void> searchRecipes(String query) async {
    _searchQuery = query;
    await _applyFilters();
  }

  /// Filters recipes by category.
  /// 
  /// [category] - The category to filter by. Null to show all categories.
  /// 
  /// When a category is selected, search is still applied on top.
  Future<void> filterByCategory(RecipeCategory? category) async {
    _selectedCategory = category;
    await _applyFilters();
  }

  /// Toggles the favorite status of a recipe.
  /// 
  /// [recipeId] - The ID of the recipe to toggle.
  /// 
  /// After toggling, the recipes list and favorites list are updated
  /// to reflect the new status.
  Future<void> toggleFavorite(String recipeId) async {
    try {
      final updatedRecipe = await _toggleFavorite(recipeId);
      
      // Update the recipe in all recipes list
      _allRecipes = _allRecipes.map((r) {
        if (r.id == recipeId) {
          return updatedRecipe;
        }
        return r;
      }).toList();

      // Update the displayed recipes list
      _recipes = _recipes.map((r) {
        if (r.id == recipeId) {
          return updatedRecipe;
        }
        return r;
      }).toList();

      // Reload favorites to reflect the change
      await loadFavorites();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      notifyListeners();
    }
  }

  /// Gets a single recipe by ID.
  /// 
  /// [recipeId] - The ID of the recipe to retrieve.
  /// Returns the recipe if found, null otherwise.
  Recipe? getRecipeById(String recipeId) {
    try {
      return _allRecipes.firstWhere((r) => r.id == recipeId);
    } catch (_) {
      return null;
    }
  }

  /// Clears all filters and search.
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _recipes = _allRecipes;
    notifyListeners();
  }

  // ==================== Private Methods ====================

  /// Applies both search and category filters.
  /// 
  /// This method combines the search query and category filter
  /// to produce the final list of recipes to display.
  Future<void> _applyFilters() async {
    List<Recipe> filtered = _allRecipes;

    // Apply category filter first
    if (_selectedCategory != null) {
      filtered = filtered
          .where((recipe) => recipe.category == _selectedCategory)
          .toList();
    }

    // Apply search filter on top
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
