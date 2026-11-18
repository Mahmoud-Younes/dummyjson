// Translates Dio's error types into friendly human messages.
//
// When a request fails, Dio throws a DioException. Its "type"
// tells us WHY it failed (slow internet? server said 400? user
// cancelled?). This file maps each reason to an ErrorModel.

import 'package:dio/dio.dart';

import 'package:dummyjson/core/networking/api_error_model.dart';

// A top-level function (no class needed) - just call: handle(exception).
ErrorModel handle(DioException exception) {
  switch (exception.type) {
    // Timeouts: the server took too long to answer (slow internet).
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return ErrorModel(message: 'Internet is too slow. Please try again.');

    // Could not reach the server at all (no internet, airplane mode...).
    case DioExceptionType.connectionError:
      return ErrorModel(message: 'No internet connection.');

    // The server DID answer, but with an error code (400, 401, 500...).
    case DioExceptionType.badResponse:
      return _handleBadResponse(exception);

    // The request was cancelled before it finished.
    case DioExceptionType.cancel:
      return ErrorModel(message: 'Request was cancelled.');

    // Anything else (unknown error, bad certificate...).
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return ErrorModel(message: 'Something went wrong. Please try again.');
  }
}

// The server answered with an error code - read its message from the body.
ErrorModel _handleBadResponse(DioException exception) {
  final int? statusCode = exception.response?.statusCode;
  final Object? data = exception.response?.data;

  // The server usually sends a JSON body like {"message": "Invalid credentials"}.
  if (data is Map) {
    final String? serverMessage = data['message'] as String?;
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ErrorModel(statusCode: statusCode, message: serverMessage);
    }
  }
  // No usable body: build a generic message that shows the status code.
  return ErrorModel(
    statusCode: statusCode,
    message: 'Server error (${statusCode ?? 'unknown'}).',
  );
}
