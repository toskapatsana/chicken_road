import 'local_profile.dart';

/// Abstract interface for local profile persistence.
/// Swap implementations to change storage backend.
abstract class ProfileRepository {
  Future<LocalProfile?> getProfile();
  Future<void> saveProfile(LocalProfile profile);
  Future<void> setPrivacyAccepted(bool accepted);
  Future<void> clearProfile();
}
