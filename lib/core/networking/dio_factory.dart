// This file BUILDS the one Dio object the whole app shares.
//
// Dio is like the "phone" used to call the server.
// We build it ONCE here (with the base address + timeouts)
// and get_it hands it to anyone who needs to call the internet
// (see dependency_injection.dart).

import 'package:dio/dio.dart';

import 'package:dummyjson/core/networking/api_constants.dart';

class DioFactory {
  // Private constructor: nobody should ever create a DioFactory.
  // Everything here is static - just use DioFactory.getDio().
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    // How long to wait before giving up (15 seconds).
    final Duration timeOut = const Duration(seconds: 15);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut // time to OPEN the line
        ..options.receiveTimeout = timeOut // time to get the answer
        ..options.responseType = ResponseType.json
        ..options.baseUrl = ApiConstants.apiBaseUrl;
      addDioInterceptor();
    }
    return dio!;
  }

  static void addDioInterceptor() {
    // Interceptors watch every request/response that goes by.
    // LogInterceptor PRINTS them in the console - great for learning.
    dio!.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: false,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }
}
