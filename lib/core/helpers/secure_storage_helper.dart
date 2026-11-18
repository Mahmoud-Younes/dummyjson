// A tiny wrapper around flutter_secure_storage (the ENCRYPTED box).
//
// Only the two auth tokens live here - they are secrets, so they
// must NOT go into the normal shared_preferences box.
//
// All methods are static: call them like SecureStorageHelper.getAccessToken().

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/helpers/constants.dart';

abstract final class SecureStorageHelper {
  // Ask get_it for the storage object registered in main().
  static FlutterSecureStorage get _storage => getIt<FlutterSecureStorage>();

  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: SharedPrefKeys.accessToken, value: token);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: SharedPrefKeys.refreshToken, value: token);

  // Returns null when no token was saved yet (not logged in).
  static Future<String?> getAccessToken() =>
      _storage.read(key: SharedPrefKeys.accessToken);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: SharedPrefKeys.refreshToken);

  // Called on logout: forget BOTH tokens in one go.
  static Future<void> clearTokens() async {
    await _storage.delete(key: SharedPrefKeys.accessToken);
    await _storage.delete(key: SharedPrefKeys.refreshToken);
  }
}
