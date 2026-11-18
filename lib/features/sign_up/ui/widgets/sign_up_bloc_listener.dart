// The ears of the sign-up page: it LISTENS to the SignUpCubit and
// reacts to state changes that are not about drawing a widget:
//   - SignUpSuccessState -> show the "Account Created!" dialog,
//                           then hop to the login screen.
//   - SignUpErrorState   -> show the red banner below the form.
//
// It sits LAST in the sign-up column (a listener reacts after the widgets draw).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/extensions.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/widgets/app_error_banner.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_cubit.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_state.dart';

class SignUpBlocListener extends StatelessWidget {
  const SignUpBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. The listener: side effect on success (dialog + navigation).
    return BlocListener<SignUpCubit, SignUpState>(
      listenWhen: (previous, current) => current is SignUpSuccessState,
      listener: (context, state) {
        if (state is SignUpSuccessState) {
          // IMPORTANT: there is no auto-login after sign-up!
          // DummyJSON never really saved this account, so there are
          // no tokens to store - we just celebrate, then send the
          // user to the login screen (username already pre-filled
          // by the repository) to sign in with the DEMO account.
          showDialog(
            context: context,
            // "Continue" is the ONLY way out (pop + navigate): tapping
            // outside must not close the dialog and strand the user on
            // a finished sign-up with a re-enabled Create Account
            // button.
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Account Created!'),
              content: Text(
                'Welcome to DummyJSON Store, ${state.user.firstName}! '
                'Your account has been created.\n\n'
                'Note: DummyJSON is a fake learning API - new accounts '
                'are not saved on the server. Continue to the login '
                'screen (your username is prefilled), or use the demo '
                'account to explore.',
              ),
              actions: [
                TextButton(
                  // The button closes the dialog FIRST (pop removes the
                  // dialog route), THEN replaces the sign-up screen
                  // with the login screen. The screen-level `context`
                  // is still alive here - the dialogContext would be
                  // dead the moment the dialog is removed.
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pushReplacementNamed(Routes.loginScreen);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: ColorsManager.mainTeal,
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        }
      },
      // 2. The child: the inline error banner. A BlocBuilder makes it
      //    appear/disappear with the state (no snackbars).
      child: BlocBuilder<SignUpCubit, SignUpState>(
        // Rebuild when an error arrives OR when it goes away
        // (so the banner is hidden again after a new attempt).
        buildWhen: (previous, current) =>
            current is SignUpErrorState || previous is SignUpErrorState,
        builder: (context, state) {
          if (state is SignUpErrorState) {
            // The shared banner (core/widgets) - the same red box the
            // login screen shows, so a failure looks like a failure
            // everywhere.
            return AppErrorBanner(message: state.error.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
