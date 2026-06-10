import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Input decoration theme matching the Figma card-style text fields.
class AppInputTheme {
  AppInputTheme._();

  static InputDecorationTheme get theme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 14,
          color: AppColors.grey,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 14,
          color: AppColors.grey,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 11,
          color: AppColors.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );
}
