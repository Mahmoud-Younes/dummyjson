// The "switch to sign up" hint under the login form.
//
// Text.rich mixes two styles in ONE line: the grey question and the
// teal "Sign Up" word (Text.rich, NOT RichText, so system text
// scaling applies to it like every other text on screen).
//
// The WHOLE line is tappable - a GestureDetector wraps it (no
// TapGestureRecognizer to create/dispose) and vertical padding
// makes the touch area ~50px tall: a comfortable target instead of
// a 13px-tall word.
//
// Tapping swaps this screen for the sign-up one.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/helpers/extensions.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/theming/styles.dart';

class DontHaveAccountText extends StatelessWidget {
  const DontHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Screen readers announce this as a NAMED button ("Go to the
      // sign-up screen") instead of bare text. The tap itself still
      // comes from the GestureDetector below.
      button: true,
      label: 'Go to the sign-up screen',
      child: GestureDetector(
        // opaque: taps land even on the padding, not just on the text.
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // REPLACE (not push): "back" from the sign-up screen
          // should not return to the finished login screen.
          context.pushReplacementNamed(Routes.signUpScreen);
        },
        child: Container(
          // 16 + text + 16 = ~50px tall: a real touch target (48px+).
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text.rich(
            TextSpan(
              children: [
                // The grey question.
                TextSpan(
                  text: "Don't have an account?",
                  style: Styles.font13RegularGray,
                ),
                // The teal action word.
                TextSpan(
                  text: ' Sign Up',
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
