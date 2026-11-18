import 'package:flutter/material.dart';

class ColorsManager {
  // The one teal color the whole app is built around.
  // Darkened (was 0xFF00897B) so WHITE text on it passes WCAG AA:
  // 5.32:1 (was only 4.32:1). Same teal, just a darker shade.
  static const Color mainTeal = Color(0xFF00796B);

  // Green for "requirement met" ticks (sign-up password checklist).
  // Colors.green (#4CAF50) was only 2.78:1 on white and failed
  // WCAG AA - this darker green (the same one styles.dart uses for
  // prices/stock) reads 5.13:1. Non-text elements need 3:1.
  static const Color success = Color(0xFF2E7D32);

  // Grey for "not yet" crosses (sign-up password checklist) and for
  // small decorative icons next to grey text (the user card).
  // Colors.grey (#9E9E9E) was only 2.68:1 on white and failed
  // WCAG AA - this darker grey (the same one styles.dart uses for
  // hints) reads 6.19:1.
  static const Color inactive = Color(0xFF616161);

  // Red for "this failed" ICONS (the shared error banner, the
  // full-screen ErrorView). Same shade styles.dart already uses for
  // red text: 4.98:1 on white. (It used to be spelled Colors.red.)
  static const Color error = Color(0xFFD32F2F);

  // The light red wash BEHIND the inline error banners.
  // (It used to be spelled Colors.red.shade50 in each banner.)
  static const Color errorBackground = Color(0xFFFFEBEE);

  // Amber for the rating star (product card + details page).
  // (It used to be spelled Colors.amber in both places.)
  static const Color ratingStar = Color(0xFFFFC107);

  // Grey outline of an IDLE (not focused) text field. While the user
  // types, the border switches to mainTeal. (= Colors.grey)
  static const Color fieldBorder = Color(0xFF9E9E9E);
}
