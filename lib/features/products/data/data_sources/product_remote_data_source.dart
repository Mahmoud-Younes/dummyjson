// This file talks to the internet THROUGH ApiService
// (the central caller in core/networking/api_service.dart).
//
// It has only 3 jobs:
//   1. getProducts()  -> GET /products
//   2. getProductById -> GET /products/1
//   3. searchProducts -> GET /products/search?q=phone
//
// It returns raw Maps. The Repository (next file)
// will turn those Maps into ProductModel objects.

import 'package:dummyjson/core/networking/api_service.dart';

class ProductRemoteDataSource {
  // We receive ApiService from outside (from get_it - see
  // dependency_injection.dart). Same as the login feature:
  // nobody here touches the raw Dio directly.
  const ProductRemoteDataSource(this._apiService);

  final ApiService _apiService;

  // ---- Job 1: get all products ----
  Future<Map<String, dynamic>> getProducts() async {
    // ApiService makes the call and hands back the Map
    // the server sent.
    return _apiService.getProducts();
  }

  // ---- Job 2: get ONE product by its id ----
  Future<Map<String, dynamic>> getProductById(int id) async {
    return _apiService.getProductById(id);
  }

  // ---- Job 3: search products by a word ----
  Future<Map<String, dynamic>> searchProducts(String word) async {
    return _apiService.searchProducts(word);
  }
}

// NOTE about errors: ApiService does NOT catch errors on purpose.
// When a call fails, the error flies up to the Repository,
// which turns it into a simple friendly AppException.
