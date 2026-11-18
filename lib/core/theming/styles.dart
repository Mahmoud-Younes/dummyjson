// Every text style used in the app lives here (ONE place to tune them).
//
// Name formula: font<SIZE><WEIGHT><COLOR> - for example
// font14RegularGray = size 14, regular weight, grey color.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/theming/colors.dart';
import 'package:dummyjson/core/theming/font_weight_helper.dart';

abstract final class Styles {
  // Splash screen title (big white text on the teal background).
  static const TextStyle font26WhiteBold = TextStyle(
    fontSize: 26,
    fontWeight: FontWeightHelper.bold,
    color: Colors.white,
  );

  // 'Welcome back' heading on the login screen.
  static const TextStyle font24Bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeightHelper.bold,
    color: Colors.black,
  );

  // Card titles.
  static const TextStyle font18SemiBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeightHelper.semiBold,
    color: Colors.black,
  );

  // Normal body text.
  static const TextStyle font16Regular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
    color: Colors.black,
  );

  // White label inside the teal Login button.
  static const TextStyle font14SemiBoldWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeightHelper.semiBold,
    color: Colors.white,
  );

  // Grey subtitles under headings.
  // (shade700 #616161: 6.19:1 on white - plain Colors.grey #9E9E9E
  // was only 2.68:1 and failed WCAG AA.)
  static const TextStyle font14RegularGray = TextStyle(
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
    color: Color(0xFF616161),
  );

  // Small hints.
  static const TextStyle font13RegularGray = TextStyle(
    fontSize: 13,
    fontWeight: FontWeightHelper.regular,
    color: Color(0xFF616161),
  );

  // The tap-to-navigate part of a hint (" Login", " Sign Up") -
  // grey hint text with the teal action word next to it.
  static const TextStyle font13SemiBoldTeal = TextStyle(
    fontSize: 13,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.mainTeal,
  );

  // Tiny hints / demo credentials line.
  static const TextStyle font12RegularGray = TextStyle(
    fontSize: 12,
    fontWeight: FontWeightHelper.regular,
    color: Color(0xFF616161),
  );

  // Product details title.
  static const TextStyle font22Bold = TextStyle(
    fontSize: 22,
    fontWeight: FontWeightHelper.bold,
    color: Colors.black,
  );

  // Product details section headings.
  static const TextStyle font18Bold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeightHelper.bold,
    color: Colors.black,
  );

  // Product details discounted price.
  // (shade800 #2E7D32: 5.13:1 on white - Colors.green #4CAF50 was
  // only 2.78:1 and failed WCAG AA.)
  static const TextStyle font24BoldGreen = TextStyle(
    fontSize: 24,
    fontWeight: FontWeightHelper.bold,
    color: Color(0xFF2E7D32),
  );

  // Product details stock status.
  static const TextStyle font16BoldGreen = TextStyle(
    fontSize: 16,
    fontWeight: FontWeightHelper.bold,
    color: Color(0xFF2E7D32),
  );

  // (shade700 #D32F2F: 4.98:1 on white - Colors.red #F44336 was
  // only 3.68:1 and failed WCAG AA.)
  static const TextStyle font16BoldRed = TextStyle(
    fontSize: 16,
    fontWeight: FontWeightHelper.bold,
    color: Color(0xFFD32F2F),
  );

  // ---- Styles below were moved here from inline UI code ----

  // App bar titles: white text on the teal bar.
  static const TextStyle font18SemiBoldWhite = TextStyle(
    fontSize: 18,
    fontWeight: FontWeightHelper.semiBold,
    color: Colors.white,
  );

  // The OLD price (details + product card): grey + line-through.
  static const TextStyle font16RegularGray = TextStyle(
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
    color: Color(0xFF616161),
    decoration: TextDecoration.lineThrough,
  );

  // Small green texts: "in stock" + the card's current price.
  static const TextStyle font14BoldGreen = TextStyle(
    fontSize: 14,
    fontWeight: FontWeightHelper.bold,
    color: Color(0xFF2E7D32),
  );

  // "Out of stock" status.
  static const TextStyle font14BoldRed = TextStyle(
    fontSize: 14,
    fontWeight: FontWeightHelper.bold,
    color: Color(0xFFD32F2F),
  );

  // Login error banner text (dark red on light red background).
  static const TextStyle font14RegularRed = TextStyle(
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
    color: Color(0xFFB71C1C),
  );
}
