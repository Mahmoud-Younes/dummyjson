// Shortcut SizedBoxes so layouts read cleaner:
//   before: SizedBox(height: 16)
//   after:  verticalSpace(16)

import 'package:flutter/material.dart';

// Empty box that adds vertical space (a gap between widgets stacked down).
SizedBox verticalSpace(double height) => SizedBox(height: height);

// Empty box that adds horizontal space (a gap inside a Row).
SizedBox horizontalSpace(double width) => SizedBox(width: width);
