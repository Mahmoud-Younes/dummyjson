// The possible SITUATIONS the login screen can be in.
//
// A Cubit can only be in ONE state at a time, and the screen
// redraws itself whenever the state changes:
//
//   LoginInitialState  -> the screen as it first looks (idle)
//   LoginLoadingState  -> the Login button shows a spinner
//   LoginSuccessState  -> login worked (carries the full session)
//   LoginErrorState    -> login failed (carries a friendly message)
//
// Every state extends Equatable so the Cubit can skip emitting
// a state that is identical to the current one.

import 'package:equatable/equatable.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';

// The base class: every login state IS a LoginState.
// It has no fields of its own - the subclasses below add them.
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

// The starting point: nothing has happened yet.
class LoginInitialState extends LoginState {
  const LoginInitialState();
}

// The request to the server is running right now.
// The login button listens for this to show a spinner.
class LoginLoadingState extends LoginState {
  const LoginLoadingState();
}

// The server said yes! The session (user + tokens) travels
// inside this state; a listener uses it to open the products screen.
class LoginSuccessState extends LoginState {
  const LoginSuccessState({required this.loginResponse});

  final LoginResponse loginResponse;

  @override
  List<Object?> get props => [loginResponse];
}

// Something went wrong (wrong password, no internet, empty
// fields...). The message is already user-friendly because the
// error handler translated the raw Dio error for us.
class LoginErrorState extends LoginState {
  const LoginErrorState({required this.error});

  final ErrorModel error;

  @override
  List<Object?> get props => [error];
}
