// The possible SITUATIONS the splash screen can be in.
//
// The splash screen has ONE job: wait while we check for a
// saved session, then move out of the way:
//
//   SplashChecking        -> still checking (show logo + spinner)
//   SplashAuthenticated   -> saved session found (go to Products)
//   SplashUnauthenticated -> no saved session (go to the Login page)
//
// Every state extends Equatable so the Cubit can skip emitting
// a state that is identical to the current one.

import 'package:equatable/equatable.dart';

// The base class: every splash state IS a SplashState.
abstract class SplashState extends Equatable {
  const SplashState();

  // No state holds data, so the props list is empty for everyone.
  @override
  List<Object?> get props => [];
}

// The app just opened and checkSavedSession() is still running.
class SplashChecking extends SplashState {
  const SplashChecking();
}

// A saved session was found and still works (or offline mode
// saved us). The session itself stays in storage - the products
// screen reads what it needs from there, so this state stays
// empty and the listener just navigates.
class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

// No saved session (or it died): time for the login page.
class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
