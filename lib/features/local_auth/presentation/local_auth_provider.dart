import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/local_profile.dart';
import '../domain/profile_repository.dart';
import '../data/profile_repository_impl.dart';

class LocalAuthProvider extends ChangeNotifier {
  final ProfileRepository _repo;

  LocalAuthProvider({ProfileRepository? repository})
      : _repo = repository ?? ProfileRepositoryImpl();

  LocalProfile? _profile;
  bool _isLoading = true;
  String _displayName = '';
  String? _photoPath;
  DateTime? _birthDate;
  bool _privacyAccepted = false;
  String? _nameError;
  String? _privacyError;
  String? _photoError;

  
  LocalProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String get displayName => _displayName;
  String? get photoPath => _photoPath;
  DateTime? get birthDate => _birthDate;
  bool get privacyAccepted => _privacyAccepted;
  String? get nameError => _nameError;
  String? get privacyError => _privacyError;
  String? get photoError => _photoError;
  bool get hasValidProfile => _profile != null && _profile!.isComplete;

  bool get canContinue =>
      _displayName.trim().isNotEmpty && _privacyAccepted;

  
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repo.getProfile();
      if (_profile != null) {
        _displayName = _profile!.displayName;
        _photoPath = _profile!.photoPath;
        _birthDate = _profile!.birthDate;
        _privacyAccepted = _profile!.privacyAccepted;
      }
    } catch (_) {
      _profile = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  
  void setDisplayName(String value) {
    _displayName = value;
    _nameError =
        value.trim().isEmpty ? 'Please enter your display name.' : null;
    notifyListeners();
  }

  
  Future<bool> pickPhotoFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) {
        _photoError = null;
        return false;
      }

      final dir = await getApplicationDocumentsDirectory();
      final bytes = await picked.readAsBytes();
      final dest = File(
        '${dir.path}/profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await dest.writeAsBytes(bytes, flush: true);

      _photoPath = dest.path;
      _photoError = null;
      await _persistCurrentProfile();
      notifyListeners();
      return true;
    } catch (_) {
      _photoError = 'Could not add photo. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> setBirthDate(DateTime? value) async {
    _birthDate = value;
    await _persistCurrentProfile();
    notifyListeners();
  }

  Future<void> removePhoto() async {
    _photoPath = null;
    _photoError = null;
    await _persistCurrentProfile();
    notifyListeners();
  }

  
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
      birthDate: _birthDate,
      privacyAccepted: true,
      createdAt: DateTime.now(),
    );

    await _repo.saveProfile(profile);
    _profile = profile;
    notifyListeners();
    return true;
  }

  Future<bool> updateDisplayName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _nameError = 'Please enter your display name.';
      notifyListeners();
      return false;
    }

    _displayName = trimmed;
    _nameError = null;
    await _persistCurrentProfile();
    notifyListeners();
    return true;
  }

  Future<void> clearProfile() async {
    await _repo.clearProfile();
    _profile = null;
    _displayName = '';
    _photoPath = null;
    _birthDate = null;
    _privacyAccepted = false;
    _nameError = null;
    _privacyError = null;
    notifyListeners();
  }

  Future<void> _persistCurrentProfile() async {
    if (_displayName.trim().isEmpty && _profile == null) return;
    final base = _profile ??
        LocalProfile(
          displayName: _displayName.trim(),
          photoPath: _photoPath,
          birthDate: _birthDate,
          privacyAccepted: _privacyAccepted,
          createdAt: DateTime.now(),
        );

    final updated = base.copyWith(
      displayName: _displayName.trim().isEmpty ? base.displayName : _displayName.trim(),
      photoPath: _photoPath,
      birthDate: _birthDate,
      privacyAccepted: _privacyAccepted,
    );
    await _repo.saveProfile(updated);
    _profile = updated;
  }
}
