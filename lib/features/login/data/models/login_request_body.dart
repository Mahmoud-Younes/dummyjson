// This file describes the DATA we SEND to the login endpoint.
//
// POST /auth/login expects a body like:
//   {"username": "emilys", "password": "emilyspass", "expiresInMins": 60}
//
// expiresInMins = how many MINUTES the access token stays valid.
// Wrapping the body in a class (instead of a raw Map) means the
// Cubit can build it safely and typos are caught by the compiler.

import 'package:equatable/equatable.dart';

// The login request body: just a small box with the 3 fields
// the server asks for.
// We extend Equatable so two requests with the same values
// are considered equal (handy for tests and Cubit comparisons).
class LoginRequestBody extends Equatable {
  final String username; // example: "emilys"
  final String password; // example: "emilyspass"
  final int expiresInMins; // example: 60 (token lives for 1 hour)

  // expiresInMins has a DEFAULT (60) so callers can skip it:
  //   LoginRequestBody(username: ..., password: ...)
  const LoginRequestBody({
    required this.username,
    required this.password,
    this.expiresInMins = 60,
  });

  // Turn the object into the JSON map Dio will send as the body.
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'expiresInMins': expiresInMins,
    };
  }

  // Needed for Equatable: two bodies are equal when all
  // three fields are equal.
  @override
  List<Object?> get props => [username, password, expiresInMins];
}
