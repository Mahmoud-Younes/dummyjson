// The "kitchen" of the app (dependency injection with get_it).
//
// Instead of every screen BUILDING the objects it needs
// (Dio, repos, cubits...), they are built ONCE here and
// handed out on request, like a waiter bringing orders.
//
//   registerLazySingleton -> built the FIRST time it is asked
//                            for, then the SAME one is reused.
//   registerFactory       -> a NEW one every time it is asked
//                            for (perfect: one cubit per screen).
//
// main() calls setupGetIt() once, before runApp().

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dummyjson/core/helpers/constants.dart';
import 'package:dummyjson/core/networking/api_service.dart';
import 'package:dummyjson/core/networking/auth_interceptor.dart';
import 'package:dummyjson/core/networking/dio_factory.dart';
import 'package:dummyjson/core/routing/navigator_key.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/features/login/data/repos/login_repo.dart';
import 'package:dummyjson/features/login/logic/login_cubit.dart';
import 'package:dummyjson/features/product_details/logic/product_details_cubit.dart';
import 'package:dummyjson/features/products/data/data_sources/product_remote_data_source.dart';
import 'package:dummyjson/features/products/data/repos/product_repo.dart';
import 'package:dummyjson/features/products/logic/products_cubit.dart';
import 'package:dummyjson/features/settings/logic/settings_cubit.dart';
import 'package:dummyjson/features/sign_up/data/repos/sign_up_repo.dart';
import 'package:dummyjson/features/sign_up/logic/sign_up_cubit.dart';
import 'package:dummyjson/features/splash/logic/splash_cubit.dart';

// The global "service locator". Screens ask getIt<LoginCubit>() etc.
final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // ---- Outside packages first ----
  // shared_preferences needs one await before it is ready to use.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // The encrypted box for the tokens (access + refresh).
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // The one shared Dio (the phone line to the server).
  Dio dio = DioFactory.getDio();
  getIt.registerLazySingleton<Dio>(() => dio);

  // ---- Core networking: the raw API caller ----
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt()));

  // ---- The session watchdog (auth interceptor) ----
  // It rides on the SAME Dio the whole app shares: attaches the
  // Bearer token to every request, refreshes ONCE on 401, and when
  // the session is truly dead it rings the bell below. The
  // interceptor itself never navigates (core must not touch the
  // UI) - this callback, wired HERE where the app is assembled,
  // jumps to Login with the stack wiped and the "session expired"
  // reason so the login screen can explain what happened.
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshTokens: (String refreshToken) =>
          getIt<ApiService>().refreshTokens(refreshToken),
      onSessionExpired: () => navigatorKey.currentState
          ?.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            (route) => false,
            arguments: RouteArguments.sessionExpired,
          ),
    ),
  );

  // ---- Login feature: repo -> the two cubits that use it ----
  // (login = the login form, splash = auto-login check; the settings
  // cubit reuses the same repo below)
  getIt.registerLazySingleton<LoginRepo>(() => LoginRepoImpl(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(repo: getIt()));
  getIt.registerFactory<SplashCubit>(() => SplashCubit(repo: getIt()));

  // ---- Sign up feature ----
  // Same recipe as login: ONE shared repo (it reuses ApiService),
  // but a FRESH cubit per screen visit so old states never leak in.
  getIt.registerLazySingleton<SignUpRepo>(() => SignUpRepoImpl(getIt()));
  getIt.registerFactory<SignUpCubit>(() => SignUpCubit(repo: getIt()));

  // ---- Settings feature (the products app-bar popup) ----
  // No repo of its own: it reuses LoginRepo (logout + saved user).
  // A FRESH cubit per products-screen visit, like every other cubit.
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit(repo: getIt()));

  // ---- Products feature ----
  // The products data source talks THROUGH ApiService (same as
  // login), so getIt() hands it ApiService - nobody here touches
  // the raw Dio directly.
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<ProductRepo>(() => ProductRepo(getIt()));
  getIt.registerFactory<ProductsCubit>(() => ProductsCubit(repository: getIt()));
  getIt.registerFactory<ProductDetailsCubit>(
    () => ProductDetailsCubit(repository: getIt()),
  );
}
