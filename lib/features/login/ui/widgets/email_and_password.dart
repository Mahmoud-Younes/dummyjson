// The FORM part of the login page:
// username field + password field + "Remember me" + Login button.
//
// The controllers come from LoginScreen (it owns them). The cubit is
// NOT created here — we only READ it when Login is tapped, and
// WATCH it (BlocBuilder) to spin the button while logging in.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/app_regex.dart';
import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/core/widgets/app_text_form_field.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/login/logic/login_state.dart';

class EmailAndPassword extends StatefulWidget {
  const EmailAndPassword({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  // Owned by LoginScreen, only used here.
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  // Validates all fields at once when Login is tapped.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Hide the password (dots) until the eye icon is tapped.
  bool isObscureText = true;

  // "Remember me" checkbox (checked by default).
  bool rememberMe = true;

  // Focus node sitting on the password field: the username field
  // moves the keyboard focus here when the user taps "next".
  final FocusNode passwordFocusNode = FocusNode();

  // What happens when the Login button is tapped, or when the user
  // submits from the keyboard ("done" in the password field).
  void _onLoginPressed() {
    // Same rule as the disabled button: no second login while the
    // first request is still in flight.
    if (context.read<LoginCubit>().state is LoginLoadingState) {
      return;
    }

    // Close the keyboard first (nicer UX).
    FocusScope.of(context).unfocus();

    // Only log in when every field passes its validator.
    if (formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().login(
            widget.usernameController.text,
            widget.passwordController.text,
            rememberMe: rememberMe,
          );
    }
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Username field ----
          AppTextFormField(
            controller: widget.usernameController,
            labelText: 'Username',
            // Plain text keyboard (the SDK has no "username" type).
            keyboardType: TextInputType.text,
            // A username is typed EXACTLY as chosen: no silent
            // "corrections" from the keyboard (emilys -> emails).
            autocorrect: false,
            enableSuggestions: false,
            // "Next" on the keyboard jumps to the password field.
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
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

          // ---- Password field ----
          AppTextFormField(
            controller: widget.passwordController,
            labelText: 'Password',
            focusNode: passwordFocusNode,
            obscureText: isObscureText, // dots instead of text
            // "Done" on the keyboard submits the form, the same way
            // the Login button does.
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onLoginPressed(),
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
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !AppRegex.isPasswordValid(value)) {
                return 'Please enter a valid password';
              }
              return null;
            },
          ),

          // ---- "Remember me" checkbox (local UI state) ----
          CheckboxListTile(
            value: rememberMe,
            // The checkbox is plain UI state -> needs setState.
            onChanged: (value) =>
                setState(() => rememberMe = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('Remember me'),
          ),
          verticalSpace(24),

          // ---- Login button (spins while logging in) ----
          BlocBuilder<LoginCubit, LoginState>(
            // Rebuild only when loading starts or ends.
            buildWhen: (previous, current) =>
                current is LoginLoadingState ||
                previous is LoginLoadingState,
            builder: (context, state) {
              final bool isLoading = state is LoginLoadingState;
              return FilledButton(
                // null = disabled (no double login while spinning).
                onPressed: isLoading ? null : _onLoginPressed,
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
                    : Text('Login', style: Styles.font14SemiBoldWhite),
              );
            },
          ),
        ],
      ),
    );
  }
}
