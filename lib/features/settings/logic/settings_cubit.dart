// The brain of the little settings POPUP (the gear icon in the
// products app bar).
//
// It has exactly TWO actions:
//   loadUsername() -> read the saved user (for the menu header)
//   logout()       -> clean the session, then announce "logged out"
//
// It reuses the LoginRepo: the repo already knows how to clear
// the tokens + saved user safely (its logout() is best-effort and
// never throws), and how to read the saved user back.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  // The ROUTER creates this cubit (with the repo from get_it) and
  // provides it ABOVE the products screen, next to ProductsCubit.
  SettingsCubit({required this._repo}) : super(const SettingsInitial());

  final LoginRepo _repo;

  // ---- Action 1: who is logged in? (for the menu header) ----
  // Reads the user JSON saved in shared_preferences. No internet
  // and no loading state: reading one small string is instant.
  void loadUsername() {
    final user = _repo.getSavedUser();
    emit(SettingsLoaded(username: user?.username ?? ''));
  }

  // ---- Action 2: log out ----
  Future<void> logout() async {
    // 1. Tell the UI "busy" (the app bar icon shows a spinner).
    emit(const SettingsLoggingOut());

    // 2. Let the repo delete tokens + saved user from storage.
    await _repo.logout();

    // 3. Tell the UI "done" (the menu's listener goes to Login).
    emit(const SettingsLoggedOut());
  }
}
