// Unit tests for SettingsCubit - the products app-bar popup's brain.
//
// The same FakeLoginRepo idea as the LoginCubit tests: the fake
// records what it was asked and answers with whatever the test set
// beforehand. No storage, no internet. We check EXACTLY which
// states are emitted for each scenario, using bloc_test.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'package:dummyjson/features/settings/logic/settings_cubit.dart';
import 'package:dummyjson/features/settings/logic/settings_state.dart';

// A hand-rolled fake: only getSavedUser and logout matter here.
class FakeLoginRepo implements LoginRepo {
  // What the "saved user box" answers with (null = nothing saved).
  UserModel? savedUser;

  // Counts logout taps so tests can verify the cleanup really ran.
  int logoutCallCount = 0;

  @override
  UserModel? getSavedUser() => savedUser;

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<LoginResponse?> checkSavedSession() async => null;

  @override
  Future<ApiResult<LoginResponse>> login(
    LoginRequestBody requestBody, {
    bool rememberMe = true,
  }) async =>
      throw UnimplementedError();

  @override
  String? getPrefillUsername() => null;
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

void main() {
  group('SettingsCubit', () {
    // Set by each blocTest's build closure, read again in verify -
    // so the test can inspect what the cubit did to ITS repo.
    late FakeLoginRepo repo;

    test('starts in SettingsInitial', () {
      final cubit = SettingsCubit(repo: FakeLoginRepo());
      expect(cubit.state, isA<SettingsInitial>());
      cubit.close();
    });

    blocTest<SettingsCubit, SettingsState>(
      'loadUsername with a saved user -> SettingsLoaded with the username',
      build: () {
        repo = FakeLoginRepo()..savedUser = tUser;
        return SettingsCubit(repo: repo);
      },
      act: (cubit) => cubit.loadUsername(),
      expect: () => [
        isA<SettingsLoaded>().having((s) => s.username, 'username', 'emilys'),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'loadUsername with nothing saved -> SettingsLoaded with an EMPTY username',
      build: () {
        repo = FakeLoginRepo()..savedUser = null;
        return SettingsCubit(repo: repo);
      },
      act: (cubit) => cubit.loadUsername(),
      expect: () => [
        isA<SettingsLoaded>().having((s) => s.username, 'username', ''),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'logout -> logging-out then logged-out (and the repo cleaned once)',
      build: () {
        repo = FakeLoginRepo();
        return SettingsCubit(repo: repo);
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<SettingsLoggingOut>(),
        isA<SettingsLoggedOut>(),
      ],
      verify: (_) {
        // The repo's logout must have been called exactly ONCE.
        expect(repo.logoutCallCount, 1);
      },
    );
  });
}
