// This file is the "translator + manager" for everything login.
//
// It connects the two worlds:
//   ApiService (the internet) + the storage helpers (the phone)
//
// and offers the Cubits just 5 clean actions:
//   1. login              -> check password, SAVE the tokens, return the session
//   2. checkSavedSession  -> app just opened: is there a saved session?
//   3. logout             -> delete the session (but keep the last username)
//   4. getPrefillUsername -> the last username typed (to fill the form)
//   5. getSavedUser       -> the saved user (for the settings popup)
//
// The Cubits NEVER talk to Dio or storage directly.
// They only talk to this Repository. That keeps things tidy.
//
// Every method answers with an ApiResult:
//   ApiSuccess -> everything worked (carries the data)
//   ApiFailure -> something failed (carries a friendly ErrorModel)

import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:dummyjson/core/helpers/shared_pref_helper.dart';
import 'package:dummyjson/core/helpers/secure_storage_helper.dart';
import 'package:dummyjson/core/networking/api_error_handler.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/core/networking/api_service.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';

// The CONTRACT: what any login repository must be able to do.
// The Cubits depend on THIS (not on the implementation), so the
// real work can be swapped or faked without touching them.
abstract class LoginRepo {
  Future<ApiResult<LoginResponse>> login(
    LoginRequestBody requestBody, {
    bool rememberMe = true,
  });

  Future<LoginResponse?> checkSavedSession();

  Future<void> logout();

  String? getPrefillUsername();

  /// The user saved in shared_preferences, or null when nothing is
  /// saved (the settings popup shows the username from it).
  UserModel? getSavedUser();
}

// The REAL implementation: talks to the internet and to both
// storage boxes (secure storage for tokens, shared_preferences
// for the user JSON + last username).
class LoginRepoImpl implements LoginRepo {
  // We receive the ApiService from outside (from get_it).
  const LoginRepoImpl(this._apiService);

  final ApiService _apiService;

  // ---- 1. LOGIN ----
  // Step by step:
  //   a) ask the server (it checks username + password)
  //   b) if "remember me" is checked:
  //        - copy the two tokens into the SAFE box (secure storage)
  //        - copy the user info into the NORMAL box (shared_preferences)
  //   c) remember the username (to pre-fill the form next time)
  //   d) hand the full LoginResponse back as ApiSuccess
  //
  // rememberMe = false means: "keep me logged in for THIS run only".
  // The session still works now, but the phone forgets it on restart.
  @override
  Future<ApiResult<LoginResponse>> login(
    LoginRequestBody requestBody, {
    bool rememberMe = true,
  }) async {
    try {
      // a) The server answers with ONE flat map: user + tokens.
      final Map<String, dynamic> json = await _apiService.login(
        requestBody.username,
        requestBody.password,
        expiresInMins: requestBody.expiresInMins,
      );

      final LoginResponse response = LoginResponse.fromJson(json);

      if (rememberMe) {
        // b) Save in BOTH boxes. Now the session survives a restart.
        await SecureStorageHelper.saveAccessToken(response.accessToken);
        await SecureStorageHelper.saveRefreshToken(response.refreshToken);
        await SharedPrefHelper.saveUserJson(jsonEncode(response.user.toJson()));
        // c) Remember the username so the form can pre-fill it.
        await SharedPrefHelper.saveLastUsername(requestBody.username);
      }

      return ApiSuccess<LoginResponse>(response);
    } on DioException catch (e) {
      // Wrong password, no internet, server down... all Dio
      // problems are translated here into one friendly message.
      return ApiFailure<LoginResponse>(handle(e));
    }
  }

