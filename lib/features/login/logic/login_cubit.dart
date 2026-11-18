// This is the BRAIN of the login screen (a Cubit).
//
// A Cubit is a simple state machine: the screen calls its
// methods DIRECTLY (no events needed) and the screen listens
// to the states it emits:
//
//   login(...)           -> called when the Login button is pressed
//   getPrefillUsername() -> called so the form can pre-fill the username
//
// Flow of a login:
//   Screen calls login("emilys", "emilyspass")
//     -> Cubit says LoginLoadingState   (button spins)
//     -> Cubit asks the Repository (server + save tokens)
//     -> Cubit says LoginSuccessState   (listener opens Products)
//        ...or LoginErrorState (screen shows the reason)

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  // The Cubit needs the Repository to do the real work.
  // We give it from outside (from get_it), like giving the
  // waiter a menu. We start in the idle state.
  LoginCubit({required this._repo}) : super(const LoginInitialState());

  final LoginRepo _repo;

  // ---- Action 1: the Login button was pressed ----
  // rememberMe comes from the checkbox on the login page:
  //   true  -> tokens are SAVED (next app open is auto-logged-in)
  //   false -> session lives only until the app closes
  Future<void> login(
    String username,
    String password, {
    bool rememberMe = true,
  }) async {
    // Small guard: don't even call the server if fields are empty.
    if (username.trim().isEmpty || password.isEmpty) {
      emit(const LoginErrorState(
        error: ErrorModel(message: 'Please fill in both fields.'),
      ));
      return;
    }

    // Tell the screen to show a spinner.
    emit(const LoginLoadingState());

    // The Repository calls the server AND (if rememberMe)
    // saves the tokens + user + last username.
    final result = await _repo.login(
      LoginRequestBody(
        username: username.trim(),
        password: password,
      ),
      rememberMe: rememberMe,
    );

    // ApiResult is a sealed class, so the compiler KNOWS these
    // are the only two possibilities - no "else" needed.
    switch (result) {
      case ApiSuccess<LoginResponse>():
        // Welcome back! The listener navigates to the products screen.
        emit(LoginSuccessState(loginResponse: result.data));
      case ApiFailure<LoginResponse>():
        // Show the friendly message the error handler built.
        emit(LoginErrorState(error: result.error));
    }
  }

  // ---- Action 2: the last username typed ----
  // So the username field can start pre-filled. The screen asks
  // for this once when it opens.
  String? getPrefillUsername() {
    return _repo.getPrefillUsername();
  }
}
