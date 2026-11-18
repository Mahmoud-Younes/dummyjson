// ONE small class that carries an error around the app.
//
// Whenever something goes wrong (slow internet, wrong password...)
// we wrap the reason in an ErrorModel and give it to the UI,
// so screens only ever need to know ONE error shape.

class ErrorModel {
  // The HTTP code (400, 401...) when the server answered, otherwise null.
  final int? statusCode;

  // A short human-readable message we can show on the screen.
  final String message;

  const ErrorModel({this.statusCode, required this.message});

  // Builds an ErrorModel from whatever the server (or Dio) gave us.
  factory ErrorModel.fromJson(dynamic json) {
    // Case 1: a JSON object like {"message": "Invalid credentials"}.
    if (json is Map) {
      return ErrorModel(
        // int.tryParse gives null when the value is missing/not a number.
        statusCode: int.tryParse('${json['statusCode']}'),
        message: (json['message'] as String?) ?? '',
      );
    }
    // Case 2: just a plain string message.
    return ErrorModel(message: json is String ? json : '');
  }
}
