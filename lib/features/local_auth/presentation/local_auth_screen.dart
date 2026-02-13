import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'local_auth_provider.dart';
import 'privacy_policy_webview_screen.dart';

class LocalAuthScreen extends StatefulWidget {
  final VoidCallback onProfileCreated;

  const LocalAuthScreen({super.key, required this.onProfileCreated});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  late final TextEditingController _nameCtrl;
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final provider = context.read<LocalAuthProvider>();
    _nameCtrl = TextEditingController(text: provider.displayName);
    _nameCtrl.addListener(() {
      provider.setDisplayName(_nameCtrl.text);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyPolicy() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyWebViewScreen(),
      ),
    );

    if (!mounted) return;

    final provider = context.read<LocalAuthProvider>();
    if (result == true) {
      provider.setPrivacyAccepted(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Privacy Policy accepted.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      provider.setPrivacyAccepted(false);
      provider.showPrivacyRequiredMessage();
    }
  }

  void _showPhotoOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<LocalAuthProvider>();

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
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await provider.pickPhotoFromGallery();
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.photoError ??
                              'Could not add photo. Please try again.',
                        ),
                      ),
                    );
                  }
                },
              ),
              if (provider.photoPath != null)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text('Remove Photo', style: TextStyle(color: colorScheme.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    _nameFocus.unfocus();
    final provider = context.read<LocalAuthProvider>();
    final success = await provider.saveAndContinue();
    if (success && mounted) {
      widget.onProfileCreated();
    }
  }

  Future<void> _pickBirthDate(LocalAuthProvider provider) async {
    final now = DateTime.now();
    final initial = provider.birthDate ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Select Date of Birth',
      confirmText: 'Save',
    );
    if (picked != null) {
      await provider.setBirthDate(picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date of birth';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer<LocalAuthProvider>(
          builder: (context, provider, _) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.primaryContainer.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_rounded,
                            size: 44,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create Your Profile',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Set up your cooking profile to get started.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Photo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(child: _buildAvatar(provider, colorScheme)),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton.icon(
                                onPressed: _showPhotoOptions,
                                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                                label: Text(
                                  provider.photoPath != null ? 'Change Photo' : 'Add Photo (optional)',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Display Name',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _nameCtrl,
                              focusNode: _nameFocus,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Display Name',
                                hintText: 'e.g. Chef Maria',
                                prefixIcon: const Icon(Icons.person_outline),
                                errorText: provider.nameError,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _pickBirthDate(provider),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: const Icon(Icons.cake_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _formatDate(provider.birthDate),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: provider.birthDate == null
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildPrivacyRow(provider, theme, colorScheme),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: provider.canContinue ? _onContinue : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Create Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(LocalAuthProvider provider, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: provider.photoPath != null ? FileImage(File(provider.photoPath!)) : null,
            child: provider.photoPath == null ? Icon(Icons.person, size: 48, color: colorScheme.primary) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyRow(LocalAuthProvider provider, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _openPrivacyPolicy,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: provider.privacyAccepted,
                    onChanged: (_) => _openPrivacyPolicy(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I have read and accept the Privacy Policy.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _openPrivacyPolicy,
                        child: Text(
                          'Open Privacy Policy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (provider.privacyError != null)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 6),
            child: Text(
              provider.privacyError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
