// Unit tests for LoginRepoImpl - the class that saves the
// Access Token + Refresh Token and restores the saved session.
//
// Strategy:
//   ApiService   -> stubbed (subclass; answers canned JSON, no internet)
//   SharedPreferences -> SharedPreferences.setMockInitialValues (in-memory)
//   FlutterSecureStorage -> mocktail mock backed by a plain Map
//
// All three are registered in get_it because the storage helpers
// (SharedPrefHelper / SecureStorageHelper) are static and pull
// their dependencies from getIt.

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/helpers/constants.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/core/networking/api_service.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';

// ---- Test doubles ----

/// ApiService is a concrete class, so we fake it by subclassing and
/// passing a throwaway Dio to the super constructor (never used:
/// every method below is overridden).
class StubApiService extends ApiService {
  StubApiService() : super(Dio());

  // Canned answers, set per test.
  Map<String, dynamic> loginAnswer = {};
  Object? loginThrow;

  // meThrows is a QUEUE: the test puts one error per call it wants
  // to fail (e.g. first /auth/me 401, retry OK -> queue = [error]).
  Map<String, dynamic> Function(String accessToken)? meAnswer;
  final List<Object?> meThrows = [];

  Map<String, dynamic> refreshAnswer = {};
  Object? refreshThrow;

  @override
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    int expiresInMins = 60,
  }) async {
    if (loginThrow != null) throw loginThrow!;
    return loginAnswer;
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    if (meThrows.isNotEmpty) {
      final Object? error = meThrows.removeAt(0);
      if (error != null) throw error;
    }
    return meAnswer!(accessToken);
  }

  @override
  Future<Map<String, dynamic>> refreshTokens(
    String refreshToken, {
    int expiresInMins = 60,
  }) async {
    if (refreshThrow != null) throw refreshThrow!;
    return refreshAnswer;
  }
}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

// ---- Helpers ----

const String tAccessToken = 'ACCESS_TOKEN_123';
const String tRefreshToken = 'REFRESH_TOKEN_456';

Map<String, dynamic> get tLoginJson => {
  'id': 9,
  'username': 'emilys',
  'email': 'emily.johnson@x.dummyjson.com',
  'firstName': 'Emily',
  'lastName': 'Johnson',
  'gender': 'female',
  'image': 'https://dummyjson.com/icon/emilys/128',
  'accessToken': tAccessToken,
  'refreshToken': tRefreshToken,
};

Map<String, dynamic> get tUserJson => {
  'id': 9,
  'username': 'emilys',
  'email': 'emily.johnson@x.dummyjson.com',
  'firstName': 'Emily',
  'lastName': 'Johnson',
  'gender': 'female',
  'image': 'https://dummyjson.com/icon/emilys/128',
};

// A 401 from the server (access token expired/revoked).
DioException serverError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/auth/me'),
  type: DioExceptionType.badResponse,
  response: Response<void>(
    requestOptions: RequestOptions(path: '/auth/me'),
    statusCode: statusCode,
  ),
);

// No internet: no response object at all.
DioException networkError() => DioException(
  requestOptions: RequestOptions(path: '/auth/me'),
  type: DioExceptionType.connectionError,
);

