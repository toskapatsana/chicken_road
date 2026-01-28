/// Presentation Layer - Settings Screen
/// 
/// App settings including measurement units, cook mode preferences,
/// timer settings, and data management.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/shopping_provider.dart';

const String _privacyPolicyUrl = 'https://toskapatsana.github.io/chicken-recipes-hot/privacy';
const String _termsOfServiceUrl = 'https://toskapatsana.github.io/chicken-recipes-hot/terms';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, provider, _) {
            final settings = provider.settings;
            
            return ListView(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Settings',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customize your experience',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Measurement Units
                _SectionHeader(title: 'Preferences'),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Measurement Units'),
                  subtitle: Text(settings.measurementUnit.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMeasurementDialog(context, provider),
                ),

                // Default Servings
                ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: const Text('Default Servings'),
                  subtitle: Text('${settings.defaultServings} servings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showServingsDialog(context, provider),
                ),

                const Divider(),

                // Cook Mode Section
                _SectionHeader(title: 'Cook Mode'),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Font Size'),
                  subtitle: Text(settings.cookModeFontSize.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFontSizeDialog(context, provider),
                ),

                SwitchListTile(
                  secondary: const Icon(Icons.screen_lock_portrait),
                  title: const Text('Keep Screen On'),
                  subtitle: const Text('Prevent screen from sleeping during cooking'),
                  value: settings.keepScreenOnInCookMode,
                  onChanged: (value) => provider.setKeepScreenOn(value),
                ),

                const Divider(),

                // Timer Section
                _SectionHeader(title: 'Timer'),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Timer Sound'),
                  subtitle: const Text('Play sound when timer completes'),
                  value: settings.timerSoundEnabled,
                  onChanged: (value) => provider.setTimerSoundEnabled(value),
                ),

                const Divider(),

                // Data Management Section
                _SectionHeader(title: 'Data'),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    'Clear Shopping List',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: const Text('Remove all items from shopping list'),
                  onTap: () => _confirmClearShoppingList(context),
                ),

                ListTile(
                  leading: Icon(Icons.delete_forever, color: colorScheme.error),
                  title: Text(
                    'Clear All Data',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: const Text('Reset ratings, notes, and history'),
                  onTap: () => _confirmClearAllData(context),
                ),

                const Divider(),

                // About Section
                _SectionHeader(title: 'About'),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Chicken Recipes Hot'),
                  subtitle: Text('Version 1.0.0 (Build 3)'),
                ),

                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _launchUrl(_privacyPolicyUrl),
                ),

                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _launchUrl(_termsOfServiceUrl),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showMeasurementDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Measurement Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MeasurementUnit.values.map((unit) {
            return RadioListTile<MeasurementUnit>(
              title: Text(unit.displayName),
              value: unit,
              groupValue: provider.settings.measurementUnit,
              onChanged: (value) {
                if (value != null) {
                  provider.setMeasurementUnit(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showServingsDialog(BuildContext context, SettingsProvider provider) {
    int selected = provider.settings.defaultServings;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Default Servings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: selected.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$selected',
                onChanged: (value) {
                  setState(() => selected = value.round());
                },
              ),
              Text(
                '$selected servings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                provider.setDefaultServings(selected);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cook Mode Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CookModeFontSize.values.map((size) {
            return RadioListTile<CookModeFontSize>(
              title: Text(size.displayName),
              subtitle: Text('${size.size.toInt()}pt'),
              value: size,
              groupValue: provider.settings.cookModeFontSize,
              onChanged: (value) {
                if (value != null) {
                  provider.setCookModeFontSize(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmClearShoppingList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Shopping List?'),
        content: const Text('This will remove all items from your shopping list. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ShoppingProvider>().clearAllItems();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shopping list cleared')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will reset all your ratings, notes, cooking history, and settings. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<UserDataProvider>().clearAllUserData();
              await context.read<ShoppingProvider>().clearAllItems();
              await context.read<SettingsProvider>().resetSettings();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
