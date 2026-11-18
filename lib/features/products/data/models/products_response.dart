// This file describes the ANSWER we get when we ask for MANY products.
//
// When we call GET https://dummyjson.com/products
// the internet does NOT send just a list.
// It sends a Map like this:
// {
//   "products": [ {...}, {...} ],  <- the real list
//   "total": 194,                  <- how many products exist in total
//   "skip": 0,                     <- how many we skipped
//   "limit": 30                    <- how many we asked for
// }
//
// This class holds those 4 things together.

import 'package:equatable/equatable.dart';

import 'product_model.dart';

class ProductsResponse extends Equatable {
  // The list of products.
  final List<ProductModel> products;

  // Extra numbers from the server (useful later for pages).
  final int total;
  final int skip;
  final int limit;

  // Create it. All boxes have safe defaults so it never crashes.
  const ProductsResponse({
    this.products = const [],
    this.total = 0,
    this.skip = 0,
    this.limit = 0,
  });

  // Make it from internet data (JSON).
  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    // Step 1: get the raw list (or empty list if missing).
    final List rawList = (json['products'] as List? ?? []);

    // Step 2: turn each Map inside into a ProductModel.
    // We use a simple for-loop because it is easiest to read.
    final List<ProductModel> cleanList = [];
    for (final item in rawList) {
      if (item is Map) {
        // item is Map<dynamic, dynamic>, so convert to Map<String, dynamic>
        cleanList.add(
          ProductModel.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    // Step 3: return the finished object.
    return ProductsResponse(
      products: cleanList,
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }

  // Needed for Equatable (lets Cubit compare responses).
  @override
  List<Object?> get props => [products, total, skip, limit];
}
