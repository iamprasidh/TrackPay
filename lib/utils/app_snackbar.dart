import 'package:flutter/material.dart';

/// Global helper for showing lightweight, consistent snackbars.
class AppSnackbar {
  const AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Builder(
          builder: (ctx) {
            final cs = Theme.of(ctx).colorScheme;
            return Text(
              message,
              style: TextStyle(
                color: isError ? cs.onError : cs.onPrimary,
              ),
            );
          },
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}