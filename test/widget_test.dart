// Simple tests to make sure our Product code works.
// Run with: flutter test
//
// These tests use FAKE data (no internet needed).
// They check: "if the server sends this Map, do we read it correctly?"

import 'package:flutter_test/flutter_test.dart';

import 'package:dummyjson/features/products/data/models/product_model.dart';
import 'package:dummyjson/features/products/data/models/products_response.dart';

void main() {
  // Test 1: a normal product with all fields.
  test('Reads a full product correctly', () {
    const fakeJson = <String, dynamic>{
      'id': 1,
      'title': 'iPhone 9',
      'description': 'A great phone',
      'price': 549,
      'discountPercentage': 10,
      'rating': 4.5,
      'stock': 94,
      'brand': 'Apple',
      'category': 'smartphones',
      'thumbnail': 'https://example.com/small.jpg',
      'images': ['https://example.com/big1.jpg'],
    };

    final product = ProductModel.fromJson(fakeJson);

    expect(product.id, 1);
    expect(product.title, 'iPhone 9');
    expect(product.price, 549.0);
    expect(product.brand, 'Apple');

    // Our helper: first image should win.
    expect(product.bestImage, 'https://example.com/big1.jpg');

    // Our helper: 549 with 10% off = 494.1
    expect(product.priceAfterDiscount, closeTo(494.1, 0.01));
  });

  // Test 2: some products have NO brand (like apples!).
  // Our code must NOT crash, brand should just be null.
  test('Missing brand does not crash', () {
    const fakeJson = <String, dynamic>{
      'id': 16,
      'title': 'Apple',
      'price': 1,
      'category': 'groceries',
    };

    final product = ProductModel.fromJson(fakeJson);

    expect(product.brand, isNull);
    expect(product.brandText, 'No brand');
    expect(product.price, 1.0);
  });

  // Test 3: the list wrapper (products + total + skip + limit).
  test('Reads a list of products correctly', () {
    const fakeJson = <String, dynamic>{
      'products': [
        {'id': 1, 'title': 'A', 'price': 10},
        {'id': 2, 'title': 'B', 'price': 20},
      ],
      'total': 194,
      'skip': 0,
      'limit': 30,
    };

    final response = ProductsResponse.fromJson(fakeJson);

    expect(response.products.length, 2);
    expect(response.total, 194);
    expect(response.products[0].title, 'A');
  });
}
