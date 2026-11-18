// Unit tests for SignUpCubit - the sign-up screen's state machine.
//
// The repo is faked (implements the abstract SignUpRepo), so no
// internet and no storage are touched. We check EXACTLY which
// states are emitted for each scenario, using bloc_test.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/sign_up/data/models/sign_up_request_body.dart';
import 'package:dummyjson/features/sign_up/data/repos/sign_up_repo.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_cubit.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_state.dart';

// A hand-rolled fake: records what it was asked and answers with
// whatever the test set beforehand.
class FakeSignUpRepo implements SignUpRepo {
  ApiResult<UserModel> signUpResult =
      const ApiFailure(ErrorModel(message: 'not configured'));

  SignUpRequestBody? lastBody;
  int signUpCallCount = 0;

  @override
  Future<ApiResult<UserModel>> signUp(SignUpRequestBody requestBody) async {
    signUpCallCount++;
    lastBody = requestBody;
    return signUpResult;
  }
}

// The user the fake repo "creates" - the same shape the REAL
// POST /users/add answers with (verified 2026-11-06).
const tUser = UserModel(
  id: 209,
  username: 'ovitester99',
  email: 'ovi99@test.com',
  firstName: 'Ovi',
  lastName: 'Tester',
  gender: '',
  image: '',
);

// A full, valid sign-up call (all six parameters the cubit asks for).
Future<void> fillAndSubmit(SignUpCubit cubit) => cubit.signUp(
      firstName: 'Ovi',
      lastName: 'Tester',
      username: 'ovitester99',
      email: 'ovi99@test.com',
      password: 'ovipass123',
      confirmPassword: 'ovipass123',
    );

void main() {
  group('SignUpCubit', () {
    test('starts in SignUpInitialState', () {
      final cubit = SignUpCubit(repo: FakeSignUpRepo());
      expect(cubit.state, isA<SignUpInitialState>());
      cubit.close();
    });

    blocTest<SignUpCubit, SignUpState>(
      'success -> loading then success (carrying the new user)',
      build: () {
        final repo = FakeSignUpRepo()..signUpResult = const ApiSuccess(tUser);
        return SignUpCubit(repo: repo);
      },
      act: (cubit) => fillAndSubmit(cubit),
      expect: () => [
        isA<SignUpLoadingState>(),
        isA<SignUpSuccessState>().having((s) => s.user, 'user', tUser),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'repo failure -> loading then error (message carried through)',
      build: () {
        final repo = FakeSignUpRepo()
          ..signUpResult = const ApiFailure(
            ErrorModel(statusCode: 400, message: 'Username already taken'),
          );
        return SignUpCubit(repo: repo);
      },
      act: (cubit) => fillAndSubmit(cubit),
      expect: () => [
        isA<SignUpLoadingState>(),
        isA<SignUpErrorState>().having(
          (s) => s.error.message,
          'message',
          'Username already taken',
        ),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'empty email -> ONLY SignUpErrorState (no loading, no repo call)',
      build: () {
        final repo = FakeSignUpRepo();
        return SignUpCubit(repo: repo);
      },
      act: (cubit) => cubit.signUp(
        firstName: 'Ovi',
        lastName: 'Tester',
        username: 'ovitester99',
        email: '',
        password: 'ovipass123',
        confirmPassword: 'ovipass123',
      ),
      expect: () => [
        const SignUpErrorState(
          error: ErrorModel(message: 'Please fill in all fields.'),
        ),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      "passwords don't match -> ONLY SignUpErrorState (no repo call)",
      build: () {
        final repo = FakeSignUpRepo();
        return SignUpCubit(repo: repo);
      },
      act: (cubit) => cubit.signUp(
        firstName: 'Ovi',
        lastName: 'Tester',
        username: 'ovitester99',
        email: 'ovi99@test.com',
        password: 'ovipass123',
        confirmPassword: 'different123',
      ),
      expect: () => [
        const SignUpErrorState(
          error: ErrorModel(message: 'Passwords do not match.'),
        ),
      ],
    );

    test('guards never reach the repo', () async {
      final repo = FakeSignUpRepo();
      final cubit = SignUpCubit(repo: repo);

      // An empty field...
      await cubit.signUp(
        firstName: 'Ovi',
        lastName: 'Tester',
        username: 'ovitester99',
        email: '',
        password: 'ovipass123',
        confirmPassword: 'ovipass123',
      );
      expect(repo.signUpCallCount, 0);
      expect(cubit.state, isA<SignUpErrorState>());

      // ...and a password mismatch must ALSO stay local.
      await cubit.signUp(
        firstName: 'Ovi',
        lastName: 'Tester',
        username: 'ovitester99',
        email: 'ovi99@test.com',
        password: 'ovipass123',
        confirmPassword: 'different123',
      );
      expect(repo.signUpCallCount, 0);
      await cubit.close();
    });

    test('fields are trimmed before being sent to the repo', () async {
      final repo = FakeSignUpRepo()..signUpResult = const ApiSuccess(tUser);
      final cubit = SignUpCubit(repo: repo);

      await cubit.signUp(
        firstName: '  Ovi  ',
        lastName: ' Tester ',
        username: ' ovitester99 ',
        email: ' ovi99@test.com ',
        password: 'ovipass123',
        confirmPassword: 'ovipass123',
      );

      expect(repo.lastBody?.firstName, 'Ovi');
      expect(repo.lastBody?.lastName, 'Tester');
      expect(repo.lastBody?.username, 'ovitester99');
      expect(repo.lastBody?.email, 'ovi99@test.com');
      // The password is NOT trimmed on purpose (spaces can be part
      // of a password - same rule as login).
      expect(repo.lastBody?.password, 'ovipass123');
      expect(repo.signUpCallCount, 1);
      await cubit.close();
    });
  });
}
