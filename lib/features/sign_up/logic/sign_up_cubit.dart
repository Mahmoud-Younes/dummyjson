// This is the BRAIN of the sign-up screen (a Cubit).
//
// A Cubit is a simple state machine: the screen calls its
// methods DIRECTLY (no events needed) and the screen listens
// to the states it emits:
//
//   signUp(...) -> called when Create Account is pressed
//
// Flow of a sign-up:
//   Screen calls signUp(first, last, username, email, pass, confirm)
//     -> Cubit says SignUpLoadingState  (button spins)
//     -> Cubit asks the Repository (server + the last username)
//     -> Cubit says SignUpSuccessState  (listener shows the success
//        dialog, then goes to the login screen on "Continue")
//        ...or SignUpErrorState (screen shows the reason)

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/sign_up/data/models/sign_up_request_body.dart';
import 'package:dummyjson/features/sign_up/data/repos/sign_up_repo.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  // The Cubit needs the Repository to do the real work.
  // We give it from outside (from get_it), like giving the
  // waiter a menu. We start in the idle state.
  SignUpCubit({required this._repo}) : super(const SignUpInitialState());

  final SignUpRepo _repo;

  // ---- Action 1: the Create Account button was pressed ----
  // Two cheap guards run BEFORE any internet is used (like the
  // login cubit checks its two fields first):
  //   1) no empty fields (password is NOT trimmed on purpose -
  //      spaces can be part of a password, same rule as login)
  //   2) password and its confirmation must be identical
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Guard 1: don't even call the server if a field is empty.
    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        username.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      emit(const SignUpErrorState(
        error: ErrorModel(message: 'Please fill in all fields.'),
      ));
      return;
    }

    // Guard 2: the two passwords must match exactly.
    if (password != confirmPassword) {
      emit(const SignUpErrorState(
        error: ErrorModel(message: 'Passwords do not match.'),
      ));
      return;
    }

    // Tell the screen to show a spinner.
    emit(const SignUpLoadingState());

    // The Repository calls the server and remembers the username
    // (shared_preferences) so the login screen can pre-fill it.
    final result = await _repo.signUp(
      SignUpRequestBody(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        username: username.trim(),
        email: email.trim(),
        password: password,
      ),
    );

    // ApiResult is a sealed class, so the compiler KNOWS these
    // are the only two possibilities - no "else" needed.
    switch (result) {
      case ApiSuccess<UserModel>():
        // Account "created" (simulated)! The listener shows the
        // success dialog, then navigates to the login screen.
        emit(SignUpSuccessState(user: result.data));
      case ApiFailure<UserModel>():
        // Show the friendly message the error handler built.
        emit(SignUpErrorState(error: result.error));
    }
  }
}
