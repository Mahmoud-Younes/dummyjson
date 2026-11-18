// The LOGIN page.
//
// The LoginCubit is ALREADY provided by the router (it sits ABOVE
// this screen in the widget tree), so here we never create it. We
// only READ it to prefill the username; the small widgets in
// ./widgets do the reading/watching for the form and the states.
//
// Page structure (one widget per job):
//   header -> EmailAndPassword -> DontHaveAccountText
//   -> LoginBlocListener.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/constants.dart';
import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/core/widgets/app_error_banner.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/login/ui/widgets/dont_have_account_text.dart';
import 'package:dummyjson/features/login/ui/widgets/email_and_password.dart';
import 'package:dummyjson/features/login/ui/widgets/login_bloc_listener.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers hold what the user types in the two fields.
  // This screen OWNS them (creates + disposes) and hands them down.
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    // Pre-fill the username with the last one typed (from storage),
    // so returning users don't have to type it again. The sign-up
    // flow feeds this too: SignUpRepoImpl saves the username right
    // before sending the user here.
    final String? prefill =
        context.read<LoginCubit>().getPrefillUsername();
    if (prefill != null && prefill.isNotEmpty) {
      usernameController.text = prefill;
    }
  }

  @override
  void dispose() {
    // Controllers use memory -> always throw them away here.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Did the AuthInterceptor bounce us back here? When the refresh
    // token dies mid-session, that interceptor (core/networking)
    // wipes the storage and navigates to THIS screen carrying the
    // 'sessionExpired' argument. Reading the route arguments here
    // lets us explain WHY the user is back on login - instead of
    // showing silence. (The normal login after splash/logout carries
    // no argument, so the banner stays hidden for them.)
    final bool sessionExpired =
        ModalRoute.of(context)?.settings.arguments ==
            RouteArguments.sessionExpired;

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

                  // ---- "Why am I back here?" banner ----
                  // Shown ONLY when the interceptor sent us here with
                  // the session-expired argument (see build above).
                  if (sessionExpired)
                    const AppErrorBanner(
                      message: 'Your session expired. Please sign in again.',
                    ),

                  verticalSpace(32),

                  // ---- Fields + "Remember me" + Login button ----
                  EmailAndPassword(
                    usernameController: usernameController,
                    passwordController: passwordController,
                  ),
                  verticalSpace(16),

                  // ---- Link to the sign-up page ----
                  const DontHaveAccountText(),

                  // ---- Navigation on success + error banner ----
                  // Kept LAST in the column (the listener reacts after the widgets draw).
                  const LoginBlocListener(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // "Welcome" in black, " back" in teal (RichText mixes styles).
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Welcome', style: Styles.font24Bold),
              TextSpan(
                text: ' back',
                style: Styles.font24Bold
                    .copyWith(color: ColorsManager.mainTeal),
              ),
            ],
          ),
        ),
        verticalSpace(8),
        Text('Sign in to continue shopping',
            style: Styles.font14RegularGray),
      ],
    );
  }
}
