// Unit tests for SignUpRepoImpl - the class that "creates" an
// account on DummyJSON (POST /users/add) and saves the username.
//
// Strategy (same as login_repo_test.dart):
//   ApiService        -> stubbed (subclass; answers canned JSON, no internet)
//   SharedPreferences -> SharedPreferences.setMockInitialValues (in-memory)
//
// prefs is registered in get_it because SharedPrefHelper is static
// and pulls its dependency from getIt.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/helpers/constants.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/core/networking/api_service.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/sign_up/data/models/sign_up_request_body.dart';
import 'package:dummyjson/features/sign_up/data/repos/sign_up_repo.dart';

/// ApiService is a concrete class, so we fake it by subclassing and
/// passing a throwaway Dio to the super constructor (never used:
/// every method below is overridden).
class StubApiService extends ApiService {
  StubApiService() : super(Dio());

  // Canned answers, set per test.
  Map<String, dynamic> signUpAnswer = {};
  Object? signUpThrow;

  @override
  Future<Map<String, dynamic>> signUpUser(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
  ) async {
    if (signUpThrow != null) throw signUpThrow!;
    return signUpAnswer;
  }
}

// The REAL answer DummyJSON's POST /users/add gives (verified
// 2026-11-06): the new user object, including its fresh id. The
// server does NOT actually keep this account (fake learning API).
Map<String, dynamic> get tUsersAddJson => {
      'id': 209,
      'firstName': 'Ovi',
      'lastName': 'Tester',
      'username': 'ovitester99',
      'email': 'ovi99@test.com',
      'password': 'ovipass123',
      'gender': '',
      'image': '',
    };

final tRequestBody = SignUpRequestBody(
  firstName: 'Ovi',
  lastName: 'Tester',
  username: 'ovitester99',
  email: 'ovi99@test.com',
  password: 'ovipass123',
);

void main() {
  late StubApiService api;
  late SignUpRepoImpl repo;
  late SharedPreferences prefs;

  setUp(() async {
    // Fresh get_it + in-memory storage for every test.
    // (reset() is async - it must be awaited or it races with the
    // registrations below and can clear them mid-test.)
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);

    api = StubApiService();
    repo = SignUpRepoImpl(api);
  });

  group('signUp', () {
    test('success: parses id/username/email and saves the last username',
        () async {
      api.signUpAnswer = tUsersAddJson;

      final result = await repo.signUp(tRequestBody);

      expect(result, isA<ApiSuccess<UserModel>>());
      final success = result as ApiSuccess<UserModel>;
      // The fields from the REAL /users/add answer must reach the model.
      expect(success.data.id, 209);
      expect(success.data.username, 'ovitester99');
      expect(success.data.email, 'ovi99@test.com');
      expect(success.data.firstName, 'Ovi');

      // The username is saved so the login screen can pre-fill it
      // after the "Continue" tap (LoginCubit.getPrefillUsername
      // reads this same key).
      expect(prefs.getString(SharedPrefKeys.lastUsername), 'ovitester99');
    });

    test('server rejects the username -> ApiFailure with its message',
        () async {
      // The server answers 400 with a JSON body, e.g. when the
      // username is already taken.
      api.signUpThrow = DioException(
        requestOptions: RequestOptions(path: '/users/add'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/users/add'),
          statusCode: 400,
          data: {'message': 'Username already taken'},
        ),
      );

      final result = await repo.signUp(tRequestBody);

      expect(result, isA<ApiFailure<UserModel>>());
      final failure = result as ApiFailure<UserModel>;
      expect(failure.error.statusCode, 400);
      expect(failure.error.message, 'Username already taken');
    });

    test('no internet -> ApiFailure (the repo NEVER throws)', () async {
      api.signUpThrow = DioException(
        requestOptions: RequestOptions(path: '/users/add'),
        type: DioExceptionType.connectionError,
      );

      final result = await repo.signUp(tRequestBody);

      expect(result, isA<ApiFailure<UserModel>>());
      expect(
        (result as ApiFailure<UserModel>).error.message,
        'No internet connection.',
      );
    });

    test('a failure saves NO username (nothing to pre-fill)', () async {
      api.signUpThrow = DioException(
        requestOptions: RequestOptions(path: '/users/add'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/users/add'),
          statusCode: 400,
          data: {'message': 'Username already taken'},
        ),
      );

      await repo.signUp(tRequestBody);

      expect(prefs.getString(SharedPrefKeys.lastUsername), isNull);
    });
  });
}
