// This file holds ONE simple error type for the whole app.
//
// Why only one? Because you are just starting out.
// One error with a message is enough:
//   throw AppException('No internet');
// The Cubit will show that message on screen.
//
// NOTE: the code that turns internet errors into this error
// lives at the bottom of product_remote_datasource.dart
// (so you can see it right where it is used).

// A simple error that only carries a human message.
class AppException implements Exception {
  const AppException(this.message);

  // The text we will show to the user.
  final String message;

  @override
  String toString() => 'AppException: $message';
}
