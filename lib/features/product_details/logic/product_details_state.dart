// Answers for the details page.
// Only 3 answers: Loading, Loaded (here is the product!), Error.

import 'package:equatable/equatable.dart';

import 'package:dummyjson/features/products/data/models/product_model.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

// Starting point.
class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

// "Please wait..."
class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

// "Here is your product!"
class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded({required this.product});

  final ProductModel product;

  @override
  List<Object?> get props => [product];
}

// "Oops, failed." We keep the id so Retry knows what to fetch again.
class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError({
    required this.message,
    required this.productId,
  });

  final String message;
  final int productId;

  @override
  List<Object?> get props => [message, productId];
}
