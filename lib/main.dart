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
import 'features/local_auth/presentation/local_auth_provider.dart';
import 'features/local_auth/presentation/local_auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(
          create: (_) => LocalAuthProvider()..loadProfile(),
        ),
      ],
      child: MaterialApp(
        title: 'Chicken Hot Recipes',
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

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  bool _animDone = false;
  bool _dataReady = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward().then((_) {
      _animDone = true;
      _tryNavigate();
    });

    _waitForData();
  }

  Future<void> _waitForData() async {
    
    await Future.delayed(const Duration(milliseconds: 500));
    _dataReady = true;
    _tryNavigate();
  }

  void _tryNavigate() {
    if (_navigated || !_animDone || !_dataReady) return;
    if (!mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _AppContent()),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.9),
              colorScheme.primaryContainer,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chicken Recipes',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hot & Delicious',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalAuthProvider, SettingsProvider>(
      builder: (context, authProvider, settingsProvider, _) {
        
        if (authProvider.isLoading || settingsProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        
        if (!authProvider.hasValidProfile) {
          return LocalAuthScreen(
            onProfileCreated: () {
              
              
            },
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
