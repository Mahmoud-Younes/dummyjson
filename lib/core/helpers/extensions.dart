// Small helpers added to existing types ("extensions").
//
// The first one makes navigation shorter and nicer:
//   before: Navigator.of(context).pushNamed(Routes.loginScreen);
//   after:  context.pushNamed(Routes.loginScreen);

import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  // Go to a NEW screen (the old one stays below it, like stacked papers).
  void pushNamed(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed(routeName, arguments: arguments);

  // Replace the current screen (the old one is thrown away).
  void pushReplacementNamed(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);

  // Go to a new screen and REMOVE every screen before it
  // (used after login so "back" can never return to the login page).
  void pushNamedAndRemoveUntil(
    String routeName, {
    required RoutePredicate predicate,
    Object? arguments,
  }) =>
      Navigator.of(this)
          .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);

  // Close the current screen (go one step back).
  void pop() => Navigator.of(this).pop();
}
