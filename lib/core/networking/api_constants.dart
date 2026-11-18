// All the addresses (URLs) of the DummyJSON server live here.
//
// apiBaseUrl ends with '/', and every endpoint has NO '/' at the
// start - Dio glues them together, for example:
//   https://dummyjson.com/ + products = https://dummyjson.com/products

class ApiConstants {
  static const String apiBaseUrl = 'https://dummyjson.com/';

  // ---- Auth endpoints (https://dummyjson.com/docs/auth) ----
  static const String login = 'auth/login';
  static const String refresh = 'auth/refresh';
  static const String authMe = 'auth/me';

  // ---- Products endpoints ----
  static const String products = 'products';
  static const String productsSearch = 'products/search';

  // ---- Users endpoints (https://dummyjson.com/docs/users) ----
  // /users/add only PRETENDS to create a user: it answers 201 with
  // a made-up user object but saves NOTHING on the server. It is a
  // public endpoint: no Authorization header, no required fields.
  static const String usersAdd = 'users/add';
}
