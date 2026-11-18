// This file holds the TWO shapes of a successful login.
//
// The server answers POST /auth/login with ONE flat JSON map
// that mixes user info AND the tokens:
//   {
//     "id": 1,
//     "username": "emilys",
//     "email": "emily.johnson@x.dummyjson.com",
//     "firstName": "Emily",
//     "lastName": "Johnson",
//     "gender": "female",
//     "image": "https://dummyjson.com/icon/emilys/128",
//     "accessToken": "...",   <- goes to secure storage, NOT here
//     "refreshToken": "..."   <- goes to secure storage, NOT here
//   }
//
// So we split it into two boxes:
//   UserModel      -> only the person's info (saved in shared_preferences)
//   LoginResponse  -> user + the two tokens (what the app flows around)
//
// Both classes live in THIS one file on purpose (one file per response):
// they always travel together.

import 'package:equatable/equatable.dart';

// A User is a box that holds the logged-in person's info.
// We extend Equatable so Flutter can easily tell if two users
// are the same (needed for Cubit state comparison).
class UserModel extends Equatable {
  // ---- 1. The fields every user has ----

  final int id; // example: 1
  final String username; // example: "emilys"
  final String email; // example: "emily.johnson@x.dummyjson.com"
  final String firstName; // example: "Emily"
  final String lastName; // example: "Johnson"
  final String gender; // example: "female"
  final String image; // link to the profile picture

  // ---- 2. How to CREATE a user ----
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
  });

  // ---- 3. How to MAKE a user from internet data (JSON) ----
  // Defensive parsing: read with "as ...?" and fall back to an
  // empty value if the server omits a field. That way one
  // missing key can never crash the app.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
    );
  }

  // ---- 4. How to TURN a user back into JSON (text) ----
  // Why? shared_preferences can only store simple things (text,
  // numbers, booleans) - not objects. So before saving the user
  // we convert it to a JSON string with jsonEncode(user.toJson()).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }

  // ---- 5. Small helper to make the UI code shorter ----
  // "Emily Johnson" - the full name in one line.
  String get fullName => '$firstName $lastName';

  // ---- 6. Needed for Equatable (lets Cubit compare users) ----
  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        gender,
        image,
      ];
}

// A LoginResponse is the FULL session: the person + their two keys.
// It is what a successful login carries and what SplashCubit
// restores from storage.
class LoginResponse extends Equatable {
  final UserModel user;
  final String accessToken; // short-lived key (sent with every request)
  final String refreshToken; // long-lived key (used to get a new pair)

  const LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  // Build the session from the SAME flat map the server sends:
  // user fields + accessToken + refreshToken all live together.
  // Defensive parsing again: missing tokens become '' instead of
  // crashing (the repository decides what to do with them).
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json),
      accessToken: (json['accessToken'] as String?) ?? '',
      refreshToken: (json['refreshToken'] as String?) ?? '',
    );
  }

  // Needed for Equatable (lets Cubit compare sessions).
  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
