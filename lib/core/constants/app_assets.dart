/// Centralised asset path constants so file paths are never
/// hard-coded/duplicated across multiple screens.
class AppAssets {
  AppAssets._();

  static const String dataPath = 'assets/data';
  static const String imagesPath = 'assets/images';
  static const String iconsPath = 'assets/icons';

  static const String commoditiesJson = '$dataPath/commodities.json';

  static const String logo = '$imagesPath/logo.png';
  static const String onboarding1 = '$imagesPath/onboarding_1.png';
  static const String onboarding2 = '$imagesPath/onboarding_2.png';
  static const String onboarding3 = '$imagesPath/onboarding_3.png';
  static const String placeholder = '$imagesPath/placeholder.png';
}
