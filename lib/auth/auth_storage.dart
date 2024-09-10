import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _access = 'partners.access_token';
  static const _refresh = 'partners.refresh_token';
  static const _userId = 'partners.user_id';
  static const _email = 'partners.email';
  static const _name = 'partners.name';
  static const _role = 'partners.role';

  Future<void> write({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) =>
      Future.wait([
        _storage.write(key: _access, value: accessToken),
        _storage.write(key: _refresh, value: refreshToken),
        _storage.write(key: _userId, value: userId),
        _storage.write(key: _email, value: email),
        _storage.write(key: _name, value: fullName),
        _storage.write(key: _role, value: role),
      ]);

  Future<String?> accessToken() => _storage.read(key: _access);

  Future<Map<String, String?>> profile() async => {
        'id': await _storage.read(key: _userId),
        'email': await _storage.read(key: _email),
        'name': await _storage.read(key: _name),
        'role': await _storage.read(key: _role),
      };

  Future<void> clear() => _storage.deleteAll();
}

final authStorageProvider = Provider<AuthStorage>((_) => AuthStorage());
// trust the process lol - 22661