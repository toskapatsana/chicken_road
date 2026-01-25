/// Checken Road - A Chicken Recipe Mobile Application
/// 
/// This is the main entry point of the application.
/// 
/// Architecture: Clean Architecture
/// - Domain Layer: Business entities and use cases (pure Dart)
/// - Data Layer: Models, data sources, and repository implementations
/// - Presentation Layer: UI (screens, widgets) and state management (Provider)
/// 
/// State Management: Provider with ChangeNotifier
/// - RecipeProvider manages all recipe-related state
/// - Uses ChangeNotifierProvider for reactive UI updates
/// 
/// Theme: Follows system theme (light/dark)
/// - Uses ThemeMode.system to automatically adapt to device settings

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Domain layer - use cases
import 'domain/usecases/get_recipes.dart';
import 'domain/usecases/search_recipes.dart';
import 'domain/usecases/filter_by_category.dart';
import 'domain/usecases/toggle_favorite.dart';
import 'domain/usecases/get_favorites.dart';

// Data layer - data sources and repository
import 'data/datasources/local_recipe_datasource.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/recipe_repository_impl.dart';

// Presentation layer - provider and screens
import 'presentation/providers/recipe_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/favorites_screen.dart';

void main() {
  runApp(const CheckenRoadApp());
}

/// The root widget of the Checken Road application.
/// 
/// This widget sets up:
/// 1. Dependency injection using Provider
/// 2. App-wide theme configuration
/// 3. Navigation structure
class CheckenRoadApp extends StatelessWidget {
  const CheckenRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize data sources
    final localRecipeDataSource = LocalRecipeDataSource();
    final localStorageDataSource = LocalStorageDataSource();

    // Initialize repository with data sources
    // This is dependency injection - the repository doesn't know
    // about concrete data source implementations
    final recipeRepository = RecipeRepositoryImpl(
      recipeDataSource: localRecipeDataSource,
      storageDataSource: localStorageDataSource,
    );

    // Initialize use cases with repository
    // Use cases depend on the repository interface, not implementation
    final getRecipes = GetRecipes(recipeRepository);
    final searchRecipes = SearchRecipes(recipeRepository);
    final filterByCategory = FilterByCategory(recipeRepository);
    final toggleFavorite = ToggleFavorite(recipeRepository);
    final getFavorites = GetFavorites(recipeRepository);

    return MultiProvider(
      providers: [
        // Provide RecipeProvider to the entire app
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(
            getRecipes: getRecipes,
            searchRecipes: searchRecipes,
            filterByCategory: filterByCategory,
            toggleFavorite: toggleFavorite,
            getFavorites: getFavorites,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Checken Road',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        // The app follows the system theme (light/dark) automatically
        themeMode: ThemeMode.system,
        
        // Light theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // Dark theme
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        home: const MainNavigation(),
      ),
    );
  }
}

/// Main navigation widget with BottomNavigationBar.
/// 
/// Contains two tabs:
/// - Recipes (Home screen)
/// - Favorites
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Reload favorites when navigating to favorites tab
          if (index == 1) {
            context.read<RecipeProvider>().loadFavorites();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
