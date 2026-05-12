import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> load();

  Future<void> saveProfile(UserProfile profile);

  Future<void> updateDisplayName(String name);

  Future<bool> verifyPassword(String password);

  Future<void> savePassword(String password);

  Future<void> clearPassword();
}
