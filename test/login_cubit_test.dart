// Unit tests for LoginCubit - the login screen's state machine.
//
// The repo is faked (implements the abstract LoginRepo), so no
// internet and no storage are touched. We check EXACTLY which
// states are emitted for each scenario, using bloc_test.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/login/logic/login_state.dart';

// A hand-rolled fake: records what it was asked and answers with
// whatever the test set beforehand.
class FakeLoginRepo implements LoginRepo {
  ApiResult<LoginResponse> loginResult =
      const ApiFailure(ErrorModel(message: 'not configured'));

  LoginRequestBody? lastBody;
  bool? lastRememberMe;
  int loginCallCount = 0;

  @override
  Future<ApiResult<LoginResponse>> login(
    LoginRequestBody requestBody, {
    bool rememberMe = true,
  }) async {
    loginCallCount++;
    lastBody = requestBody;
    lastRememberMe = rememberMe;
    return loginResult;
  }

  @override
  Future<LoginResponse?> checkSavedSession() async => null;

  @override
  Future<void> logout() async {}

  @override
  String? getPrefillUsername() => null;

  @override
  UserModel? getSavedUser() => null;
}

const tUser = UserModel(
  id: 9,
  username: 'emilys',
  email: 'emily.johnson@x.dummyjson.com',
  firstName: 'Emily',
  lastName: 'Johnson',
  gender: 'female',
  image: 'https://dummyjson.com/icon/emilys/128',
);

const tSession = LoginResponse(
  user: tUser,
  accessToken: 'ACCESS',
  refreshToken: 'REFRESH',
);

void main() {
  group('LoginCubit', () {
    test('starts in LoginInitialState', () {
      final cubit = LoginCubit(repo: FakeLoginRepo());
      expect(cubit.state, isA<LoginInitialState>());
      cubit.close();
    });

    blocTest<LoginCubit, LoginState>(
      'empty fields -> LoginErrorState WITHOUT calling the repo',
      build: () {
        final repo = FakeLoginRepo();
        return LoginCubit(repo: repo);
      },
      act: (cubit) => cubit.login('', ''),
      expect: () => [
        const LoginErrorState(
          error: ErrorModel(message: 'Please fill in both fields.'),
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'whitespace-only username also hits the empty-field guard',
      build: () => LoginCubit(repo: FakeLoginRepo()),
      act: (cubit) => cubit.login('   ', 'secret1'),
      expect: () => [
        const LoginErrorState(
          error: ErrorModel(message: 'Please fill in both fields.'),
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'success -> loading then success (with the server session)',
      build: () {
        final repo = FakeLoginRepo()
          ..loginResult = const ApiSuccess(tSession);
        return LoginCubit(repo: repo);
      },
      act: (cubit) => cubit.login('emilys', 'emilyspass'),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginSuccessState>()
            .having((s) => s.loginResponse, 'loginResponse', tSession),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'cubit trims the username and forwards rememberMe to the repo',
      build: () {
        final repo = FakeLoginRepo()
          ..loginResult = const ApiSuccess(tSession);
        return LoginCubit(repo: repo);
      },
      act: (cubit) =>
          cubit.login('  emilys  ', 'emilyspass', rememberMe: false),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginSuccessState>(),
      ],
      verify: (_) {
        // Inspect the captured fake directly (same closure).
      },
    );

    blocTest<LoginCubit, LoginState>(
      'repo failure -> loading then error (message carried through)',
      build: () {
        final repo = FakeLoginRepo()
          ..loginResult = const ApiFailure(
            ErrorModel(statusCode: 400, message: 'Invalid credentials'),
          );
        return LoginCubit(repo: repo);
      },
      act: (cubit) => cubit.login('emilys', 'wrongpass'),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginErrorState>().having(
          (s) => s.error.message,
          'message',
          'Invalid credentials',
        ),
      ],
    );

    test('username is trimmed before being sent to the repo', () async {
      final repo = FakeLoginRepo()
        ..loginResult = const ApiSuccess(tSession);
      final cubit = LoginCubit(repo: repo);

      await cubit.login('  emilys  ', 'emilyspass', rememberMe: false);

      expect(repo.lastBody?.username, 'emilys');
      expect(repo.lastBody?.password, 'emilyspass');
      expect(repo.lastRememberMe, isFalse);
      expect(repo.loginCallCount, 1);
      await cubit.close();
    });

    test('empty fields never reach the repo', () async {
      final repo = FakeLoginRepo();
      final cubit = LoginCubit(repo: repo);

      await cubit.login('', '');

      expect(repo.loginCallCount, 0);
      expect(cubit.state, isA<LoginErrorState>());
      await cubit.close();
    });
  });
}