void main() {
  late StubApiService api;
  late MockSecureStorage secure;
  late Map<String, String?> secureBox; // simulated encrypted storage
  late LoginRepoImpl repo;
  late SharedPreferences prefs;

  setUp(() async {
    // Fresh get_it + in-memory storage for every test.
    // (reset() is async - it must be awaited or it races with the
    // registrations below and can clear them mid-test.)
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);

    secureBox = {};
    secure = MockSecureStorage();
    when(
      () => secure.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      secureBox[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String?;
    });
    when(() => secure.read(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      return secureBox[invocation.namedArguments[#key] as String];
    });
    when(() => secure.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      secureBox.remove(invocation.namedArguments[#key] as String);
    });
    getIt.registerSingleton<FlutterSecureStorage>(secure);

    api = StubApiService();
    repo = LoginRepoImpl(api);
  });

  group('login', () {
    final body = LoginRequestBody(username: 'emilys', password: 'emilyspass');

    test('success + rememberMe saves tokens, user and last username', () async {
      api.loginAnswer = tLoginJson;

      final result = await repo.login(body);

      expect(result, isA<ApiSuccess<LoginResponse>>());
      final success = result as ApiSuccess<LoginResponse>;
      expect(success.data.accessToken, tAccessToken);
      expect(success.data.refreshToken, tRefreshToken);
      expect(success.data.user.fullName, 'Emily Johnson');

      // BOTH tokens must be in the SECURE box...
      expect(secureBox[SharedPrefKeys.accessToken], tAccessToken);
      expect(secureBox[SharedPrefKeys.refreshToken], tRefreshToken);

      // ...and the user JSON + username in the NORMAL box.
      expect(
        prefs.getString(SharedPrefKeys.savedUser),
        jsonEncodeUser(tUserJson),
      );
      expect(prefs.getString(SharedPrefKeys.lastUsername), 'emilys');
    });

    test('rememberMe = false saves NOTHING', () async {
      api.loginAnswer = tLoginJson;

      final result = await repo.login(body, rememberMe: false);

      expect(result, isA<ApiSuccess<LoginResponse>>());
      expect(secureBox, isEmpty);
      expect(prefs.getString(SharedPrefKeys.savedUser), isNull);
      expect(prefs.getString(SharedPrefKeys.lastUsername), isNull);
    });

    test('server rejects credentials -> ApiFailure (no token saved)', () async {
      api.loginThrow = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 400,
          data: {'message': 'Invalid credentials'},
        ),
      );

      final result = await repo.login(body);

      expect(result, isA<ApiFailure<LoginResponse>>());
      final failure = result as ApiFailure<LoginResponse>;
      expect(failure.error.statusCode, 400);
      expect(secureBox, isEmpty);
    });
  });

  group('checkSavedSession', () {
    test('returns null when no tokens are saved', () async {
      expect(await repo.checkSavedSession(), isNull);
    });

    test('returns null when only ONE of the two tokens exists', () async {
      secureBox[SharedPrefKeys.accessToken] = tAccessToken;
      expect(await repo.checkSavedSession(), isNull);
    });

    test('/auth/me answers 200 -> session restored', () async {
      secureBox[SharedPrefKeys.accessToken] = tAccessToken;
      secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
      api.meAnswer = (_) => tUserJson;

      final session = await repo.checkSavedSession();

      expect(session, isNotNull);
      expect(session!.accessToken, tAccessToken);
      expect(session.refreshToken, tRefreshToken);
      expect(session.user.username, 'emilys');
    });

    test(
      '/auth/me 401 -> refresh succeeds -> NEW pair saved + retried',
      () async {
        secureBox[SharedPrefKeys.accessToken] = tAccessToken;
        secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;

        // First /auth/me call: rejected (queue holds the error).
        // Refresh: accepted. Retry /auth/me: OK (queue is empty then).
        api.meThrows.add(serverError(401));
        api.refreshAnswer = {
          'accessToken': 'NEW_ACCESS',
          'refreshToken': 'NEW_REFRESH',
        };
        api.meAnswer = (_) => tUserJson;

        final session = await repo.checkSavedSession();

        expect(session, isNotNull);
        expect(session!.accessToken, 'NEW_ACCESS');
        // The NEW pair must overwrite the old one in secure storage.
        expect(secureBox[SharedPrefKeys.accessToken], 'NEW_ACCESS');
        expect(secureBox[SharedPrefKeys.refreshToken], 'NEW_REFRESH');
      },
    );

    test('refresh rejected (400) -> both boxes cleaned -> null', () async {
      secureBox[SharedPrefKeys.accessToken] = tAccessToken;
      secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
      prefs.setString(SharedPrefKeys.savedUser, '{"id": 9}');
      api.meThrows.add(serverError(401));
      api.refreshThrow = serverError(400);

      final session = await repo.checkSavedSession();

      expect(session, isNull);
      expect(secureBox, isEmpty); // tokens cleared
      expect(prefs.getString(SharedPrefKeys.savedUser), isNull);
    });

    test(
      'no internet on /auth/me -> offline session from saved user',
      () async {
        secureBox[SharedPrefKeys.accessToken] = tAccessToken;
        secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
        await prefs.setString(
          SharedPrefKeys.savedUser,
          jsonEncodeUser(tUserJson),
        );
        api.meThrows.add(networkError());

        final session = await repo.checkSavedSession();

        expect(session, isNotNull);
        expect(session!.user.fullName, 'Emily Johnson');
        expect(session.accessToken, tAccessToken);
      },
    );

    test('no internet AND no saved user -> null', () async {
      secureBox[SharedPrefKeys.accessToken] = tAccessToken;
      secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
      api.meThrows.add(networkError());

      expect(await repo.checkSavedSession(), isNull);
    });

    test(
      'secure storage READ fails -> null (no throw) + cleanable boxes cleaned',
      () async {
        secureBox[SharedPrefKeys.accessToken] = tAccessToken;
        secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
        await prefs.setString(SharedPrefKeys.savedUser, '{"id": 9}');

        // The safe box is BROKEN: every read blows up with a
        // PlatformException (mocktail thenThrow, same pattern as the
        // stubs in setUp). A storage failure is NOT a network error.
        when(() => secure.read(key: any(named: 'key'))).thenThrow(
          PlatformException(code: 'platform_error', message: 'broken'),
        );

        // The whole point: this must RETURN null, never throw.
        LoginResponse? session;
        try {
          session = await repo.checkSavedSession();
        } catch (_) {
          fail('a storage failure must never escape checkSavedSession');
        }

        expect(session, isNull);
        // Best-effort cleanup ran: our mock's delete still works, so
        // the tokens are gone - and the saved user with them.
        expect(secureBox, isEmpty);
        expect(prefs.getString(SharedPrefKeys.savedUser), isNull);
      },
    );
  });

  group('logout', () {
    test('clears tokens + saved user but KEEPS lastUsername', () async {
      secureBox[SharedPrefKeys.accessToken] = tAccessToken;
      secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
      await prefs.setString(SharedPrefKeys.savedUser, '{"id": 9}');
      await prefs.setString(SharedPrefKeys.lastUsername, 'emilys');

      await repo.logout();

      expect(secureBox, isEmpty);
      expect(prefs.getString(SharedPrefKeys.savedUser), isNull);
      expect(prefs.getString(SharedPrefKeys.lastUsername), 'emilys');
    });

    test(
      'secure storage DELETE fails -> no throw, other box still cleaned',
      () async {
        secureBox[SharedPrefKeys.accessToken] = tAccessToken;
        secureBox[SharedPrefKeys.refreshToken] = tRefreshToken;
        await prefs.setString(SharedPrefKeys.savedUser, '{"id": 9}');
        await prefs.setString(SharedPrefKeys.lastUsername, 'emilys');

        // The safe box refuses to delete anything (broken storage).
        when(() => secure.delete(key: any(named: 'key'))).thenThrow(
          PlatformException(code: 'platform_error', message: 'locked'),
        );

        // The whole point: logout must COMPLETE without throwing -
        // otherwise the logout button would spin with no way out.
        await repo.logout();

        // Logout TRIED to clean the broken safe box first...
        verify(() => secure.delete(key: SharedPrefKeys.accessToken)).called(1);
        // ...then still cleaned what it could in the normal box.
        expect(prefs.getString(SharedPrefKeys.savedUser), isNull);
        // lastUsername survives on purpose (form stays pre-filled).
        expect(prefs.getString(SharedPrefKeys.lastUsername), 'emilys');
        // The broken box could not be emptied (our mock refuses) -
        // the assertion above proves delete really was attempted.
        expect(secureBox, isNotEmpty);
      },
    );
  });

  group('getPrefillUsername', () {
    test('returns the last username saved in prefs', () async {
      await prefs.setString(SharedPrefKeys.lastUsername, 'emilys');
      expect(repo.getPrefillUsername(), 'emilys');
    });

    test('returns null when nothing was saved', () {
      expect(repo.getPrefillUsername(), isNull);
    });
  });
}

// Small helper: the exact JSON string the repo saves for a user.
String jsonEncodeUser(Map<String, dynamic> user) {
  // Order of keys matters for string equality, so build it the same
  // way the repo does: jsonEncode(user.toJson()) from UserModel.
  return user.toString().isEmpty ? '' : _encode(user);
}

String _encode(Map<String, dynamic> user) {
  // Same field order as UserModel.toJson().
  return '{"id":${user['id']},"username":"${user['username']}",'
      '"email":"${user['email']}","firstName":"${user['firstName']}",'
      '"lastName":"${user['lastName']}","gender":"${user['gender']}",'
      '"image":"${user['image']}"}';
}
