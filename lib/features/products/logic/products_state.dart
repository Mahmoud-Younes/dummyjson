// These are the ANSWERS the ProductsCubit can give back.
//
// The screen looks at the current answer and decides what to show:
//   Loading -> show a spinning circle
//   Loaded  -> show the list of products
//   Empty   -> show "no products found"
//   Error   -> show the error message + a Retry button

import 'package:equatable/equatable.dart';

import 'package:dummyjson/features/products/data/models/product_model.dart';

// The parent of all answers. We never use this directly.
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

// Starting point, before we asked for anything.
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

// "Please wait, I am fetching..."
class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

// "Here is your list!" Also remembers the search word (if any).
class ProductsLoaded extends ProductsState {
  const ProductsLoaded({
    required this.products,
    this.word = '',
  });

  final List<ProductModel> products;
  final String word;

  @override
  List<Object?> get props => [products, word];
}

// "The list is empty." Happens when search finds nothing.
class ProductsEmpty extends ProductsState {
  const ProductsEmpty({required this.word});

  final String word;

  @override
  List<Object?> get props => [word];
}

// "Oops, something failed." Holds the message to show.
class ProductsError extends ProductsState {
  const ProductsError({
    required this.message,
    this.word = '',
  });

  final String message;
  final String word;

  @override
  List<Object?> get props => [message, word];
}
