import 'package:flutter/material.dart';

Future<bool> showExitConfirmationDialog(
  BuildContext context, {
  String title = 'Exit app?',
  String message = 'Are you sure you want to exit?',
  String confirmLabel = 'Exit',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.logout),
            label: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result == true;
}
