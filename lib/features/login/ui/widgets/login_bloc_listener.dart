// The ears of the login page: it LISTENS to the LoginCubit and
// reacts to state changes that are not about drawing a widget:
//   - LoginSuccessState -> open Home (and wipe the stack).
//   - LoginErrorState   -> show the red banner below the form.
//
// It sits LAST in the login column (a listener reacts after the widgets draw).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/extensions.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/widgets/app_error_banner.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/login/logic/login_state.dart';

class LoginBlocListener extends StatelessWidget {
  const LoginBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. The listener: side effects on success (navigation).
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => current is LoginSuccessState,
      listener: (context, state) {
        if (state is LoginSuccessState) {
          // Login worked! Open the shop and remove EVERY screen below
          // it (so "back" exits the app, not back to the login page).
          // The tokens + user are already saved by the repo - the
          // products screen needs no arguments.
          context.pushNamedAndRemoveUntil(
            Routes.productsScreen,
            predicate: (route) => false,
          );
        }
      },
      // 2. The child: the inline error banner. A BlocBuilder makes it
      //    appear/disappear with the state (no dialogs, no snackbars).
      child: BlocBuilder<LoginCubit, LoginState>(
        // Rebuild when an error arrives OR when it goes away
        // (so the banner is hidden again after a new attempt).
        buildWhen: (previous, current) =>
            current is LoginErrorState || previous is LoginErrorState,
        builder: (context, state) {
          if (state is LoginErrorState) {
            // The shared banner (core/widgets) - the same red box the
            // sign-up screen shows, so a failure looks like a failure
            // everywhere.
            return AppErrorBanner(message: state.error.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
