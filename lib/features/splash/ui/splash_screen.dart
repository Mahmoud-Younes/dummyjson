// The FIRST screen the user sees (a simple logo page).
//
// It does NOT decide anything by itself and it does NOT create
// its Cubit either: the router already wrapped it with a
// SplashCubit that calls restoreSession(). While that check
// runs, we show a logo + a small spinner. When the answer
// arrives, the listener below jumps to:
//   Products (still logged in)  or  Login (no saved session).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/extensions.dart';
import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/features/splash/logic/splash_cubit.dart';
import 'package:dummyjson/features/splash/logic/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // The app's teal color fills the whole screen.
        color: ColorsManager.mainTeal,
        width: double.infinity,
        child: BlocListener<SplashCubit, SplashState>(
          // This runs (not on every frame) only when the state changes.
          listener: (context, state) {
            if (state is SplashAuthenticated) {
              // Still logged in: go straight to the shop and REPLACE
              // the splash (so pressing back from the shop does not
              // return here). The shop reads the saved user from
              // storage itself - no route arguments needed.
              context.pushReplacementNamed(Routes.productsScreen);
            } else if (state is SplashUnauthenticated) {
              // No saved session: show the login page instead.
              context.pushReplacementNamed(Routes.loginScreen);
            }
          },
          // The listener needs a child: this centered logo column.
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LEFT: a big shopping bag icon as the logo.
                const Icon(Icons.shopping_bag, size: 80, color: Colors.white),
                verticalSpace(16),
                const Text(
                  'DummyJSON Store',
                  style: Styles.font26WhiteBold,
                ),
                verticalSpace(24),
                // Small spinner while restoreSession() is working.
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
