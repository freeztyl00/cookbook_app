import 'package:flutter/material.dart';

SnackBar showSnackBar({
  required BuildContext context,
  required String message,
  IconData? icon,
}) {
  return SnackBar(
    content: Row(
      children: [
        if (icon != null) Icon(icon),
        Flexible(child: Text(message)),
      ],
    ),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(12),
    ),
  );
}

void clearSnackBars(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
}
