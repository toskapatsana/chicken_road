import 'package:shared_preferences/shared_preferences.dart';
import '../config/local_auth_config.dart';
import '../domain/local_profile.dart';
import '../domain/profile_repository.dart';

/// SharedPreferences-backed implementation of [ProfileRepository].
class ProfileRepositoryImpl implements ProfileRepository {
  static const _key = LocalAuthConfig.profileStorageKey;

  @override
  Future<LocalProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return LocalProfile.decode(raw);
  }

  @override
  Future<void> saveProfile(LocalProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, profile.encode());
  }

  @override
  Future<void> setPrivacyAccepted(bool accepted) async {
    final existing = await getProfile();
    if (existing == null) return;
    await saveProfile(existing.copyWith(privacyAccepted: accepted));
  }

  @override
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
