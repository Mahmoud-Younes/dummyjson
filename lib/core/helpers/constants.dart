// Names we write ONCE here and reuse everywhere else.

// Keys used with shared_preferences (the "normal box").
// (The tokens themselves live in the ENCRYPTED box -
// flutter_secure_storage - but they use the same key names.)
class SharedPrefKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String savedUser = 'saved_user';
  static const String lastUsername = 'last_username';
}

// Values the app passes BETWEEN screens as route arguments.
class RouteArguments {
  // Login route: set by the AuthInterceptor when the saved session
  // could not be recovered (the refresh token was rejected).
  // LoginScreen shows its "session expired" banner when it
  // receives this value.
  static const String sessionExpired = 'sessionExpired';
}
