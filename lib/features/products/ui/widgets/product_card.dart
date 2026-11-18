// A small card that shows ONE product in the list.
//
// It shows: image (left), name, price + rating (right).
// When you tap it, it calls "onTap" (goes to details page).
//
// We use ListTile because it is the SIMPLEST way
// to make a row with image + text in Flutter.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/helpers/spacing.dart';
import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/styles.dart';
import 'package:dummyjson/features/products/data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // The product to show.
  final ProductModel product;

  // What to do when tapped. The screen gives us this function.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card gives a nice white box with shadow.
      child: ListTile(
        onTap: onTap,

        // LEFT: product image.
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.thumbnail,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            // If image fails to load, show a broken-image icon.
            errorBuilder: (context, error, stack) {
              return const Icon(Icons.broken_image, size: 40);
            },
          ),
        ),

        // MIDDLE: name on top, price + category below.
        // Same price language as the details screen: the price AFTER
        // discount is the real price, with the old price struck
        // through - but only when there IS an actual discount.
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // "Long name..." with dots
        ),
        subtitle: Text.rich(
          TextSpan(
            children: [
              if (product.discountPercentage > 0) ...[
                // The real price you pay (after discount).
                TextSpan(
                  text: '\$${product.priceAfterDiscount.toStringAsFixed(2)}',
                  style: Styles.font14BoldGreen,
                ),
                const TextSpan(text: ' '),
                // The old price, struck through (details screen style).
                TextSpan(
                  text: '\$${product.price}',
                  style: Styles.font16RegularGray,
                ),
              ] else
                // No discount: just the plain price.
                TextSpan(text: '\$${product.price}'),
              const TextSpan(text: '  •  '),
              TextSpan(text: product.category),
            ],
          ),
        ),

        // RIGHT: star + rating number.
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // take only needed space
          children: [
            const Icon(Icons.star, color: ColorsManager.ratingStar, size: 18),
            horizontalSpace(4),
            Text('${product.rating}'),
          ],
        ),
      ),
    );
  }
}
