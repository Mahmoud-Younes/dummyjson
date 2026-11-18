// The WAITER for the details page.
//
// Same idea as ProductsCubit, but simpler:
// it only knows how to fetch ONE product.
// (A Cubit, so the screen calls its method DIRECTLY - no events.)

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/error/app_exceptions.dart';
import 'package:dummyjson/features/products/data/repos/product_repo.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  // We receive the Repository from outside (from get_it - see
  // dependency_injection.dart), like giving the waiter a menu.
  ProductDetailsCubit({required this._repository})
      : super(const ProductDetailsInitial());

  final ProductRepo _repository;

  // The only action: "bring me product number [id]".
  Future<void> fetchProductDetails(int id) async {
    // Tell the screen: "loading..."
    emit(const ProductDetailsLoading());

    try {
      // Ask the Repository for product number [id].
      final product = await _repository.getProductById(id);

      // Success! Send the product to the screen.
      emit(ProductDetailsLoaded(product: product));
    } on AppException catch (e) {
      // Friendly error. Keep the id so Retry works.
      emit(
        ProductDetailsError(
          message: e.message,
          productId: id,
        ),
      );
    } catch (_) {
      // Unexpected error. Show ONE friendly message, never the
      // raw exception text. Keep the id so Retry works.
      emit(
        ProductDetailsError(
          message: 'Something went wrong. Please try again.',
          productId: id,
        ),
      );
    }
  }
}
