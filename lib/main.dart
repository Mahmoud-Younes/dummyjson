// The entry point of the app.
//
// Steps:
//   1. Make sure Flutter is ready (needed BEFORE using plugins
//      like shared_preferences).
//   2. Prepare the "kitchen" (setupGetIt registers Dio, repos,
//      cubits... so screens can ask for them).
//   3. Start the app with our router.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/routing/app_router.dart';
import 'package:dummyjson/dummyjson_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web only: build the accessibility tree as a DOM overlay, so browser
  // automation (Playwright/e2e tests) and screen readers can see the UI.
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  await setupGetIt();

  runApp(DummyJsonApp(appRouter: AppRouter()));
}
