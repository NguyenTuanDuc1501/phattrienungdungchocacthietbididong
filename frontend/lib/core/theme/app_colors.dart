import 'package:flutter/material.dart';

/// Figma-faithful color tokens for the E-Commerce app.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFDB3022);
  static const Color primaryDark = Color(0xFFC62828);

  // ── Neutral / Text ───────────────────────────────────────────────────
  static const Color dark = Color(0xFF222222);
  static const Color grey = Color(0xFF9B9B9B);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color inputGrey = Color(0xFFF2F2F2);
  static const Color divider = Color(0xFFE0E0E0);

  // ── Background ───────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x14000000);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2AA952);
  static const Color error = Color(0xFFF01F0E);
  static const Color warning = Color(0xFFFFBA49);
  static const Color star = Color(0xFFFFBA49);

  // ── Sale / Discount ──────────────────────────────────────────────────
  static const Color saleBadge = Color(0xFFDB3022);
  static const Color newBadge = Color(0xFF222222);

  // ── Bottom Nav ───────────────────────────────────────────────────────
  static const Color navActive = Color(0xFFDB3022);
  static const Color navInactive = Color(0xFF9B9B9B);
}
