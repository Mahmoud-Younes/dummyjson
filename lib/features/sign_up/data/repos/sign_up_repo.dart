// This file is the "manager" for everything sign-up.
//
// It connects ApiService (the internet) to the Cubit and offers it
// ONE clean action:
//   1. signUp -> ask the server to "create" the account, return the user
//
// The Cubit NEVER talks to Dio directly. It only talks to this
// Repository - that keeps things tidy (same rule as login).
//
// The method answers with an ApiResult:
//   ApiSuccess -> everything worked (carries the UserModel)
//   ApiFailure -> something failed (carries a friendly ErrorModel)
//
// STORAGE RULE (important!): sign-up saves ONLY the username - no
// tokens, no user JSON. Why?
//   - The account is NOT real (DummyJSON throws it away), so saving
//     user data or tokens here would make the splash screen think
//     someone is logged in while /auth/me would fail.
//   - The username goes into shared_preferences (lastUsername), and
//     the login screen reads it back to pre-fill its form.

import 'package:dio/dio.dart';

import 'package:dummyjson/core/helpers/shared_pref_helper.dart';
import 'package:dummyjson/core/networking/api_error_handler.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/core/networking/api_service.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/sign_up/data/models/sign_up_request_body.dart';

// The CONTRACT: what any sign-up repository must be able to do.
// The Cubit depends on THIS (not on the implementation), so the
// real work can be swapped or faked without touching it.
abstract class SignUpRepo {
  Future<ApiResult<UserModel>> signUp(SignUpRequestBody requestBody);
}

// The REAL implementation: talks to the internet (through
// ApiService) and to ONE storage box (shared_preferences for the
// last username) - never to secure storage (no tokens here!).
class SignUpRepoImpl implements SignUpRepo {
  // We receive the ApiService from outside (from get_it).
  const SignUpRepoImpl(this._apiService);

  final ApiService _apiService;

  // ---- 1. SIGN UP ----
  // Step by step:
  //   a) ask the server to "create" the account (/users/add)
  //   b) remember the username (so login can pre-fill it later)
  //   c) hand the new user back as ApiSuccess
  //
  // LEARNING NOTE: /users/add answers 201 with the new user BUT
  // does not really save it - DummyJSON is a fake learning API.
  // So we do NOT store tokens and we do NOT auto-login here: the
  // login screen is the next stop (the UI navigates to it).
  @override
  Future<ApiResult<UserModel>> signUp(
    SignUpRequestBody requestBody,
  ) async {
    try {
      // a) The server answers with the new user as a flat JSON map.
      final Map<String, dynamic> json = await _apiService.signUpUser(
        requestBody.firstName,
        requestBody.lastName,
        requestBody.username,
        requestBody.email,
        requestBody.password,
      );

      // Same user shape as login (UserModel) - sign-up just builds
      // it from the "created" answer instead of a login answer.
      final UserModel user = UserModel.fromJson(json);

      // b) Remember the username so the login screen can pre-fill
      // it. (LoginCubit.getPrefillUsername reads this same key.)
      await SharedPrefHelper.saveLastUsername(requestBody.username);

      // c) Success! The user travels to the Cubit inside ApiSuccess.
      return ApiSuccess<UserModel>(user);
    } on DioException catch (e) {
      // Wrong data, no internet, server down... all Dio problems are
      // translated here into one friendly message. The repo NEVER
      // throws - the Cubit just gets an ApiFailure it can show.
      return ApiFailure<UserModel>(handle(e));
    }
  }
}
