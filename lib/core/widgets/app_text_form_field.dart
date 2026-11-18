// ONE styled text field used everywhere (login form, search bars...).
//
// It wraps Flutter's TextFormField so every field in the app looks
// the same: white background, grey border, teal when focused.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/theming/colors.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization,
    this.formFieldKey,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  // Keyboard smarts, passed straight through to TextFormField.
  // Defaults keep Flutter's normal behavior (corrections ON); fields
  // holding EXACT text - like a username - turn them OFF so the
  // keyboard never silently "fixes" what was typed.
  final bool autocorrect;
  final bool enableSuggestions;

  // A capitalization hint for the keyboard (e.g. words for name
  // fields). Null = the keyboard decides (same as before).
  final TextCapitalization? textCapitalization;

  // A direct handle on the inner field's state (GlobalKey<
  // FormFieldState<String>>). A caller uses it to re-run ONE
  // field's validator on demand - e.g. re-checking "confirm
  // password" when the password above it changes.
  final GlobalKey<FormFieldState<String>>? formFieldKey;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: formFieldKey,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Border when the field is ENABLED but not focused.
        enabledBorder: _border(ColorsManager.fieldBorder),
        // Border while the user is TYPING in this field.
        focusedBorder: _border(ColorsManager.mainTeal),
      ),
    );
  }

  // Small helper so all borders share the same rounded shape.
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );
}
