
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'Welcome to Chicken Hot Recipes',
          body: 'Your ultimate chicken recipe companion with 50+ delicious recipes from around the world.',
          image: _buildImage(
            Icons.restaurant_menu,
            colorScheme.primary,
          ),
          decoration: _getPageDecoration(theme),
        ),
        PageViewModel(
          title: 'Discover Recipes',
          body: 'Browse through soups, main dishes, snacks, and spicy recipes. Search and filter to find exactly what you want.',
          image: _buildImage(
            Icons.search,
            Colors.orange,
          ),
          decoration: _getPageDecoration(theme),
        ),
        PageViewModel(
          title: 'Cook Mode',
          body: 'Step-by-step cooking instructions with large text and built-in timer. Your screen stays on while you cook!',
          image: _buildImage(
            Icons.menu_book,
            Colors.green,
          ),
          decoration: _getPageDecoration(theme),
        ),
        PageViewModel(
          title: 'Shopping List',
          body: 'Add ingredients from any recipe to your shopping list. Check off items as you shop.',
          image: _buildImage(
            Icons.shopping_cart,
            Colors.blue,
          ),
          decoration: _getPageDecoration(theme),
        ),
        PageViewModel(
          title: 'Track Your Cooking',
          body: 'Rate recipes, add notes, and track which dishes you\'ve made. Build your personal cooking journal!',
          image: _buildImage(
            Icons.star,
            Colors.amber,
          ),
          decoration: _getPageDecoration(theme),
        ),
      ],
      onDone: onComplete,
      onSkip: onComplete,
      showSkipButton: true,
      skip: const Text('Skip'),
      next: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward,
          color: colorScheme.onPrimary,
        ),
      ),
      done: Text(
        'Get Started',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(22.0, 10.0),
        activeColor: colorScheme.primary,
        color: colorScheme.outline.withOpacity(0.3),
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      globalBackgroundColor: colorScheme.surface,
    );
  }

  Widget _buildImage(IconData icon, Color color) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 100,
          color: color,
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration(ThemeData theme) {
    return PageDecoration(
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: theme.textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
      imagePadding: const EdgeInsets.only(top: 40),
    );
  }
}
