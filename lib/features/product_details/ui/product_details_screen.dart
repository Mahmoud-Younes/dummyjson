// The DETAILS page: shows everything about ONE product.
//
// It receives a productId (example: 5).
// Its Cubit is created by the ROUTER (get_it) and it already
// started fetching this product the moment the page opened.
// This page just watches with BlocBuilder and shows:
//   Loading -> spinner
//   Loaded  -> photo + title + price + rating + stock + description...
//   Error   -> message + Retry button

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dummyjson/features/product_details/logic/product_details_cubit.dart';
import 'package:dummyjson/features/product_details/logic/product_details_state.dart';
import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/features/products/data/models/product_model.dart';
import 'package:dummyjson/core/widgets/app_states.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  // Which product to show.
  final int productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          // 1. Still loading?
          if (state is ProductDetailsInitial ||
              state is ProductDetailsLoading) {
            return const LoadingView();
          }

          // 2. Failed? Show error + retry same product.
          if (state is ProductDetailsError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context
                    .read<ProductDetailsCubit>()
                    .fetchProductDetails(productId);
              },
            );
          }

          // 3. Success! Show the product.
          if (state is ProductDetailsLoaded) {
            return _ProductInfo(product: state.product);
          }

          return const LoadingView();
        },
      ),
    );
  }
}

// The pretty layout for a loaded product.
// Kept in a separate small widget so the code above stays short.
class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    // Use the model's single source of truth for image selection.
    final String firstImage = product.bestImage;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big photo on top.
          if (firstImage.isNotEmpty)
            Image.network(
              firstImage,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: Icon(Icons.broken_image, size: 48)),
                );
              },
            ),

          // All the text below, with some padding.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (big + bold).
                Text(
                  product.title,
                  style: Styles.font22Bold,
                ),
                verticalSpace(4),

                // Brand + category (small grey text).
                Text(
                  '${product.brandText}  •  ${product.category}',
                  style: Styles.font14RegularGray,
                ),
                verticalSpace(12),

                // Rating row: star + number.
                Row(
                  children: [
                    const Icon(Icons.star, color: ColorsManager.ratingStar),
                    horizontalSpace(4),
                    Text(
                      '${product.rating} / 5',
                      style: Styles.font16Regular,
                    ),
                  ],
                ),
                verticalSpace(12),

                // Price row: old price + new price + discount.
                // Example: $100  ->  $90  (-10%)
                Row(
                  children: [
                    Text(
                      '\$${product.price}',
                      style: Styles.font16RegularGray,
                    ),
                    horizontalSpace(8),
                    Text(
                      '\$${product.priceAfterDiscount.toStringAsFixed(2)}',
                      style: Styles.font24BoldGreen,
                    ),
                    // The "-10%" chip only when there IS a discount:
                    // a product sold at full price would otherwise
                    // wear a silly "-0.0%" badge.
                    if (product.discountPercentage > 0) ...[
                      horizontalSpace(8),
                      Chip(
                        label: Text('-${product.discountPercentage}%'),
                      ),
                    ],
                  ],
                ),
                verticalSpace(8),

                // Stock: green if available, red if empty.
                Text(
                  product.stock > 0
                      ? '${product.stock} in stock'
                      : 'Out of stock',
                  style: product.stock > 0
                      ? Styles.font14BoldGreen
                      : Styles.font14BoldRed,
                ),
                verticalSpace(16),

                // Description title + text.
                const Text(
                  'Description',
                  style: Styles.font18Bold,
                ),
                verticalSpace(4),
                Text(product.description),
                verticalSpace(16),

                // Extra photos (if any) in a horizontal row.
                if (product.images.length > 1) ...[
                  const Text(
                    'More photos',
                    style: Styles.font18Bold,
                  ),
                  verticalSpace(8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.images.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.images[i],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                  Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
