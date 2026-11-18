// A LIVE "strength guide" under the password field (one row per rule).
//
// On sign-up this list IS the contract: the field's validator
// (AppRegex.isStrongPasswordValid) demands all five rules, so a row
// still grey = a rule the form will reject when Create Account is
// tapped. Every keystroke in the password field re-runs the five
// small AppRegex checks and the matching row flips from a grey X to
// a green tick, so the user SEES what their password is made of
// while typing.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';

class PasswordValidations extends StatelessWidget {
  const PasswordValidations({
    super.key,
    required this.hasLowerCase,
    required this.hasUpperCase,
    required this.hasNumber,
    required this.hasSpecialCharacter,
    required this.hasMinLength,
  });

  // The five booleans come from SignUpForm (it recomputes them on
  // every keystroke) - this widget only DRAWS them.
  final bool hasLowerCase;
  final bool hasUpperCase;
  final bool hasNumber;
  final bool hasSpecialCharacter;
  final bool hasMinLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationRow('At least 1 lowercase letter', hasLowerCase),
        _buildValidationRow('At least 1 uppercase letter', hasUpperCase),
        _buildValidationRow('At least 1 number', hasNumber),
        _buildValidationRow('At least 1 special character', hasSpecialCharacter),
        _buildValidationRow('At least 6 characters', hasMinLength),
      ],
    );
  }

  // One row: green tick when the rule is satisfied, grey X when not.
  // The colors come from ColorsManager (NOT raw Colors.green/grey):
  // the raw ones fail WCAG AA contrast, and theming stays in theming.
  Widget _buildValidationRow(String text, bool isSatisfied) {
    return Row(
      children: [
        // The tick/cross is the ONLY signal of the rule's state, and
        // a picture alone says nothing to a screen reader - so the
        // icon carries its state as a semantics label.
        Semantics(
          label: isSatisfied ? 'requirement met' : 'requirement not met',
          child: Icon(
            isSatisfied ? Icons.check_circle : Icons.cancel,
            color: isSatisfied ? ColorsManager.success : ColorsManager.inactive,
            size: 18,
          ),
        ),
        horizontalSpace(6),
        Text(text, style: Styles.font13RegularGray),
      ],
    );
  }
}
