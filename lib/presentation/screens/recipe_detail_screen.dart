/// Presentation Layer - Recipe Detail Screen
/// 
/// Displays detailed information about a single recipe:
/// - Full-size recipe image
/// - Title and description
/// - Time, difficulty, and servings info
/// - Servings calculator
/// - Ingredients list (scaled by servings)
/// - Step-by-step cooking instructions
/// - Rating and notes
/// - Add to shopping list
/// - Share recipe
/// - Cook mode button

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/shopping_provider.dart';
import '../widgets/servings_selector.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/nutritional_info_card.dart';
import '../widgets/rating_widget.dart';
import '../widgets/cooking_timer_widget.dart';
import 'cook_mode_screen.dart';

/// Screen showing detailed recipe information.
/// 
/// [recipeId] - The ID of the recipe to display
class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _currentServings;
  bool _showTimer = false;
  bool _showNotes = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load user data for this recipe
    Future.microtask(() {
      final recipe = context.read<RecipeProvider>().getRecipeById(widget.recipeId);
      if (recipe != null) {
        _currentServings = recipe.servings;
        
        // Check for saved servings
        final userData = context.read<UserDataProvider>().getUserDataForRecipe(widget.recipeId);
        if (userData != null) {
          setState(() {
            _currentServings = userData.selectedServings;
            _notesController.text = userData.notes ?? '';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _shareRecipe(Recipe recipe) {
    final text = '''
${recipe.title}

${recipe.description}

Prep Time: ${recipe.prepTime} min
Cook Time: ${recipe.cookTime} min
Servings: ${recipe.servings}

INGREDIENTS:
${recipe.ingredients.map((i) => '• $i').join('\n')}

INSTRUCTIONS:
${recipe.steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

Shared from Checken Road App
''';
    Share.share(text, subject: recipe.title);
  }

  void _addToShoppingList(BuildContext context, Recipe recipe) {
    context.read<ShoppingProvider>().addIngredientsFromRecipe(
      ingredients: recipe.ingredients,
      recipeId: recipe.id,
      recipeName: recipe.title,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${recipe.ingredients.length} ingredients to shopping list'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to shopping list - user can switch tabs
          },
        ),
      ),
    );
  }

  void _openCookMode(BuildContext context, Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CookModeScreen(recipe: recipe),
      ),
    );
  }

  String _scaleIngredient(String ingredient, int originalServings, int newServings) {
    if (originalServings == newServings) return ingredient;
    
    final multiplier = newServings / originalServings;
    
    // Simple number scaling regex
    final regex = RegExp(r'^([\d]+(?:\.[\d]+)?(?:\/[\d]+)?)\s*');
    final match = regex.firstMatch(ingredient);
    
    if (match != null) {
      final numberStr = match.group(1)!;
      double? number;
      
      if (numberStr.contains('/')) {
        // Handle fractions like 1/2
        final parts = numberStr.split('/');
        number = double.parse(parts[0]) / double.parse(parts[1]);
      } else {
        number = double.tryParse(numberStr);
      }
      
      if (number != null) {
        final scaled = number * multiplier;
        final scaledStr = scaled == scaled.roundToDouble() 
            ? scaled.round().toString()
            : scaled.toStringAsFixed(1);
        return ingredient.replaceFirst(regex, '$scaledStr ');
      }
    }
    
    return ingredient;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer2<RecipeProvider, UserDataProvider>(
      builder: (context, recipeProvider, userDataProvider, _) {
        final recipe = recipeProvider.getRecipeById(widget.recipeId);
        
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Recipe not found'),
            ),
          );
        }
        
        final userData = userDataProvider.getUserDataForRecipe(widget.recipeId);
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Recipe image
                      Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 64,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  // Share button
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareRecipe(recipe),
                    ),
                  ),
                  // Favorite button
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        recipe.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: recipe.isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => recipeProvider.toggleFavorite(widget.recipeId),
                    ),
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and difficulty badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(recipe.category),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              recipe.category.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DifficultyBadge(difficulty: recipe.difficulty),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Title
                      Text(
                        recipe.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        recipe.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Time info row
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TimeInfoItem(
                              icon: Icons.timer_outlined,
                              label: 'Prep',
                              value: '${recipe.prepTime} min',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            _TimeInfoItem(
                              icon: Icons.local_fire_department_outlined,
                              label: 'Cook',
                              value: '${recipe.cookTime} min',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            _TimeInfoItem(
                              icon: Icons.schedule,
                              label: 'Total',
                              value: '${recipe.totalTime} min',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // User rating and cooking history
                      if (userData != null && (userData.rating != null || userData.timesMade > 0))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RatingDisplay(
                            rating: userData.rating,
                            timesCooked: userData.timesMade,
                          ),
                        ),
                      
                      // Cook Mode button
                      FilledButton.icon(
                        onPressed: () => _openCookMode(context, recipe),
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Start Cooking'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Timer toggle
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _showTimer = !_showTimer);
                        },
                        icon: Icon(_showTimer ? Icons.timer_off : Icons.timer),
                        label: Text(_showTimer ? 'Hide Timer' : 'Show Timer'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      
                      // Timer widget
                      if (_showTimer) ...[
                        const SizedBox(height: 16),
                        CookingTimerWidget(
                          initialMinutes: recipe.cookTime,
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Servings selector
                      ServingsSelector(
                        servings: _currentServings,
                        onChanged: (value) {
                          setState(() => _currentServings = value);
                          userDataProvider.setSelectedServings(widget.recipeId, value);
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Ingredients section
                      Row(
                        children: [
                          Expanded(
                            child: _buildSectionHeader(
                              context,
                              icon: Icons.shopping_basket,
                              title: 'Ingredients',
                              count: recipe.ingredients.length,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _addToShoppingList(context, recipe),
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('Add All'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Ingredients list
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(4),
                          itemCount: recipe.ingredients.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: 48,
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                          itemBuilder: (context, index) {
                            final scaledIngredient = _scaleIngredient(
                              recipe.ingredients[index],
                              recipe.servings,
                              _currentServings,
                            );
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                scaledIngredient,
                                style: theme.textTheme.bodyMedium,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Nutritional Info
                      NutritionalInfoCard(
                        nutritionalInfo: recipe.nutritionalInfo,
                        originalServings: recipe.servings,
                        currentServings: _currentServings,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Cooking steps section
                      _buildSectionHeader(
                        context,
                        icon: Icons.menu_book,
                        title: 'Instructions',
                        count: recipe.steps.length,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Steps list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipe.steps.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      recipe.steps[index],
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Rating section
                      _buildSectionHeader(
                        context,
                        icon: Icons.star,
                        title: 'Your Rating',
                        count: 0,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Center(
                        child: RatingWidget(
                          rating: userData?.rating,
                          onRatingChanged: (rating) {
                            userDataProvider.setRating(widget.recipeId, rating);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notes section
                      Row(
                        children: [
                          Expanded(
                            child: _buildSectionHeader(
                              context,
                              icon: Icons.note,
                              title: 'Notes',
                              count: 0,
                            ),
                          ),
                          IconButton(
                            icon: Icon(_showNotes ? Icons.expand_less : Icons.expand_more),
                            onPressed: () {
                              setState(() => _showNotes = !_showNotes);
                            },
                          ),
                        ],
                      ),
                      
                      if (_showNotes) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Add your personal notes here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            userDataProvider.setNotes(widget.recipeId, value);
                          },
                        ),
                      ],
                      
                      if (userData?.notes != null && userData!.notes!.isNotEmpty && !_showNotes) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.note, size: 16, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  userData.notes!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Floating action button
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => recipeProvider.toggleFavorite(widget.recipeId),
            backgroundColor: recipe.isFavorite
                ? Colors.red
                : colorScheme.primaryContainer,
            icon: Icon(
              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite
                  ? Colors.white
                  : colorScheme.onPrimaryContainer,
            ),
            label: Text(
              recipe.isFavorite ? 'Favorited' : 'Add to Favorites',
              style: TextStyle(
                color: recipe.isFavorite
                    ? Colors.white
                    : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count > 0) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count items',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getCategoryColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.soups:
        return Colors.blue;
      case RecipeCategory.mainDishes:
        return Colors.green;
      case RecipeCategory.snacks:
        return Colors.orange;
      case RecipeCategory.spicy:
        return Colors.red;
    }
  }
}

class _TimeInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TimeInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
