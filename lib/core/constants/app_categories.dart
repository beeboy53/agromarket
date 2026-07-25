import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';

/// Simple description of a commodity category used to render the
/// category grid on the Home screen.
class AppCategory {
  final String name;
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// The 5 fixed commodity categories used throughout the app.
class AppCategories {
  AppCategories._();

  static const List<AppCategory> all = [
    AppCategory(name: AppStrings.grains, icon: Icons.grass, color: AppColors.grains),
    AppCategory(name: AppStrings.tubers, icon: Icons.eco, color: AppColors.tubers),
    AppCategory(name: AppStrings.vegetables, icon: Icons.local_florist, color: AppColors.vegetables),
    AppCategory(name: AppStrings.legumes, icon: Icons.spa, color: AppColors.legumes),
    AppCategory(name: AppStrings.livestock, icon: Icons.pets, color: AppColors.livestock),
  ];
}