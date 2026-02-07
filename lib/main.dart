
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'domain/usecases/get_recipes.dart';
import 'domain/usecases/search_recipes.dart';
import 'domain/usecases/filter_by_category.dart';
import 'domain/usecases/toggle_favorite.dart';
import 'domain/usecases/get_favorites.dart';
import 'data/datasources/local_recipe_datasource.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/recipe_repository_impl.dart';
import 'presentation/providers/recipe_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/user_data_provider.dart';
import 'presentation/providers/shopping_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/shopping_list_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

void main() {
  runApp(const ChickenRecipesHotApp());
}
class ChickenRecipesHotApp extends StatelessWidget {
  const ChickenRecipesHotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localRecipeDataSource = LocalRecipeDataSource();
    final localStorageDataSource = LocalStorageDataSource();
    final recipeRepository = RecipeRepositoryImpl(
      recipeDataSource: localRecipeDataSource,
      storageDataSource: localStorageDataSource,
    );
    final getRecipes = GetRecipes(recipeRepository);
    final searchRecipes = SearchRecipes(recipeRepository);
    final filterByCategory = FilterByCategory(recipeRepository);
    final toggleFavorite = ToggleFavorite(recipeRepository);
    final getFavorites = GetFavorites(recipeRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(
            getRecipes: getRecipes,
            searchRecipes: searchRecipes,
            filterByCategory: filterByCategory,
            toggleFavorite: toggleFavorite,
            getFavorites: getFavorites,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDataProvider()..loadAllUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShoppingProvider()..loadShoppingList(),
        ),
      ],
      child: MaterialApp(
        title: 'Chicken Recipes Hot',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
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
        
        home: const AppEntryPoint(),
      ),
    );
  }
}
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        if (settingsProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (!settingsProvider.settings.hasCompletedOnboarding) {
          return OnboardingScreen(
            onComplete: () {
              settingsProvider.setOnboardingCompleted(true);
            },
          );
        }
        
        return const MainNavigation();
      },
    );
  }
}
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
    ShoppingListScreen(),
    SettingsScreen(),
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
          if (index == 1) {
            context.read<RecipeProvider>().loadFavorites();
          } else if (index == 2) {
            context.read<ShoppingProvider>().loadShoppingList();
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
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
