
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/shopping_provider.dart';
import '../../features/local_auth/presentation/privacy_policy_webview_screen.dart';
import '../../features/local_auth/presentation/local_auth_provider.dart';

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
        child: Consumer2<SettingsProvider, LocalAuthProvider>(
          builder: (context, provider, authProvider, _) {
            final settings = provider.settings;
            
            return ListView(
              children: [
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
                const Divider(),
                _SectionHeader(title: 'Account'),
                ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: authProvider.photoPath != null
                        ? FileImage(File(authProvider.photoPath!))
                        : null,
                    child: authProvider.photoPath == null
                        ? Icon(Icons.person, color: colorScheme.primary, size: 18)
                        : null,
                  ),
                  title: Text(
                    authProvider.displayName.trim().isEmpty
                        ? 'Set Display Name'
                        : authProvider.displayName,
                  ),
                  subtitle: const Text('Display name'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _showEditNameDialog(context, authProvider),
                ),
                ListTile(
                  leading: const Icon(Icons.add_a_photo_outlined),
                  title: const Text('Profile Photo'),
                  subtitle: Text(
                    authProvider.photoPath == null
                        ? 'No photo selected'
                        : 'Photo selected',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPhotoOptions(context, authProvider),
                ),
                ListTile(
                  leading: Icon(Icons.person_remove_outlined, color: colorScheme.error),
                  title: Text('Clear Profile', style: TextStyle(color: colorScheme.error)),
                  subtitle: const Text('Remove local account name and photo'),
                  onTap: () => _confirmClearProfile(context, authProvider),
                ),

                _SectionHeader(title: 'Preferences'),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Measurement Units'),
                  subtitle: Text(settings.measurementUnit.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMeasurementDialog(context, provider),
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: const Text('Default Servings'),
                  subtitle: Text('${settings.defaultServings} servings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showServingsDialog(context, provider),
                ),

                const Divider(),
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
                _SectionHeader(title: 'Timer'),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Timer Sound'),
                  subtitle: const Text('Play sound when timer completes'),
                  value: settings.timerSoundEnabled,
                  onChanged: (value) => provider.setTimerSoundEnabled(value),
                ),

                const Divider(),
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
                const _SectionHeader(title: 'About'),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Chicken Reciper'),
                ),

                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openLegalInfo(context),
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

  void _showEditNameDialog(BuildContext context, LocalAuthProvider authProvider) {
    final controller = TextEditingController(text: authProvider.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter display name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await authProvider.updateDisplayName(controller.text);
              if (context.mounted && ok) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Display name updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, LocalAuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await authProvider.pickPhoto(ImageSource.camera);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authProvider.photoError ??
                              'Could not add photo. Please try again.',
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await authProvider.pickPhoto(ImageSource.gallery);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authProvider.photoError ??
                              'Could not add photo. Please try again.',
                        ),
                      ),
                    );
                  }
                },
              ),
              if (authProvider.photoPath != null)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    authProvider.removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearProfile(BuildContext context, LocalAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Profile?'),
        content: const Text('This will remove your local profile name and photo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await authProvider.clearProfile();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
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

  void _openLegalInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyWebViewScreen(),
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
