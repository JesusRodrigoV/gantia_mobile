import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

void showErrorSnackBar(BuildContext context, String message, {int durationSeconds = 4}) {
  _showSnackBar(context, message, AppColors.red500, durationSeconds);
}

void showSuccessSnackBar(BuildContext context, String message, {int durationSeconds = 3}) {
  _showSnackBar(context, message, AppColors.green500, durationSeconds);
}

void showInfoSnackBar(BuildContext context, String message, {int durationSeconds = 3}) {
  _showSnackBar(context, message, AppColors.primary500, durationSeconds);
}

void showWarnSnackBar(BuildContext context, String message, {int durationSeconds = 4}) {
  _showSnackBar(context, message, AppColors.amber600, durationSeconds);
}

void _showSnackBar(BuildContext context, String message, Color backgroundColor, int durationSeconds) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: durationSeconds),
      ),
    );
}
