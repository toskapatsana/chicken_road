import 'local_profile.dart';

abstract class ProfileRepository {
  Future<LocalProfile?> getProfile();
  Future<void> saveProfile(LocalProfile profile);
  Future<void> setPrivacyAccepted(bool accepted);
  Future<void> clearProfile();
}
