// The root widget: the MaterialApp.
//
// (One tiny file with ONE job: assemble the root MaterialApp.)
//
// It only knows THREE things:
//   - which theme to use (our teal),
//   - the FIRST screen (splash),
//   - WHO decides what each route name means (AppRouter).

import 'package:flutter/material.dart';

import 'package:dummyjson/core/routing/app_router.dart';
import 'package:dummyjson/core/routing/navigator_key.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';

class DummyJsonApp extends StatelessWidget {
  const DummyJsonApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DummyJSON Store',
      debugShowCheckedModeBanner: false,
      // Handing the MaterialApp our GLOBAL navigator key: from now on
      // navigatorKey.currentState IS this app's Navigator. That lets
      // the DI wiring (dependency_injection.dart) react to an expired
      // session - and jump to the login page - WITHOUT any
      // BuildContext, because that code lives outside the widget tree.
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorsManager.mainTeal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: ColorsManager.mainTeal,
          foregroundColor: Colors.white,
          // ONE title style for every app bar in the app
          // (Products, Details): the bars style nothing by hand.
          titleTextStyle: Styles.font18SemiBoldWhite,
        ),
      ),
      initialRoute: Routes.splashScreen,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
