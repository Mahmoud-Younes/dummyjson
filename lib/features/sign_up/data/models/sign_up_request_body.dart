// This file describes the DATA we SEND to the sign-up endpoint.
//
// POST /users/add expects a body like:
//   {
//     "firstName": "Ovi",
//     "lastName": "Tester",
//     "email": "ovi99@test.com",
//     "username": "ovitester99",
//     "password": "ovipass123"
//   }
//
// Wrapping the body in a class (instead of a raw Map) means the
// Cubit can build it safely and typos are caught by the compiler -
// same idea as LoginRequestBody.

import 'package:equatable/equatable.dart';

// The sign-up request body: a small box with the 5 fields the
// server asks for to "create" an account.
// We extend Equatable so two requests with the same values are
// considered equal (handy for tests and Cubit comparisons).
class SignUpRequestBody extends Equatable {
  final String firstName; // example: "Ovi"
  final String lastName; // example: "Tester"
  final String email; // example: "ovi99@test.com"
  final String username; // example: "ovitester99"
  final String password; // example: "ovipass123"

  const SignUpRequestBody({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
  });

  // Turn the object into the JSON map Dio will send as the body.
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'password': password,
    };
  }

  // Needed for Equatable: two bodies are equal when ALL five
  // fields are equal.
  @override
  List<Object?> get props =>
      [firstName, lastName, email, username, password];
}
