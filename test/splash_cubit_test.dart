// Unit tests for SplashCubit - the auto-login decider.
//
// The same FakeLoginRepo idea as the LoginCubit tests: the fake
// answers checkSavedSession() with a session or null, and we
// assert which state the splash screen will receive.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'package:dummyjson/features/splash/logic/splash_cubit.dart';
import 'package:dummyjson/features/splash/logic/splash_state.dart';

// Minimal fake: only checkSavedSession matters for the splash.
class FakeLoginRepo implements LoginRepo {
  LoginResponse? session;

  // When set, checkSavedSession() blows up with it - simulates a
  // storage failure that slipped past the repo's own guards.
  Object? restoreThrow;

  @override
  Future<LoginResponse?> checkSavedSession() async {
    if (restoreThrow != null) {
      throw restoreThrow!;
    }
    return session;
  }

  @override
  Future<ApiResult<LoginResponse>> login(
    LoginRequestBody requestBody, {
    bool rememberMe = true,
  }) async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  String? getPrefillUsername() => null;

  @override
  UserModel? getSavedUser() => null;
}

const tSession = LoginResponse(
  user: UserModel(
    id: 9,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://dummyjson.com/icon/emilys/128',
  ),
  accessToken: 'ACCESS',
  refreshToken: 'REFRESH',
);

void main() {
  // Same hygiene as login_repo_test.dart: a FRESH get_it and
  // in-memory prefs before every test. The fake-repo tests below
  // never touch them, but keeping the pattern uniform protects
  // against accidental real-storage access.
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
  });

  group('SplashCubit', () {
    test('starts in SplashChecking', () {
      final cubit = SplashCubit(repo: FakeLoginRepo());
      expect(cubit.state, isA<SplashChecking>());
      cubit.close();
    });

    blocTest<SplashCubit, SplashState>(
      'saved session exists -> SplashAuthenticated (auto-login to Products)',
      build: () {
        final repo = FakeLoginRepo()..session = tSession;
        return SplashCubit(repo: repo);
      },
      act: (cubit) => cubit.restoreSession(),
      // The state carries NO session data anymore: the products
      // screen reads what it needs from storage instead.
      expect: () => [isA<SplashAuthenticated>()],
    );

    blocTest<SplashCubit, SplashState>(
      'no saved session -> SplashUnauthenticated (open the login page)',
      build: () => SplashCubit(repo: FakeLoginRepo()),
      act: (cubit) => cubit.restoreSession(),
      expect: () => [isA<SplashUnauthenticated>()],
    );

    blocTest<SplashCubit, SplashState>(
      'unexpected repo crash (broken secure storage) -> '
      'SplashUnauthenticated instead of being stuck forever',
      build: () {
        // The repo explodes with the SAME kind of failure the
        // real one can hit: a PlatformException from the safe box.
        final repo = FakeLoginRepo()
          ..restoreThrow = PlatformException(
            code: 'platform_error',
            message: 'secure storage broken',
          );
        return SplashCubit(repo: repo);
      },
      act: (cubit) => cubit.restoreSession(),
      // The safety net: exactly ONE more state, and it is the
      // login page - never an eternal SplashChecking.
      expect: () => [isA<SplashUnauthenticated>()],
    );
  });
}
