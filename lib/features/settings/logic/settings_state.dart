// The possible SITUATIONS of the settings popup (the gear icon in
// the products app bar).
//
//   SettingsInitial    -> the cubit was just created
//   SettingsLoaded     -> the saved user was read (carries the username)
//   SettingsLoggingOut -> logout is running (spinner in the app bar)
//   SettingsLoggedOut  -> storage is clean (the listener goes to Login)
//
// Every state extends Equatable so the Cubit can skip emitting
// a state that is identical to the current one.

import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

// The saved user was read. The username feeds the popup menu's
// header line ("Signed in as @emilys"). Empty string = nothing
// saved (the menu then simply hides the header line).
class SettingsLoaded extends SettingsState {
  const SettingsLoaded({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

// The user tapped Logout and the cleanup is still running.
class SettingsLoggingOut extends SettingsState {
  const SettingsLoggingOut();
}

// Logout finished -> time to go back to the Login page.
class SettingsLoggedOut extends SettingsState {
  const SettingsLoggedOut();
}
