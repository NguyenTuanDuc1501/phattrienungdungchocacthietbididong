import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography tokens based on the Figma E-Commerce design.
/// Uses Metropolis font family (configured in pubspec.yaml).
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Metropolis';

  // ── Headlines ────────────────────────────────────────────────────────
  static const TextStyle headline1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
    height: 1.0,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
    height: 1.2,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
    height: 1.3,
  );

  // ── Body ─────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
    height: 1.43,
  );

  // ── Caption ──────────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
    height: 1.1,
  );

  // ── Button ───────────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
    letterSpacing: 0.5,
    height: 1.43,
  );

  // ── Price ────────────────────────────────────────────────────────────
  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.dark,
    height: 1.43,
  );

  static const TextStyle priceOriginal = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
    height: 1.43,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle priceDiscount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.43,
  );

  // ── Tab Bar ──────────────────────────────────────────────────────────
  static const TextStyle tabActive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
    height: 1.0,
  );

  static const TextStyle tabInactive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
    height: 1.0,
  );
}
