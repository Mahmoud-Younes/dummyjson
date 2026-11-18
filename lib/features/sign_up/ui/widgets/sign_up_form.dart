// The FORM part of the sign-up page:
// six fields + the live password checklist + Create Account button.
//
// The controllers come from SignUpScreen (it owns them). The cubit is
// NOT created here — we only READ it when Create Account is tapped,
// and WATCH it (BlocBuilder) to spin the button while signing up.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/app_regex.dart';
import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/core/widgets/app_text_form_field.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_cubit.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_state.dart';
import 'password_validations.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  // Owned by SignUpScreen, only used here.
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // Validates all fields at once when Create Account is tapped.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // A direct handle on the Confirm Password FIELD (not the whole
  // form): the password below it is compared against the password
  // field, so when THAT one changes we re-run just this validator
  // and an old "Passwords do not match" never lingers under a pair
  // that now matches.
  final GlobalKey<FormFieldState<String>> confirmKey =
      GlobalKey<FormFieldState<String>>();

  // Hide the passwords (dots) until the eye icon is tapped.
  // TWO flags: each password field hides/shows independently.
  bool isObscureText = true;
  bool isConfirmObscureText = true;

  // The five rows of the live checklist below the fields.
  // They start false (empty fields) and refresh on EVERY keystroke
  // in the password field (see _onPasswordChanged).
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;
  bool hasMinLength = false;

  // One keystroke landed in the password field: re-run the five
  // small checks and rebuild, so the checklist ticks live.
  void _onPasswordChanged(String password) {
    setState(() {
      hasLowercase = AppRegex.hasLowerCase(password);
      hasUppercase = AppRegex.hasUpperCase(password);
      hasNumber = AppRegex.hasNumber(password);
      hasSpecialCharacter = AppRegex.hasSpecialCharacter(password);
      hasMinLength = AppRegex.hasMinLength(password);
    });

    // The confirm field is compared against THIS password - so it
    // must be re-checked whenever the password changes. (Only when
    // the confirm field has text: an empty one is not an error yet,
    // just not filled in.)
    if (widget.confirmPasswordController.text.isNotEmpty) {
      confirmKey.currentState?.validate();
    }
  }

  // What happens when the Create Account button is tapped, or when
  // the user submits from the keyboard ("done" in the confirm field).
  void _onSignUpPressed() {
    // Same rule as the disabled button: no second sign-up while the
    // first request is still in flight.
    if (context.read<SignUpCubit>().state is SignUpLoadingState) {
      return;
    }

    // Close the keyboard first (nicer UX).
    FocusScope.of(context).unfocus();

    // Only sign up when every field passes its validator.
    if (formKey.currentState?.validate() ?? false) {
      context.read<SignUpCubit>().signUp(
            firstName: widget.firstNameController.text,
            lastName: widget.lastNameController.text,
            username: widget.usernameController.text,
            email: widget.emailController.text,
            password: widget.passwordController.text,
            confirmPassword: widget.confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- First Name field ----
          AppTextFormField(
            controller: widget.firstNameController,
            labelText: 'First Name',
            keyboardType: TextInputType.text,
            // Capitalize each word ("ovi" becomes "Ovi") - it is a
            // name, not code.
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          verticalSpace(18),

          // ---- Last Name field ----
          AppTextFormField(
            controller: widget.lastNameController,
            labelText: 'Last Name',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          verticalSpace(18),

          // ---- Username field ----
          AppTextFormField(
            controller: widget.usernameController,
            labelText: 'Username',
            // Plain text keyboard (the SDK has no "username" type).
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            // Tell password managers this field holds a username.
            autofillHints: const [AutofillHints.username],
            // A username is typed EXACTLY as chosen: no silent
            // "corrections" from the keyboard (emilys -> emails).
            autocorrect: false,
            enableSuggestions: false,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !AppRegex.isUsernameValid(value)) {
                return 'Please enter a valid username';
              }
              return null;
            },
          ),
          verticalSpace(18),

          // ---- Email field ----
          AppTextFormField(
            controller: widget.emailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            // Tell password managers/browsers this field holds an email.
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !AppRegex.isEmailValid(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          verticalSpace(18),

          // ---- Password field ----
          AppTextFormField(
            controller: widget.passwordController,
            labelText: 'Password',
            obscureText: isObscureText, // dots instead of text
            // "Next" on the keyboard moves to the confirm field.
            textInputAction: TextInputAction.next,
            // Every keystroke refreshes the live checklist.
            onChanged: _onPasswordChanged,
            // Eye icon: tap to show/hide the password. The tooltip
            // names the NEXT action ("Show"/"Hide") so screen readers
            // don't announce an unnamed button.
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => isObscureText = !isObscureText),
              tooltip: isObscureText ? 'Show password' : 'Hide password',
              icon: Icon(
                isObscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            autofillHints: const [AutofillHints.newPassword],
            // Sign-up enforces the FULL checklist shown right below
            // (all five rules - AppRegex.isStrongPasswordValid), so
            // the guide and the gate always agree. Login keeps its
            // simple "6+ characters" rule on purpose: the demo
            // account's password must keep passing THERE.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (!AppRegex.isStrongPasswordValid(value)) {
                // Name the missing rules exactly, so the message
                // matches the checklist rows instead of a vague
                // "not valid".
                final List<String> missing = [
                  if (!AppRegex.hasLowerCase(value)) 'a lowercase letter',
                  if (!AppRegex.hasUpperCase(value)) 'an uppercase letter',
                  if (!AppRegex.hasNumber(value)) 'a number',
                  if (!AppRegex.hasSpecialCharacter(value))
                    'a special character',
                  if (!AppRegex.hasMinLength(value)) 'at least 6 characters',
                ];
                return 'Password needs ${missing.join(', ')}';
              }
              return null;
            },
          ),
          verticalSpace(18),

          // ---- Confirm Password field ----
          AppTextFormField(
            // formFieldKey (NOT plain key): the handle must reach the
            // INNER TextFormField's state for validate() to work.
            formFieldKey: confirmKey,
            controller: widget.confirmPasswordController,
            labelText: 'Confirm Password',
            obscureText: isConfirmObscureText,
            // "Done" on the keyboard submits the form, the same way
            // the Create Account button does.
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSignUpPressed(),
            // Its own eye icon (toggled separately from the one above).
            suffixIcon: IconButton(
              onPressed: () => setState(
                () => isConfirmObscureText = !isConfirmObscureText,
              ),
              tooltip:
                  isConfirmObscureText ? 'Show password' : 'Hide password',
              icon: Icon(
                isConfirmObscureText
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
            ),
            // Same autofill hint as the password field, so password
            // managers offer to fill/save BOTH fields together.
            autofillHints: const [AutofillHints.newPassword],
            // Just re-type the same password. We compare against the
            // password controller directly - no clever regex needed.
            validator: (value) {
              // An empty confirm field is "not filled in yet", NOT a
              // mismatch - point at the field instead of comparing.
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != widget.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          verticalSpace(18),

          // ---- Live password checklist (ticks while typing) ----
          PasswordValidations(
            hasLowerCase: hasLowercase,
            hasUpperCase: hasUppercase,
            hasNumber: hasNumber,
            hasSpecialCharacter: hasSpecialCharacter,
            hasMinLength: hasMinLength,
          ),
          verticalSpace(24),

          // ---- Create Account button (spins while signing up) ----
          BlocBuilder<SignUpCubit, SignUpState>(
            // Rebuild only when loading starts or ends.
            buildWhen: (previous, current) =>
                current is SignUpLoadingState ||
                previous is SignUpLoadingState,
            builder: (context, state) {
              final bool isLoading = state is SignUpLoadingState;
              return FilledButton(
                // null = disabled (no double sign-up while spinning).
                onPressed: isLoading ? null : _onSignUpPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorsManager.mainTeal,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: Styles.font14SemiBoldWhite,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
