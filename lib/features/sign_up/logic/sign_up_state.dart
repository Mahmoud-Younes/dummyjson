// The possible SITUATIONS the sign-up screen can be in.
//
// A Cubit can only be in ONE state at a time, and the screen
// redraws itself whenever the state changes:
//
//   SignUpInitialState  -> the screen as it first looks (idle)
//   SignUpLoadingState  -> the Create Account button shows a spinner
//   SignUpSuccessState  -> sign-up worked (carries the new user)
//   SignUpErrorState    -> sign-up failed (carries a friendly message)
//
// Every state extends Equatable so the Cubit can skip emitting
// a state that is identical to the current one.

import 'package:equatable/equatable.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';

// The base class: every sign-up state IS a SignUpState.
// It has no fields of its own - the subclasses below add them.
abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

// The starting point: nothing has happened yet.
class SignUpInitialState extends SignUpState {
  const SignUpInitialState();
}

// The request to the server is running right now.
// The Create Account button listens for this to show a spinner.
class SignUpLoadingState extends SignUpState {
  const SignUpLoadingState();
}

// The server said yes! The new user (UserModel - the SAME shape
// login uses) travels inside this state; the success dialog reads
// the name from it.
class SignUpSuccessState extends SignUpState {
  const SignUpSuccessState({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

// Something went wrong (empty fields, passwords that don't match,
// no internet, server error...). The message is already
// user-friendly because the error handler translated the raw Dio
// error for us. (Note: the server never says "username taken" -
// /users/add accepts ANY username.)
class SignUpErrorState extends SignUpState {
  const SignUpErrorState({required this.error});

  final ErrorModel error;

  @override
  List<Object?> get props => [error];
}
