// Three tiny helper screens used by BOTH pages:
//
//   LoadingView  -> spinning circle (while waiting)
//   ErrorView    -> sad message + Retry button (when something fails)
//   EmptyView    -> "nothing found" message (when list is empty)
//
// Keeping them here (in one file) means we write them ONCE
// and reuse them everywhere.

import 'package:flutter/material.dart';

import 'package:dummyjson/core/theming/colors.dart';

// ---- 1. Loading: just a spinner in the middle ----
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// ---- 2. Error: message + Retry button ----
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  // The error text to show.
  final String message;

  // What to do when Retry is pressed.
  // The screen gives us this function.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          // mainAxisSize.min = "take only needed space, stay centered".
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: ColorsManager.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- 3. Empty: "nothing here" message ----
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.text,
    this.onClear,
  });

  // Message to show. Example: 'No results for "phone"'.
  final String text;

  // Optional: if given, show a "Clear search" button.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: ColorsManager.inactive),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            // "if (onClear != null)" means: only show button if needed.
            if (onClear != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
