
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/recipe.dart';
import '../providers/settings_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/cooking_timer_widget.dart';

class CookModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookModeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends State<CookModeScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  bool _showTimer = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final settings = context.read<SettingsProvider>().settings;
    if (settings.keepScreenOnInCookMode) {
      WakelockPlus.enable();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _goToStep(int step) {
    if (step >= 0 && step < widget.recipe.steps.length) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _markAsCooked() {
    context.read<UserDataProvider>().markAsCooked(widget.recipe.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe marked as cooked!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = context.watch<SettingsProvider>().settings;
    final fontSize = settings.cookModeFontSize.size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showTimer ? Icons.timer_off : Icons.timer,
                      color: _showTimer ? colorScheme.primary : null,
                    ),
                    onPressed: () {
                      setState(() => _showTimer = !_showTimer);
                    },
                  ),
                ],
              ),
            ),
            if (_showTimer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CookingTimerWidget(
                  initialMinutes: widget.recipe.cookTime,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentStep + 1} of ${widget.recipe.steps.length}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: ((_currentStep + 1) / widget.recipe.steps.length),
                      backgroundColor: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.recipe.steps.length,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                itemBuilder: (context, index) {
                  return _StepPage(
                    step: widget.recipe.steps[index],
                    stepNumber: index + 1,
                    fontSize: fontSize,
                    isLastStep: index == widget.recipe.steps.length - 1,
                    onMarkCooked: _markAsCooked,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentStep > 0
                          ? () => _goToStep(_currentStep - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _currentStep < widget.recipe.steps.length - 1
                          ? () => _goToStep(_currentStep + 1)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final String step;
  final int stepNumber;
  final double fontSize;
  final bool isLastStep;
  final VoidCallback onMarkCooked;

  const _StepPage({
    required this.step,
    required this.stepNumber,
    required this.fontSize,
    required this.isLastStep,
    required this.onMarkCooked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            step,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (isLastStep) ...[
            const SizedBox(height: 32),
            Center(
              child: FilledButton.icon(
                onPressed: onMarkCooked,
                icon: const Icon(Icons.check_circle),
                label: const Text('I made this!'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
