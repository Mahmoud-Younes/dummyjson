// The "switch to login" hint under the sign-up form.
//
// Text.rich mixes two styles in ONE line: the grey question and the
// teal "Login" word (Text.rich, NOT RichText, so system text
// scaling applies to it like every other text on screen).
//
// The WHOLE line is tappable - a GestureDetector wraps it (no
// TapGestureRecognizer to create/dispose) and vertical padding
// makes the touch area ~50px tall: a comfortable target instead of
// a 13px-tall word.
//
// Tapping swaps this screen for the login one. NOTE: at this
// moment sign-up never finished, so NOTHING was saved by it - the
// login form is pre-filled only by an EARLIER completed sign-up or
// a previous "remember me" login (SharedPrefKeys.lastUsername);
// otherwise the user types their username there.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/helpers/extensions.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/theming/styles.dart';

class AlreadyHaveAccountText extends StatelessWidget {
  const AlreadyHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Screen readers announce this as a NAMED button ("Go to the
      // login screen") instead of bare text. The tap itself still
      // comes from the GestureDetector below.
      button: true,
      label: 'Go to the login screen',
      child: GestureDetector(
        // opaque: taps land even on the padding, not just on the text.
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // REPLACE (not push): after sign-up there is nothing
          // to go "back" to, so the stack stays clean.
          context.pushReplacementNamed(Routes.loginScreen);
        },
        child: Container(
          // 16 + text + 16 = ~50px tall: a real touch target (48px+).
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text.rich(
            TextSpan(
              children: [
                // The grey question.
                TextSpan(
                  text: 'Already have an account?',
                  style: Styles.font13RegularGray,
                ),
                // The teal action word.
                TextSpan(
                  text: ' Login',
                  style: Styles.font13SemiBoldTeal,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