  // ---- 2. CHECK SAVED SESSION (auto login when the app opens) ----
  // This is where the saved tokens earn their keep!
  //
  //   no tokens saved?            -> return null (show login page)
  //   /auth/me works              -> still logged in, welcome back!
  //   /auth/me says 401/403       -> use the REFRESH token to get a
  //                                  new pair, then try again
  //   refresh rejected (400/401/403) -> session is dead: clean up
  //                                     both boxes, show login page
  //   no internet at any point    -> fall back to the SAVED user
  //                                  (shared_preferences) so the
  //                                  app still opens "logged in"
  @override
  Future<LoginResponse?> checkSavedSession() async {
    // Step 1: look in the safe box.
    final String? accessToken;
    final String? refreshToken;
    try {
      accessToken = await SecureStorageHelper.getAccessToken();
      refreshToken = await SecureStorageHelper.getRefreshToken();
    } catch (_) {
      // The safe box itself is broken (a rare platform error).
      // That is NOT a network problem and NOT the session's fault.
      // Without this guard the exception would fly up and leave
      // the user stuck on the splash screen FOREVER. So: treat it
      // as "no session", clean whatever we safely can, show login.
      await _clearStorageSafely();
      return null;
    }
    if (accessToken == null || refreshToken == null) {
      return null; // never logged in (or logged out before)
    }

    // Step 2: ask the server "who am I?" with the access token.
    try {
      final Map<String, dynamic> json = await _apiService.getCurrentUser(
        accessToken,
      );
      return LoginResponse(
        user: UserModel.fromJson(json),
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      // Step 3: the access token was rejected (expired or revoked).
      // Time to trade the refresh token for a fresh pair.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return _refreshAndRetry(
          savedAccessToken: accessToken,
          savedRefreshToken: refreshToken,
        );
      }
      // Step 4: not the server's verdict (probably no internet).
      // Use the saved user so the app still works offline.
      return _offlineSession(accessToken, refreshToken);
    }
  }

  // Helper for Step 3: trade the refresh token for a new pair of
  // tokens, then ask "who am I?" again with the NEW access token.
  Future<LoginResponse?> _refreshAndRetry({
    required String savedAccessToken,
    required String savedRefreshToken,
  }) async {
    // Start with the tokens we already have; they are replaced
    // below the moment the server sends a fresh pair. If the
    // internet dies halfway, we still have SOMETHING to fall
    // back to in the offline session.
    String accessToken = savedAccessToken;
    String refreshToken = savedRefreshToken;

    try {
      final Map<String, dynamic> refreshJson = await _apiService.refreshTokens(
        refreshToken,
      );

      // IMPORTANT: save the NEW pair - the old one is now useless.
      accessToken = (refreshJson['accessToken'] as String?) ?? accessToken;
      refreshToken = (refreshJson['refreshToken'] as String?) ?? refreshToken;
      await SecureStorageHelper.saveAccessToken(accessToken);
      await SecureStorageHelper.saveRefreshToken(refreshToken);

      // Ask again with the fresh access token.
      final Map<String, dynamic> meJson = await _apiService.getCurrentUser(
        accessToken,
      );
      return LoginResponse(
        user: UserModel.fromJson(meJson),
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      // The refresh token was rejected too (400/401/403):
      // the session is truly over. Clean up BOTH boxes and
      // show the login page.
      final int? code = e.response?.statusCode;
      if (code == 400 || code == 401 || code == 403) {
        await SecureStorageHelper.clearTokens();
        await SharedPrefHelper.removeSavedUser();
        return null;
      }
      // The internet died DURING the refresh. Not the session's
      // fault! Use the saved user instead.
      return _offlineSession(accessToken, refreshToken);
    }
  }

  // Helper: build a session from the user saved in
  // shared_preferences (works with no internet). The tokens are
  // the last ones we know about - good enough for offline mode.
  // Returns null when there is no saved user (or the saved text
  // is broken), meaning: show the login page.
  LoginResponse? _offlineSession(String accessToken, String refreshToken) {
    // The parsing itself lives in getSavedUser() below - the old
    // duplicated parsing now lives in ONE place.
    final UserModel? user = getSavedUser();
    if (user == null) {
      return null; // nothing saved before
    }
    return LoginResponse(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  // ---- 3. LOGOUT ----
  // Clear both boxes. NOTE: we deliberately KEEP lastUsername,
  // so the login form stays pre-filled with the old username.
  @override
  Future<void> logout() async {
    // Best-effort cleanup: a broken box must never make logout
    // throw, or the logout button would spin with no way out.
    // If one box fails we still clean the other one.
    await _clearStorageSafely();
  }

  // Shared safety net for storage failures: try to empty BOTH
  // boxes, one box at a time, and swallow every storage error on
  // the way. Used by logout AND by the "safe box is unreadable"
  // fallback in checkSavedSession above. Each step is guarded on
  // its own, so one broken box never blocks the other.
  Future<void> _clearStorageSafely() async {
    try {
      await SecureStorageHelper.clearTokens();
    } catch (_) {
      // The safe box refused. Keep going: the normal box may
      // still be cleanable.
    }
    try {
      await SharedPrefHelper.removeSavedUser();
    } catch (_) {
      // Nothing else we can safely clean - give up quietly.
    }
  }

  // ---- 4. LAST USERNAME ----
  // So the login form can pre-fill the username field.
  @override
  String? getPrefillUsername() {
    return SharedPrefHelper.getLastUsername();
  }

  // ---- 5. THE SAVED USER ----
  // Reads the user JSON from shared_preferences and decodes it back
  // into a UserModel (used by the settings popup AND by the offline
  // session above). Defensive parsing: null/empty/broken text always
  // answers null - never an exception.
  @override
  UserModel? getSavedUser() {
    final String? userJson = SharedPrefHelper.getUserJson();
    if (userJson == null || userJson.isEmpty) {
      return null; // nothing saved before
    }
    try {
      final Map<String, dynamic> json =
          jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      // The saved text was not valid JSON - broken text must never
      // crash a popup header (or the splash screen).
      return null;
    }
  }
}
