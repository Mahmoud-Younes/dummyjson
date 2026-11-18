// A tiny wrapper around shared_preferences (the NORMAL, not-encrypted box).
//
// Good for things that are NOT secrets: the saved user JSON and
// the last username typed into the login form (for pre-filling it).
//
// All methods are static: call them like SharedPrefHelper.getUserJson().

import 'package:shared_preferences/shared_preferences.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/helpers/constants.dart';

abstract final class SharedPrefHelper {
  // Ask get_it for the prefs object registered in main().
  static SharedPreferences get _prefs => getIt<SharedPreferences>();

  // Save the logged-in user as a JSON string (saved_user key).
  static Future<void> saveUserJson(String userJson) =>
      _prefs.setString(SharedPrefKeys.savedUser, userJson);

  // Read it back (null when nothing was saved yet).
  static String? getUserJson() => _prefs.getString(SharedPrefKeys.savedUser);

  // Remember the last username so the form can pre-fill it next time.
  static Future<void> saveLastUsername(String username) =>
      _prefs.setString(SharedPrefKeys.lastUsername, username);

  static String? getLastUsername() =>
      _prefs.getString(SharedPrefKeys.lastUsername);

  // Called on logout: forget the user but KEEP lastUsername,
  // so the login form stays pre-filled next time.
  static Future<void> removeSavedUser() =>
      _prefs.remove(SharedPrefKeys.savedUser);
}
