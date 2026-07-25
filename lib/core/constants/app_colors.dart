import 'package:flutter/material.dart';

/// Centralised colour palette for the whole app.
/// Keeping all colours in one place makes it easy to explain
/// the design system during project defense and easy to re-theme.
class AppColors {
  AppColors._();

  // Brand colours
  static const Color primary = Color(0xFF2E7D32); // Agricultural green
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF81C784);

  static const Color secondary = Color(0xFFFF8F00); // Market/price orange
  static const Color secondaryDark = Color(0xFFE65100);

  // Status colours
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color priceUp = Color(0xFFD32F2F); // price increased
  static const Color priceDown = Color(0xFF2E7D32); // price decreased

  // Neutral colours (Light theme)
  static const Color backgroundLight = Color(0xFFF5F7F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1B1B1B);
  static const Color textSecondaryLight = Color(0xFF5F5F5F);

  // Neutral colours (Dark theme)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Category colours (used for category icons/chips)
  static const Color grains = Color(0xFFC98E2E);
  static const Color tubers = Color(0xFF8D6E63);
  static const Color vegetables = Color(0xFF43A047);
  static const Color legumes = Color(0xFF6D4C41);
  static const Color livestock = Color(0xFFEF6C00);
}
