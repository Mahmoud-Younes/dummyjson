// The ONLY file that calls the DummyJSON server endpoints
// (the auth ones AND the products ones).
//
// Each method: 1) send the request, 2) return the raw JSON Map.
// It does NOT catch errors on purpose - a DioException flies up to
// the repository, which turns it into a friendly ErrorModel.

import 'package:dio/dio.dart';

import 'package:dummyjson/core/networking/api_constants.dart';

class ApiService {
  // Dio is injected from outside (see dependency_injection.dart).
  const ApiService(this._dio);

  final Dio _dio;

  // POST /auth/login -> user data + accessToken + refreshToken.
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    int expiresInMins = 60,
  }) async {
    final Response response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
        'expiresInMins': expiresInMins,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // POST /auth/refresh -> brand new access + refresh tokens.
  Future<Map<String, dynamic>> refreshTokens(
    String refreshToken, {
    int expiresInMins = 60,
  }) async {
    final Response response = await _dio.post(
      ApiConstants.refresh,
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': expiresInMins,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // GET /auth/me -> the logged-in user (needs a Bearer token).
  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    final Response response = await _dio.get(
      ApiConstants.authMe,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // POST /users/add -> a NEW user object (id, username, email...).
  //
  // LEARNING NOTE (important!): DummyJSON has NO real "sign up"
  // endpoint. /users/add only PRETENDS to create an account: it
  // answers with the new user, but the account is NOT saved on the
  // server - logging in with the same data would fail with
  // "Invalid credentials". We use it to SIMULATE registration.
  Future<Map<String, dynamic>> signUpUser(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
  ) async {
    final Response response = await _dio.post(
      ApiConstants.usersAdd,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // GET /products -> the list of ALL products.
  Future<Map<String, dynamic>> getProducts() async {
    final Response response = await _dio.get(ApiConstants.products);
    return Map<String, dynamic>.from(response.data as Map);
  }

  // GET /products/:id -> ONE product by its number (e.g. /products/1).
  Future<Map<String, dynamic>> getProductById(int id) async {
    final Response response = await _dio.get('${ApiConstants.products}/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  // GET /products/search?q=... -> products matching the word.
  // queryParameters means: "?q=word" at the end of the URL.
  // Dio adds it for us, so we do not write the URL by hand.
  Future<Map<String, dynamic>> searchProducts(String word) async {
    final Response response = await _dio.get(
      ApiConstants.productsSearch,
      queryParameters: {'q': word},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
