// This file describes what ONE product looks like in our app.
//
// Think of it like a form with empty boxes (id, title, price...).
// The internet sends us a Map called "JSON", and we copy the values
// from that Map into our boxes. That is all "fromJson" does.

import 'package:equatable/equatable.dart';

// A Product is just a box that holds product info.
// We extend Equatable so Flutter can easily tell
// if two products are the same (needed for Cubit).
class ProductModel extends Equatable {
  // ---- 1. The boxes (variables) every product has ----

  final int id; // example: 1
  final String title; // example: "iPhone 9"
  final String description; // example: "A great phone..."
  final double price; // example: 549.0
  final double discountPercentage; // example: 12.5 means 12.5% off
  final double rating; // example: 4.6 (stars out of 5)
  final int stock; // example: 94 (how many are left)
  final String? brand; // example: "Apple". The "?" means it can be empty!
  final String category; // example: "smartphones"
  final String thumbnail; // small image link (shown in the list)
  final List<String> images; // big image links (shown on details page)

  // ---- 2. How to CREATE a product ----
  // "const" just means: once you make it, you cannot change it.
  // This keeps our app safe from accidents.
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand, // NOT required, because some products have no brand
    required this.category,
    required this.thumbnail,
    this.images = const [], // empty list by default
  });

  // ---- 3. How to MAKE a product from internet data (JSON) ----
  // The internet sometimes sends a whole number (like 10)
  // and sometimes a decimal (like 10.5).
  // So we always read numbers as "num" first, then convert.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // (json['id'] as num?) means: "get 'id', it might be missing".
      // ?.toInt() means: "if it exists, turn it into an int".
      // ?? 0 means: "if it was missing, just use 0".
      id: (json['id'] as num?)?.toInt() ?? 0,

      // Same idea for text: "get 'title', or use empty text if missing".
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',

      // Prices can be int OR double, so we use num then toDouble().
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,

      stock: (json['stock'] as num?)?.toInt() ?? 0,

      // Brand is special: some products (like groceries) have NO brand.
      // So we keep it nullable (String?) and do NOT give a default.
      brand: json['brand'] as String?,

      thumbnail: (json['thumbnail'] as String?) ?? '',

      // Images is a list. If missing, we use an empty list [].
      // List<String>.from(...) means: "make a clean list of texts".
      images: List<String>.from(json['images'] as List? ?? []),
    );
  }

  // ---- 4. Small helpers to make the UI code shorter ----

  // The real price after discount.
  // Example: 100 with 10% off -> 90.
  double get priceAfterDiscount {
    return price * (1 - discountPercentage / 100);
  }

  // Safe brand text. If brand is missing, show "No brand".
  // The UI can just use this and never worry about null.
  String get brandText {
    if (brand == null || brand!.isEmpty) {
      return 'No brand';
    }
    return brand!;
  }

  // The best image to show. Prefer the first big image,
  // otherwise use the small thumbnail.
  String get bestImage {
    if (images.isNotEmpty) {
      return images.first;
    }
    return thumbnail;
  }

  // ---- 5. Needed for Equatable (lets Cubit compare products) ----
  // Just list every box here. You can copy-paste this pattern.
  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        discountPercentage,
        rating,
        stock,
        brand,
        category,
        thumbnail,
        images,
      ];
}
