// The GEAR icon in the products app bar.
//
// Tapping it opens a small popup menu: a "Signed in as @emilys"
// header line and a Logout entry. The SettingsCubit it talks to is
// provided by the ROUTER (above the products screen, next to
// ProductsCubit) - this widget only READS the cubit and LISTENS to
// it; it never creates one.
//
// While logout is running, the gear is replaced by a small white
// spinner: tapping a popup item CLOSES the menu, so the app-bar
// spinner is what keeps the "busy" feedback visible while the
// storage is being cleaned. (The design system's 18px spinner rule.)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/extensions.dart';
import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/features/settings/logic/settings_cubit.dart';
import 'package:dummyjson/features/settings/logic/settings_state.dart';

class SettingsMenuButton extends StatelessWidget {
  const SettingsMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. The listener: when logout FINISHES, leave the shop.
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => current is SettingsLoggedOut,
      listener: (context, state) {
        // Storage is already clean. Go to Login and wipe EVERY page
        // below us - so "back" can never return to the shop.
        context.pushNamedAndRemoveUntil(
          Routes.loginScreen,
          predicate: (route) => false,
        );
      },
      // 2. The child: the icon (or spinner) itself.
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final bool isLoggingOut = state is SettingsLoggingOut;

          // Logout in progress: swap the gear for a tiny white
          // spinner (white on the teal bar passes contrast).
          if (isLoggingOut) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            );
          }

          // The username for the header line ('' when nothing was
          // saved - the menu then simply hides the header line).
          final String username =
              state is SettingsLoaded ? state.username : '';

          return PopupMenuButton<String>(
            // The tooltip IS the semantic label - screen readers and
            // e2e tests announce a "Settings" button.
            tooltip: 'Settings',
            // The app bar theme already makes icons white.
            icon: const Icon(Icons.settings_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<SettingsCubit>().logout();
              }
            },
            itemBuilder: (context) => [
              // Header line: only when we actually know a username.
              if (username.isNotEmpty)
                PopupMenuItem<String>(
                  enabled: false, // it is a label, not a choice
                  child: Text(
                    'Signed in as @$username',
                    style: Styles.font13RegularGray,
                  ),
                ),
              // The logout action. The Row is built non-const because
              // horizontalSpace() is a function (not a const value).
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      size: 18,
                      color: ColorsManager.mainTeal,
                    ),
                    horizontalSpace(8),
                    const Text('Logout', style: Styles.font13SemiBoldTeal),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
