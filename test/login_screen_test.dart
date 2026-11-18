// Widget tests for the LOGIN page.
//
// LoginScreen expects the LoginCubit to be provided ABOVE it (the
// router does that in the real app), so every test pumps the
// screen under BlocProvider.value with a cubit built on a fake
// repo. No internet, no storage - pure UI behavior:
//   header text, prefill, form validation, loading spinner,
//   error banner, the session-expired banner, and navigation to
//   Products on success.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dummyjson/core/helpers/constants.dart';
import 'package:dummyjson/core/networking/api_error_model.dart';
import 'package:dummyjson/core/networking/api_result.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/features/login/data/models/login_request_body.dart';
import 'package:dummyjson/features/login/data/models/login_response.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/login/ui/login_screen.dart';

// Fake repo: answers login() with whatever the test armed, can hold
// the answer behind a Completer (to freeze the loading state), and
// records every call so tests can verify what the UI sent.
class FakeLoginRepo implements LoginRepo {
  Completer<ApiResult<LoginResponse>>? gate;
  ApiResult<LoginResponse> loginResult =
      const ApiSuccess(tSession);
  String? prefill;

  int loginCallCount = 0;
  LoginRequestBody? lastBody;

  @override
  Future<ApiResult<LoginResponse>> login(
    LoginRequestBody requestBody, {
    bool rememberMe = true,
  }) async {
    loginCallCount++;
    lastBody = requestBody;
    if (gate != null) return gate!.future;
    return loginResult;
  }

  @override
  Future<LoginResponse?> checkSavedSession() async => null;

  @override
  Future<void> logout() async {}

  @override
  String? getPrefillUsername() => prefill;

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

// Pumps the login screen the way the router does: cubit ABOVE the
// screen, plus a named route for Products so the success navigation
// has somewhere to go.
Future<void> pumpLoginScreen(
  WidgetTester tester,
  FakeLoginRepo repo,
) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: LoginCubit(repo: repo),
      child: MaterialApp(
        routes: {
          Routes.productsScreen: (_) =>
              const Scaffold(body: Center(child: Text('PRODUCTS_SCREEN'))),
        },
        home: const LoginScreen(),
      ),
    ),
  );
  await tester.pump(); // let initState/getPrefillUsername settle
}

TextField usernameField(WidgetTester tester) =>
    tester.widget<TextField>(find.widgetWithText(TextField, 'Username').first);

TextField passwordField(WidgetTester tester) => tester
    .widget<TextField>(find.widgetWithText(TextField, 'Password').first);

void main() {
  testWidgets('shows the header (Welcome back + subtitle)',
      (tester) async {
    await pumpLoginScreen(tester, FakeLoginRepo());

    // The header is a RichText ("Welcome" + teal " back"), so match
    // it with findRichText (every Text renders as RichText internally).
    expect(
      find.textContaining('Welcome back', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Sign in to continue shopping'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('pre-fills the username from the saved last username',
      (tester) async {
    final repo = FakeLoginRepo()..prefill = 'emilys';
    await pumpLoginScreen(tester, repo);

    expect(find.text('emilys'), findsOneWidget);
  });

  testWidgets('empty fields -> both validators fire, repo NOT called',
      (tester) async {
    final repo = FakeLoginRepo();
    await pumpLoginScreen(tester, repo);

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter a valid username'), findsOneWidget);
    expect(find.text('Please enter a valid password'), findsOneWidget);
    expect(repo.loginCallCount, 0);
  });

  testWidgets('short password -> password validator fires', (tester) async {
    final repo = FakeLoginRepo();
    await pumpLoginScreen(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'emilys');
    await tester.enterText(find.byType(TextField).last, '123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter a valid password'), findsOneWidget);
    expect(find.text('Please enter a valid username'), findsNothing);
    expect(repo.loginCallCount, 0);
  });

  testWidgets('valid credentials -> repo called with the typed values',
      (tester) async {
    final repo = FakeLoginRepo()..gate = Completer(); // hold loading
    await pumpLoginScreen(tester, repo);

    // NOTE: a username with spaces is rejected by the form validator
    // (AppRegex), so trimming itself is covered by the cubit unit test.
    await tester.enterText(find.byType(TextField).first, 'emilys');
    await tester.enterText(find.byType(TextField).last, 'emilyspass');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(repo.loginCallCount, 1);
    expect(repo.lastBody?.username, 'emilys'); // trimmed!
    expect(repo.lastBody?.password, 'emilyspass');
  });

  testWidgets('loading -> spinner replaces the button text', (tester) async {
    final repo = FakeLoginRepo()..gate = Completer(); // never resolves yet
    await pumpLoginScreen(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'emilys');
    await tester.enterText(find.byType(TextField).last, 'emilyspass');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Login'), findsNothing); // button text is gone

    // While loading, tapping the (disabled) button does nothing extra.
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(repo.loginCallCount, 1);
  });

  testWidgets('failure -> red error banner shows the message',
      (tester) async {
    final repo = FakeLoginRepo()
      ..gate = Completer<ApiResult<LoginResponse>>();
    await pumpLoginScreen(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'emilys');
    await tester.enterText(find.byType(TextField).last, 'wrongpass');
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Now the "server" answers: invalid credentials.
    repo.gate!.complete(const ApiFailure(
      ErrorModel(statusCode: 400, message: 'Invalid credentials'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
    // No navigation happened: still on the login page.
    expect(find.text('Sign in to continue shopping'), findsOneWidget);
  });

  testWidgets('success -> navigates to Products and clears the stack',
      (tester) async {
    final repo = FakeLoginRepo()
      ..gate = Completer<ApiResult<LoginResponse>>();
    await pumpLoginScreen(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'emilys');
    await tester.enterText(find.byType(TextField).last, 'emilyspass');
    await tester.tap(find.text('Login'));
    await tester.pump();

    repo.gate!.complete(const ApiSuccess(tSession));
    await tester.pumpAndSettle();

    expect(find.text('PRODUCTS_SCREEN'), findsOneWidget);
    // The login page was removed below Products ("back" can't return).
    expect(find.text('Sign in to continue shopping'), findsNothing);
  });

  testWidgets('session-expired route argument shows the banner',
      (tester) async {
    final repo = FakeLoginRepo();
    // The AuthInterceptor lands here with the 'sessionExpired' route
    // argument - pump the login screen as THAT route (onGenerateRoute
    // builds it with the argument in its RouteSettings, exactly like
    // the real navigation in dependency_injection.dart does).
    await tester.pumpWidget(
      BlocProvider.value(
        value: LoginCubit(repo: repo),
        child: MaterialApp(
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: '/loginScreen',
              arguments: RouteArguments.sessionExpired,
            ),
            builder: (_) => const LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pump(); // let initState/getPrefillUsername settle

    // The banner explains WHY the user is back on login...
    expect(
      find.text('Your session expired. Please sign in again.'),
      findsOneWidget,
    );
    // ...and the rest of the page is still the normal login page.
    expect(
      find.text('Sign in to continue shopping'),
      findsOneWidget,
    );
  });
}
