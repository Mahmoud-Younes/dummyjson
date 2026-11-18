// The "traffic officer" of the app.
//
// When we navigate (context.pushNamed(Routes.loginScreen)),
// Flutter asks THIS class: "which screen is '/loginScreen'?"
// The switch below answers, builds the screen, and wraps it
// with the Cubit(s) it needs - created by get_it.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/di/dependency_injection.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/login/ui/login_screen.dart';
import 'package:dummyjson/features/product_details/logic/product_details_cubit.dart';
import 'package:dummyjson/features/product_details/ui/product_details_screen.dart';
import 'package:dummyjson/features/products/logic/products_cubit.dart';
import 'package:dummyjson/features/products/ui/products_screen.dart';
import 'package:dummyjson/features/settings/logic/settings_cubit.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_cubit.dart';
import 'package:dummyjson/features/sign_up/ui/sign_up_screen.dart';
import 'package:dummyjson/features/splash/logic/splash_cubit.dart';
import 'package:dummyjson/features/splash/ui/splash_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ---- Splash: decides "products" or "login" ----
      case Routes.splashScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            // Starts the auto-login check (saved tokens?) right away.
            create: (context) => getIt<SplashCubit>()..restoreSession(),
            child: const SplashScreen(),
          ),
        );

      // ---- Login ----
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            // The screen pre-fills the username in its own initState
            // (from storage - no route arguments needed).
            create: (context) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );

      // ---- Sign up: "creates" an account, then back to login ----
      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            // A FRESH SignUpCubit every visit (registerFactory), so
            // old states (a previous error/success) never leak in.
            // No arguments needed: the form starts empty on purpose.
            create: (context) => getIt<SignUpCubit>(),
            child: const SignUpScreen(),
          ),
        );

      // ---- Products: the shop (the FIRST screen after login) ----
      case Routes.productsScreen:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              // Starts fetching products right away.
              BlocProvider(
                create: (context) => getIt<ProductsCubit>()..fetchProducts(),
              ),
              // Feeds the settings popup in the app bar (username +
              // logout). It reuses LoginRepo - no session data needs
              // to travel here as route arguments.
              BlocProvider(
                create: (context) => getIt<SettingsCubit>()..loadUsername(),
              ),
            ],
            child: const ProductsScreen(),
          ),
        );

      // ---- Details: needs the product id from the arguments ----
      case Routes.productDetailsScreen:
        final int productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<ProductDetailsCubit>()
              ..fetchProductDetails(productId),
            child: ProductDetailsScreen(productId: productId),
          ),
        );

      // ---- Unknown route (safety net) ----
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
