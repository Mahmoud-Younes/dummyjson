// ONE red error banner for the whole app (login + sign-up forms).
//
// When a Cubit emits its error state, the screen shows THIS under
// the form: a light-red box, a "!" icon, and the friendly message
// the error handler built. One widget = one consistent "this
// failed" look everywhere (it used to be copy-pasted in each
// listener - now both listeners just show the same one).

import 'package:flutter/material.dart';

import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.errorBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: ColorsManager.error),
          horizontalSpace(8),
          Expanded(
            child: Text(
              message,
              style: Styles.font14RegularRed,
            ),
          ),
        ],
      ),
    );
  }
}
