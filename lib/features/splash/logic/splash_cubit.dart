// This is the BRAIN of the splash screen (a Cubit).
//
// It has exactly ONE action:
//   restoreSession() -> called once when the app opens
//
// Flow:
//   App opens -> SplashChecking (logo + spinner)
//   -> Cubit asks the Repository: "is there a saved session?"
//   -> yes -> SplashAuthenticated   (listener opens Products)
//      no -> SplashUnauthenticated  (listener opens Login)

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  // The Cubit needs the Repository to do the real work.
  // We give it from outside (from get_it). We start in the
  // checking state, which shows the logo + spinner.
  SplashCubit({required this._repo}) : super(const SplashChecking());

  final LoginRepo _repo;

  // ---- Action 1: app just opened - are we still logged in? ----
  // The Repository reads the saved tokens and checks them with
  // the server (and refreshes them if they expired). Offline it
  // falls back to the saved user, so the answer is never "crash".
  Future<void> restoreSession() async {
    try {
      final LoginResponse? session = await _repo.checkSavedSession();

      if (session == null) {
        // No session (or it died): show the login page.
        emit(const SplashUnauthenticated());
      } else {
        // Welcome back! Skip the login page completely.
        emit(const SplashAuthenticated());
      }
    } catch (_) {
      // Safety net: storage can fail in rare ways the repo does
      // not translate (a platform error, for example). Without
      // this catch the Cubit would sit in SplashChecking FOREVER
      // and the user would be stuck on the splash screen. No
      // matter what blew up, the safest answer is: show login.
      emit(const SplashUnauthenticated());
    }
  }
}
