// This file is the "translator" between internet and app.
//
// The DataSource (previous file) returns raw Maps.
// This file turns those Maps into clean ProductModel objects
// that the rest of the app can use safely.
//
// The Cubit NEVER talks to the internet directly.
// It only talks to this Repository. That keeps things tidy.
//
// When the internet fails, DioExceptions are translated by the
// central handle() helper (core/networking/api_error_handler.dart)
// into friendly messages - the same one the login feature uses.

import 'package:dio/dio.dart';

import 'package:dummyjson/core/error/app_exceptions.dart';
import 'package:dummyjson/core/networking/api_error_handler.dart';
import 'package:dummyjson/features/products/data/data_sources/product_remote_data_source.dart';
import 'package:dummyjson/features/products/data/models/product_model.dart';
import 'package:dummyjson/features/products/data/models/products_response.dart';

class ProductRepo {
  // We receive the DataSource from outside (from get_it - see
  // dependency_injection.dart).
  const ProductRepo(this.dataSource);

  final ProductRemoteDataSource dataSource;

  // Get all products, already translated to ProductModels.
  Future<List<ProductModel>> getProducts() async {
    try {
      final Map<String, dynamic> json = await dataSource.getProducts();
      final ProductsResponse response = ProductsResponse.fromJson(json);
      return response.products;
    } on AppException {
      // If it is already a friendly error, just pass it on.
      rethrow;
    } on DioException catch (e) {
      // Internet problems: hand the DioException to the ONE central
      // translator (core/networking/api_error_handler.dart) - the
      // same handle() the login feature uses - then wrap its friendly
      // message in our simple AppException.
      throw AppException(handle(e).message);
    } catch (_) {
      // Anything else (like bad JSON) becomes a simple friendly error.
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  // Get ONE product by id.
  Future<ProductModel> getProductById(int id) async {
    try {
      final Map<String, dynamic> json = await dataSource.getProductById(id);
      return ProductModel.fromJson(json);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(handle(e).message);
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  // Search products by a word.
  Future<List<ProductModel>> searchProducts(String word) async {
    try {
      final Map<String, dynamic> json = await dataSource.searchProducts(word);
      final ProductsResponse response = ProductsResponse.fromJson(json);
      return response.products;
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw AppException(handle(e).message);
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }
}
