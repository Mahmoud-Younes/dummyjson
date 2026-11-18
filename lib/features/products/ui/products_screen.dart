// The SHOP screen: the list of products + search.
//
// Who gives it what?
//   - The Router already created the ProductsCubit AND the
//     SettingsCubit ABOVE this screen (with BlocProviders), so we
//     just read them.
//   - This is the app's FIRST screen after login/splash - the
//     "root" of the logged-in world. That is why the app bar has
//     NO back button (there is nothing behind it) and why the
//     settings popup (the gear icon) lives here: logout must be
//     one tap away from the main screen.
//
// Flow:
//   open screen -> fetchProducts() already called by the router -> spinner -> list
//   type in search -> wait 500ms (Timer) -> searchProducts(word) -> results

import 'dart:async'; // needed for Timer (the search delay)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/routing/routes.dart';
import 'package:dummyjson/core/widgets/app_states.dart';
import 'package:dummyjson/core/widgets/app_text_form_field.dart';
import 'package:dummyjson/features/products/logic/products_cubit.dart';
import 'package:dummyjson/features/products/logic/products_state.dart';
import 'package:dummyjson/features/products/ui/widgets/product_card.dart';
import 'package:dummyjson/features/settings/ui/widgets/settings_menu_button.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // The search "waiter": we wait 500ms AFTER the user stops typing,
  // then we search. Every new letter cancels the old timer.
  // (This trick is called "debounce" - it avoids a search per letter.)
  Timer? _debounce;

  // Lets us read (and clear) the text inside the search box.
  final TextEditingController _searchController = TextEditingController();

  // Double-tap guard for the product cards: set to true BEFORE the push,
  // cleared AFTER the details screen is closed. So a fast second tap can
  // never open the details screen twice on top of each other.
  bool _isNavigatingToDetails = false;

  // Opens the details screen for ONE product (with the guard above).
  void _openProductDetails(int productId) {
    // A second tap while we are already navigating? Ignore it.
    if (_isNavigatingToDetails) return;

    _isNavigatingToDetails = true;
    // We need Navigator here (not context.pushNamed) because pushNamed
    // gives us a Future - we use it to clear the guard once the
    // details screen is closed.
    Navigator.of(context)
        .pushNamed(
          Routes.productDetailsScreen,
          // The router needs the product's INT id.
          arguments: productId,
        )
        .whenComplete(() => _isNavigatingToDetails = false);
  }

  @override
  void dispose() {
    // Always clean up when the screen closes:
    // stop the timer + delete the controller (frees memory).
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Called every time the user types a letter in the search box.
  void _onSearchChanged(String text) {
    // User typed again! Cancel the previous timer.
    _debounce?.cancel();

    // Start a NEW timer: search only after 500ms of quiet.
    // We always send the RAW text - the Cubit owns the "empty word?"
    // rule: it cleans the word and decides (fetch all OR search).
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Ask the Cubit to handle whatever is in the box.
      context.read<ProductsCubit>().searchProducts(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        // NO back button here: this is the ROOT screen after login
        // (login/splash wipe the whole stack below it), so there is
        // nothing to go "back" to. The only app-bar action is the
        // settings popup (username + logout).
        actions: const [
          // The gear icon opens the small settings menu. It watches
          // the SettingsCubit itself (spinner while logging out).
          SettingsMenuButton(),
        ],
      ),
      body: Column(
        children: [
          // ---- TOP: the search box ----
          Padding(
            padding: const EdgeInsets.all(8),
            child: Semantics(
              // Same web story as the back button above: after returning from
              // the Details screen the search box can lose its accessible
              // name + value in the browser's accessibility tree. This outer
              // Semantics node re-announces the field's NAME every rebuild,
              // so the label is rebuilt with the widget, not by the engine.
              label: 'Search products',
              child: AppTextFormField(
                controller: _searchController,
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          // ---- BOTTOM: the products list (or loading/error/empty) ----
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                // 1. First open or loading? -> spinner.
                if (state is ProductsInitial || state is ProductsLoading) {
                  return const LoadingView();
                }

                // 2. Failed? -> error message + Retry button.
                if (state is ProductsError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () {
                      // If we were searching, retry the SAME search.
                      // Otherwise just load all products again.
                      if (state.word.isNotEmpty) {
                        context
                            .read<ProductsCubit>()
                            .searchProducts(state.word);
                      } else {
                        context
                            .read<ProductsCubit>()
                            .fetchProducts();
                      }
                    },
                  );
                }

                // 3. Nothing found? -> "no products" message.
                if (state is ProductsEmpty) {
                  return EmptyView(
                    // If a word was searched, show it in the message.
                    text: state.word.isEmpty
                        ? 'No products available.'
                        : 'No products found for "${state.word}"',
                    onClear: () {
                      // Clear the box; let the Cubit own the
                      // "empty word -> all products" rule.
                      _searchController.clear();
                      context
                          .read<ProductsCubit>()
                          .searchProducts('');
                    },
                  );
                }

                // 4. Success! -> the list of products.
                if (state is ProductsLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.products.length,

                    // The gap between two cards.
                    separatorBuilder: (context, index) => verticalSpace(8),

                    // Build ONE card per product.
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _openProductDetails(product.id),
                      );
                    },
                  );
                }

                // Safety net (should never be reached).
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
