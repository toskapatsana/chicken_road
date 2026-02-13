import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/local_profile.dart';
import '../domain/profile_repository.dart';
import '../data/profile_repository_impl.dart';

/// Manages local auth state: display name, photo, privacy acceptance.
class LocalAuthProvider extends ChangeNotifier {
  final ProfileRepository _repo;

  LocalAuthProvider({ProfileRepository? repository})
      : _repo = repository ?? ProfileRepositoryImpl();

  LocalProfile? _profile;
  bool _isLoading = true;
  String _displayName = '';
  String? _photoPath;
  bool _privacyAccepted = false;
  String? _nameError;
  String? _privacyError;

  // --- Getters ---
  LocalProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String get displayName => _displayName;
  String? get photoPath => _photoPath;
  bool get privacyAccepted => _privacyAccepted;
  String? get nameError => _nameError;
  String? get privacyError => _privacyError;
  bool get hasValidProfile => _profile != null && _profile!.isComplete;

  bool get canContinue =>
      _displayName.trim().isNotEmpty && _privacyAccepted;

  // --- Init ---
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repo.getProfile();
      if (_profile != null) {
        _displayName = _profile!.displayName;
        _photoPath = _profile!.photoPath;
        _privacyAccepted = _profile!.privacyAccepted;
      }
    } catch (_) {
      _profile = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Display name ---
  void setDisplayName(String value) {
    _displayName = value;
    _nameError =
        value.trim().isEmpty ? 'Please enter your display name.' : null;
    notifyListeners();
  }

  // --- Photo ---
  Future<void> pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      // Save to app documents for persistence
      final dir = await getApplicationDocumentsDirectory();
      final pickedPath = picked.path;
      final ext = pickedPath.contains('.')
          ? pickedPath.substring(pickedPath.lastIndexOf('.'))
          : '.jpg';
      final dest = File('${dir.path}/profile_photo$ext');
      await File(pickedPath).copy(dest.path);

      _photoPath = dest.path;
      notifyListeners();
    } catch (_) {
      // Silently fail — photo is optional
    }
  }

  void removePhoto() {
    _photoPath = null;
    notifyListeners();
  }

  // --- Privacy ---
  void setPrivacyAccepted(bool value) {
    _privacyAccepted = value;
    if (value) {
      _privacyError = null;
    }
    notifyListeners();
  }

  void showPrivacyRequiredMessage() {
    if (!_privacyAccepted) {
      _privacyError = 'Please read and accept the Privacy Policy to continue.';
      notifyListeners();
    }
  }

  // --- Validate + Save ---
  bool validate() {
    bool valid = true;

    if (_displayName.trim().isEmpty) {
      _nameError = 'Please enter your display name.';
      valid = false;
    } else {
      _nameError = null;
    }

    if (!_privacyAccepted) {
      _privacyError = 'Please read and accept the Privacy Policy to continue.';
      valid = false;
    } else {
      _privacyError = null;
    }

    notifyListeners();
    return valid;
  }

  Future<bool> saveAndContinue() async {
    if (!validate()) return false;

    final profile = LocalProfile(
      displayName: _displayName.trim(),
      photoPath: _photoPath,
      privacyAccepted: true,
      createdAt: DateTime.now(),
    );

    await _repo.saveProfile(profile);
    _profile = profile;
    notifyListeners();
    return true;
  }

  Future<void> clearProfile() async {
    await _repo.clearProfile();
    _profile = null;
    _displayName = '';
    _photoPath = null;
    _privacyAccepted = false;
    _nameError = null;
    _privacyError = null;
    notifyListeners();
  }
}
