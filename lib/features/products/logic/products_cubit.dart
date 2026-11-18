// This is the WAITER for the products list.
//
// It is a Cubit: the screen calls its methods DIRECTLY
// (no events needed) and listens to the states it emits.
//
// Flow:
//   Screen calls fetchProducts()
//     -> Cubit says "Loading..."
//     -> Cubit asks Repository for products
//     -> Cubit says "Loaded" (or "Empty" / "Error")
//
// NOTE for beginners: we do NOT use any fancy "debounce" code here.
// The screen waits 500ms after you stop typing (with a Timer),
// THEN calls searchProducts(word). So this file stays super simple.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/error/app_exceptions.dart';
import 'package:dummyjson/features/products/data/repos/product_repo.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  // The Cubit needs a Repository to fetch data.
  // We give it from get_it (see dependency_injection.dart),
  // like giving the waiter a menu.
  ProductsCubit({required this._repository}) : super(const ProductsInitial());

  final ProductRepo _repository;

  // ---- Action 1: bring ALL products ----
  Future<void> fetchProducts() async {
    // Step 1: tell the screen "loading, please wait".
    emit(const ProductsLoading());

    try {
      // Step 2: ask the Repository for data.
      final products = await _repository.getProducts();

      // Step 3a: empty list? Say "Empty".
      if (products.isEmpty) {
        emit(const ProductsEmpty(word: ''));
        return;
      }

      // Step 3b: we have products! Say "Loaded".
      emit(ProductsLoaded(products: products));
    } on AppException catch (e) {
      // Step 3c: friendly error (no internet, not found...).
      emit(ProductsError(message: e.message));
    } catch (_) {
      // Step 3d: any other unexpected error. Show ONE friendly
      // message, never the raw exception text.
      emit(
        const ProductsError(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  // ---- Action 2: search for a word ----
  Future<void> searchProducts(String query) async {
    // Clean the word: remove spaces at start/end.
    final String word = query.trim();

    // If the box is empty, just show ALL products again.
    // (This cubit owns the "empty word -> all products" rule.)
    if (word.isEmpty) {
      await fetchProducts();
      return;
    }

    emit(const ProductsLoading());

    try {
      final products = await _repository.searchProducts(word);

      if (products.isEmpty) {
        emit(ProductsEmpty(word: word));
      } else {
        emit(ProductsLoaded(products: products, word: word));
      }
    } on AppException catch (e) {
      emit(ProductsError(message: e.message, word: word));
    } catch (_) {
      emit(
        ProductsError(
          message: 'Something went wrong. Please try again.',
          word: word,
        ),
      );
    }
  }
}
