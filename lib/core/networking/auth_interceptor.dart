// The session WATCHDOG: a Dio interceptor that rides on the one
// shared Dio and handles the access/refresh token pair for EVERY
// request, so no screen or repository ever copies the token by hand.
//
// What it does on each trip:
//   request  -> attach "Authorization: Bearer <accessToken>" from
//               the encrypted box (skipping the public auth paths).
//   401/403  -> the access token was rejected. Trade the refresh
//               token for a new pair (ONCE - see below), save it,
//               then replay the failed request with the new token.
//   refresh rejected (400/401/403) -> the session is truly over:
//               clean the storage and ring the onSessionExpired
//               bell. The interceptor NEVER navigates itself (core
//               must not touch the UI) - the callback registered in
//               dependency_injection.dart does that.
//
// Why QueuedInterceptor (not the plain one)? Dio runs plain
// interceptors in parallel: three requests failing 401 at the same
// moment would start THREE refresh calls (and servers often kill a
// token when it is refreshed too many times). The QUEUED version
// lines the responses up: the first 401 refreshes, the rest wait,
// then see the already-changed token and simply retry.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:dummyjson/core/helpers/secure_storage_helper.dart';
import 'package:dummyjson/core/helpers/shared_pref_helper.dart';

class AuthInterceptor extends QueuedInterceptor {
  // The refresh call goes THROUGH ApiService (never raw Dio here -
  // only ApiService owns the endpoints), and the onSessionExpired
  // callback is wired up in dependency_injection.dart, where the
  // whole app is assembled.
  AuthInterceptor({
    required this._dio,
    required this._refreshTokens,
    required this._onSessionExpired,
  });

  final Dio _dio;
  final Future<Map<String, dynamic>> Function(String refreshToken)
      _refreshTokens;
  final void Function() _onSessionExpired;

  // Paths that must never get a token header and must never trigger
  // a refresh - a failed refresh asking for another refresh would
  // loop forever.
  static const Set<String> _publicPaths = {'auth/login', 'auth/refresh'};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public paths travel naked: no Authorization header.
    if (_publicPaths.contains(_normalize(options.path))) {
      handler.next(options);
      return;
    }
    // Attach the saved access token (if we have one) to every other
    // request - read straight from the encrypted box.
    final String? accessToken = await SecureStorageHelper.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Lifecycle prints for learning/debugging. IMPORTANT: never print
    // token values here - LogInterceptor already keeps
    // requestHeader:false for the same reason, and our own prints
    // must stay token-free too.
    final int? statusCode = err.response?.statusCode;
    // Same rule as LoginRepo: these two codes mean "your key was
    // rejected" (expired or revoked), not "the internet is down".
    final bool tokenRejected = statusCode == 401 || statusCode == 403;
    // Did THIS request already go through a refresh-and-retry? Then
    // never refresh again for it - one retry per request, max.
    final bool alreadyRetried = err.requestOptions.extra['retried'] == true;
    final RequestOptions request = err.requestOptions;
    final bool publicPath = _publicPaths.contains(_normalize(request.path));

    if (!tokenRejected || publicPath || alreadyRetried) {
      handler.next(err);
      return;
    }

    // ---- Single-flight guard ----
    // The token the FAILED request carried vs. the token in storage
    // NOW. Different? Another queued request already refreshed while
    // we were waiting in line - so we skip our own refresh and just
    // replay with the fresh token from storage.
    final String carriedToken =
        _bearerFrom(request.headers['Authorization']) ?? '';
    final String? currentToken = await SecureStorageHelper.getAccessToken();
    if (currentToken != null &&
        currentToken.isNotEmpty &&
        currentToken != carriedToken) {
      debugPrint('AuthInterceptor: token already refreshed by another '
          'queued request - replaying with the fresh one');
      handler.resolve(await _replay(request));
      return;
    }

    // ---- Try to refresh ----
    final String? refreshToken = await SecureStorageHelper.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      // No refresh key = the session cannot be saved. Clean up and
      // ring the bell; the ORIGINAL error still travels on so the
      // caller sees it.
      await _clearSession();
      _onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      // Ask ApiService for a brand-new pair (never raw Dio here).
      final Map<String, dynamic> refreshJson =
          await _refreshTokens(refreshToken);
      // Save the new pair. If the server omits a field, keep the old
      // value - exactly like LoginRepo does on the splash path.
      final String? newAccess =
          (refreshJson['accessToken'] as String?) ?? currentToken;
      final String newRefresh =
          (refreshJson['refreshToken'] as String?) ?? refreshToken;
      if (newAccess != null && newAccess.isNotEmpty) {
        await SecureStorageHelper.saveAccessToken(newAccess);
      }
      if (newRefresh.isNotEmpty) {
        await SecureStorageHelper.saveRefreshToken(newRefresh);
      }
      debugPrint('AuthInterceptor: refresh ok - replaying the failed request');
      handler.resolve(await _replay(request));
    } on DioException catch (refreshErr) {
      final int? refreshCode = refreshErr.response?.statusCode;
      debugPrint('AuthInterceptor: refresh rejected with code $refreshCode');
      if (refreshCode == 400 || refreshCode == 401 || refreshCode == 403) {
        // The refresh token was rejected too: the session is over.
        // Clean the storage and ring the bell - the callback (wired
        // in dependency_injection.dart) jumps to the login page.
        await _clearSession();
        _onSessionExpired();
      }
      // ALWAYS pass the ORIGINAL error on: the caller (a repository)
      // is still waiting for an answer, and it translates the raw
      // Dio error into a friendly message itself.
      handler.next(err);
    }
  }

  // Send the failed request AGAIN. Marking it 'retried' makes the
  // onError guard above refuse a second refresh for this request,
  // and dropping the old Authorization header lets onRequest attach
  // the FRESH token from storage.
  Future<Response<dynamic>> _replay(RequestOptions request) {
    request.extra['retried'] = true;
    request.headers.remove('Authorization');
    return _dio.fetch(request);
  }

  // Best-effort cleanup of BOTH boxes: a broken box must never stop
  // us from trying to clean the other one.
  Future<void> _clearSession() async {
    try {
      await SecureStorageHelper.clearTokens();
    } catch (_) {
      // The encrypted box refused - keep going, the other box may
      // still be cleanable.
    }
    try {
      await SharedPrefHelper.removeSavedUser();
    } catch (_) {
      // Nothing else we can safely clean - give up quietly.
    }
  }

  // Endpoints are registered WITHOUT a leading '/' (e.g. 'auth/login'),
  // but Dio reports the path WITH one - so strip it before comparing.
  static String _normalize(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  // 'Bearer abc.def' -> 'abc.def' (anything else -> null).
  static String? _bearerFrom(Object? header) {
    if (header is String && header.startsWith('Bearer ')) {
      final String token = header.substring('Bearer '.length).trim();
      return token.isEmpty ? null : token;
    }
    return null;
  }
}
