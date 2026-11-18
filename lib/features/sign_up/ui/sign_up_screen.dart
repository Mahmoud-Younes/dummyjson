// The SIGN-UP page.
//
// The SignUpCubit is ALREADY provided by the router (it sits ABOVE
// this screen in the widget tree), so here we never create it.
// This screen only OWNS the six text controllers (it creates them
// and throws them away in dispose) and hands them down to the
// form - the small widgets in ./widgets do the watching/reacting.
//
// Page structure (one widget per job):
//   header -> SignUpForm -> AlreadyHaveAccountText -> SignUpBlocListener.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/features/sign_up/ui/widgets/already_have_account_text.dart';
import 'package:dummyjson/features/sign_up/ui/widgets/sign_up_bloc_listener.dart';
import 'package:dummyjson/features/sign_up/ui/widgets/sign_up_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers hold what the user types in the six fields.
  // This screen OWNS them (creates + disposes) and hands them down.
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // Controllers use memory -> always throw them away here.
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // On wide screens (web/desktop) keep the form narrow.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Header: title + subtitle ----
                  _buildHeader(),
                  // Same gap as login: the two pages read as one family.
                  verticalSpace(32),

                  // ---- The six fields + checklist + button ----
                  SignUpForm(
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    usernameController: usernameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                  ),

                  // ---- Link back to the login page ----
                  verticalSpace(16),
                  const AlreadyHaveAccountText(),

                  // ---- Success dialog + error banner ----
                  // Kept LAST in the column (the listener reacts after the widgets draw).
                  const SignUpBlocListener(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // The whole title in the app's teal (login mixes two colors with
  // RichText; here one color is enough, so a plain Text + copyWith).
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: Styles.font24Bold.copyWith(color: ColorsManager.mainTeal),
        ),
        verticalSpace(8),
        Text('Sign up to start shopping', style: Styles.font14RegularGray),
      ],
    );
  }
}
