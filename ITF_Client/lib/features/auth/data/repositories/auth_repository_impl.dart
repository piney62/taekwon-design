import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.prefs,
    required this.secureStorage,
  });

  final PreferencesService prefs;
  final SecureStorageService secureStorage;

  static const _kDisplayName = 'user.display_name';
  static const _kPassword = 'user.password';

  @override
  Future<UserProfile?> load() async {
    final name = prefs.getString(_kDisplayName);
    if (name == null || name.isEmpty) return null;
    final hasPassword = await secureStorage.contains(_kPassword);
    return UserProfile(displayName: name, hasPassword: hasPassword);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await prefs.setString(_kDisplayName, profile.displayName);
  }

  @override
  Future<void> updateDisplayName(String name) async {
    await prefs.setString(_kDisplayName, name);
  }

  @override
  Future<bool> verifyPassword(String password) async {
    final stored = await secureStorage.read(_kPassword);
    return stored == password;
  }

  @override
  Future<void> savePassword(String password) async {
    await secureStorage.write(_kPassword, password);
  }

  @override
  Future<void> clearPassword() async {
    await secureStorage.delete(_kPassword);
  }
}
